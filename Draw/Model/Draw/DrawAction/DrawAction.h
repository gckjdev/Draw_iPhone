//
//  DrawAction.h
//  Draw
//
//  Created by  on 12-3-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Draw.pb.h"
#import "DrawUtils.h"
//#import "ShapeAction.h"
//#import "CleanAction.h"
//#import "PaintAction.h"
//#import "ChangeBackAction.h"

//#import "ItemType.h"
//#import "ShapeInfo.h"

//@class Paint;
//@class PBDrawAction;
//@class DrawColor;
//@class PBNoCompressDrawAction;
//@class PBNoCompressDrawData;
//@class PBDrawBg;


typedef enum {
    
    DrawActionTypePaint,
    DrawActionTypeClean,
    DrawActionTypeShape,
    DrawActionTypeChangeBack, //use only in the client, should not send it to the server...
} DrawActionType;

//#define BACK_GROUND_WIDTH 5000

@interface DrawAction : NSObject {
//    Paint *_paint;
}


@property(nonatomic, assign)DrawActionType type;
@property(nonatomic, assign, readonly) BOOL hasFinishAddPoint;
/*
@property (nonatomic, assign) DrawActionType type;
@property (nonatomic, retain) Paint *paint;
@property (nonatomic, retain) ShapeInfo *shapeInfo;

- (id)initWithPBNoCompressDrawAction:(PBNoCompressDrawAction *)action dataVersion:(int)dataVersion;
- (PBNoCompressDrawAction *)toPBNoCompressDrawAction;

- (NSInteger)pointCount;
- (id)initWithPBDrawAction:(PBDrawAction *)action;
- (id)initWithType:(DrawActionType)aType paint:(Paint*)aPaint;

+ (DrawAction *)actionWithType:(DrawActionType)aType paint:(Paint*)aPaint;
+ (DrawAction *)actionWithShpapeInfo:(ShapeInfo *)shapeInfo;


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
+ (PBNoCompressDrawData *)drawActionListToPBNoCompressDrawData:(NSArray *)drawActionList pbdrawBg:(PBDrawBg *)drawBg size:(CGSize)size;

- (BOOL)isChangeBackAction;
- (BOOL)isCleanAction;
- (BOOL)isDrawAction;
- (BOOL)isShapeAction;

*/
//new Method should overload by sub classes..

+ (id)drawActionWithPBDrawAction:(PBDrawAction *)action;
+ (id)drawActionWithPBNoCompressDrawAction:(PBNoCompressDrawAction *)action;

+ (NSMutableArray *)pbNoCompressDrawDataToDrawActionList:(PBNoCompressDrawData *)data;

+ (PBNoCompressDrawData *)pbNoCompressDrawDataFromDrawActionList:(NSArray *)drawActionList
                                                        pbdrawBg:(PBDrawBg *)drawBg
                                                            size:(CGSize)size
                                                      drawToUser:(PBUserBasicInfo *)drawToUser;

- (id)initWithPBDrawAction:(PBDrawAction *)action;
- (id)initWithPBNoCompressDrawAction:(PBNoCompressDrawAction *)action;


- (PBDrawAction *)toPBDrawAction;
- (void)addPoint:(CGPoint)point inRect:(CGRect)rect;

- (CGRect)drawInContext:(CGContextRef)context inRect:(CGRect)rect;

- (NSUInteger)pointCount;
- (void)finishAddPoint;
@end



@interface PBNoCompressDrawAction (Ext)

- (DrawColor *)drawColor;

@end