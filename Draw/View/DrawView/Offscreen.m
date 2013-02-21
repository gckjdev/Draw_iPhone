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

#define DEFAULT_CAPACITY 50

@interface Offscreen()
{
    CGContextRef cacheContext;
    CGLayerRef cacheLayer;
}

@end

@implementation Offscreen

+ (id)offscreenWithCapacity:(NSUInteger)capacity
{
    return [[[Offscreen alloc] initWithCapacity:capacity] autorelease];
}

+ (id)unlimitOffscreen
{
    return [[[Offscreen alloc] initWithCapacity:0] autorelease];
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
        _actionCount = 0;
        _capacity = capacity;
    }
    return self;    
}

- (id)initWithCapacity:(NSUInteger)capacity
{
    return [self initWithCapacity:capacity rect:DRAW_VIEW_RECT];
}

- (id)init
{
    return [self initWithCapacity:DEFAULT_CAPACITY];
}

- (void)dealloc
{
    CGLayerRelease(cacheLayer), cacheLayer = NULL;
    [super dealloc];
}

- (CGLayerRef)cacheLayer
{
    return cacheLayer;
}


- (void)updateContextWithCGLayer:(CGLayerRef)layer
                     actionCount:(NSInteger)actionCount
{
    PPDebug(@"<updatContextWithCGLayer> actionCount = %d", actionCount);
    _actionCount = actionCount;
    CGContextClearRect(cacheContext, _rect);
    CGContextDrawLayerAtPoint(cacheContext, CGPointZero, layer);
}

- (void)addContextWithCGLayer:(CGLayerRef)layer
                   actionCount:(NSInteger)actionCount
{
    PPDebug(@"<addContextWithCGLayer> actionCount = %d", actionCount);
    _actionCount += actionCount;
    CGContextDrawLayerAtPoint(cacheContext, CGPointZero, layer);
}

- (CGRect)strokePaint:(Paint *)paint inContext:(CGContextRef)context clear:(BOOL)clear
{
    if (clear) {
        CGRect drawBox = _rect;
        CGContextClearRect(context, drawBox);
    }
    CGPathRef path = paint.path;
    CGRect rect = [DrawUtils rectForPath:path withWidth:paint.width bounds:_rect];
    CGContextAddPath(context, path);
    CGContextStrokePath(context);
    
    return rect;
}

- (void)setStrokeColor:(DrawColor *)color lineWidth:(CGFloat)width inContext:(CGContextRef)context
{
    CGContextSetLineWidth(context, width);
    CGContextSetStrokeColorWithColor(context, color.CGColor);
}


- (CGRect)drawAction:(DrawAction *)action inContext:(CGContextRef)context
{
    if ([action isCleanAction]) {
        CGContextClearRect(context, _rect);
        return _rect;
    }else if([action isChangeBackAction]){
        CGColorRef color = action.paint.color.CGColor;
        CGContextSetFillColorWithColor(context, color);
        CGContextFillRect(context, _rect);
        return _rect;
    }else if([action isDrawAction]){
        [self setStrokeColor:action.paint.color lineWidth:action.paint.width inContext:context];
        CGRect rect = [self strokePaint:action.paint inContext:context clear:NO];
        return rect;
    }
    
    return _rect;
}


- (CGRect)strokePaint:(Paint *)paint clear:(BOOL)clear
{
    if (clear) {
        _actionCount = 1;
    }else{
        _actionCount ++;
    }
    return [self strokePaint:paint inContext:cacheContext clear:clear];
}
- (void)setStrokeColor:(DrawColor *)color lineWidth:(CGFloat)width
{
    [self setStrokeColor:color lineWidth:width inContext:cacheContext];
}
- (CGRect)drawAction:(DrawAction *)action clear:(BOOL)clear
{
    _actionCount ++;
    return [self drawAction:action inContext:cacheContext];
}

- (void)clear
{
    _actionCount = 0;
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



@end
