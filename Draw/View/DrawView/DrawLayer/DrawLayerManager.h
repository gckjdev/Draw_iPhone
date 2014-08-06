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
            didLayer:(DrawLayer *)layer
    changeClipAction:(ClipAction *)action;

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
- (BOOL)selectLayerByTag:(int)layerTag;
- (id)initWithView:(UIView *)view;
- (void)addLayer:(DrawLayer *)layer;
- (void)removeLayer:(DrawLayer *)layer;
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

- (UIImage *)createImageWithBGImage:(UIImage *)bg;

- (void)updateLayersRect:(CGRect)rect;

- (void)genLayerTagAndName:(DrawLayer *)layer;
@end
