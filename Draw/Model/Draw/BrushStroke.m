//
//  BrushStroke.m
//  Draw
//
//  Created by 黄毅超 on 14-9-1.
//
//

#import "BrushStroke.h"
#import "DrawUtils.h"
#import "GameMessage.pb.h"
#import "PenFactory.h"
#import "PointNode.h"
#import "CanvasRect.h"
#import "DrawPenFactory.h"
#import "PPConfigManager.h"
#import "HBrushPointList.h"
#import "UIImage+RTTint.h"
#import "UIImageExt.h"
#import "BrushEffectFactory.h"



@implementation BrushDot

@end

@interface BrushStroke()
{
}

@property (nonatomic, retain) HBrushPointList  *hPointList;
@property (nonatomic, assign) BOOL isFirstPoint;

@property (nonatomic, retain) BrushDot  *beginDot;
@property (nonatomic, retain) BrushDot  *controlDot;
@property (nonatomic, retain) BrushDot  *endDot;

@property (nonatomic, assign) float tempWidth;

@end

@implementation BrushStroke

#pragma mark -- init groups
- (BOOL)isBrushInterpolationOptimized
{
    return [_brush canInterpolationOptimized];
}

- (id)initWithWidth:(CGFloat)width
              color:(DrawColor *)color
          brushType:(ItemType)brushType
          pointList:(HBrushPointList*)pointList
        isOptimized:(BOOL)isOptimized
{
    self = [super init];
    if (self) {
        self.width = width;
        self.color = color;
        
        // set brush
        self.brushType = brushType;
        self.brush = [[BrushEffectFactory sharedInstance] brush:brushType];
        
        _beginDot = [[BrushDot alloc]init];
        _controlDot = [[BrushDot alloc]init];
        _endDot = [[BrushDot alloc]init];
        self.isFirstPoint = YES;
        
        //get brush image and tint it
        self.brushImage = [_brush brushImage:[self.color color] width:width];
        self.brushImageRef = _brushImage.CGImage;
        
        
        if (pointList == nil){
            _hPointList = [[HBrushPointList alloc] init];
        }
        else{
            self.hPointList = pointList;
        }
        
        self.isOptimized = isOptimized;
        self.isInterpolationOptimized = isOptimized && [self isBrushInterpolationOptimized];
    }
    return self;
}


+ (id)brushStrokeWithWidth:(CGFloat)width
                     color:(DrawColor *)color
                 brushType:(ItemType)brushType
                 pointList:(HBrushPointList*)pointList
               isOptimized:(BOOL)isOptimized
{
    return [[[BrushStroke alloc] initWithWidth:width
                                         color:color
                                     brushType:brushType
                                     pointList:pointList
                                   isOptimized:isOptimized] autorelease];
}


- (id)initWithGameMessage:(GameMessage *)gameMessage
{
    self = [super init];
    if (self && gameMessage) {
        NSInteger intColor = [[gameMessage notification] color];
        CGFloat lineWidth = [[gameMessage notification] width];
        PBArray *pointList = [[gameMessage notification] points];
        self.width = lineWidth;
        
        self.brushType = [[gameMessage notification] penType];
        self.color = [DrawUtils decompressIntDrawColor:intColor];
        _hPointList = [[HBrushPointList alloc] init];
        NSUInteger count = pointList.count;
        for (int i =0; i<count; i++) {
            int pointNumber = [pointList int32AtIndex:i];
            CGPoint point = [DrawUtils decompressIntPoint:pointNumber];
            
            //this may be wrong, need test.... By Gamy
            [self addPoint:point inRect:[CanvasRect defaultRect]];
        }
        [_hPointList complete];
        
        self.isOptimized = [[gameMessage notification] isOptimized];
        self.isInterpolationOptimized =
            [[gameMessage notification] isOptimized] && [self isBrushInterpolationOptimized];
    }
    return self;
}


- (CGLayerRef)brushLayer:(CGRect)rect
{
    if (_brushLayer == NULL){
        PPDebug(@"create brush layer with rect(%@)", NSStringFromCGRect(rect));
        _brushLayer = [DrawUtils createCGLayerWithRect:rect];
    }
    
    return _brushLayer;
}

- (void)releaseBrushLayer
{
    if (_brushLayer != NULL){
        PPDebug(@"brush stroke release brush layer!");
        CGLayerRelease(_brushLayer);
        _brushLayer = NULL;
    }
}

