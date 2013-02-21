//
//  UndoCache.m
//  Draw
//
//  Created by gamy on 13-2-20.
//
//

#import "Offscreen.h"
#import "DrawUtils.h"


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
- (id)initWithCapacity:(NSUInteger)capacity
{
    self = [super init];
    if (self) {
        cacheLayer = [DrawUtils createCGLayerWithRect:DRAW_VIEW_RECT];
        cacheContext = CGLayerGetContext(cacheLayer);
        CGContextSetLineJoin(cacheContext, kCGLineJoinRound);
        CGContextSetLineCap(cacheContext, kCGLineCapRound);
        _actionCount = 0;
        _capacity = capacity;
    }
    return self;    
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


- (void)updatContextWithCGLayer:(CGLayerRef)layer
                     actionCount:(NSInteger)actionCount
{
    PPDebug(@"<updatContextWithCGLayer> actionCount = %d", actionCount);
    _actionCount = actionCount;
    CGContextClearRect(cacheContext, DRAW_VIEW_RECT);
    CGContextDrawLayerAtPoint(cacheContext, CGPointZero, layer);
}

- (void)addContextWithCGLayer:(CGLayerRef)layer
                   actionCount:(NSInteger)actionCount
{
    PPDebug(@"<addContextWithCGLayer> actionCount = %d", actionCount);
    _actionCount += actionCount;
    CGContextDrawLayerAtPoint(cacheContext, CGPointZero, layer);
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
