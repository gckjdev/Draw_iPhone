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

//#import "Paint.h"
//#import "GameBasic.pb.h"
//#import "DrawUtils.h"
//#import "Draw.pb.h"

//#import "PointNode.h"
//

@implementation DrawAction
/*
@synthesize type = _type;
@synthesize paint = _paint;

- (void)dealloc
{
    PPRelease(_paint);
    PPRelease(_shapeInfo);
    [super dealloc];
}

- (id)initWithPBNoCompressDrawAction:(PBNoCompressDrawAction *)action dataVersion:(int)dataVersion
{
    self = [ super init];
    if (self) {
        self.type = action.type;
        if (self.type != DrawActionTypeClean) {

            CGFloat lineWidth = [action width];
            NSInteger penType = [action penType];
            DrawColor *color = nil;
            if ([DrawUtils isNotVersion1:dataVersion]){
                if ([action hasRgbColor]){
                    CGFloat red, green, blue, alpha;
                    [DrawUtils decompressColor8:action.rgbColor red:&red green:&green blue:&blue alpha:&alpha];
                    color = [[[DrawColor alloc] initWithRed:red green:green blue:blue alpha:alpha] autorelease];
                }
                else{
                    // to be deleted later
                    color = [[[DrawColor alloc] initWithRed:action.red green:action.green blue:action.blue alpha:action.alpha] autorelease];
                }
            }
            else{
                color = [[[DrawColor alloc] initWithPBColor:action.color] autorelease];
            }
            
            if (self.type == DrawActionTypePaint) {
                
                NSMutableArray *pointList = nil;
                if ([DrawUtils isNotVersion1:dataVersion]){
                    // new version
                    NSUInteger count = [[action pointXList] count];
                    if (count > 0) {
                        pointList = [[NSMutableArray alloc] initWithCapacity:count];
                        for (int i=0; i<count; i++){
                            [pointList addObject:[PointNode pointWithCGPoint:
                                                  CGPointMake([[action.pointXList objectAtIndex:i] floatValue],
                                                              [[action.pointYList objectAtIndex:i] floatValue])]];
                        }
                    }
                }
                else{
                    // old version handling
                    NSUInteger count = [[action pointList] count];
                    if (count > 0) {
                        pointList = [[NSMutableArray alloc] initWithCapacity:count];
                        for (PBPoint *point in action.pointList) {
                            [pointList addObject:[PointNode pointWithPBPoint:point]];
                        }
                    }
                }
                
                Paint *paint = [[Paint alloc] initWithWidth:lineWidth
                                                      color:color
                                                    penType:penType
                                                  pointList:pointList];
                self.paint = paint;
                PPRelease(pointList);
                PPRelease(paint);
            }
            else if(self.type == DrawActionTypeShape){
                self.shapeInfo = [ShapeInfo shapeWithType:action.shapeType penType:penType width:lineWidth color:color];
                [self.shapeInfo setPointsWithPointComponent:action.rectComponentList];
            }
        }
        
    }

    return self;

}


- (void)updateBuilder:(PBNoCompressDrawAction_Builder *)builder withColor:(DrawColor *)color penType:(ItemType)penType width:(CGFloat)width
{
    [builder setWidth:width];
    [builder setPenType:penType];
    
    // set color, new version
    [builder setRgbColor:[DrawUtils compressDrawColor8:color]];
 
}

- (PBNoCompressDrawAction *)toPBNoCompressDrawAction
{
    PBNoCompressDrawAction_Builder *builder = [[PBNoCompressDrawAction_Builder alloc] init];
    [builder setType:self.type];
    if (self.type == DrawActionTypePaint) {
        Paint *paint = self.paint;
        [self updateBuilder:builder withColor:paint.color penType:paint.penType width:paint.width];
        
        // set points, new version
        NSUInteger pCount = [paint pointCount];
        if (pCount != 0) {
            for (PointNode *value in paint.pointNodeList) {
                [builder addPointX:[value x]];
                [builder addPointY:[value y]];
            }
        }
    }else if(self.type == DrawActionTypeShape){
        ShapeInfo *shape = self.shapeInfo;
        [self updateBuilder:builder withColor:shape.color penType:shape.penType width:shape.width];
        [builder setShapeType:shape.type];
        [builder addAllRectComponent:shape.rectComponent];
    }else{
        //Clean
    }
    PBNoCompressDrawAction *action = [builder build];
    [builder release];
    return action;
}
- (id)initWithType:(DrawActionType)aType paint:(Paint*)aPaint
{
    self = [super init];
    if (self) {
        _type = aType;
        self.paint = aPaint;
    }
    return self;
}
- (id)initWithPBDrawAction:(PBDrawAction *)action
{
    self = [ super init];
    if (self) {
        self.type = action.type;
        
        NSInteger intColor = [action color];
        CGFloat lineWidth = [action width];
        NSInteger penType = [action penType];
        
        if (self.type == DrawActionTypePaint) {
            NSArray *pointList = [action pointsList];
            Paint *paint = [[Paint alloc] initWithWidth:lineWidth intColor:intColor numberPointList:pointList penType:penType];
            self.paint = paint;
            [paint release];
        }else if(self.type == DrawActionTypeShape){
            ShapeInfo *shape = [ShapeInfo shapeWithType:action.shapeType penType:penType width:lineWidth color:[DrawUtils decompressIntDrawColor:intColor]];
            [shape setPointsWithPointComponent:action.rectComponentList];
            self.shapeInfo = shape;
        }
    }
    return self;
}

+ (DrawAction *)actionWithType:(DrawActionType)aType paint:(Paint*)aPaint
{
    return [[[DrawAction alloc] initWithType:aType paint:aPaint]autorelease];
}

+ (DrawAction *)actionWithShpapeInfo:(ShapeInfo *)shapeInfo
{
    DrawAction *action = [[DrawAction alloc] init];
    [action setType:DrawActionTypeShape];
    [action setShapeInfo:shapeInfo];
    return [action autorelease];
}

+ (DrawAction *)changeBackgroundActionWithColor:(DrawColor *)color
{
    Paint *paint = [Paint paintWithWidth:BACK_GROUND_WIDTH color:color];
    [paint addPoint:CGPointMake(0, 0)];
    [paint addPoint:CGPointMake(0, BACK_GROUND_WIDTH)];
    return [DrawAction actionWithType:DrawActionTypePaint paint:paint];
}


+ (DrawAction *)clearScreenAction
{
    return [DrawAction actionWithType:DrawActionTypeClean paint:nil];
}

- (BOOL)isChangeBackAction
{
    //for changing from integer to float.
    return self.paint.width > BACK_GROUND_WIDTH/5;
}

- (BOOL)isCleanAction
{
    return self.type == DrawActionTypeClean;
}

- (BOOL)isDrawAction
{
    return self.type == DrawActionTypePaint;
}

- (BOOL)isShapeAction
{
    return self.type == DrawActionTypeShape;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.paint forKey:@"paint"];
    [aCoder encodeInt:_type forKey:@"type"];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.paint = [aDecoder decodeObjectForKey:@"paint"];
        _type = [aDecoder decodeIntForKey:@"type"];
    }
    return self;
}
- (NSInteger)pointCount
{
    if (self.paint) {
        return [self.paint pointCount];
    }
    return 0;
}

+ (BOOL)isDrawActionListBlank:(NSArray *)actionList
{
    if ([actionList count] == 0) {
        return YES;
    }
    for (DrawAction *action in actionList) {
        if (([action isDrawAction] && action.pointCount > 0) || [action isShapeAction]){
            return NO;
        }
    }
    return YES;

}
+ (NSMutableArray *)getTheLastActionListWithoutClean:(NSArray *)actionList
{
    int count = actionList.count;
    int i;
    for (i = count - 1; i >= 0; --i) {
        DrawAction *action = [actionList objectAtIndex:i];
        if (action.type == DrawActionTypeClean) {
            break;
        }
    }
    NSInteger index = i + 1;
    if(index >= actionList.count){
        return nil;
    }
    NSMutableArray *array =[[[NSMutableArray alloc] init]autorelease];
    for (int j = index; j < actionList.count; ++ j) {
        DrawAction *action = [actionList objectAtIndex:j];
        [array addObject:action];
    }
    return array;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"[type=%d, paint=%@]", _type, [_paint description]];
}

+ (DrawAction *)scaleAction:(DrawAction *)action 
                      xScale:(CGFloat)xScale 
                     yScale:(CGFloat)yScale
{
    if (action.type == DrawActionTypePaint) {
        Paint *paint = action.paint;
        if (paint.pointCount == 0) {
            return [DrawAction actionWithType:action.type paint:action.paint];
        }
        
        NSMutableArray *list = [[NSMutableArray alloc] 
                                initWithCapacity:paint.pointCount];

        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        for (PointNode *point in paint.pointNodeList) {
            point.x = point.x * xScale;
            point.y = point.y * yScale;
            [list addObject:point];
        }
        [pool release];

        Paint *newPaint = [Paint paintWithWidth:paint.width * xScale color:paint.color penType:paint.penType];
//        [newPaint setPointList:list];
        [newPaint setPointNodeList:list];
        [list release];
        DrawAction *dAction = [DrawAction actionWithType:DrawActionTypePaint paint:newPaint];
        return dAction;
    }
    return [DrawAction actionWithType:action.type paint:action.paint];
}

+ (NSMutableArray *)scaleActionList:(NSArray *)list 
                       xScale:(CGFloat)xScale 
                      yScale:(CGFloat)yScale
{
    if ([list count] != 0) {
        NSMutableArray *retList = [[[NSMutableArray alloc] 
                                    initWithCapacity:[list count]]autorelease];
        for (DrawAction *action in list) {
            DrawAction *nAction = [DrawAction scaleAction:action xScale:xScale yScale:yScale];
            [retList addObject:nAction];
        }
        return retList;
    }
    return nil;
}

+ (NSInteger)pointCountForActions:(NSArray *)actionList
{
    int sum = 0;
    for (DrawAction *action in actionList) {
        sum += [action pointCount];
    }
    return sum;
}

+ (double)calculateSpeed:(NSArray *)actionList
{
//    return [DrawAction calculateSpeed:actionList defaultSpeed:1.0/40.0 maxSecond:32];
    return 0.015;
}

+ (double)calculateSpeed:(NSArray *)actionList defaultSpeed:(double)defaultSpeed maxSecond:(NSInteger)second
{
    NSInteger count = [DrawAction pointCountForActions:actionList];
    if (defaultSpeed * count <= second) {
        return defaultSpeed;
    }
    return (double)second / (double)count;
}


*/

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

