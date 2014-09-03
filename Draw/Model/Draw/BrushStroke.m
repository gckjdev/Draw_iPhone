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


@interface BrushDot : NSObject

@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat width;

@end

@implementation BrushDot

@end

@interface BrushStroke()
{
}

@property (nonatomic, retain) HBrushPointList  *hPointList;
@property (nonatomic, assign) BOOL hasPoint;

@property (nonatomic, retain) BrushDot  *beginDot;
@property (nonatomic, retain) BrushDot  *controlDot;
@property (nonatomic, retain) BrushDot  *endDot;
@property (nonatomic, assign) CGFloat tempWidth;

//@property (nonatomic, retain) UIImage *finalImage;
//@property (nonatomic, retain) NSData *finalImageData;

@end

@implementation BrushStroke

//- (id<PenEffectProtocol>)getPen
//{
//    if (self.pen != nil)
//        return self.pen;
//    
//    self.pen = [PenFactory getPen:_brushType];
//    return self.pen;
//}

//- (void)constructPath
//{
//    [[self getPen] constructPath:_hPointList inRect:self.canvasRect];
//    return;
//}

- (id)initWithWidth:(CGFloat)width color:(DrawColor*)color
{
    self = [super init];
    if (self) {
        self.width = width;
        self.color = color;
        _hPointList = [[HBrushPointList alloc] init];
    }
    return self;
}

- (id)initWithWidth:(CGFloat)width
              color:(DrawColor *)color
            brushType:(ItemType)brushType
          pointList:(HBrushPointList*)pointList
{
    self = [super init];
    if (self) {
        self.width = width;
        self.color = color;
        self.brushType = brushType;
        
        self.beginDot = [[BrushDot alloc]init];
        self.controlDot = [[BrushDot alloc]init];
        self.endDot = [[BrushDot alloc]init];
        
        //get brush image and tint it
        self.brushImage = [UIImage imageNamed:@"brush_dot2.png"];
        UIColor *customizedColor = [UIColor colorWithRed:self.color.red
                                                   green:self.color.green
                                                    blue:self.color.blue
                                                   alpha:1.0];

        UIImage *tinted = [self.brushImage
                           rt_tintedImageWithColor:customizedColor
                                             level:1.0f];
        self.brushImage = tinted;
        self.brushImageRef = self.brushImage.CGImage;
        
        if (pointList == nil){
            _hPointList = [[HBrushPointList alloc] init];
        }
        else{
            self.hPointList = pointList;
        }
        
       
    }
    return self;
}


+ (id)brushStrokeWithWidth:(CGFloat)width
                     color:(DrawColor *)color
                 brushType:(ItemType)brushType
                 pointList:(HBrushPointList*)pointList
{
    return [[[BrushStroke alloc] initWithWidth:width
                                         color:color
                                     brushType:brushType
                                     pointList:pointList] autorelease];
}


- (id)initWithGameMessage:(GameMessage *)gameMessage
{
    self = [super init];
    if (self && gameMessage) {
        NSInteger intColor = [[gameMessage notification] color];
        CGFloat lineWidth = [[gameMessage notification] width];
        NSArray *pointList = [[gameMessage notification] pointsList];
        self.width = lineWidth;
        
        self.brushType = [[gameMessage notification] penType];
        self.color = [DrawUtils decompressIntDrawColor:intColor];
        _hPointList = [[HBrushPointList alloc] init];
        for (NSNumber *pointNumber in pointList) {
            CGPoint point = [DrawUtils decompressIntPoint:[pointNumber integerValue]];
            
            //this may be wrong, need test.... By Gamy
            [self addPoint:point inRect:[CanvasRect defaultRect]];
        }
        [_hPointList complete];
    }
    return self;
}

