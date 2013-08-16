//
//  DrawLayerManager.m
//  Draw
//
//  Created by gamy on 13-7-23.
//
//

#import "DrawLayerManager.h"

#import "DrawLayer.h"
#import "DrawAction.h"
#import "DrawView.h"
#import "NSArray+Ext.h"



@interface DrawLayerManager()
{
    NSMutableArray *_layerList;
}
@property(nonatomic, assign)UIView *view;

@end



@implementation DrawLayerManager

- (id)initWithView:(UIView *)view
{
    self = [super init];
    if (self) {
        _layerList = [[NSMutableArray array] retain];
        self.view = view;
    }
    
    return self;
}

#define CUSTOM_TAG_BASE 10
- (NSUInteger)nextTag
{
    NSUInteger mt = CUSTOM_TAG_BASE;
    for (DrawLayer *layer in _layerList) {
        mt = MAX(mt, layer.layerTag + 1);
    }
    return mt;
}

- (void)addLayer:(DrawLayer *)layer
{
    PPDebug(@"<addLayer> layer name = %@", layer.layerName);
    if (layer && ![_layerList containsObject:layer]) {
        [_layerList insertObject:layer atIndex:0];
        [self.view.layer addSublayer:layer];
    }
}
- (void)removeLayer:(DrawLayer *)layer
{
    if (layer) {
        if (self.selectedLayer == layer) {
            self.selectedLayer = nil;
        }
        
        //Remove Actions from draw view action list
        if ([self.view isKindOfClass:[DrawView class]]) {
            NSMutableArray *totalActions = [(DrawView *) self.view drawActionList];
            [totalActions removeObjectsInArray:layer.drawActionList];
        }
        
        [_layerList removeObject:layer];
        [layer removeFromSuperlayer];

    }
    if (self.selectedLayer == nil) {
        for (DrawLayer *layer in _layerList) {
            if ([layer isMainLayer]) {
                [self setSelectedLayer:layer];
                return;
            }
        }
        [self setSelectedLayer:[_layerList firstObject]];
    }
    
    
}

- (DrawLayer *)layerWithTag:(NSUInteger)tag
{
    for (DrawLayer *layer in _layerList) {
        if(layer.layerTag == tag){
            return layer;
        }
    }
    return self.selectedLayer;
}

- (void)removeLayerWithTag:(NSUInteger)tag
{
    DrawLayer *target = nil;
    for (DrawLayer *layer in _layerList) {
        if (layer.layerTag == tag) {
            target = layer;
        }
    }
    [self removeLayer:target];
}


- (void)selectLayer:(DrawLayer *)layer
{
    self.selectedLayer = layer;
}

- (void)reload
{
    NSMutableSet *set = [NSMutableSet set];
    for (DrawLayer *layer in _view.layer.sublayers) {
        if ([layer isKindOfClass:[DrawLayer class]]) {
            [set addObject:layer];
        }
    }
    for (DrawLayer *layer in set) {
        [layer removeFromSuperlayer];
    }
    
    [_layerList reversEnumWithHandler:^(id object) {
        [_view.layer addSublayer:object];
    }];
}

- (void)dealloc
{
    PPDebug(@"%@ dealloc", self);
    PPRelease(_layerList);
    [super dealloc];
}

- (void)resetAllLayers
{
    for (DrawLayer *layer in _layerList) {
        [layer reset];
        [layer setNeedsDisplay];
    }
}

- (void)refresh
{
    for (DrawLayer *layer in _layerList) {
        [layer setNeedsDisplay];
    }
}


- (NSArray *)layers
{
    return [[_layerList retain] autorelease];
}

- (void)arrangeActions:(NSArray *)actions
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:[_layerList count]];
    for (DrawLayer *layer in _layerList) {
        [dict setObject:[NSMutableArray array] forKey:@(layer.layerTag)];
    }
    for (DrawAction *action in actions) {
        NSMutableArray *array = [dict objectForKey:@(action.layerTag)];
        [array addObject:action];
    }
    for (DrawLayer *layer in _layerList) {
        PPDebug(@"<arrangeActions> layer name = %@", layer.layerName);
        [layer reset];
        NSMutableArray *array = [dict objectForKey:@(layer.layerTag)];
        [layer updateWithDrawActions:array];
        [layer setNeedsDisplay];
    }
}

//start to add a new draw action
- (void)addDrawAction:(DrawAction *)drawAction show:(BOOL)show
{
    DrawLayer *layer = [self layerWithTag:drawAction.layerTag];
    [layer addDrawAction:drawAction show:show];
}

