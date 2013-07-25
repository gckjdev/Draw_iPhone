//
//  DrawLayer.m
//  TestCodePool
//
//  Created by gamy on 13-7-22.
//  Copyright (c) 2013年 orange. All rights reserved.
//

#import "DrawLayer.h"
#import "CacheDrawManager.h"
#import "DrawAction.h"
#import "PPStack.h"



@implementation DrawInfo

- (void)dealloc
{
    PPRelease(_shadow);
    PPRelease(_penColor);
    PPRelease(_bgColor);
    [super dealloc];
}

@end


@implementation DrawLayer
@synthesize drawActionList = _drawActionList;
@synthesize drawInfo = _drawInfo;

- (id)init{
    self = [super init];
    if (self) {
        self.drawInfo = [[[DrawInfo alloc] init]autorelease];
        _supportCache = NO;
//        _redoStack = [[PPStack alloc] init];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
           drawInfo:(DrawInfo *)drawInfo
                tag:(NSUInteger)tag
               name:(NSString *)name
        suportCache:(BOOL)supporCache
{
    self = [super init];
    if (self) {
        self.frame = frame;
        self.drawInfo = (self.drawInfo == nil) ? [[[DrawInfo alloc] init] autorelease] : drawInfo;
        self.layerTag = tag;
        self.layerName = name;
        _supportCache = supporCache;
        if (_supportCache) {
            self.cdManager = [CacheDrawManager managerWithRect:self.bounds];
        }
        self.drawActionList = [NSMutableArray array];
    }
}

- (void)dealloc
{
    PPRelease(_drawActionList);
    PPRelease(_layerName);
    PPRelease(_cdManager);
    PPRelease(_drawInfo);
    PPRelease(_redoStack);
    [super dealloc];
}

- (void)drawInContext:(CGContextRef)ctx
{
    if (self.supportCache) {
        [_cdManager showInContext:ctx];
    }else{
        for (DrawAction *action in _drawActionList) {
            [action drawInContext:ctx inRect:self.bounds];
        }
    }
}


#pragma mark-- DrawProcessProtocol

//start to add a new draw action
- (void)addDrawAction:(DrawAction *)drawAction show:(BOOL)show
{
    
    if (_supportCache) {
        CGRect rect = [self.cdManager updateLastAction:action];
        if (refresh) {
            [self setNeedsDisplayInRect:rect];
        }
        return;
    }
    if (action) {
        [self.drawActionList addObject:action];
        [self updateLastAction:action refresh:show];
    }
}

//update the last action
- (void)updateLastAction:(DrawAction *)action refresh:(BOOL)refresh
{
    if (_supportCache) {
        CGRect rect = [self.cdManager updateLastAction:action];
        if (refresh) {
            [self setNeedsDisplayInRect:rect];
        }
        return;
    }
    
    if (action && [self.drawActionList lastObject]) {
        if ([self.drawActionList lastObject] != action) {
            [self.drawActionList replaceObjectAtIndex:[self.drawActionList count]-1 withObject:action];
        }
        if (refresh) {
            CGRect rect = [action redrawRectInRect:self.bounds];
            [self setNeedsDisplayInRect:rect];
        }
    }
}

//finish update the last action
- (void)finishLastAction:(DrawAction *)action refresh:(BOOL)refresh
{
    if (_supportCache) {
        [self.cdManager finishDrawAction:action];
    }
}

//remove the last action force to refresh
- (void)cancelLastAction
{
    if (_supportCache) {
        [self.cdManager cancelLastAction];
    }
    if ([self.drawActionList lastObject]) {
        [self.drawActionList removeLastObject];
    }
}


- (void)reset
{
    self.clipAction = nil;
    [self.drawActionList removeAllObjects];
    self.frame = self.superlayer.bounds;
    self.cdManager = [CacheDrawManager managerWithRect:self.bounds];
}

- (void)updateWithDrawActions:(NSArray *)actionList
{
    if ([actionList isKindOfClass:[NSMutableArray class]]) {
        self.drawActionList = actionList;
    }else{
        self.drawActionList = [NSMutableArray arrayWithArray:actionList];
    }
    
    if (_supportCache) {
        [self.cdManager reset];
        [self.cdManager updateWithDrawActionList:actionList];
    }else{
        //pass
    }
}

//clip action
- (void)enterClipMode:(ClipAction *)clipAction
{
    self.clipAction = clipAction;
}
- (void)exitFromClipMode
{
    self.clipAction = nil;
    [self.cdManager finishCurrentClip];
}

//
- (BOOL)canRedoDrawAction:(DrawAction *)action
{
    //decided by the draw view
    return YES;
}
- (BOOL)canUndoDrawAction:(DrawAction *)action
{
    if (action && [_drawActionList lastObject] == action) {
        return _supportCache && [_cdManager canUndo];
    }
    return NO;
}

//return the action remove or readd.

- (DrawAction *)redoDrawAction:(DrawAction *)action
{
    if ([self canRedoDrawAction:action]) {
        [self addDrawAction:action show:YES];
    }
}
- (DrawAction *)undoDrawAction:(DrawAction *)action
{
    if ([self canUndoDrawAction:action]) {
        if (_supportCache) {
            [_cdManager undo];
        }
        if ([action isKindOfClass:[ClipAction class]]) {
            self.clipAction = nil;
        }
        [self.drawActionList removeLastObject];
        [self setNeedsDisplayInRect:[action redrawRectInRect:self.bounds]];
        return action;
    }
    return nil;
}



@end
