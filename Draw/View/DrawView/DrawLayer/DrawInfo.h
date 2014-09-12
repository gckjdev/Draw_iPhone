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
@class ClipAction;

//Used as draw info setting.

@interface ShareDrawInfo : NSObject

@property(nonatomic, assign)CGFloat alpha;
@property(nonatomic, assign)CGFloat penWidth;

@property(nonatomic, assign)CGFloat eraserAlpha;
@property(nonatomic, assign)CGFloat eraserWidth;

@property(nonatomic, assign)ItemType lastPenType;
@property(nonatomic, assign)NSInteger gridLineNumber;

@property(nonatomic, assign)ItemType penType;

@property(nonatomic, retain)DrawColor *penColor;
@property(nonatomic, retain)DrawColor *eraserColor;

+ (id)defaultShareDrawInfo;

// 根据当前是橡皮擦还是画笔，自动返回对应的宽度、透明度、颜色
- (float)itemWidth;
- (void)setItemWidth:(float)value;
- (float)itemAlpha;
- (void)setItemAlpha:(float)value;
- (DrawColor*)itemColor;

- (void)backToLastDrawMode;

@end

@interface DrawInfo : NSObject

//@property(nonatomic, assign)CGFloat alpha;
//@property(nonatomic, assign)CGFloat penWidth;
//
//@property(nonatomic, assign)CGFloat eraserAlpha;
//@property(nonatomic, assign)CGFloat eraserWidth;
//
//@property(nonatomic, assign)ItemType lastPenType;
//@property(nonatomic, assign)NSInteger gridLineNumber;
//
//@property(nonatomic, assign)ItemType penType;

@property(nonatomic, assign)ShapeType shapeType;

@property(nonatomic, assign)TouchActionType lastDrawType;

@property(nonatomic, assign)TouchActionType touchType;

//@property(nonatomic, retain)DrawColor *penColor;
//@property(nonatomic, retain)DrawColor *eraserColor;

@property(nonatomic, retain)DrawColor *bgColor;
@property(nonatomic, retain)Shadow *shadow;
@property(nonatomic, retain)Gradient *gradient;

//@property(nonatomic, retain)ShareDrawInfo *shareDrawInfo;


@property(nonatomic, assign) BOOL strokeShape;



+ (UIImage *)imageForClipActionType:(TouchActionType)type;
//- (id)initWithShareDrawInfo:(ShareDrawInfo*)shareDrawInfo;
+ (id)defaultDrawInfo; //:(ShareDrawInfo*)shareDrawInfo;

- (void)backToLastDrawMode;

- (BOOL)isSelectorMode;

// 根据当前是橡皮擦还是画笔，自动返回对应的宽度、透明度、颜色
//- (float)itemWidth;
//- (void)setItemWidth:(float)value;
//- (float)itemAlpha;
//- (void)setItemAlpha:(float)value;
//- (DrawColor*)itemColor;

//- (float)alpha;
//- (void)setAlpha:(float)value;
//- (float)penWidth;
//- (void)setPenWidth:(float)value;
//- (ItemType)lastPenType;
//- (void)setLastPenType:(ItemType)value;
//- (ItemType)penType;
//- (void)setPenType:(ItemType)value;
//- (int)gridLineNumber;
//- (void)setGridLineNumber:(int)value;
//- (DrawColor*)penColor;
//- (void)setPenColor:(DrawColor*)penColor;

@end
