//
//  OffscreenManager.m
//  Draw
//
//  Created by gamy on 13-2-20.
//
//

#import "OffscreenManager.h"
#import "Offscreen.h"
#import "CanvasRect.h"
#import "ConfigManager.h"
#import "ChangeBackAction.h"
#import "ChangeBGImageAction.h"

@interface OffscreenManager()
{
    NSMutableArray *_offscreenList;
}

@property(nonatomic, retain)Offscreen *gridOffscreen;
@property(nonatomic, retain)Offscreen *bgOffscreen;

@end

#define MAX_CAN_UNDO_COUNT 200

#define DEFAULT_LEVEL 4
#define DEFAULT_UNDO_STEP 50

#define SHOWVIEW_LEVEL 2
#define SHOWVIEW_UNDO_STEP 1



@implementation OffscreenManager

#define VALUE(X) (ISIPAD ? 2*X : X)
#define LINE_SPACE [ConfigManager getDrawGridLineSpace]

- (void)addGridOffscreen:(CGRect)rect
{
    
    self.gridOffscreen = [[[Offscreen alloc] initWithCapacity:0 rect:rect] autorelease];
    self.gridOffscreen.forceShow = YES;
    CGContextRef context = [self.gridOffscreen cacheContext];

    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:160/255. green:1 blue:1 alpha:1].CGColor);
    CGContextSetLineWidth(context, VALUE(0.5));
    
//    CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
//    CGContextFillRect(context, rect);
    
    NSInteger i = 1;
    
    
    
    while (i * LINE_SPACE < (CGRectGetWidth(rect))) {
        CGContextMoveToPoint(context, i * LINE_SPACE, 0);
        CGContextAddLineToPoint(context, i * LINE_SPACE, CGRectGetHeight(rect));
        CGContextStrokePath(context);
        i ++;
    }
    
    i = 1;
    while (i * LINE_SPACE < (CGRectGetHeight(rect))) {
        CGContextMoveToPoint(context, 0, i * LINE_SPACE);
        CGContextAddLineToPoint(context, CGRectGetWidth(rect), i * LINE_SPACE);
        CGContextStrokePath(context);
        i ++;
    }

}


- (void)addBgOffscreen:(CGRect)rect
{
    self.bgOffscreen = [[[Offscreen alloc] initWithCapacity:1 rect:rect] autorelease];
    self.bgOffscreen.forceShow = YES;
}


+ (id)drawViewOffscreenManagerWithRect:(CGRect)rect //default OffscreenManager
{
    OffscreenManager *manager = [[[OffscreenManager alloc] initWithLevelNumber:DEFAULT_LEVEL maxUndoStep:DEFAULT_UNDO_STEP rect:rect] autorelease];
    [manager addGridOffscreen:rect];

    if ([GameApp hasBGOffscreen]) {
        [manager addBgOffscreen:rect];
    }
    
    return manager;
}
+ (id)showViewOffscreenManagerWithRect:(CGRect)rect //default OffscreenManager
{
    OffscreenManager *manager = [[[OffscreenManager alloc] initWithLevelNumber:SHOWVIEW_LEVEL maxUndoStep:SHOWVIEW_UNDO_STEP rect:rect] autorelease];
    
    if ([GameApp hasBGOffscreen]) {
        [manager addBgOffscreen:rect];
    }
    
    return manager;
}

- (void)setBGOffscreenImage:(UIImage *)image
{
    if (image && self.bgOffscreen) {
        [self.bgOffscreen showImage:image];
    }
}

- (void)dealloc
{
    PPRelease(_offscreenList);
    PPRelease(_gridOffscreen);
    PPRelease(_bgOffscreen);
    [super dealloc];
}

//draw view: the level should be >= 4, show view level must be 2
- (id)initWithLevelNumber:(NSUInteger)level maxUndoStep:(NSUInteger)step rect:(CGRect)rect
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

        Offscreen *offScreen = [Offscreen offscreenWithCapacity:1 rect:rect];
        [_offscreenList addObject:offScreen];

        NSUInteger capacity = step;
        for (NSInteger i = 1; i < level - 1; ++ i) {
            Offscreen *offScreen = [Offscreen offscreenWithCapacity:capacity rect:rect];
            [_offscreenList addObject:offScreen];
            capacity *= 2;
        }
        
        Offscreen *leftScreen = [Offscreen unlimitOffscreenWithRect:rect];
        [_offscreenList addObject:leftScreen];
        
    }
    return self;
}

- (id)init
{
    return [self initWithLevelNumber:DEFAULT_LEVEL maxUndoStep:DEFAULT_UNDO_STEP rect:[CanvasRect defaultRect]];
}

