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
#import "StringUtil.h"

@implementation DrawAction


- (void)setCanvasSize:(CGSize)canvasSize
{
    
}

- (void)dealloc
{
    [super dealloc];
}

+ (id)drawActionWithPBDrawActionC:(Game__PBDrawAction *)action
{
    switch (action->type) {
        case DrawActionTypeClean:
            return [[[CleanAction alloc] initWithPBDrawActionC:action] autorelease];
        case DrawActionTypeShape:
            return [[[ShapeAction alloc] initWithPBDrawActionC:action] autorelease];
        case DrawActionTypePaint:
            if (action->width >= BACK_GROUND_WIDTH / 10) {
                return [[[ChangeBackAction alloc] initWithPBDrawActionC:action] autorelease];
            }
            return [[[PaintAction alloc] initWithPBDrawActionC:action] autorelease];
        case DrawActionTypeChangeBack:
            return [[[ChangeBackAction alloc] initWithPBDrawActionC:action] autorelease];
        case DrawActionTypeChangeBGImage:
            return [[[ChangeBGImageAction alloc] initWithPBDrawActionC:action] autorelease];
            
        default:
            return nil;
    }
    
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

+ (id)drawActionWithPBNoCompressDrawActionC:(Game__PBNoCompressDrawAction *)action
{
    switch (action->type) {
        case DrawActionTypeClean:
            return [[[CleanAction alloc] initWithPBNoCompressDrawActionC:action] autorelease];
        case DrawActionTypeShape:
            return [[[CleanAction alloc] initWithPBNoCompressDrawActionC:action] autorelease];
        case DrawActionTypePaint:
            if (action->width >= BACK_GROUND_WIDTH / 10) {
                return [[[ChangeBackAction alloc] initWithPBNoCompressDrawActionC:action] autorelease];
            }
            return [[[PaintAction alloc] initWithPBNoCompressDrawActionC:action] autorelease];
        case DrawActionTypeChangeBack:
            return [[[ChangeBackAction alloc] initWithPBNoCompressDrawActionC:action] autorelease];
        case DrawActionTypeChangeBGImage:
            return [[[ChangeBGImageAction alloc] initWithPBNoCompressDrawActionC:action] autorelease];
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

- (id)initWithPBNoCompressDrawActionC:(Game__PBNoCompressDrawAction *)action
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

- (id)initWithPBDrawActionC:(Game__PBDrawAction *)action
{
    self = [super init];
    if (self) {
        self.type = action->type;
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

+ (NSMutableArray *)pbNoCompressDrawDataCToDrawActionList:(Game__PBNoCompressDrawData *)data canvasSize:(CGSize)canvasSize
{
    NSMutableArray *drawActionList = [NSMutableArray array];
    if (data->n_drawactionlist2 > 0) {
        
        for (int i=0; i<data->n_drawactionlist2; i++){
            DrawAction *at = [DrawAction drawActionWithPBDrawActionC:data->drawactionlist2[i]];
            [at setCanvasSize:canvasSize];
            [drawActionList addObject:at];
            at = nil;
        }
    }else if(data->n_drawactionlist > 0){
        for (int i=0; i<data->n_drawactionlist; i++){
            DrawAction *dAction = [DrawAction drawActionWithPBNoCompressDrawActionC:data->drawactionlist[i]];
            [dAction setCanvasSize:canvasSize];
            [drawActionList addObject:dAction];
            dAction = nil;
        }
    }
    
    return drawActionList;
}

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
                                                 bgImageFileName:(NSString *)bgImageFileName
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
        [builder setBgImageName:bgImageFileName];

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
                                                 bgImageFileName:(NSString *)bgImageFileName
{
    if ([drawActionList count] != 0 || [GameApp forceSaveDraft]) {
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
        [builder setBgImageName:bgImageFileName];
        
        PBNoCompressDrawData *nData = [builder build];
        
        PPRelease(builder);
        return nData;
    }
    return nil;
}




+ (Game__PBNoCompressDrawData *)pbNoCompressDrawDataCFromDrawActionList:(NSArray *)drawActionList
                                                                   size:(CGSize)size
                                                               opusDesc:(NSString *)opusDesc
                                                             drawToUser:(PBUserBasicInfo *)drawToUser
                                                        bgImageFileName:(NSString *)bgImageFileName
{
    if ([drawActionList count] != 0 || [GameApp forceSaveDraft]) {
        
//        PBNoCompressDrawData_Builder *builder = [[PBNoCompressDrawData_Builder alloc] init];
        
        Game__PBNoCompressDrawData pbNoCompressDrawDataC = GAME__PBNO_COMPRESS_DRAW_DATA__INIT;
        
        int count = [drawActionList count];
        pbNoCompressDrawDataC.drawactionlist2 = malloc(sizeof(Game__PBNoCompressDrawAction)*count);
        pbNoCompressDrawDataC.n_drawactionlist2 = count;
        
        int i=0;
        for (DrawAction *drawAction in drawActionList) {
//            PBDrawAction *pbd = [drawAction toPBDrawAction];
//            if (pbd) {
//                [builder addDrawActionList2:pbd];
//            }
            
            pbNoCompressDrawDataC.drawactionlist2[i] = [drawAction toPBDrawActionC];
            i++;
        }
        
        if (drawToUser) {
//            [builder setDrawToUser:drawToUser];
            pbNoCompressDrawDataC.drawtouser = malloc(sizeof(Game__PBUserBasicInfo));            
            pbNoCompressDrawDataC.drawtouser->avatar = [drawToUser.avatar copyToCString];
            pbNoCompressDrawDataC.drawtouser->nickname = [drawToUser.nickName copyToCString];
            pbNoCompressDrawDataC.drawtouser->userid = [drawToUser.userId copyToCString];
            pbNoCompressDrawDataC.drawtouser->gender = [drawToUser.gender copyToCString];
        }
        
        if (opusDesc) {
//            [builder setOpusDesc:opusDesc];
            pbNoCompressDrawDataC.opusdesc = [opusDesc copyToCString];
        }
        
        pbNoCompressDrawDataC.canvassize = malloc(sizeof(Game__PBSize));
        CGSizeToPBSizeC(size, pbNoCompressDrawDataC.canvassize);
        
//        [builder setCanvasSize:CGSizeToPBSize(size)];
        
        pbNoCompressDrawDataC.version = [ConfigManager currentDrawDataVersion];
        pbNoCompressDrawDataC.has_version = 1;

        pbNoCompressDrawDataC.bgimagename = [bgImageFileName copyToCString];
        
        void* ret = malloc(sizeof(Game__PBNoCompressDrawData));
        memcpy(ret, &pbNoCompressDrawDataC, sizeof(Game__PBNoCompressDrawData));
        return ret;
        
//        [builder setVersion:[ConfigManager currentDrawDataVersion]];
//        [builder setBgImageName:bgImageFileName];
        
//        PBNoCompressDrawData *nData = [builder build];
//        
//        PPRelease(builder);
//        return nData;
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