- (CGLayerRef)brushLayer:(CGRect)rect
{
    if (_brushLayer == NULL){
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

- (void)updateLastPoint:(CGPoint)point inRect:(CGRect)rect
{
    if ([_hPointList count] <= 0){
        return;
    }
    
    CGPoint lastPoint = [_hPointList lastPoint];
    
    if (!CGPointEqualToPoint(point, lastPoint)) {
//        [self constructPath];
    }
}

#define INTERPOLATION 4
#define FIXED_PEN_SIZE 32
- (void)addPoint:(CGPoint)point inRect:(CGRect)rect
{
    
    if (!CGRectContainsPoint(rect, point)){
        //add By Gamy
        //we can change point(304.1,320.4) to point(304,320)
        //this point is not incorrect, but mistake.
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
    
//    [[self getPen] addPointIntoPath:point];
    
    _brushLayer = [self brushLayer:rect];
    CGContextRef layerContext = CGLayerGetContext(_brushLayer);
    CGContextSaveGState(layerContext);
    
    if (_hasPoint == NO){
        
//        CGContextClearRect(layerContext, CGRectFromCGSize(CGLayerGetSize(_brushLayer)));
        
        _controlDot.x = point.x;
        _controlDot.y = point.y;
        _controlDot.width = self.width;
        
        _beginDot.x = point.x;
        _beginDot.y = point.y;
        _beginDot.width = self.width;
        
        _endDot.x = point.x;
        _endDot.y = point.y;
        _endDot.width = self.width;
        
        _hasPoint = YES;
        _tempWidth = 0;
        _beginDot.width = _tempWidth;
        _controlDot. width = _tempWidth;
        _endDot.width = _tempWidth;
    }
    else{
        //重采样定位第一点
        _beginDot.x = 0.25*_beginDot.x + 0.5*_controlDot.x + 0.25*_endDot.x;
        _beginDot.y = 0.25*_beginDot.y + 0.5*_controlDot.y + 0.25*_endDot.y;
        _beginDot.width = 0.5*_beginDot.width + 0.5*_controlDot.width;
        //第二点，为控制点
        _controlDot.x = _endDot.x;
        _controlDot.y = _endDot.y;
        _controlDot.width = _endDot.width;
        //第三点，为当前点
        _endDot.x = point.x;
        _endDot.y = point.y;
        _endDot.width = self.width;
        
        double distance1 = [self distanceOfDot:_controlDot AndDot:_beginDot];
        double distance2 = [self distanceOfDot:_endDot AndDot:_controlDot];
        
        double accelerate = distance2 - distance1;
        if( accelerate / FIXED_PEN_SIZE > 0.1)
            _tempWidth  -= (FIXED_PEN_SIZE / 4);
        else if (accelerate / FIXED_PEN_SIZE < - 0.1)
            _tempWidth += (FIXED_PEN_SIZE / 8);
        
        if(_tempWidth > FIXED_PEN_SIZE) _tempWidth = FIXED_PEN_SIZE;
        else if (_tempWidth <= FIXED_PEN_SIZE / 2) _tempWidth = FIXED_PEN_SIZE / 2;
        
        _endDot.width = _tempWidth;
        
        float pointX=0;
        float pointY=0;
        float width=0;
        
        int dis = (distance1 + distance2) / 10 + 1;
        
//        PPDebug(@"<distance> %f,%d",distance,dis);
        
        int interpolationLength = INTERPOLATION * dis;
        
        CGImageRef brushImageRef = [self brushImageRef];
        for(int i = 0; i<interpolationLength/2; i++)
        {
            [self bezierInterpolationWithBegin:_beginDot
                                       Control:_controlDot
                                           End:_endDot
                                            No:i
                                        Length:interpolationLength
                                        pointX:&pointX
                                        pointY:&pointY
                                         width:&width];
            
            [_hPointList addPoint:pointX y:pointY width:width];
            
            // draw by point list
            CGRect rect = CGRectMake(pointX - width/2, pointY - width/2, width, width);
            CGContextDrawImage(layerContext, rect, brushImageRef);
        }
        
        CGContextRestoreGState(layerContext);
    }
}

-(double)distanceOfDot:(BrushDot*)dot1 AndDot:(BrushDot*)dot2
{
    double distance = sqrt(pow((dot2.x-dot1.x), 2)+pow((dot2.y-dot1.y), 2));
    
    return distance;
}

-(void)bezierInterpolationWithBegin:(BrushDot*)begin
                            Control:(BrushDot*)control
                                End:(BrushDot*)end
                                 No:(NSInteger)i
                             Length:(NSInteger)length
                             pointX:(float*)pointX
                             pointY:(float*)pointY
                              width:(float*)width
{
    double t = 1.0*i/length;
    
    *pointX = (1-t)*(1-t)*begin.x + 2*t*(1-t)*control.x + t*t*end.x;
    *pointY = (1-t)*(1-t)*begin.y + 2*t*(1-t)*control.y + t*t*end.y;
    *width = (1-t)*begin.width+t*control.width;

}

//- (CGPathRef)path
//{
//    id<PenEffectProtocol> pen = [self getPen];
//    if (![pen hasPoint]){
//        [pen constructPath:_hPointList inRect:self.canvasRect];
//    }
//    
//    return [pen penPath];
//}

- (CGRect)redrawRectInRect:(CGRect)rect
{
//    return self.canvasRect;
    return [self.hPointList bounds]; //self.canvasRect;
    
//    CGRect r = [DrawUtils rectForPath:self.can // self.path
//                            withWidth:self.width
//                               bounds:rect];
//    return r;
}

- (CGRect)drawInBrushLayer:(float)currentX y:(float)currentY width:(float)currentW;
{
    CGContextRef context = CGLayerGetContext(_brushLayer);
//    CGRect rect = CGRectFromCGSize(CGLayerGetSize(_brushLayer));
    
    // to be removed
    if (self.drawPen == nil) {
        self.drawPen = [DrawPenFactory createDrawPen:self.brushType];
    }
    
    CGContextSaveGState(context);
    
    /*
     [self.drawPen updateCGContext:context paint:self];
     
     CGContextAddPath(context, [self path]);
     CGContextStrokePath(context);
     */
    
    // draw by point list
    CGRect rect = CGRectMake(currentX - currentW/2, currentY - currentW/2, currentW, currentW);
    CGContextDrawImage(context, rect, self.brushImage.CGImage);
    
    CGContextRestoreGState(context);
    return [self redrawRectInRect:rect];
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
}

- (CGRect)drawInContext:(CGContextRef)context inRect:(CGRect)rect
{
    if (self.drawPen == nil) {
        self.drawPen = [DrawPenFactory createDrawPen:self.brushType];
    }
    CGContextSaveGState(context);
    
    /*
    [self.drawPen updateCGContext:context paint:self];

    CGContextAddPath(context, [self path]);
    CGContextStrokePath(context);
    */
    
    // draw by point list
    if (_brushLayer != NULL){
        CGContextDrawLayerAtPoint(context, CGPointZero, _brushLayer);
    }
//    else if (_finalImageData){
////        [_finalImage drawAtPoint:CGPointZero];
//        UIImage* image = [UIImage imageWithData:_finalImageData];
//        CGContextDrawImage(context, rect, image.CGImage);
//    }
    else{
        _brushLayer = [self brushLayer:rect];
        CGContextRef layerContext = CGLayerGetContext(_brushLayer);
        CGImageRef brushImageRef = [self brushImageRef];
        for(int i = 0; i<[_hPointList count];i++)
        {
            CGFloat currentX = [_hPointList getPointX:i];
            CGFloat currentY = [_hPointList getPointY:i];
            CGFloat currentW = [_hPointList getPointWidth:i];

            CGRect pointRect = CGRectMake(currentX - currentW/2, currentY - currentW/2, currentW, currentW);
            CGContextDrawImage(layerContext, pointRect, brushImageRef);
//            CGContextDrawImage(context, rect, brushImage);
        }
        
        CGContextDrawLayerAtPoint(context, CGPointZero, _brushLayer);
//        CGLayerRelease(_brushLayer);
//        _brushLayer = NULL;
    }
    
    CGContextRestoreGState(context);
    return [self redrawRectInRect:rect];
}

- (UIImage*)createImageFromLayer
{
    NSInteger width = self.canvasRect.size.width;
    NSInteger height = self.canvasRect.size.height;
    
    float *bitmap = NULL;
    CGColorSpaceRef colorSpace =  CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(
                                                 bitmap,
                                                 width,
                                                 height,
                                                 8, // 每个通道8位
                                                 width * 4,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast);
    
    if (context == NULL) {
        PPDebug(@"<createBitmapContext> failed. context = NULL");
        return NULL;
    }
    
    // draw layer
    CGContextDrawLayerAtPoint(context, CGPointZero, _brushLayer);

    // create image
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
//    self.finalImageData = UIImagePNGRepresentation([UIImage imageWithCGImage:imageRef]);
//    PPDebug(@"create final image for bursh, size is %@", NSStringFromCGSize(self.finalImage.size));
    
    // release
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    if (bitmap != NULL) {
        free(bitmap);
    }
    
    return nil;
}

- (void)finishAddPoint
{
    // create final image
//    if (_brushLayer != NULL){
    
//        [self createImageFromLayer];
        
//        CGLayerRelease(_brushLayer);
//        _brushLayer = NULL;
//    }
    
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


- (void)updatePBDrawActionBuilder:(PBDrawAction_Builder *)builder
{
    if ([self pointCount] != 0) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        NSMutableArray *pointXList = nil;
        NSMutableArray *pointYList = nil;
        NSMutableArray *pointWList = nil;
        
        [_hPointList createPointXList:&pointXList
                           pointYList:&pointYList
                            widthList:&pointWList];
        
        [builder addAllPointsX:pointXList];
        [builder addAllPointsY:pointYList];
        [builder addAllBrushPointWidth:pointWList];
        
        [pool drain];
    }
    [builder setBetterColor:[self.color toBetterCompressColor]];
    [builder setPenType:self.brushType];
    [builder setWidth:self.width];
}

- (void)updatePBDrawActionC:(Game__PBDrawAction*)pbDrawActionC
{
    int count = [self pointCount];
    if (count > 0) {
        
        pbDrawActionC->pointsx = malloc(sizeof(float)*count);
        pbDrawActionC->pointsy = malloc(sizeof(float)*count);
        pbDrawActionC->brushpointwidth = malloc(sizeof(float)*count);
        
        pbDrawActionC->n_pointsx = count;
        pbDrawActionC->n_pointsy = count;
        pbDrawActionC->n_brushpointwidth = count;
        
        [_hPointList createPointFloatXList:pbDrawActionC->pointsx
                                floatYList:pbDrawActionC->pointsy
                                 widthList:pbDrawActionC->brushpointwidth];
        
    }

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
    
    PPRelease(_beginDot);
    PPRelease(_controlDot);
    PPRelease(_endDot);
    
    if (_brushLayer != NULL){
        CGLayerRelease(_brushLayer);
        _brushLayer = NULL;
    }
    
    [super dealloc];
}
@end