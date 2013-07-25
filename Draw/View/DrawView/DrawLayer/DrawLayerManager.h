//
//  DrawLayerManager.h
//  Draw
//
//  Created by gamy on 13-7-23.
//
//

#import <Foundation/Foundation.h>
#import "DrawLayer.h"

@class DrawAction;
@class DrawLayer;

@interface DrawLayerManager : NSObject<DrawProcessProtocol>
{
    
}
@property(nonatomic, assign)DrawLayer *selectedLayer;


- (void)selectLayer:(DrawLayer *)layer;
- (id)initWithView:(UIView *)view;
- (void)addLayer:(DrawLayer *)layer;
- (void)removeLayer:(DrawLayer *)layer;
- (DrawLayer *)addLayerWithTag:(NSUInteger)tag;
- (DrawLayer *)layerWithTag:(NSUInteger)tag;
- (void)removeLayerWithTag:(NSUInteger)tag;
- (void)bringLayerToFront:(DrawLayer *)layer;
- (void)moveLayer:(DrawLayer *)layer1 below:(DrawLayer *)layer2; //if layer2 is nil, then move layer1 to the front.
- (void)reload;
- (void)resetAllLayers;

- (NSArray *)layers;

//key = layerTag, value = actionList
- (void)arrangeActions:(NSArray *)actions;

- (DrawAction *)undoWithDrawAction:(DrawAction *)action;

- (DrawAction *)redoWithDrawAction:(DrawAction *)action;


@end
