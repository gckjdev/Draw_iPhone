//
//  DrawAction.h
//  Draw
//
//  Created by  on 12-3-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ItemType.h"

@class Paint;
@class PBDrawAction;
@class DrawColor;
@class PBNoCompressDrawAction;
@class PBNoCompressDrawData;
@class PBShapeInfo;
@class ShapeInfo;


typedef enum {
    
    DRAW_ACTION_TYPE_DRAW,
    DRAW_ACTION_TYPE_CLEAN,
    DRAW_ACTION_TYPE_SHAPE,
} DRAW_ACTION_TYPE;

@interface DrawAction : NSObject <NSCoding>{
    Paint *_paint;
}

@property (nonatomic, assign) DRAW_ACTION_TYPE type;
@property (nonatomic, retain) Paint *paint;
@property (nonatomic, retain) ShapeInfo *shapeInfo;

- (id)initWithPBNoCompressDrawAction:(PBNoCompressDrawAction *)action dataVersion:(int)dataVersion;
- (PBNoCompressDrawAction *)toPBNoCompressDrawAction;

- (NSInteger)pointCount;
- (id)initWithPBDrawAction:(PBDrawAction *)action;
- (id)initWithType:(DRAW_ACTION_TYPE)aType paint:(Paint*)aPaint;

+ (DrawAction *)actionWithType:(DRAW_ACTION_TYPE)aType paint:(Paint*)aPaint;
+ (DrawAction *)changeBackgroundActionWithColor:(DrawColor *)color;
+ (DrawAction *)clearScreenAction;


+ (BOOL)isDrawActionListBlank:(NSArray *)actionList;
+ (NSMutableArray *)getTheLastActionListWithoutClean:(NSArray *)actionList;
+ (DrawAction *)scaleAction:(DrawAction *)action 
                      xScale:(CGFloat)xScale 
                     yScale:(CGFloat)yScale;

+ (NSMutableArray *)scaleActionList:(NSArray *)list 
                       xScale:(CGFloat)xScale 
                      yScale:(CGFloat)yScale;


+ (NSInteger)pointCountForActions:(NSArray *)actionList;
+ (double)calculateSpeed:(NSArray *)actionList;
+ (double)calculateSpeed:(NSArray *)actionList defaultSpeed:(double)defaultSpeed maxSecond:(NSInteger)second;


+ (NSMutableArray *)pbNoCompressDrawDataToDrawActionList:(PBNoCompressDrawData *)data;
+ (PBNoCompressDrawData *)drawActionListToPBNoCompressDrawData:(NSArray *)drawActionList;

- (BOOL)isChangeBackAction;
- (BOOL)isCleanAction;
- (BOOL)isDrawAction;

@end



#pragma mark -- Shape Info

typedef enum{
    ShapeTypeBeeline,
    ShapeTypeRectangle,
    ShapeTypeEllipse,
    ShapeTypeStar,
    ShapeTypeTriangle
}ShapeType;

@interface ShapeInfo : NSObject
{
    
}

@property(nonatomic, assign)CGPoint startPoint;
@property(nonatomic, assign)CGPoint endPoint;

@property(nonatomic, assign)ItemType penType;
@property(nonatomic, assign)ShapeType type;
@property(nonatomic, assign)CGFloat width;

@property(nonatomic, retain)DrawColor *color;

+ (id)shapeWithPBShapeInfo:(PBShapeInfo *)shapeInfo;
- (void)drawInContext:(CGContextRef)context;
- (CGRect)rect;
- (PBShapeInfo *)toPBShape;
@end
