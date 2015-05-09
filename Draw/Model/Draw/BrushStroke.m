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
//#import "DrawPenProtocol.h"
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

- (BOOL)isBrushInterpolationOptimized
{
    return [_brush canInterpolationOptimized];
}

//- (id)initWithWidth:(CGFloat)width color:(DrawColor*)color
//{
//    self = [super init];
//    if (self) {
//        self.width = width;
//        self.color = color;
//        _hPointList = [[HBrushPointList alloc] init];
//        self.isOptimized = YES;
//        self.isInterpolationOptimized = self.isOptimized && [self isBrushInterpolationOptimized];
//    }
//    return self;
//}

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


#define RECT_SPAN_WIDTH 10
- (BOOL)spanRect:(CGRect)rect ContainsPoint:(CGPoint)point
{
    rect.origin.x -= RECT_SPAN_WIDTH;
    rect.origin.y -= RECT_SPAN_WIDTH;
    rect.size.width += RECT_SPAN_WIDTH*2;
    rect.size.height += RECT_SPAN_WIDTH*2;
    return CGRectContainsPoint(rect, point);
}

// *******
// 用途：在画图当中存储采样点，并且同步显示插值点效果的
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
    
    [self dynamicDrawStrokeAtNewPoint:point
                       withBrushImage:brushImageRef
                       inLayerContext:layerContext
                      needRecordPoint:YES];
}

// *******
// 用途：在回放中，或者是在草稿中，显示采样点和插值点
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
        // TODO for Charlie Brush Random
        // 新版本的数据有优化，储存的只有采样点，需要把插值和抖动算法重现在replay端
        [self.hPointList addPointX:point.x
                            PointY:point.y
                        PointWidth:width
                       PointRandom:0];
        
        [self dynamicDrawStrokeAtNewPoint:point
                           withBrushImage:brushImageRef
                           inLayerContext:layerContext
                          needRecordPoint:NO];
    }
}

- (void)dynamicDrawStrokeAtNewPoint:(CGPoint)point
                     withBrushImage:(CGImageRef)brushImage
                     inLayerContext:(CGContextRef)layerContext
                    needRecordPoint:(BOOL)needRecordPoint
{
    CGContextSaveGState(layerContext);
    if (self.isFirstPoint == YES){
        [self initBezierKeyPointWithPoint:point];
        self.isFirstPoint = NO;

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
            [_brush shakePointWithRandomList:[_brush randomNumberList]
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

- (void)releaseBrushLayer
{
    if (_brushLayer != NULL){
        PPDebug(@"brush stroke release brush layer!");
        CGLayerRelease(_brushLayer);
        _brushLayer = NULL;
    }
}

- (void)clearMemory
{
    [self releaseBrushLayer];
    self.brushImage = nil;
    self.brushImageRef = NULL;
}

//这个draw是缓存层，在内存中把之前的先画好，再画下一笔的时候就把之前的一下子搬上来。
- (CGRect)drawInContext:(CGContextRef)context inRect:(CGRect)rect
{
    if (self.drawPen == nil) {
        self.drawPen = [DrawPenFactory createDrawPen:self.brushType];
    }
    
    //get brush image and tint it
    if (self.brushImageRef == NULL){
        self.brushImage = [_brush brushImage:[self.color color] width:self.width];
        self.brushImageRef = _brushImage.CGImage;
    }
    
    // 如果已经有一个完成了的layer，直接画到设备上，否则就新建一个layer并绘制
    if (_brushLayer != NULL)
    {
        CGContextSaveGState(context);
        CGContextDrawLayerAtPoint(context, CGPointZero, _brushLayer);
        CGContextRestoreGState(context);
        return CGRectZero;
    }

    //缓存层需要做的事：一次性在内存把所有点画出来，然后存到一个layer里面。
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
            CGPoint point = CGPointMake(currentX, currentY);
            //新版本数据，需要用算法复现插值点
            [self dynamicDrawStrokeAtNewPoint:point
                               withBrushImage:brushImageRef
                               inLayerContext:context
                              needRecordPoint:NO];
        }
    }
    
    return [self redrawRectInRect:rect];
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
        
//        [builder addAllPointsX:pointXList];
//        [builder addAllPointsY:pointYList];
//        [builder addAllBrushPointWidth:pointWList];

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