- (CGImageRef)brushImageRef:(CGSize)size
{
    if (self.brushImage == nil){
        return NULL;
    }
    
    if (CGSizeEqualToSize(self.brushImage.size, size)){
        return self.brushImage.CGImage;
    }
    else{
        UIImage* tempImage = [self.brushImage imageByScalingAndCroppingForSize:size];
        return tempImage.CGImage;
    }
}


- (CGRect)redrawRectInRect:(CGRect)rect
{
    //bounds返回一个rect，这个rect是一个笔画中所有点的最小外接矩形，通过计算左上，右下两个点坐标获得。
    //maxWidth是记录当前点的宽度，用于扩大bounds所返回的rect，使得笔画不会缺少边缘部分。
    //explained by Charlie， 2014 9 21
    CGRect r = [DrawUtils rectForRect:[self.hPointList bounds]
                            withWidth:[self.hPointList maxWidth]
                               bounds:rect];
    return r;
}

- (void)clearMemory
{
    [self releaseBrushLayer];
    self.brushImage = nil;
    self.brushImageRef = NULL;
}


#define RECT_SPAN_WIDTH 10
- (BOOL)spanRect:(CGRect)rect ContainsPoint:(CGPoint)point
{
    rect.origin.x -= RECT_SPAN_WIDTH;
    rect.origin.y -= RECT_SPAN_WIDTH;
    rect.size.width += RECT_SPAN_WIDTH*2;
    rect.size.height += RECT_SPAN_WIDTH*2;
    return CGRectContainsPoint(rect, point);
}

#pragma mark -- add point methods: storing new points && showing new interpolation
// *******
// 用途：在画图当中存储采样点，并且同步显示新增插值点效果的
// 2015 5 7
// charlie
// *******
- (void)addPoint:(CGPoint)point inRect:(CGRect)rect
{
    if (!CGRectContainsPoint(rect, point)){
        if (![self spanRect:rect ContainsPoint:point]) {
            PPDebug(@"<addPoint> Detect Incorrect Point = %@, Skip It", NSStringFromCGPoint(point));
            return;
        }
        point.x = MAX(point.x, 0);
        point.y = MAX(point.y, 0);
        point.x = MIN(point.x, CGRectGetWidth(rect));
        point.y = MIN(point.y, CGRectGetHeight(rect));
        PPDebug(@"<addPoint> Change Point to %@", NSStringFromCGPoint(point));
    }
    
    _brushLayer = [self brushLayer:rect];
    CGContextRef layerContext = CGLayerGetContext(_brushLayer);
    CGImageRef brushImageRef = self.brushImageRef;
    
    if (self.brushImageRef == NULL){
        self.brushImage = [_brush brushImage:[self.color color] width:self.width];
        self.brushImageRef = _brushImage.CGImage;
    }
    
    //每次进入dynamicDrawStroke..方法之前，都需要
    //合理判断isFirstPoint的状态，否则三个控制点会乱
    if([self.hPointList count]==0) self.isFirstPoint = YES;
    else self.isFirstPoint = NO;
    
    // 新加入的点和新点的上一点之间需要插值，插入的点需要在addpoint的同时显示。
    // 所以这里使用了dynamicDrawStroke...
    // 而之前所画的点，都是在缓存中先画好，然后直接从内存载入。见drawInContext
    [self dynamicDrawStrokeAtNewPoint:point
                       withBrushImage:brushImageRef
                       inLayerContext:layerContext
                      needRecordPoint:YES];
}

