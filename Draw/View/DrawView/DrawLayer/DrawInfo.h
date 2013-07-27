//
//  DrawInfo.h
//  Draw
//
//  Created by gamy on 13-7-26.
//
//

#import <Foundation/Foundation.h>
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
@class DrawColor;
@class Gradient;


//Used as draw info setting.

@interface DrawInfo : NSObject

@property(nonatomic, assign)CGFloat alpha;
@property(nonatomic, assign)CGFloat penWidth;

@property(nonatomic, assign)ItemType penType;
@property(nonatomic, assign)ShapeType shapeType;
@property(nonatomic, assign)TouchActionType touchType;

@property(nonatomic, retain)DrawColor *penColor;
@property(nonatomic, retain)DrawColor *bgColor;
@property(nonatomic, retain)Shadow *shadow;
@property(nonatomic, retain)Gradient *gradient;

@property(nonatomic, assign) BOOL strokeShape;

@property(nonatomic, assign) BOOL grid;

+ (id)defaultDrawInfo;

@end
