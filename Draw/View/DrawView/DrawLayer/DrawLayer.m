//
//  DrawLayer.m
//  TestCodePool
//
//  Created by gamy on 13-7-22.
//  Copyright (c) 2013年 orange. All rights reserved.
//

#import "DrawLayer.h"
#import "DrawAction.h"
#import "GradientAction.h"
#import "ClipAction.h"
#import "PPConfigManager.h"
#import "ChangeBackAction.h"
#import "ChangeBGImageAction.h"
#import "DrawBgManager.h"
#import "GameBasic.pb.h"
#import "DrawUtils.h"
#import "GameBasic.pb-c.h"
#import "Draw.pb-c.h"

@interface DrawLayer()
@property(nonatomic, retain) NSString *drawBgId;

@end

@implementation DrawLayer
@synthesize drawActionList = _drawActionList;
@synthesize drawInfo = _drawInfo;


- (id)init{
    self = [super init];
    if (self) {
        self.drawInfo = [[[DrawInfo alloc] init]autorelease];
        _supportCache = YES;
        _cachedCount = [PPConfigManager minUndoActionCount];
    }
    return self;
}

+ (id)layerWithLayer:(DrawLayer *)layer frame:(CGRect)frame
{
    DrawLayer *dl = [[DrawLayer alloc] initWithFrame:frame
                                            drawInfo:layer.drawInfo
                                                 tag:layer.layerTag
                                                name:layer.layerName
                                         suportCache:layer.supportCache];
    dl.opacity = layer.opacity;
    [dl updateFinalOpacity:layer.finalOpacity];
    return [dl autorelease];
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

        _drawActionList = [[NSMutableArray alloc] init];
        if (_supportCache) {
            _offscreen = [[Offscreen alloc] initWithCapacity:0 rect:self.bounds];
        }
        _cachedCount = [PPConfigManager minUndoActionCount];
        _finalOpacity = 1.0f;
    }
    return self;
}

- (void)dealloc
{
    PPDebug(@"%@ drawlayer dealloc", self);
    PPRelease(_drawActionList);
    PPRelease(_layerName);
    PPRelease(_drawInfo);
    PPRelease(_shareDrawInfo);
    PPRelease(_offscreen);
    [super dealloc];
}



- (void)showCleanDataInContext:(CGContextRef)ctx
{
    if (self.supportCache) {
        [self.offscreen showInContext:ctx];
        
        NSUInteger i = 0;
        NSUInteger offscreenActionCount = self.offscreen.actionCount;
        for (DrawAction *action in _drawActionList) {
            if (i < offscreenActionCount){
                [action clearMemory];
            }
            else{
                [action drawInContext:ctx inRect:self.bounds];
            }
            i++;
        }
        
    }else{
        for (DrawAction *action in _drawActionList) {
            [action drawInContext:ctx inRect:self.bounds];
        }
    }
}

- (void)drawInContext:(CGContextRef)ctx
{
    [self showCleanDataInContext:ctx];
    [self.clipAction showClipInContext:ctx inRect:self.bounds];
    
    [DrawLayer drawGridInContext:ctx
                            rect:self.bounds
                      lineNumber:self.shareDrawInfo.gridLineNumber];
}


#pragma mark-- DrawProcessProtocol