// *******
// 用途：在回放中，或者是在草稿中，添加储存采样点，显示新增插值点
// 2015 5 7
// charlie
// *******
- (void)addPoint:(CGPoint)point
           width:(float)width
          inRect:(CGRect)rect
         forShow:(BOOL)forShow
{
    if (!CGRectContainsPoint(rect, point)){
        if (![self spanRect:rect ContainsPoint:point]) {
            PPDebug(@"<addPoint> Detect Incorrect Point = %@, Skip It", NSStringFromCGPoint(point));
            return;
        }
        point.x = MAX(point.x, 0);
        point.y = MAX(point.y, 0);
        point.x = MIN(point.x, CGRectGetWidth(rect));
        point.y = MIN(point.y, CGRectGetHeight(rect));
        PPDebug(@"<addPoint> Change Point to %@", NSStringFromCGPoint(point));
    }
    
    _brushLayer = [self brushLayer:rect];
    CGContextRef layerContext = CGLayerGetContext(_brushLayer);
    CGImageRef brushImageRef = self.brushImageRef;
    
    if (self.brushImageRef == NULL){
        self.brushImage = [_brush brushImage:[self.color color] width:self.width];
        self.brushImageRef = _brushImage.CGImage;
    }
    
    if(self.isInterpolationOptimized == NO){
        //旧版本的数据没有经过插值优化，则直接画每一个储存了的点.此处为兼容代码
        [self.hPointList addPointX:point.x
                            PointY:point.y
                        PointWidth:width
                       PointRandom:0];
        //draw by point list
        CGContextSaveGState(layerContext);
        CGRect imageRect = CGRectMake(point.x-width/2, point.y-width/2, width, width);
        CGContextDrawImage(layerContext, imageRect, brushImageRef);
        CGContextRestoreGState(layerContext);
    }
    else
    {
        // 新版本的数据有优化，储存的只有采样点，需要把插值和抖动算法重现在replay端.
        // 新加入的点和新点的上一点之间需要插值，插入的点需要在addpoint的同时显示
        // 而之前所画的点，都是在缓存中先画好，然后直接从内存载入。见drawInContext
        
        //每次进入dynamicDrawStroke..方法之前，都需要
        //合理判断isFirstPoint的状态，否则三个控制点会乱
        if([self.hPointList count]==0) self.isFirstPoint = YES;
        else self.isFirstPoint = NO;
        [self dynamicDrawStrokeAtNewPoint:point
                           withBrushImage:brushImageRef
                           inLayerContext:layerContext
                          needRecordPoint:YES];
    }
}

- (void)finishAddPoint
{
    if (self.brushImageRef == NULL){
        self.brushImage = [_brush brushImage:[self.color color] width:self.width];
        self.brushImageRef = _brushImage.CGImage;
    }
    
    //特殊处理，在采样点过少（只有一两个，无法进行贝塞尔插值时),直接显示单个采样点
    if(_hPointList.count == 1 || _hPointList.count == 2)
    {
        CGFloat singleDotX,singleDotY,singleDotW;
        singleDotX = [_hPointList getPointX:0];
        singleDotY = [_hPointList getPointY:0];
        singleDotW = [_hPointList getPointWidth:0];
        CGContextRef layerContext = CGLayerGetContext(_brushLayer);
        CGRect rect = CGRectMake(singleDotX - singleDotW/2, singleDotY - singleDotW/2, singleDotW, singleDotW);
        CGImageRef brushImageRef = [self brushImageRef];
        
        CGContextDrawImage(layerContext, rect, brushImageRef);
    }
    
    [_hPointList complete];
}

- (NSInteger)pointCount
{
    return [_hPointList count];
}

- (CGPoint)pointAtIndex:(NSInteger)index
{
    if (index < 0 || index >= [self pointCount]) {
        return ILLEGAL_POINT;
    }
    
    return [_hPointList pointAtIndex:index];
    
}

- (float)widthAtIndex:(NSInteger)index
{
    if (index < 0 || index >= [self pointCount]) {
        return 0;
    }
    
    return [_hPointList getPointWidth:index];
}


#pragma mark -- Drawing algorithm methods with interpolation and shake
- (void)dynamicDrawStrokeAtNewPoint:(CGPoint)point
                     withBrushImage:(CGImageRef)brushImage
                     inLayerContext:(CGContextRef)layerContext
                    needRecordPoint:(BOOL)needRecordPoint
{
    CGContextSaveGState(layerContext);
    
    if (self.isFirstPoint == YES){
        [self initBezierKeyPointWithPoint:point];

        //储存采样点，记录到hPointList。这种情况仅用于draw: inRect:
        if(needRecordPoint)
            [self.hPointList addPointX:_endDot.x
                                PointY:_endDot.y
                            PointWidth:_endDot.width
                           PointRandom:0];
    }
    else{
        [self relocateBezierKeyPointWithNewPoint:point];
        
        double distance1 = [self distanceOfDot:_controlDot andDot:_beginDot];
        double distance2 = [self distanceOfDot:_endDot andDot:_controlDot];
        
        _tempWidth = [_brush calculateWidthWithThreshold:FIXED_PEN_SIZE
                                               distance1:distance1
                                               distance2:distance2
                                            currentWidth:_tempWidth];
        _endDot.width = _tempWidth;
        
        //储存采样点，记录到hPointList。这种情况仅用于draw: inRect:
        if(needRecordPoint)
            [self.hPointList addPointX:_endDot.x
                                PointY:_endDot.y
                            PointWidth:_endDot.width
                           PointRandom:0];
        
        //如果笔停在某处，则不进行插值，也不进行画图
        if(distance1 == 0 || distance2 == 0)
            return;

        //得到采样点后，再利用算法生成插值点和随机抖动。
        float pointX=0,pointY=0,width=0;
        //插值长度，与三点之间的距离有关，距离越远，插值越多。不同种类笔刷由插值系数控制。
        int interpolationLength = [_brush interpolationLength:self.width
                                                    distance1:distance1
                                                    distance2:distance2];
        for(int index = 0; index<interpolationLength; index++)
        {
            [self bezierInterpolationWithBegin:_beginDot
                                       Control:_controlDot
                                           End:_endDot
                                         Index:index
                                        Length:interpolationLength
                                        pointX:&pointX
                                        pointY:&pointY
                                         width:&width];
            //随机抖动，适用于部分笔刷
            [_brush shakePointWithRandomList:[PPConfigManager getRandomNumberList]
                                     atIndex:index
                                      PointX:&pointX
                                      PointY:&pointY
                                      PointW:&width
                            withDefaultWidth:self.width];
            
            
            CGRect rect = CGRectMake(pointX-width/2, pointY-width/2, width, width);
            CGContextDrawImage(layerContext, rect, brushImage);
        }
        CGContextRestoreGState(layerContext);
    }
}

