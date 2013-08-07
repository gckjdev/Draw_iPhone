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

@interface DrawLayerManager()
{
    NSMutableArray *_layerList;
}
@property(nonatomic, retain)UIView *view;

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

- (NSUInteger)nextTag
{
    NSUInteger mt = 0;
    for (DrawLayer *layer in _layerList) {
        mt = MAX(mt, layer.layerTag);
    }
    return mt + 1;
}

- (void)addLayer:(DrawLayer *)layer
{
    PPDebug(@"<addLayer> layer name = %@", layer.layerName);
    if (layer && ![_layerList containsObject:layer]) {
        [_layerList addObject:layer];
        [self.view.layer addSublayer:layer];
        self.selectedLayer = layer;
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
        [self setSelectedLayer:[_layerList lastObject]];
    }
    
    
}
- (DrawLayer *)addLayerWithTag:(NSUInteger)tag name:(NSString *)name
{
    DrawLayer *layer = [[[DrawLayer alloc] init] autorelease];
    layer.layerTag = [self nextTag];
    layer.layerName = name;
    layer.frame = self.view.bounds;
    [self addLayer:layer];
    return layer;
}

- (DrawLayer *)layerWithTag:(NSUInteger)tag
{
    if (self.selectedLayer.layerTag == tag) {
        return self.selectedLayer;
    }
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
    for (DrawLayer *layer in _layerList) {
        [_view.layer addSublayer:layer];
        [layer setNeedsDisplay];
    }
}

- (void)dealloc
{
    PPRelease(_layerList);
    PPRelease(_view);
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
    return [layer undoDrawAction:action];
}

- (DrawAction *)redoDrawAction:(DrawAction *)action
{
    DrawLayer *layer = [self layerWithTag:action.layerTag];
    return [layer redoDrawAction:action];
}

- (void)enterClipMode:(ClipAction *)clipAction
{
    [self.selectedLayer enterClipMode:clipAction];
}
- (void)exitFromClipMode
{
    [self.selectedLayer exitFromClipMode];
}

- (void)updateLayers:(NSArray *)layers
{
    for (DrawLayer *layer in _layerList) {
        [layer removeFromSuperlayer];
    }
    
    [_layerList removeAllObjects];
    
    for (DrawLayer *layer in layers) {
        [self addLayer:layer];
        [self setSelectedLayer:layer];
    }
}

- (void)setSelectedLayer:(DrawLayer *)selectedLayer
{
    [self.delegate layerManager:self
         didChangeSelectedLayer:selectedLayer
                      lastLayer:_selectedLayer];
    _selectedLayer = selectedLayer;
}

- (UIImage *)createImageWithBGImage:(UIImage *)bg
{
    UIImage *image;
    UIGraphicsBeginImageContext(self.view.bounds.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[UIColor whiteColor] setFill];
    CGContextFillRect(ctx, self.view.bounds);
    [bg drawAtPoint:CGPointZero];
    for (DrawLayer *layer in _layerList) {
        [layer showCleanDataInContext:ctx];
    }
    
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
        [layer removeFromSuperlayer];
    }
    [_layerList removeAllObjects];
    for (DrawLayer *layer in newLayers) {
        [self addLayer:layer];
    }

}

@end


