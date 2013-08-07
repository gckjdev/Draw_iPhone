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

@class DrawLayerManager;

@protocol DrawLayerManagerDelegate <NSObject>


- (void)layerManager:(DrawLayerManager *)manager
didChangeSelectedLayer:(DrawLayer *)selectedLayer
           lastLayer:(DrawLayer *)lastLayer;

@end

@interface DrawLayerManager : NSObject<DrawProcessProtocol>
{
    
}
@property(nonatomic, assign)DrawLayer *selectedLayer;
@property(nonatomic, assign)id<DrawLayerManagerDelegate> delegate;

- (void)selectLayer:(DrawLayer *)layer;
- (id)initWithView:(UIView *)view;
- (void)addLayer:(DrawLayer *)layer;
- (void)removeLayer:(DrawLayer *)layer;
- (DrawLayer *)addLayerWithTag:(NSUInteger)tag name:(NSString *)name;
- (DrawLayer *)layerWithTag:(NSUInteger)tag;
- (void)removeLayerWithTag:(NSUInteger)tag;
- (void)reload;
- (void)resetAllLayers;

- (NSArray *)layers;

- (void)arrangeActions:(NSArray *)actions;

- (DrawAction *)undoDrawAction:(DrawAction *)action;

- (DrawAction *)redoDrawAction:(DrawAction *)action;

- (void)updateLayers:(NSArray *)layers;

- (void)refresh;

- (UIImage *)createImage;

- (void)updateLayersRect:(CGRect)rect;
@end
