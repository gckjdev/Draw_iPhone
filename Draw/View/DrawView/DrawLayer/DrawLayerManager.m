//
//  DrawLayerManager.m
//  Draw
//
//  Created by gamy on 13-7-23.
//
//

#import "DrawLayerManager.h"

#import "DrawLayer.h"


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
        _layerList = [[NSMutableArray alloc] initWithCapacity:5];
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
    if (layer && ![_layerList containsObject:layer]) {
        [_layerList addObject:layer];
        [self.view.layer addSublayer:layer];
        self.selectedLayer = layer;
    }
}
- (void)removeLayer:(DrawLayer *)layer
{
    if (layer) {
        [_layerList removeObject:layer];
        [layer removeFromSuperlayer];
    }
}
- (DrawLayer *)addLayerWithTag:(NSUInteger)tag
{
    DrawLayer *layer = [[[DrawLayer alloc] init] autorelease];
    layer.layerTag = [self nextTag];
    layer.frame = self.view.bounds;
    [self addLayer:layer];
    return layer;
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

- (void)bringLayerToFront:(DrawLayer *)layer
{
    DrawLayer *l = [layer retain];
    [self removeLayer:layer];
    [self addLayer:l];
    [l release];
}

- (void)moveLayer:(DrawLayer *)layer1 below:(DrawLayer *)layer2
{
    if (!layer1 || layer1 == layer2) {
        return;
    }
    if ([_layerList containsObject:layer1] &&([_layerList containsObject:layer2] || layer2 == nil)) {
        
        if (layer2) {
            [self removeLayer:layer1];
            NSUInteger l2 = [_layerList indexOfObject:layer2];
            
            [_layerList insertObject:layer1 atIndex:l2];
            [_view.layer insertSublayer:layer1 below:layer2];
        }else{
            [self removeLayer:layer1];
            [self addLayer:layer1];
        }
    }
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
    }
}

- (void)dealloc
{
    PPRelease(_layerList);
    PPRelease(_view);
    [super dealloc];
}


@end


