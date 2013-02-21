//
//  OffscreenManager.m
//  Draw
//
//  Created by gamy on 13-2-20.
//
//

#import "OffscreenManager.h"
#import "Offscreen.h"


@interface OffscreenManager()
{
    NSMutableArray *_offscreenList;
}

- (Offscreen *)enteryScreen;

@end

#define DEFAULT_LEVEL 4
#define DEFAULT_UNDO_STEP 50

#define SHOWVIEW_LEVEL 2
#define SHOWVIEW_UNDO_STEP 1


@implementation OffscreenManager

+ (id)drawViewOffscreenManager //default OffscreenManager
{
    return [[[OffscreenManager alloc] initWithLevelNumber:DEFAULT_LEVEL maxUndoStep:DEFAULT_UNDO_STEP] autorelease];
}
+ (id)showViewOffscreenManager //default OffscreenManager
{
    return [[[OffscreenManager alloc] initWithLevelNumber:SHOWVIEW_LEVEL maxUndoStep:SHOWVIEW_UNDO_STEP] autorelease];
}


- (void)dealloc
{
    PPRelease(_offscreenList);
    [super dealloc];
}

//draw view: the level should be >= 4, show view level must be 2
- (id)initWithLevelNumber:(NSUInteger)level maxUndoStep:(NSUInteger)step
{
    if (level < 2) {
        PPDebug(@"<initWithLevelNumber>warnning: level must >= 2");
        return nil;
    }
    self = [super init];
    if (self) {
        _level = level;
        _step = step;
        _offscreenList = [[NSMutableArray alloc] initWithCapacity:level];

        Offscreen *offScreen = [Offscreen offscreenWithCapacity:1];
        [_offscreenList addObject:offScreen];

        NSUInteger capacity = step;
        for (NSInteger i = 1; i < level - 1; ++ i) {
            Offscreen *offScreen = [Offscreen offscreenWithCapacity:capacity];
            [_offscreenList addObject:offScreen];
            capacity *= 2;
        }
        
        Offscreen *leftScreen = [Offscreen unlimitOffscreen];
        [_offscreenList addObject:leftScreen];
        
    }
    return self;
}

- (id)init
{
    return [self initWithLevelNumber:DEFAULT_LEVEL maxUndoStep:DEFAULT_UNDO_STEP];
}

- (void)adjustOffscreenAtIndex:(NSUInteger)index
                 withOffscreen:(Offscreen *)offscreen;
{
    if (index < _step) {
        Offscreen *os = [_offscreenList objectAtIndex:index];
        if ([os isFull]) {
            [self adjustOffscreenAtIndex:index + 1 withOffscreen:os];
            [os updateContextWithCGLayer:offscreen.cacheLayer actionCount:offscreen.actionCount];
        }else{
            [os addContextWithCGLayer:offscreen.cacheLayer actionCount:offscreen.actionCount];
        }
    }
}



- (Offscreen *)enteryScreen
{
    return [_offscreenList objectAtIndex:0];
}
//add draw action and draw it in the last layer.
- (void)addDrawAction:(DrawAction *)action
{
    Offscreen *entery = [self enteryScreen];
    if ([entery isFull]) {
        [self adjustOffscreenAtIndex:0 withOffscreen:entery];
    }

    //Draw the action in the entry screen.
}

//show all the action render in the layer list
- (void)showAllLayersInContext:(CGContextRef)context
{
    for (NSInteger i = _level - 1; i >= 0; -- i) {
        Offscreen *os = [_offscreenList objectAtIndex:i];
        if (os.actionCount > 0) {
            CGContextDrawLayerAtPoint(context, CGPointZero, os.cacheLayer);
        }
    }
}

//show to index, and return the real index. such as: show to index 12, but can return 10. real index <= index is guaranteed
- (NSUInteger)showToIndex:(NSUInteger)index inContext:(CGContextRef)context
{
    NSInteger count = 0;
    for (NSInteger i = _level - 1; i >= 0; -- i) {
        Offscreen *os = [_offscreenList objectAtIndex:i];
        count += os.actionCount;
        if (os.actionCount > 0 && count <= index) {
            CGContextDrawLayerAtPoint(context, CGPointZero, os.cacheLayer);
        }
    }
    return count;
}

@end