+ (NSMutableArray *)pbNoCompressDrawDataToDrawActionList:(PBNoCompressDrawData *)data
{
    NSMutableArray *drawActionList = [NSMutableArray array];
    if ([[data drawActionList2List] count] != 0) {
        for (PBDrawAction *action in [data drawActionList2List]) {
            DrawAction *at = [DrawAction drawActionWithPBDrawAction:action];
            [drawActionList addObject:at];
            at = nil;
        }
    }else if([[data drawActionListList] count] != 0)
        for (PBNoCompressDrawAction *action in [data drawActionListList]) {
            DrawAction *dAction = [DrawAction drawActionWithPBNoCompressDrawAction:action];
            [drawActionList addObject:dAction];
            dAction = nil;
        }
    return drawActionList;
}
+ (PBNoCompressDrawData *)pbNoCompressDrawDataFromDrawActionList:(NSArray *)drawActionList
                                                        pbdrawBg:(PBDrawBg *)drawBg
                                                            size:(CGSize)size
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
        if (drawBg) {
            [builder setDrawBg:drawBg];
        }
        [builder setCanvasSize:CGSizeToPBSize(size)];
        [builder setVersion:[ConfigManager currentDrawDataVersion]];

        PBNoCompressDrawData *nData = [builder build];
        PPRelease(builder);
        return nData;
    }
    return nil;
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