- (void)addDrawAction:(DrawAction *)drawAction show:(BOOL)show redo:(BOOL)redo
{
    //special deal
    if ([drawAction isClipAction]) {
        self.clipAction = (id)drawAction;
    }
    
    if (!redo) {
        drawAction.shadow = [Shadow shadowWithShadow:self.drawInfo.shadow];
        if ([self.clipAction isLegal]) {
            drawAction.clipAction = self.clipAction;
        }
        
        if ([drawAction isGradientAction]) {
            if (self.clipAction) {
                [[(GradientAction *)drawAction gradient] setRect:self.clipAction.pathRect];
            }else{ 
                [[(GradientAction *)drawAction gradient] setRect:self.bounds];
            }
            [[(GradientAction *)drawAction gradient] updatePointsWithDegreeAndDivision];
        }
    }else{
        if (![drawAction isClipAction] && ![[drawAction clipAction] isLegal]) {
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
    if (show) {
//        PPDebug(@"<setNeedsDisplayInRect> %@", NSStringFromCGRect(rect));
        [self setNeedsDisplayInRect:rect];
    }


}

//start to add a new draw action
- (void)addDrawAction:(DrawAction *)drawAction show:(BOOL)show
{
//    PPDebug(@"<DrawLayer> name = %@, addDrawAction", self.layerName);
    [self addDrawAction:drawAction show:show redo:NO];
}

//update the last action
- (void)updateLastAction:(DrawAction *)action refresh:(BOOL)refresh
{
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
        NSUInteger count = [_drawActionList count];
        if(count - self.offscreen.actionCount > _cachedCount * 2){
            PPDebug(@"<finishLastAction> action count = %d, reach cached count", count);
            NSUInteger endIndex = count - _cachedCount;
            for(NSUInteger i = _offscreen.actionCount; i < endIndex; ++ i){
                DrawAction *drawAction = [_drawActionList objectAtIndex:i];
                [self.offscreen drawAction:drawAction clear:NO];
                [drawAction clearMemory];
            }
        }
    }
    
    if (refresh) {
        [self setNeedsDisplayInRect:[action redrawRectInRect:self.bounds]];
    }    
}

- (void)updateClipAction
{
    DrawAction *lastAction = [self.drawActionList lastObject];
    if ([lastAction isClipAction] && [(ClipAction *)lastAction isLegal]) {
        self.clipAction = (id)lastAction;
    }else{
        self.clipAction = lastAction.clipAction;
    }
}

//remove the last action force to refresh
- (void)cancelLastAction
{
    DrawAction *lastAction = [self.drawActionList lastObject];    
    if (lastAction) {
        [self.drawActionList removeLastObject];
        [self updateClipAction];
        [self setNeedsDisplay];
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
    self.offscreen = [Offscreen offscreenWithCapacity:0 rect:self.bounds];
}



- (void)updateWithDrawActions:(NSArray *)actionList
{
    if ([actionList isKindOfClass:[NSMutableArray class]]) {
        self.drawActionList = (id)actionList;
    }else{
        self.drawActionList = [NSMutableArray arrayWithArray:actionList];
    }
    
    if (_supportCache) {
        PPDebug(@"<updateWithDrawActions> start");
        NSUInteger count = [_drawActionList count];
        time_t timestamp = time(0);
        [self.offscreen clear];
        if(count - self.offscreen.actionCount >= _cachedCount * 2){
            NSUInteger endIndex = count - _cachedCount;

            for(NSUInteger i = _offscreen.actionCount; i < endIndex; ++ i){
                DrawAction *drawAction = _drawActionList[i];
                [self.offscreen drawAction:drawAction clear:NO];
                [drawAction clearMemory];
            }
        }

        PPDebug(@"<updateWithDrawActions>added count = %d, finish to show. spend: %d", _offscreen.actionCount, time(0)-timestamp);
    }
    [self updateClipAction];
}

//clip action
- (void)enterClipMode:(ClipAction *)clipAction
{
    self.clipAction = clipAction;
}
- (void)exitFromClipMode
{
    self.clipAction = nil;
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
            return [_drawActionList count] - [_offscreen actionCount] > 0;
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
        [self updateClipAction];        
        [self setNeedsDisplay];
        return action;
    }
    return nil;
}

- (CGFloat)finalOpacity
{
    return _finalOpacity;
}

- (void)updateFinalOpacity:(CGFloat)opacity
{
    _finalOpacity = opacity;
}



- (BOOL)canBeRemoved
{
    NSArray *retainTags = @[@(DEFAULT_LAYER_TAG)];
    return ![retainTags containsObject:@(self.layerTag)];
}

- (BOOL)isBGLayer
{
    return BG_LAYER_TAG == self.layerTag;
}

- (BOOL)isMainLayer
{
    return self.layerTag == MAIN_LAYER_TAG || self.layerTag == DEFAULT_LAYER_TAG;
}

+ (NSArray *)defaultLayersWithFrame:(CGRect)frame
{
    DrawInfo *drawInfo = [DrawInfo defaultDrawInfo];
    
    DrawLayer *bgLayer = [[[DrawLayer alloc] initWithFrame:frame
                                                  drawInfo:drawInfo
                                                       tag:BG_LAYER_TAG
                                                      name:NSLS(@"kBGLayer")
                                               suportCache:YES] autorelease];
     
    DrawLayer *mainLayer = [[[DrawLayer alloc] initWithFrame:frame
                                                  drawInfo:drawInfo
                                                       tag:MAIN_LAYER_TAG
                                                      name:NSLS(@"kMainLayer")
                                               suportCache:YES] autorelease];
    return @[bgLayer, mainLayer];
}

+ (NSArray *)defaultOldLayersWithFrame:(CGRect)frame
{
    DrawInfo *drawInfo = [DrawInfo defaultDrawInfo];
    
    DrawLayer *bgLayer = [[[DrawLayer alloc] initWithFrame:frame
                                                  drawInfo:drawInfo
                                                       tag:BG_LAYER_TAG
                                                      name:NSLS(@"kBGLayer")
                                               suportCache:YES] autorelease];
    
    DrawLayer *defaultLayer = [[[DrawLayer alloc] initWithFrame:frame
                                                    drawInfo:drawInfo
                                                         tag:DEFAULT_LAYER_TAG
                                                        name:NSLS(@"kMainLayer")
                                                 suportCache:YES] autorelease];
    
    return @[bgLayer, defaultLayer];

}

#define VALUE(X) (ISIPAD?(2*X):X)

+ (void)drawGridInContext:(CGContextRef)context
                     rect:(CGRect)rect
               lineNumber:(NSInteger)lineNumber
{
    if (lineNumber <= 0) {
        return;
    }
    CGFloat LINE_SPACE = rect.size.width/lineNumber;
    
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

+ (DrawLayer *)layerFromPBLayerC:(Game__PBLayer *)layer
{
    float *r = layer->rectcomponent;
    CGRect rect = CGRectMake(r[0], r[1], r[2], r[3]);
    NSString *name = [NSString stringWithUTF8String:layer->name];

    BOOL cached = YES;
    
    DrawLayer *l = [[DrawLayer alloc] initWithFrame:rect
                                           drawInfo:nil
                                                tag:layer->tag
                                               name:name
                                        suportCache:cached];
    l.opacity = layer->alpha;
    [l updateFinalOpacity:layer->alpha];
    return [l autorelease];
}
- (void)updatePBLayerC:(Game__PBLayer *)layer
{
    layer->tag = self.layerTag;
    layer->has_alpha = 1;
    layer->alpha = self.opacity;
    
    layer->name = (char *)[self.layerName UTF8String];
    layer->n_rectcomponent = 4;
    layer->rectcomponent = malloc(sizeof(float) * 4);
    float *r = layer->rectcomponent;
    r[0] = CGRectGetMinX(self.frame);
    r[1] = CGRectGetMinY(self.frame);
    r[2] = CGRectGetWidth(self.frame);
    r[3] = CGRectGetHeight(self.frame);
        
}

+ (NSMutableArray *)layersFromPBLayers:(Game__PBLayer **)layers number:(int)number
{
    if (number <= 0) {
        return nil;
    }
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:number];
    for (int i = 0; i < number; ++i) {
        Game__PBLayer *layer = layers[i];
        DrawLayer *dl = [DrawLayer layerFromPBLayerC:layer];
        [array addObject:dl];
    }
    return array;
}
@end
