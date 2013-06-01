//
//  UndoCache.m
//  Draw
//
//  Created by gamy on 13-2-20.
//
//

#import "Offscreen.h"
#import "DrawUtils.h"
#import "DrawAction.h"
#import "Paint.h"
#import "DrawPenFactory.h"

#define DEFAULT_CAPACITY 50

@interface Offscreen()
{
    CGContextRef cacheContext;
    CGLayerRef cacheLayer;
}

@end

@implementation Offscreen

+ (id)unlimitOffscreenWithRect:(CGRect)rect
{
    return [[[Offscreen alloc] initWithCapacity:0 rect:rect] autorelease];
}

+ (id)offscreenWithCapacity:(NSUInteger)capacity rect:(CGRect)rect
{
    return [[[Offscreen alloc] initWithCapacity:capacity rect:rect] autorelease];
}
- (id)initWithCapacity:(NSUInteger)capacity rect:(CGRect)rect
{
    self = [super init];
    if (self) {
        _rect = rect;
        cacheLayer = [DrawUtils createCGLayerWithRect:rect];
        cacheContext = CGLayerGetContext(cacheLayer);
        CGContextSetLineJoin(cacheContext, kCGLineJoinRound);
        CGContextSetLineCap(cacheContext, kCGLineCapRound);
//        CGContextSaveGState(cacheContext);
        _actionCount = 0;
        _capacity = capacity;
    }
    return self;    
}


//- (id)init
//{
//    return [self initWithCapacity:DEFAULT_CAPACITY];
//}

- (void)dealloc
{
    CGLayerRelease(cacheLayer), cacheLayer = NULL;
    PPRelease(_drawPen);
    [super dealloc];
}

- (CGLayerRef)cacheLayer
{
    return cacheLayer;
}

- (CGContextRef)cacheContext
{
    return cacheContext;
}

- (void)updateContextWithCGLayer:(CGLayerRef)layer
                     actionCount:(NSInteger)actionCount
{
//    PPDebug(@"<updatContextWithCGLayer> actionCount = %d", actionCount);
    _actionCount = actionCount;
    CGContextClearRect(cacheContext, _rect);
    CGContextDrawLayerAtPoint(cacheContext, CGPointZero, layer);
}

- (void)addContextWithCGLayer:(CGLayerRef)layer
                   actionCount:(NSInteger)actionCount
{
//    PPDebug(@"<addContextWithCGLayer> actionCount = %d", actionCount);
    _actionCount += actionCount;
    CGContextDrawLayerAtPoint(cacheContext, CGPointZero, layer);
}

- (void)updateContext:(CGContextRef)context withPaint:(Paint *)paint
{
    if ([self.drawPen penType] != paint.penType) {
        self.drawPen = [DrawPenFactory createDrawPen:paint.penType];
        [self.drawPen updateCGContext:context paint:paint];
    }else if([self.drawPen penType] == DrawPenTypeBlur){
        [self.drawPen updateCGContext:context paint:paint];
    }
}

- (CGRect)strokePaint:(Paint *)paint inContext:(CGContextRef)context clear:(BOOL)clear
{
    if (clear) {
        CGRect drawBox = _rect;
        CGContextClearRect(context, drawBox);
    }
    CGContextSaveGState(context);
    [self updateContext:context withPaint:paint];
    [self setStrokeColor:paint.color lineWidth:paint.width inContext:context];
    CGPathRef path = paint.path;
    CGRect rect = [DrawUtils rectForPath:path withWidth:paint.width bounds:_rect];
    CGContextAddPath(context, path);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    return rect;
}

- (void)setStrokeColor:(DrawColor *)color lineWidth:(CGFloat)width inContext:(CGContextRef)context
{
    CGContextSetLineWidth(context, width);
    CGContextSetStrokeColorWithColor(context, color.CGColor);
}


//- (CGRect)drawAction:(DrawAction *)action inContext:(CGContextRef)context
//{
//    return [action drawInContext:context inRect:_rect];
//    if ([action isCleanAction]) {
//        CGContextClearRect(context, _rect);
//        return _rect;
//    }else if([action isChangeBackAction]){
//        CGColorRef color = action.paint.color.CGColor;
//        CGContextSetFillColorWithColor(context, color);
//        CGContextFillRect(context, _rect);
//        return _rect;
//    }else if([action isDrawAction]){
//        [self setStrokeColor:action.paint.color lineWidth:action.paint.width inContext:context];
//        CGRect rect = [self strokePaint:action.paint inContext:context clear:NO];
//        return rect;
//    }else if([action isShapeAction]){
//        [self setStrokeColor:action.shapeInfo.color lineWidth:action.shapeInfo.width inContext:context];
//        return [self drawShape:action.shapeInfo clear:NO];
//    }
//    
//    return _rect;
//}

//- (void)updateDrawPen:()

//- (CGRect)strokePaint:(Paint *)paint clear:(BOOL)clear
//{
//    if (clear) {
//        [self clear];
//    }
//    _actionCount ++;
//    
//    return [self strokePaint:paint inContext:cacheContext clear:NO];
//}

//- (CGRect)drawShape:(ShapeInfo *)shape clear:(BOOL)clear
//{
//    if (clear) {
//        CGContextClearRect(cacheContext, _rect);
//    }
//    [shape drawInContext:cacheContext];
//    return [shape redrawRect];//_rect;//[shape rect];
//}

//- (void)setStrokeColor:(DrawColor *)color lineWidth:(CGFloat)width
//{
//    [self setStrokeColor:color lineWidth:width inContext:cacheContext];
//}

- (CGRect)drawAction:(DrawAction *)action clear:(BOOL)clear
{
    if (clear) {
        [self clear];
    }
    _actionCount ++;
    return [action drawInContext:cacheContext inRect:_rect];
}

- (void)showInContext:(CGContextRef)context
{
    if ([self hasContentToShow] || self.forceShow) {
        CGContextDrawLayerAtPoint(context, CGPointZero, cacheLayer);
    }
}

- (void)clear
{
    _actionCount = 0;
    _hasImage = NO;
    CGContextClearRect(cacheContext, _rect);
}

- (BOOL)noLimit
{
    return _capacity == 0;
}

- (BOOL)isFull
{
    return ![self noLimit] && (_actionCount >= _capacity);
}

- (BOOL)hasContentToShow
{
    return _actionCount > 0 || _hasImage;
}

#define CTMContext(context,rect) \
CGContextScaleCTM(context, 1.0, -1.0);\
CGContextTranslateCTM(context, 0, -CGRectGetHeight(rect));


- (void)showImage:(UIImage *)image
{
    if (image) {
        [self clear];
        _hasImage = YES;
        CTMContext(cacheContext, self.rect);
        CGContextDrawImage(cacheContext, self.rect, image.CGImage);
    }
}

@end