- (void)initBezierKeyPointWithPoint:(CGPoint)point
{
    //开始采样，记录坐标
    _controlDot.x = point.x;
    _controlDot.y = point.y;
    
    _beginDot.x = point.x;
    _beginDot.y = point.y;
    
    _endDot.x = point.x;
    _endDot.y = point.y;
    
    _tempWidth = [_brush firstPointWidth:self.width];
    _controlDot.width = _tempWidth;
    _beginDot.width = _tempWidth;
    _endDot.width = _tempWidth;
}



- (void)relocateBezierKeyPointWithNewPoint:(CGPoint)point
{
    //重采样定位第一点
    _beginDot.x = 0.25*_beginDot.x + 0.5*_controlDot.x + 0.25*_endDot.x;
    _beginDot.y = 0.25*_beginDot.y + 0.5*_controlDot.y + 0.25*_endDot.y;
    _beginDot.width = 0.25*_beginDot.width + 0.5*_controlDot.width + 0.25*_endDot.width;
    
    //第二点，为控制点
    _controlDot.x = _endDot.x;
    _controlDot.y = _endDot.y;
    _controlDot.width = _endDot.width;
    
    //第三点，为当前点
    _endDot.x = point.x;
    _endDot.y = point.y;
}

-(double)distanceOfDot:(BrushDot*)dot1 andDot:(BrushDot*)dot2
{
    double distance = sqrt(pow((dot2.x-dot1.x), 2)+pow((dot2.y-dot1.y), 2));
    
    return distance;
}

-(void)bezierInterpolationWithBegin:(BrushDot*)begin
                            Control:(BrushDot*)control
                                End:(BrushDot*)end
                              Index:(NSInteger)index
                             Length:(NSInteger)length
                             pointX:(float*)pointX
                             pointY:(float*)pointY
                              width:(float*)width
{
    double t = 1.0*index / (length * 2);
    
    *pointX = (1-t)*(1-t)*begin.x + 2*t*(1-t)*control.x + t*t*end.x;
    *pointY = (1-t)*(1-t)*begin.y + 2*t*(1-t)*control.y + t*t*end.y;
    *width = (1-t)*(1-t)*begin.width + 2*t*(1-t)*control.width + t*t*end.width;

}

