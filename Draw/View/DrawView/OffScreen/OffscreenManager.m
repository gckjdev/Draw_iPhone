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



BOOL showBGOffscreen = NO;

@interface OffscreenManager()
{
    NSMutableArray *_offscreenList;
    NSMutableArray *_cachedActionList;
}

//@property(nonatomic, retain)Offscreen *gridOffscreen;
@property(nonatomic, retain)Offscreen *bgOffscreen;

@end

#define MAX_CAN_UNDO_COUNT 200

#define DEFAULT_LEVEL 3
#define DEFAULT_UNDO_STEP 100

#define SHOWVIEW_LEVEL 1
#define SHOWVIEW_UNDO_STEP 0

//#define DEFAULT

@implementation OffscreenManager

+ (void)setShowBGOffscreen:(BOOL)show
{
    showBGOffscreen = show;
}

#define VALUE(X) (ISIPAD ? 2*X : X)
#define LINE_SPACE [ConfigManager getDrawGridLineSpace]


- (void)drawGridInContext:(CGContextRef)context rect:(CGRect)rect
{
    CGContextSaveGState(context);
    
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:160/255. green:1 blue:1 alpha:1].CGColor);
    CGContextSetLineWidth(context, VALUE(0.5));
    
    
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
    CGContextRestoreGState(context);

}

//- (void)addGridOffscreen:(CGRect)rect
//{
//    
//    self.gridOffscreen = [[[Offscreen alloc] initWithCapacity:0 rect:rect] autorelease];
//    self.gridOffscreen.forceShow = YES;
//    CGContextRef context = [self.gridOffscreen cacheContext];
//    [self drawGridInContext:context rect:rect];
//
//}


- (void)addBgOffscreen:(CGRect)rect
{
    self.bgOffscreen = [[[Offscreen alloc] initWithCapacity:1 rect:rect] autorelease];
    self.bgOffscreen.forceShow = YES;
}


//- (void)setShowGridOffscreen:(BOOL)showGridOffscreen
//{
//    if (showGridOffscreen && self.gridOffscreen == nil) {
//        [self addGridOffscreen:self.enteryScreen.rect];
//    }
//    _showGridOffscreen = showGridOffscreen;
//}

+ (id)drawViewOffscreenManagerWithRect:(CGRect)rect //default OffscreenManager
{
//    OffscreenManager *manager = [[[OffscreenManager alloc] initWithLevelNumber:DEFAULT_LEVEL maxUndoStep:DEFAULT_UNDO_STEP rect:rect] autorelease];

    OffscreenManager *manager = [[[OffscreenManager alloc] initWithRect:rect] autorelease];

    if ([GameApp hasBGOffscreen]||showBGOffscreen) {
        [manager addBgOffscreen:rect];
    }
    
    return manager;
}
+ (id)showViewOffscreenManagerWithRect:(CGRect)rect //default OffscreenManager
{
//    OffscreenManager *manager = [[[OffscreenManager alloc] initWithLevelNumber:SHOWVIEW_LEVEL maxUndoStep:SHOWVIEW_UNDO_STEP rect:rect] autorelease];

    OffscreenManager *manager = [[[OffscreenManager alloc] initWithRect:rect] autorelease];
    
    if ([GameApp hasBGOffscreen] || showBGOffscreen) {
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
    PPRelease(_bgOffscreen);
    PPRelease(_cachedActionList);
    
    [super dealloc];
}

- (id)initWithRect:(CGRect)rect
{
    self = [super init];
    if (self) {
        _level = 1;
        _step = 0;
        _offscreenList = [[NSMutableArray alloc] initWithCapacity:1];
        Offscreen *leftScreen = [Offscreen unlimitOffscreenWithRect:rect];
        [_offscreenList addObject:leftScreen];
        
        _cachedActionList = [[NSMutableArray arrayWithCapacity:DEFAULT_UNDO_STEP] retain];
        
    }
    return self;

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
  //new implementation
    return [action redrawRectInRect:[self bottomScreen].rect];
    
//    return [[self enteryScreen] drawAction:action clear:YES];
}

- (void)printOSInfo
{
    PPDebug(@"======<printOSInfo> total action count = %d ======", [self actionCount]);
    for (NSInteger i = _level - 1; i >= 0; -- i) {
        Offscreen *os = [_offscreenList objectAtIndex:i];
        PPDebug(@"OS index = %d, action count = %d", i, os.actionCount);
    }
    
}

- (CGRect)addDrawAction:(DrawAction *)action
            toOffscreen:(Offscreen *)os
{
    return [os drawAction:action clear:NO];
}


- (CGRect)addDrawAction:(DrawAction *)action option:(AddDrawActionOption)option
{
    BOOL hasCacheData = ([_cachedActionList count] != 0);
    if (option == AddDrawActionOptionNOCache) {
        if (hasCacheData) {
            for (DrawAction *act in _cachedActionList) {
                [[self bottomScreen] drawAction:act clear:NO];
            }
            [_cachedActionList removeAllObjects];
        }
        CGRect rect = [[self bottomScreen] drawAction:action clear:NO];
        if (hasCacheData) {
            return [self bottomScreen].rect;
        }else{
            return rect;
        }
    }
    if ([_cachedActionList count] >= DEFAULT_UNDO_STEP) {

        int i = 0;
        while (i <= DEFAULT_UNDO_STEP / 2) {
            DrawAction *action0 = [_cachedActionList objectAtIndex:i];
            [[self bottomScreen] drawAction:action0 clear:NO];
            i++;
        }
        [_cachedActionList removeObjectsInRange:NSMakeRange(0, i)];
        [_cachedActionList addObject:action];
        return [self bottomScreen].rect;
        
    }else{
        [_cachedActionList addObject:action];
        return [action redrawRectInRect:[self bottomScreen].rect];
    }
}

//add draw action and draw it in the last layer.
- (CGRect)addDrawAction:(DrawAction *)action
{
    
    //new implementatiion
    
    return [self addDrawAction:action option:AddDrawActionOptionNormal];
    
    
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
    CGRect rect1 = [entery drawAction:action clear:full];
    return  rect1;
}

- (void)cancelLastAction
{
    [_cachedActionList removeLastObject];
    return;
//    [[self enteryScreen] clear];
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
    if ([drawActionList count] == 0) {
        return;
    }
    //new implementation
    NSInteger start = 0;
    NSInteger count = [drawActionList count];
    NSInteger end = count - DEFAULT_UNDO_STEP;
    if (end > 0) {
        [self updateOS:[self bottomScreen] WithDrawActionList:drawActionList start:start end:end];
    }else{
        [_cachedActionList removeAllObjects];
        NSArray *subArray = [drawActionList subarrayWithRange:NSMakeRange(end, count - end)];
        
        [_cachedActionList addObjectsFromArray:subArray];
    }
    
    
    return;
    //
    
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
    
    for (DrawAction * drawAction in _cachedActionList) {
        [drawAction drawInContext:context inRect:[self bottomScreen].rect];
    }
    
    
    if (self.showGridOffscreen) {
        [self drawGridInContext:context rect:self.enteryScreen.rect];
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
    [_cachedActionList removeAllObjects];
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

- (void)undo
{
    if ([self canUndo]) {
        [_cachedActionList removeLastObject];
    }
}

- (BOOL)canUndo
{
    
    //new implementation
    
    return [_cachedActionList count] > 0;
    
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