- (void)adjustOffscreenAtIndex:(NSUInteger)index
                 withOffscreen:(Offscreen *)offscreen;
{
//    PPDebug(@"<adjustOffscreenAtIndex> index = %d",index);
    if (index < _level) {
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


- (Offscreen *)bottomScreen
{
    return [_offscreenList lastObject];
}

- (CGRect)updateLastAction:(DrawAction *)action
{
    return [[self enteryScreen] drawAction:action clear:YES];
}

- (void)printOSInfo
{
    PPDebug(@"======<printOSInfo> total action count = %d ======", [self actionCount]);
    for (NSInteger i = _level - 1; i >= 0; -- i) {
        Offscreen *os = [_offscreenList objectAtIndex:i];
        PPDebug(@"OS index = %d, action count = %d", i, os.actionCount);
    }
    
}

//add draw action and draw it in the last layer.
- (CGRect)addDrawAction:(DrawAction *)action
{
    
    //DONOT REMOVE BY GAMY
    
//    if ([action isKindOfClass:[ChangeBackAction class]] || [action isKindOfClass:[ChangeBGImageAction class]]) {
//        return [self.bgOffscreen drawAction:action clear:YES];
//    }
    Offscreen *entery = [self enteryScreen];
    BOOL full = [entery isFull];
    if (full) {
        [self adjustOffscreenAtIndex:1 withOffscreen:entery];
    }
    //Draw the action in the entry screen.
    CGRect rect = [entery drawAction:action clear:full];
    return  rect;
}

- (void)cancelLastAction
{
    [[self enteryScreen] clear];
}

- (void)updateOS:(Offscreen*)os WithDrawActionList:(NSArray *)drawActionList
                             start:(NSInteger)start
                               end:(NSInteger)end
{
    PPDebug(@"<updateOS> start = %d, end = %d",start, end);
    if (start < end && start >= 0 && end <= [drawActionList count]) {
        [os clear];
        for (NSInteger i = start; i < end; ++ i) {
            DrawAction *action = [drawActionList objectAtIndex:i];
            [os drawAction:action clear:NO];
        }
    }
}

- (void)updateWithDrawActionList:(NSArray *)drawActionList
{
    
    PPDebug(@"<updateWithDrawActionList> , action count = %d", [drawActionList count]);
    NSUInteger index = 0;
    NSInteger startIndex = 0;
    NSInteger endIndex = [drawActionList count];
    for (; index < _level; ++ index) {
        //cal start and end index
        Offscreen *os = [_offscreenList objectAtIndex:index];
        if ([os noLimit]) {
            startIndex = 0;
        }else{
            startIndex = endIndex - os.capacity;
            if (startIndex < 0) {
                startIndex = 0;
            }
        }
        [self updateOS:os WithDrawActionList:drawActionList start:startIndex end:endIndex];
        endIndex = startIndex;
    }

    [self printOSInfo];
}

//show all the action render in the layer list
- (void)showAllLayersInContext:(CGContextRef)context
{
    if (self.bgOffscreen) {
        [_bgOffscreen showInContext:context];
    }

    for (NSInteger i = _level - 1; i >= 0; -- i) {
        Offscreen *os = [_offscreenList objectAtIndex:i];
        [os showInContext:context];
    }
    if (self.showGridOffscreen) {
        [_gridOffscreen showInContext:context];
    }
}

//show to index, and return the real index. such as: show to index 12, but can return 10. real index <= index is guaranteed

- (NSUInteger)closestIndexWithActionIndex:(NSUInteger)index
{
    NSInteger count = 0;
    for (NSInteger i = _level - 1; i >= 0; -- i) {
        Offscreen *os = [_offscreenList objectAtIndex:i];
        if ((count + os.actionCount)<= index) {
            count += os.actionCount;
        }else{
            break;
        }
    }
    PPDebug(@"<closestIndexWithActionIndex>");
    [self printOSInfo];
    PPDebug(@"<closestIndexWithActionIndex> input index = %d, return index = %d",index, count);
    return count;

}

- (Offscreen *)offScreenForActionIndex:(NSInteger)index
{
//    PPDebug(@"<offScreenForActionIndex>");
//    [self printOSInfo];
    
    NSInteger count = 0;
    for (NSInteger i = _level - 1; i >= 0; -- i) {
        Offscreen *os = [_offscreenList objectAtIndex:i];
        count += os.actionCount;
        if (index < count) {
            return os;
        }
    }
    return nil;
}


//clean all the layer.
- (void)clean
{
    for (Offscreen *os in _offscreenList) {
        [os clear];
    }
}

//return total action count;
- (NSUInteger)actionCount
{
    NSUInteger count = 0;
    for (Offscreen *os in _offscreenList) {
        count += [os actionCount];
    }
    return count;
}

- (BOOL)isEmpty
{
    return [self actionCount] == 0;
}


- (BOOL)canUndo
{
    if ([self actionCount] <= MAX_CAN_UNDO_COUNT) {
        return YES;
    }
    for (NSInteger i = 0; i < _level - 1; ++ i) {
        Offscreen *os = [_offscreenList objectAtIndex:i];
        if ([os actionCount] != 0) {
            return YES;
        }
    }
    return NO;
//    for (Offscreen *os in _offscreenList) {
////        count += [os actionCount];
//        if([os actionCount] > 0){
//            flag |= YES;
//        }
//    }
}

@end
