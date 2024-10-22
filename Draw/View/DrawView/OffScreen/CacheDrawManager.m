//
//  CacheDrawManager.m
//  Draw
//
//  Created by gamy on 13-6-20.
//
//


#import "CacheDrawManager.h"
#import "Offscreen.h"
#import "DrawAction.h"
#import "ConfigManager.h"
#import "ClipAction.h"

#define MAX_CACHED_ACTION_COUNT [ConfigManager cachedActionCount]
#define MIN_UNDO_COUNT [ConfigManager minUndoActionCount]



@interface CacheDrawManager()
{

}
@property(nonatomic, retain)Offscreen *offscreen;
@property(nonatomic, assign)NSInteger imageIndex; //[0, imageIndex)
@property(nonatomic, retain)UIImage* cachedImage;



@end

@implementation CacheDrawManager

- (void)dealloc
{
    PPRelease(_offscreen);
    PPRelease(_bgPhto);
    PPRelease(_inDrawAction);
    PPRelease(_cachedImage);
    PPRelease(_drawActionList);
    [super dealloc];
}
+ (id)managerWithRect:(CGRect)rect
{
    CacheDrawManager *manager = [[[CacheDrawManager alloc] init] autorelease];
    manager.rect = rect;
    manager.offscreen = [Offscreen offscreenWithCapacity:MAX_CACHED_ACTION_COUNT rect:rect];
    manager.useCachedImage = YES;
    return manager;
}

//add draw action and draw it in the last layer.
- (CGRect)addDrawAction:(DrawAction *)action
{
//    PPDebug(@"<addDrawAction> Start: Change image, image index = %d, os count = %u, action count = %u", self.imageIndex, _offscreen.actionCount, [_drawActionList count]);

//    self.inDrawAction = nil;
    if (_offscreen.actionCount >= MAX_CACHED_ACTION_COUNT && self.useCachedImage) {
        NSInteger from = self.imageIndex;
        
        NSInteger osIndex = from + _offscreen.actionCount + 1;
        NSInteger to = self.imageIndex + MAX_CACHED_ACTION_COUNT - MIN_UNDO_COUNT;

//        PPDebug(@"<addDrawAction> Start: Change image, image index = %d, os count = %u, action count = %u", self.imageIndex, _offscreen.actionCount, [_drawActionList count]);

        [self updateImageFromIndex:from toIndex:to];
        [_offscreen clear];
        [_offscreen showImage:self.cachedImage];
        
        [self updateOSFromIndex:to toIndex:osIndex clear:NO];

        PPDebug(@"Change Image!!!");
        PPDebug(@"<addDrawAction> Start: Change image, image index = %d, os count = %u, action count = %u", self.imageIndex, _offscreen.actionCount, [_drawActionList count]);

        return _rect;
    }else{
        CGRect rect = [_offscreen drawAction:action clear:NO];
//        PPDebug(@"<addDrawAction> End: Change image, image index = %d, os count = %u, action count = %u", self.imageIndex, _offscreen.actionCount, [_drawActionList count]);        
        return rect;
    }
}


- (void)reset
{
    self.inDrawAction = nil;
//    self.drawActionList = nil;
    self.cachedImage = nil;
    self.imageIndex = 0;
    [self.offscreen clear];
}

- (void)updateImageFromIndex:(NSInteger)from toIndex:(NSInteger)to
{
    UIGraphicsBeginImageContextWithOptions(_rect.size, NO, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self.cachedImage drawAtPoint:CGPointZero];
    for (NSInteger i = from ; i < to; i ++) {
        DrawAction *action = [_drawActionList objectAtIndex:i];
        [action drawInContext:context inRect:_rect];
    }
    self.cachedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.imageIndex = to;
}

//read from draft
- (void)updateWithDrawActionList:(NSArray *)drawActionList toIndex:(NSInteger)index
{
    [self reset];
    self.drawActionList = drawActionList;
    NSInteger count = [drawActionList count];

    if (self.useCachedImage) {
        index = MIN(index, count);
        //create image
        NSInteger toIndex = index - MAX_CACHED_ACTION_COUNT / 2;
        toIndex = MAX(0, toIndex);
        self.imageIndex = toIndex;
        
        if (toIndex > 0) {
            [self updateImageFromIndex:0 toIndex:toIndex];
        }
        [_offscreen clear];
        [_offscreen showImage:self.cachedImage];
        [self updateOSFromIndex:self.imageIndex toIndex:index clear:NO];
    }else{
        [self updateOSFromIndex:0 toIndex:index clear:YES];
    }
}

- (void)updateWithDrawActionList:(NSArray *)drawActionList
{
    [self updateWithDrawActionList:drawActionList toIndex:[drawActionList count]];
}

//show all the action render in the layer list
- (void)showInContext:(CGContextRef)context
{
    [self.bgPhto drawInRect:_rect];
    [_offscreen showInContext:context];
    
    [self.currentClip showClipInContext:context inRect:_rect];
    [_inDrawAction drawInContext:context inRect:_rect];
}


- (CGRect)updateLastAction:(DrawAction *)action
{
    self.inDrawAction = action;
    
    if ([action isClipAction]) {
        self.currentClip = (id)action;
    }
    return [action redrawRectInRect:_rect];
}

- (void)cancelLastAction
{
    if ([self.inDrawAction isClipAction]) {
        self.currentClip = nil;
    }
    if (self.inDrawAction) {
        
    }
    self.inDrawAction = nil;
    
}

- (BOOL)canUndo
{
    return [_offscreen actionCount] > 0;
}

- (void)updateOSFromIndex:(NSInteger)from toIndex:(NSInteger)to clear:(BOOL)clear
{
    if (clear) {
        [_offscreen clear];
    }
    for (NSInteger i = from; i < to; ++ i) {
        DrawAction *action = [_drawActionList objectAtIndex:i];
        [_offscreen drawAction:action clear:NO]; 
    }
}

- (void)undo
{
    if ([self canUndo]) {
        [_offscreen clear];
        self.inDrawAction = nil;
        [_offscreen showImage:self.cachedImage];
        [self updateOSFromIndex:self.imageIndex toIndex:[_drawActionList count] clear:NO];
    }
}

- (BOOL)finishDrawAction:(DrawAction *)action
{
    if (action) {
        CGRect  rect = [self addDrawAction:action];
        self.inDrawAction = nil;
        if (CGRectEqualToRect(rect, _rect)) {
            return YES;
        }
    }
    return YES;
}





- (void)showToIndex:(NSInteger)index
{
    if (index < _offscreen.actionCount) {
      [self updateWithDrawActionList:_drawActionList toIndex:index];
    }else{
        for (NSInteger i = _offscreen.actionCount; i < index; ++ i) {
            DrawAction *action = [_drawActionList objectAtIndex:i];
            [self addDrawAction:action];
        }
    }
}

- (void)finishCurrentClip
{
    self.currentClip = nil;
}


@end
