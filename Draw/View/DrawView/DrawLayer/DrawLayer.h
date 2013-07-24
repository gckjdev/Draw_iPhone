//
//  DrawLayer.h
//  TestCodePool
//
//  Created by gamy on 13-7-22.
//  Copyright (c) 2013年 orange. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ItemType.h"
#import "ShapeInfo.h"


typedef enum{
    
    TouchActionTypeDraw = 0,
    TouchActionTypeGetColor = 1,
    TouchActionTypeShape = 2,
    TouchActionTypeClipPath = 3,
    TouchActionTypeClipPolygon = 4,
    TouchActionTypeClipEllipse = 5,
    TouchActionTypeClipRectangle = 6,
    
}TouchActionType;


@class Shadow;
//@class Gradient;

@interface DrawInfo : NSObject

@property(nonatomic, assign)CGFloat alpha;
@property(nonatomic, assign)CGFloat penWidth;

@property(nonatomic, assign)ItemType penType;
@property(nonatomic, assign)ShapeType shapeType;
@property(nonatomic, assign)TouchActionType touchType;

@property(nonatomic, retain)DrawColor *penColor;
@property(nonatomic, retain)DrawColor *bgColor;
@property(nonatomic, retain)Shadow *shadow;

@property(nonatomic, assign) BOOL strokeShape;



@end



@class CacheDrawManager;
@class DrawAction;

@interface DrawLayer : CALayer
{
    
}


@property(nonatomic, retain)DrawInfo *drawInfo;
@property(nonatomic, retain)CacheDrawManager *cdManager;
@property(nonatomic, retain)NSMutableArray *drawActionList;
@property(nonatomic, retain)NSString *layerName;

@property(nonatomic, assign)NSUInteger layerTag;
@property(nonatomic, assign)BOOL supportCache;
//@property(nonatomic, assign)DrawAction *lastAction;

- (void)addDrawAction:(DrawAction *)action show:(BOOL)show;
- (void)updateLastAction:(DrawAction *)action refresh:(BOOL)refresh;
- (void)finishLastAction;



@end
