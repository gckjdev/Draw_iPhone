//
//  DrawLayer.h
//  TestCodePool
//
//  Created by gamy on 13-7-22.
//  Copyright (c) 2013年 orange. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "DrawInfo.h"
#import "DrawProcessProtocol.h"
#import "Offscreen.h"

#define BG_LAYER_TAG 1
#define MAIN_LAYER_TAG 2
#define DEFAULT_LAYER_TAG 2

@class DrawAction;
@class ClipAction;

@interface DrawLayer : CALayer<DrawProcessProtocol>
{
    CGFloat _finalOpacity;
}

+ (id)layerWithLayer:(DrawLayer *)layer frame:(CGRect)frame;

- (id)initWithFrame:(CGRect)frame
           drawInfo:(DrawInfo *)drawInfo
                tag:(NSUInteger)tag
               name:(NSString *)name
        suportCache:(BOOL)supporCache;

@property(nonatomic, retain)DrawInfo *drawInfo;
@property(nonatomic, retain)Offscreen *offscreen;
@property(nonatomic, retain)NSMutableArray *drawActionList;
@property(nonatomic, retain)NSString *layerName;
@property(nonatomic, assign)ClipAction *clipAction;

@property(nonatomic, assign)NSUInteger layerTag;
@property(nonatomic, retain)ShareDrawInfo *shareDrawInfo;

//CACHED
//supported cached
//only used in draw layer panel.
@property(nonatomic, readonly)BOOL supportCache;
@property(nonatomic, assign)NSUInteger cachedCount; //only used when

- (void)updateFinalOpacity:(CGFloat)opacity;
- (CGFloat)finalOpacity;

- (BOOL)canBeRemoved;
- (BOOL)isMainLayer;
- (BOOL)isBGLayer;

- (void)reset;
- (void)updateWithDrawActions:(NSArray *)actionList;
- (DrawAction *)lastAction;

- (void)updatePBLayerC:(Game__PBLayer *)layer;


- (void)showCleanDataInContext:(CGContextRef)ctx;

+ (NSArray *)defaultLayersWithFrame:(CGRect)frame;
+ (NSArray *)defaultOldLayersWithFrame:(CGRect)frame;
+ (DrawLayer *)layerFromPBLayerC:(Game__PBLayer *)layer;
+ (NSMutableArray *)layersFromPBLayers:(Game__PBLayer **)layers number:(int)number;


@end
