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
#import "Draw.pb-c.h"
#import "Shadow.h"

@class PBBBSDraw;
@class PBMessage;
@class Word;
//@class Shadow;

typedef enum {
    
    DrawActionTypePaint,            //Paint Action 0
    DrawActionTypeClean,            //Clean Action 1 //new version without it
    DrawActionTypeShape,            //Shape Action 2
    DrawActionTypeChangeBack,       //Change bg with color 3
    DrawActionTypeChangeBGImage,    //Change bg with pb draw bg 4

    DrawActionTypeGradient,             //Gradient 5
    DrawActionTypeClip,             //Clip 6
    
} DrawActionType;

//#define BACK_GROUND_WIDTH 5000

@interface DrawAction : NSObject {
//    Paint *_paint;
}


@property(nonatomic, assign)DrawActionType type;
@property(nonatomic, assign)NSInteger clipTag;
@property(nonatomic, assign, readonly) BOOL hasFinishAddPoint;
@property(nonatomic, retain)Shadow *shadow;

//@property(nonatomic, assign)CGSize canvasSize;

- (void)setCanvasSize:(CGSize)canvasSize;

+ (id)drawActionWithPBDrawAction:(PBDrawAction *)action;
+ (id)drawActionWithPBDrawActionC:(Game__PBDrawAction *)action;

//deprecated
+ (id)drawActionWithPBNoCompressDrawAction:(PBNoCompressDrawAction *)action;

//deprecated
+ (NSMutableArray *)pbNoCompressDrawDataToDrawActionList:(PBNoCompressDrawData *)data
                                              canvasSize:(CGSize)canvasSize;

+ (NSMutableArray *)pbNoCompressDrawDataCToDrawActionList:(Game__PBNoCompressDrawData *)data
                                               canvasSize:(CGSize)canvasSize;


+ (PBNoCompressDrawData *)pbNoCompressDrawDataFromDrawActionList:(NSArray *)drawActionList
                                                            size:(CGSize)size
                                                      drawToUser:(PBUserBasicInfo *)drawToUser
                                                 bgImageFileName:(NSString *)bgImageFileName;

+ (PBNoCompressDrawData *)pbNoCompressDrawDataFromDrawActionList:(NSArray *)drawActionList
                                                            size:(CGSize)size
                                                        opusDesc:(NSString *)opusDesc
                                                      drawToUser:(PBUserBasicInfo *)drawToUser
                                                 bgImageFileName:(NSString *)bgImageFileName;


+ (NSData *)pbNoCompressDrawDataCFromDrawActionList:(NSArray *)drawActionList
                                               size:(CGSize)size
                                           opusDesc:(NSString *)opusDesc
                                         drawToUser:(PBUserBasicInfo *)drawToUser
                                    bgImageFileName:(NSString *)bgImageFileName;

+ (NSData*)buildPBDrawData:(NSString*)userId
                      nick:(NSString *)nick
                    avatar:(NSString *)avatar
            drawActionList:(NSArray*)drawActionList
                  drawWord:(Word*)drawWord
                  language:(int)language
                      size:(CGSize)size
              isCompressed:(BOOL)isCompressed;


+ (void)freePBDrawActionC:(Game__PBDrawAction**)pbDrawActionC count:(int)count;

+ (NSMutableArray *)drawActionListFromPBBBSDraw:(PBBBSDraw *)bbsDraw;
+ (NSMutableArray *)drawActionListFromPBMessage:(PBMessage *)message;

+ (NSData *)buildBBSDrawData:(NSArray *)drawActionList canvasSize:(CGSize)size;

- (NSData *)toData;

//new Method should overload by sub classes..


- (id)initWithPBDrawAction:(PBDrawAction *)action;//deprecated
- (id)initWithPBDrawActionC:(Game__PBDrawAction *)action;

- (id)initWithPBNoCompressDrawAction:(PBNoCompressDrawAction *)action;//deprecated

- (id)initWithPBNoCompressDrawActionC:(Game__PBNoCompressDrawAction *)action;


- (void)toPBDrawActionC:(Game__PBDrawAction*)pbDrawActionC;
- (void)addPoint:(CGPoint)point inRect:(CGRect)rect;

- (CGRect)drawInContext:(CGContextRef)context inRect:(CGRect)rect;

- (NSUInteger)pointCount;
- (void)finishAddPoint;
- (CGRect)redrawRectInRect:(CGRect)rect;


- (PBDrawAction *)toPBDrawAction; //deprecated


@end



@interface PBNoCompressDrawAction (Ext)

- (DrawColor *)drawColor;

@end



