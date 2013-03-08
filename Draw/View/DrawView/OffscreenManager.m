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



@end

#define MAX_CAN_UNDO_COUNT 200

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
//    PPRelease(_drawPen);
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

- (void)updateDrawPenWithPaint:(Paint *)paint
{
    [self setStrokeColor:paint.color width:paint.width];
//    if (paint) {
//        if (paint.penType != [self.drawPen penType]) {
//            self.drawPen = [DrawPenFactory createDrawPen:paint.penType];
//        }
//        CGContextRef context = [[self enteryScreen] cacheContext];
////        CGContextRestoreGState(context);
//        [self.drawPen updateCGContext:context paint:paint];
//        CGContextSaveGState(context);
//    }
}

- (void)setStrokeColor:(DrawColor *)color width:(CGFloat)width
{
    [[self enteryScreen] setStrokeColor:color lineWidth:width];
}

- (CGRect)updateLastPaint:(Paint *)paint
{
    return [[self enteryScreen] strokePaint:paint clear:YES];
}

- (CGRect)updateLastAction:(DrawAction *)action
{
    if (action.type == DRAW_ACTION_TYPE_DRAW) {
        return [self updateLastPaint:action.paint];
    }else if(action.type == DRAW_ACTION_TYPE_SHAPE)
    {
        return [[self enteryScreen] drawShape:action.shapeInfo clear:YES];
    }
    return [[self enteryScreen] rect];
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
    Offscreen *entery = [self enteryScreen];
    BOOL full = [entery isFull];
    if (full) {
        [self adjustOffscreenAtIndex:1 withOffscreen:entery];
    }
    //Draw the action in the entry screen.
    CGRect rect = [entery drawAction:action clear:full];
//    PPDebug(@"<addDrawAction>");
//    [self printOSInfo];
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
    for (NSInteger i = _level - 1; i >= 0; -- i) {
        Offscreen *os = [_offscreenList objectAtIndex:i];
        [os showInContext:context];
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
    PPDebug(@"<offScreenForActionIndex>");
    [self printOSInfo];
    
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
