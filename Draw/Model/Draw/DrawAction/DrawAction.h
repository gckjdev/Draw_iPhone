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


typedef enum {
    
    DrawActionTypePaint,//0
    DrawActionTypeClean,//1
    DrawActionTypeShape,//2
    DrawActionTypeChangeBack, //change bg with color//3
    DrawActionTypeChangeBGImage, //change bg with pb draw bg//4
} DrawActionType;

//#define BACK_GROUND_WIDTH 5000

@interface DrawAction : NSObject {
//    Paint *_paint;
}


@property(nonatomic, assign)DrawActionType type;
@property(nonatomic, assign, readonly) BOOL hasFinishAddPoint;
//@property(nonatomic, assign)CGSize canvasSize;

- (void)setCanvasSize:(CGSize)canvasSize;

+ (id)drawActionWithPBDrawAction:(PBDrawAction *)action;
+ (id)drawActionWithPBNoCompressDrawAction:(PBNoCompressDrawAction *)action;

+ (NSMutableArray *)pbNoCompressDrawDataToDrawActionList:(PBNoCompressDrawData *)data canvasSize:(CGSize)canvasSize;

+ (PBNoCompressDrawData *)pbNoCompressDrawDataFromDrawActionList:(NSArray *)drawActionList
                                                            size:(CGSize)size
                                                      drawToUser:(PBUserBasicInfo *)drawToUser;

+ (PBNoCompressDrawData *)pbNoCompressDrawDataFromDrawActionList:(NSArray *)drawActionList
                                                            size:(CGSize)size
                                                        opusDesc:(NSString *)opusDesc
                                                      drawToUser:(PBUserBasicInfo *)drawToUser;


//new Method should overload by sub classes..

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