- (CGRect)drawInContext:(CGContextRef)context inRect:(CGRect)rect
{
    if (self.drawPen == nil) {
        self.drawPen = [DrawPenFactory createDrawPen:self.brushType];
    }
    
    // 获取笔刷数据（形状），并进行了染色（用户可调）
    if (self.brushImageRef == NULL){
        self.brushImage = [_brush brushImage:[self.color color] width:self.width];
        self.brushImageRef = _brushImage.CGImage;
    }
    
    // 把已经存在的缓存层画到屏幕上。正常情况下，就是除了正在画的一笔以外的所有
    if (_brushLayer != NULL)
    {
        CGContextSaveGState(context);
        CGContextDrawLayerAtPoint(context, CGPointZero, _brushLayer);
        CGContextRestoreGState(context);
        return rect;
    }

    // 正在画的一笔，新建一个缓存层去实时刷新和储存在内存
    // 每一个单位时间刷新屏幕的时候，都重新画这一笔，故而是一个hpointlist的遍历
    // 点坐标数据已通过addpoint相关方法添加到hpointlist，故而这里只需要读取hpointlist即可
    CGImageRef brushImageRef = [self brushImageRef];
    for(int i = 0; i<[_hPointList count];i++)
    {
        CGFloat currentX = [_hPointList getPointX:i];
        CGFloat currentY = [_hPointList getPointY:i];
        CGFloat currentW = [_hPointList getPointWidth:i];
        
        self.width = currentW;
        
        if(self.isInterpolationOptimized == NO){
            //旧版本数据直接画所有点，不需要实现算法插值抖动
            CGContextSaveGState(context);
            CGRect pointRect = CGRectMake(currentX - currentW/2, currentY - currentW/2, currentW, currentW);
            CGContextDrawImage(context, pointRect, brushImageRef);
            CGContextRestoreGState(context);
        }
        else
        {
            //新版本数据，需要用算法复现插值点。重构后，插值抖动算法统一用dynamicDrawStroke...
            
            //每次进入dynamicDrawStroke..方法之前，都需要
            //合理判断isFirstPoint的状态，否则三个控制点会乱
            if(i==0) self.isFirstPoint = YES;
            else self.isFirstPoint = NO;
            [self dynamicDrawStrokeAtNewPoint:CGPointMake(currentX, currentY)
                               withBrushImage:brushImageRef
                               inLayerContext:context
                              needRecordPoint:NO];
        }
    }
    
    return [self redrawRectInRect:rect];
}


#pragma mark -- PB related: stored point list into proto
- (void)updatePBDrawActionBuilder:(PBDrawActionBuilder *)builder
{
    if ([self pointCount] != 0) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        NSMutableArray *pointXList = nil;
        NSMutableArray *pointYList = nil;
        NSMutableArray *pointWList = nil;
        NSMutableArray *randomList = nil;
        
        [_hPointList createPointXList:&pointXList
                           pointYList:&pointYList
                            widthList:&pointWList
                           randomList:&randomList];

        [builder setPointsXArray:pointXList];
        [builder setPointsYArray:pointYList];
        [builder setBrushPointWidthArray:pointWList];
        [builder setBrushRandomValueArray:randomList];
        
        [pool drain];
    }
    [builder setBetterColor:[self.color toBetterCompressColor]];
    [builder setPenType:self.brushType];
    [builder setWidth:self.width];
    [builder setIsOptimized:self.isOptimized];
}

- (void)updatePBDrawActionC:(Game__PBDrawAction*)pbDrawActionC
{
    NSInteger count = [self pointCount];
    if (count > 0) {
        
        pbDrawActionC->pointsx = malloc(sizeof(float)*count);
        pbDrawActionC->pointsy = malloc(sizeof(float)*count);
        pbDrawActionC->brushpointwidth = malloc(sizeof(float)*count);
        pbDrawActionC->brushrandomvalue = malloc(sizeof(int32_t)*count);
        
        pbDrawActionC->n_pointsx = count;
        pbDrawActionC->n_pointsy = count;
        pbDrawActionC->n_brushpointwidth = count;
        pbDrawActionC->n_brushrandomvalue = count;
        
        [_hPointList createPointFloatXList:pbDrawActionC->pointsx
                                floatYList:pbDrawActionC->pointsy
                                 widthList:pbDrawActionC->brushpointwidth
                                randomList:pbDrawActionC->brushrandomvalue];
        
    }

    pbDrawActionC->isoptimized = self.isOptimized;
    pbDrawActionC->has_isoptimized = 1;

    pbDrawActionC->bettercolor = [self.color toBetterCompressColor];
    pbDrawActionC->has_bettercolor = 1;
    
    pbDrawActionC->pentype = self.brushType;
    pbDrawActionC->has_pentype = 1;
    
    pbDrawActionC->width = self.width;
    pbDrawActionC->has_width = 1;
    
}

- (void)dealloc
{
//    PPRelease(_finalImageData);
    PPRelease(_color);
    PPRelease(_pen);
    PPRelease(_hPointList);
    PPRelease(_drawPen);
    PPRelease(_brush);
    
    PPRelease(_beginDot);
    PPRelease(_controlDot);
    PPRelease(_endDot);
    
    PPRelease(_brushImage);

    [self releaseBrushLayer];
    [super dealloc];
}
@end