//update the last action
- (void)updateLastAction:(DrawAction *)action refresh:(BOOL)refresh
{
    DrawLayer *layer = [self layerWithTag:action.layerTag];
    [layer updateLastAction:action refresh:refresh];
}

//finish update the last action
- (void)finishLastAction:(DrawAction *)action refresh:(BOOL)refresh
{
    DrawLayer *layer = [self layerWithTag:action.layerTag];
    [layer finishLastAction:action refresh:refresh];
}

//remove the last action force to refresh
- (void)cancelLastAction
{
    DrawLayer *layer = [self selectedLayer];
    [layer cancelLastAction];
}

- (DrawAction *)undoDrawAction:(DrawAction *)action
{
    DrawLayer *layer = [self layerWithTag:action.layerTag];
    DrawAction *retAction = [layer undoDrawAction:action];
    
    return retAction;
}

- (DrawAction *)redoDrawAction:(DrawAction *)action
{
    DrawLayer *layer = [self layerWithTag:action.layerTag];
    return [layer redoDrawAction:action];
}

- (void)enterClipMode:(ClipAction *)clipAction
{
    [self.selectedLayer enterClipMode:clipAction];
//    [self.delegate layerManager:self didLayer:self.selectedLayer changeClipAction:clipAction];
}
- (void)exitFromClipMode
{
    [self.selectedLayer exitFromClipMode];
//    [self.delegate layerManager:self didLayer:self.selectedLayer changeClipAction:nil];
}

- (void)updateLayers:(NSArray *)layers
{
    for (DrawLayer *layer in _layerList) {
        [layer removeFromSuperlayer];
    }
    _selectedLayer = nil;
    [_layerList removeAllObjects];
    
    if ([layers count] != 0) {
        [layers reversEnumWithHandler:^(id object) {
            DrawLayer *layer = object;
            [self addLayer:layer];
            if ([layer isMainLayer]) {
                [self setSelectedLayer:layer];
            }
        }];
        
        if (self.selectedLayer == nil) {
            self.selectedLayer = [_layerList firstObject];
        }
    }
}

- (void)setSelectedLayer:(DrawLayer *)selectedLayer
{
    DrawLayer *oldLayer = [[_selectedLayer retain] autorelease];
    _selectedLayer = selectedLayer;
    [self.delegate layerManager:self
         didChangeSelectedLayer:selectedLayer
                      lastLayer:oldLayer];

}

- (UIImage *)createImageWithBGImage:(UIImage *)bg
{
    UIImage *image;
    UIGraphicsBeginImageContext(self.view.bounds.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[UIColor whiteColor] setFill];
    CGContextFillRect(ctx, self.view.bounds);
    [bg drawAtPoint:CGPointZero];
    
    [_layerList reversEnumWithHandler:^(id object) {
        DrawLayer *layer= object;
        CGContextSaveGState(ctx);

        ClipAction *clip = [layer clipAction];
        BOOL grid = [[layer drawInfo] grid];
        if (clip != nil || !grid) {
            layer.clipAction = nil;
            layer.drawInfo.grid = NO;
            [layer setNeedsDisplay];
            
            [layer renderInContext:ctx];
            
            [layer setClipAction:clip];
            
            [layer.drawInfo setGrid:grid];
            [layer setNeedsDisplay];
        }else{
            [layer renderInContext:ctx];
        }
        CGContextRestoreGState(ctx);
    }];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

- (void)updateLayersRect:(CGRect)rect
{
    NSMutableArray *newLayers = [NSMutableArray arrayWithCapacity:[_layerList count]];
    for (DrawLayer *layer in _layerList) {
        DrawLayer *l = [DrawLayer layerWithLayer:layer frame:rect];
        [newLayers addObject:l];
    }
    [self updateLayers:newLayers];
}

- (void)genLayerTagAndName:(DrawLayer *)layer
{
    layer.layerTag = [self nextTag];
    NSInteger index = 0;
    for (DrawLayer *l in _layerList) {
        if ([l.layerName hasPrefix:NSLS(@"kNewLayerName")]) {
            NSArray *array = [l.layerName componentsSeparatedByString:@" "];
            if ([array count] == 2) {
                index = MAX(index, [[array lastObject] integerValue] + 1);
            }else if([array count] == 1){
                index = MAX(index, 1);
            }
        }
    }
    if (index < 1) {
        layer.layerName = NSLS(@"kNewLayerName");
    }else{
      layer.layerName = [NSString stringWithFormat:@"%@ %d", NSLS(@"kNewLayerName"), index];
    }
}

@end


