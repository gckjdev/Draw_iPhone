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
#import "GradientAction.h"
#import "ClipAction.h"

@implementation DrawLayer
@synthesize drawActionList = _drawActionList;
@synthesize drawInfo = _drawInfo;

- (id)init{
    self = [super init];
    if (self) {
        self.drawInfo = [[[DrawInfo alloc] init]autorelease];
        _supportCache = NO;
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
        self.drawActionList = [NSMutableArray array];
        if (_supportCache) {
            self.cdManager = [CacheDrawManager managerWithRect:self.bounds];
            [self.cdManager updateWithDrawActionList:self.drawActionList];
        }
    
    }
    return self;
}

- (void)dealloc
{
    PPRelease(_drawActionList);
    PPRelease(_layerName);
    PPRelease(_cdManager);
    PPRelease(_drawInfo);
    [super dealloc];
}

- (void)drawInContext:(CGContextRef)ctx
{
    if (self.drawInfo.grid) {
        //TODO show grid
    }
    if (self.supportCache) {
        [_cdManager showInContext:ctx];
    }else{
        [self.clipAction showClipInContext:ctx inRect:self.bounds];
        for (DrawAction *action in _drawActionList) {
            [action drawInContext:ctx inRect:self.bounds];
        }
    }
}


#pragma mark-- DrawProcessProtocol

- (void)addDrawAction:(DrawAction *)drawAction show:(BOOL)show redo:(BOOL)redo
{
    
    if ([drawAction isClipAction]) {
        self.clipAction = (id)drawAction;
    }
    
    if (!redo) {
        drawAction.shadow = [Shadow shadowWithShadow:self.drawInfo.shadow];
        drawAction.clipAction = self.clipAction;
        
        if ([drawAction isGradientAction]) {
            if (self.clipAction) {
                [[(GradientAction *)drawAction gradient] setRect:self.clipAction.pathRect];
            }else{ 
                [[(GradientAction *)drawAction gradient] setRect:self.bounds];
            }
            [[(GradientAction *)drawAction gradient] updatePointsWithDegreeAndDivision];
        }
    }else{
        if (![drawAction isClipAction] && [drawAction clipAction] == nil) {
            self.clipAction = nil;
        }
    }

    if (drawAction) {
        [self.drawActionList addObject:drawAction];
        drawAction.layerTag = self.layerTag;
    }

    CGRect rect = self.bounds;
    if ([drawAction isClipAction] || [drawAction clipAction] != [self.lastAction clipAction]) {
        rect = self.bounds;
    }else{
        rect = [drawAction redrawRectInRect:self.bounds];
    }    
    if (_supportCache) {
        [self.cdManager updateLastAction:drawAction];
    }
    if (show) {
        [self setNeedsDisplayInRect:rect];
    }


}

//start to add a new draw action
- (void)addDrawAction:(DrawAction *)drawAction show:(BOOL)show
{
    PPDebug(@"<DrawLayer> name = %@, addDrawAction", self.layerName);
    [self addDrawAction:drawAction show:show redo:NO];
}

//update the last action
- (void)updateLastAction:(DrawAction *)action refresh:(BOOL)refresh
{

//    PPDebug(@"<DrawLayer> name = %@, updateLastAction", self.layerName);
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
    PPDebug(@"<DrawLayer> name = %@, tag = %d, finishLastAction", self.layerName, self.layerTag);
    if (_supportCache) {
        [self.cdManager finishDrawAction:action];
    }
    if (refresh) {
        [self setNeedsDisplayInRect:[action redrawRectInRect:self.bounds]];
    }    
}

//remove the last action force to refresh
- (void)cancelLastAction
{
//    PPDebug(@"<DrawLayer> name = %@, cancelLastAction", self.layerName);        
    if (_supportCache) {
        [self.cdManager cancelLastAction];
    }
    if ([self.drawActionList lastObject]) {
        [self.drawActionList removeLastObject];
    }
}

- (DrawAction *)lastAction
{
    return [self.drawActionList lastObject];
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
        self.drawActionList = (id)actionList;
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
    [self setNeedsDisplay];
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
        if (_supportCache) {
            return [_cdManager canUndo];
        }else{
            return YES;
        }
    }
    return NO;
}

//return the action remove or readd.

- (DrawAction *)redoDrawAction:(DrawAction *)action
{
    if ([self canRedoDrawAction:action]) {
        [self addDrawAction:action show:NO redo:YES];
        [self finishLastAction:action refresh:NO];
        [self setNeedsDisplay];
        return action;
    }
    return nil;
}

- (DrawAction *)undoDrawAction:(DrawAction *)action
{
    if ([self canUndoDrawAction:action]) {
        [self.drawActionList removeLastObject];
        
        if (_supportCache) {
            [_cdManager undo];
        }

        DrawAction *drawAction = [_drawActionList lastObject];
        if (drawAction.clipAction) {
            self.clipAction = drawAction.clipAction;
        }else if([drawAction isClipAction]){
            self.clipAction = (id)drawAction;
        }else{
            self.clipAction = nil;
            _cdManager.currentClip = nil;
        }
        [self setNeedsDisplay];
        return action;
    }
    return nil;
}

#define BG_LAYER_TAG 1
#define MAIN_LAYER_TAG 2

+ (NSArray *)defaultLayersWithFrame:(CGRect)frame
{
    DrawInfo *drawInfo = [DrawInfo defaultDrawInfo];
    /*
    DrawLayer *bgLayer = [[[DrawLayer alloc] initWithFrame:frame
                                                  drawInfo:drawInfo
                                                       tag:BG_LAYER_TAG
                                                      name:NSLS(@"kBGLayer")
                                               suportCache:NO] autorelease];
     */
    DrawLayer *mainLayer = [[[DrawLayer alloc] initWithFrame:frame
                                                  drawInfo:drawInfo
                                                       tag:MAIN_LAYER_TAG
                                                      name:NSLS(@"kMainLayer")
                                               suportCache:NO] autorelease];

//    mainLayer.backgroundColor = [UIColor redColor].CGColor;
    
//    return [NSArray arrayWithObjects:bgLayer, mainLayer, nil];
 
    return [NSArray arrayWithObjects:mainLayer, nil];
}

@end
