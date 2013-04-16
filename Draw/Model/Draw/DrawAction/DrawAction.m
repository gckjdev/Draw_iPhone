//
//  DrawAction.m
//  Draw
//
//  Created by  on 12-3-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DrawAction.h"
#import "DrawColor.h"
#import "ConfigManager.h"
#import "ShapeAction.h"
#import "ChangeBackAction.h"
#import "PaintAction.h"
#import "CleanAction.h"
#import "ChangeBGImageAction.h"


@implementation DrawAction


- (void)setCanvasSize:(CGSize)canvasSize
{
    
}

- (void)dealloc
{
    [super dealloc];
}

+ (id)drawActionWithPBDrawAction:(PBDrawAction *)action
{
    switch (action.type) {
        case DrawActionTypeClean:
            return [[[CleanAction alloc] initWithPBDrawAction:action] autorelease];
        case DrawActionTypeShape:
            return [[[ShapeAction alloc] initWithPBDrawAction:action] autorelease];
        case DrawActionTypePaint:
            if (action.width >= BACK_GROUND_WIDTH / 10) {
                return [[[ChangeBackAction alloc] initWithPBDrawAction:action] autorelease];
            }
            return [[[PaintAction alloc] initWithPBDrawAction:action] autorelease];
        case DrawActionTypeChangeBack:
            return [[[ChangeBackAction alloc] initWithPBDrawAction:action] autorelease];
        case DrawActionTypeChangeBGImage:
            return [[[ChangeBGImageAction alloc] initWithPBDrawAction:action] autorelease];
        
        default:
            return nil;
    }
}


+ (id)drawActionWithPBNoCompressDrawAction:(PBNoCompressDrawAction *)action
{
    switch (action.type) {
        case DrawActionTypeClean:
            return [[[CleanAction alloc] initWithPBNoCompressDrawAction:action] autorelease];
        case DrawActionTypeShape:
            return [[[CleanAction alloc] initWithPBNoCompressDrawAction:action] autorelease];
        case DrawActionTypePaint:
            if (action.width >= BACK_GROUND_WIDTH / 10) {
                return [[[ChangeBackAction alloc] initWithPBNoCompressDrawAction:action] autorelease];
            }
            return [[[PaintAction alloc] initWithPBNoCompressDrawAction:action] autorelease];
        case DrawActionTypeChangeBack:
            return [[[ChangeBackAction alloc] initWithPBNoCompressDrawAction:action] autorelease];
        case DrawActionTypeChangeBGImage:
            return [[[ChangeBGImageAction alloc] initWithPBNoCompressDrawAction:action] autorelease];
        default:
            return nil;
    }
}


- (id)initWithPBNoCompressDrawAction:(PBNoCompressDrawAction *)action
{
    self = [super init];
    if (self) {
        
    }
    return self;
}


- (CGRect)drawInContext:(CGContextRef)context inRect:(CGRect)rect
{
    return CGRectZero;
}
- (id)initWithPBDrawAction:(PBDrawAction *)action
{
    self = [super init];
    if (self) {
        self.type = action.type;
    }
    return self;
}
- (PBDrawAction *)toPBDrawAction
{
    return nil;
}

- (void)addPoint:(CGPoint)point inRect:(CGRect)rect
{
    
}

- (NSUInteger)pointCount
{
    return 0;
}

- (void)finishAddPoint
{
    _hasFinishAddPoint = YES;
}

#pragma mark-- Common Methods

+ (NSMutableArray *)pbNoCompressDrawDataToDrawActionList:(PBNoCompressDrawData *)data canvasSize:(CGSize)canvasSize
{
    NSMutableArray *drawActionList = [NSMutableArray array];
    if ([[data drawActionList2List] count] != 0) {
        for (PBDrawAction *action in [data drawActionList2List]) {
            DrawAction *at = [DrawAction drawActionWithPBDrawAction:action];

            [at setCanvasSize:canvasSize];

            [drawActionList addObject:at];
            at = nil;
        }
    }else if([[data drawActionListList] count] != 0)
        for (PBNoCompressDrawAction *action in [data drawActionListList]) {
            DrawAction *dAction = [DrawAction drawActionWithPBNoCompressDrawAction:action];
            [dAction setCanvasSize:canvasSize];
            [drawActionList addObject:dAction];
            dAction = nil;
        }
    return drawActionList;
}
+ (PBNoCompressDrawData *)pbNoCompressDrawDataFromDrawActionList:(NSArray *)drawActionList
                                                            size:(CGSize)size
                                                      drawToUser:(PBUserBasicInfo *)drawToUser
{
//    if ([drawActionList count] != 0) {
        PBNoCompressDrawData_Builder *builder = [[PBNoCompressDrawData_Builder alloc] init];
        
        for (DrawAction *drawAction in drawActionList) {
            PBDrawAction *pbd = [drawAction toPBDrawAction];
            if (pbd) {
                [builder addDrawActionList2:pbd];
            }
        }
        
        if (drawToUser) {
            [builder setDrawToUser:drawToUser];
        }
        [builder setCanvasSize:CGSizeToPBSize(size)];
        [builder setVersion:[ConfigManager currentDrawDataVersion]];

        PBNoCompressDrawData *nData = [builder build];
        PPRelease(builder);
        return nData;
//    }
//    return nil;
}

+ (PBNoCompressDrawData *)pbNoCompressDrawDataFromDrawActionList:(NSArray *)drawActionList
                                                            size:(CGSize)size
                                                        opusDesc:(NSString *)opusDesc
                                                      drawToUser:(PBUserBasicInfo *)drawToUser
{
    if ([drawActionList count] != 0) {
        PBNoCompressDrawData_Builder *builder = [[PBNoCompressDrawData_Builder alloc] init];
        
        for (DrawAction *drawAction in drawActionList) {
            PBDrawAction *pbd = [drawAction toPBDrawAction];
            if (pbd) {
                [builder addDrawActionList2:pbd];
            }
        }
        
        if (drawToUser) {
            [builder setDrawToUser:drawToUser];
        }
        if (opusDesc) {
            [builder setOpusDesc:opusDesc];
        }
        [builder setCanvasSize:CGSizeToPBSize(size)];
        [builder setVersion:[ConfigManager currentDrawDataVersion]];
        
        PBNoCompressDrawData *nData = [builder build];
        PPRelease(builder);
        return nData;
    }
    return nil;
}

@end



@implementation PBNoCompressDrawAction (Ext)

- (DrawColor *)drawColor
{
    if ([self hasRgbColor]){
        return [DrawColor colorWithBetterCompressColor:self.rgbColor];
    }
    if ([self hasColor]) {
        return [[[DrawColor alloc] initWithPBColor:self.color] autorelease];
    }
    return [DrawColor colorWithRed:self.red green:self.green blue:self.blue alpha:self.alpha];
}

@end