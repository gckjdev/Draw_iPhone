//
//  DrawAction.m
//  Draw
//
//  Created by  on 12-3-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DrawAction.h"
#import "Paint.h"
#import "GameBasic.pb.h"
#import "DrawUtils.h"
#import "Draw.pb.h"
#import "ConfigManager.h"
#import "PointNode.h"

@implementation DrawAction

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
        if (self.type != DRAW_ACTION_TYPE_CLEAN) {

            CGFloat lineWidth = [action width];
            NSInteger penType = [action penType];
            DrawColor *color = nil;
            if ([DrawUtils isNotVersion1:dataVersion]){
                color = [[[DrawColor alloc] initWithRed:action.red green:action.green blue:action.blue alpha:action.alpha] autorelease];
            }
            else{
                color = [[[DrawColor alloc] initWithPBColor:action.color] autorelease];
            }
            
            if (self.type == DRAW_ACTION_TYPE_DRAW) {
                
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
            else if(self.type == DRAW_ACTION_TYPE_SHAPE){
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
    [builder setAlpha:[color alpha]];
    [builder setBlue:[color blue]];
    [builder setRed:[color red]];
    [builder setGreen:[color green]];

}

- (PBNoCompressDrawAction *)toPBNoCompressDrawAction
{
    PBNoCompressDrawAction_Builder *builder = [[PBNoCompressDrawAction_Builder alloc] init];
    [builder setType:self.type];
    if (self.type == DRAW_ACTION_TYPE_DRAW) {
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
    }else if(self.type == DRAW_ACTION_TYPE_SHAPE){
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
- (id)initWithType:(DRAW_ACTION_TYPE)aType paint:(Paint*)aPaint
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
        
        if (self.type == DRAW_ACTION_TYPE_DRAW) {
            NSArray *pointList = [action pointsList];
            Paint *paint = [[Paint alloc] initWithWidth:lineWidth intColor:intColor numberPointList:pointList penType:penType];
            self.paint = paint;
            [paint release];
        }else if(self.type == DRAW_ACTION_TYPE_SHAPE){
            ShapeInfo *shape = [ShapeInfo shapeWithType:action.shapeType penType:penType width:lineWidth color:[DrawUtils decompressIntDrawColor:intColor]];
            [shape setPointsWithPointComponent:action.rectComponentList];
            self.shapeInfo = shape;
        }
    }
    return self;
}

+ (DrawAction *)actionWithType:(DRAW_ACTION_TYPE)aType paint:(Paint*)aPaint
{
    return [[[DrawAction alloc] initWithType:aType paint:aPaint]autorelease];
}

+ (DrawAction *)actionWithShpapeInfo:(ShapeInfo *)shapeInfo
{
    DrawAction *action = [[DrawAction alloc] init];
    [action setType:DRAW_ACTION_TYPE_SHAPE];
    [action setShapeInfo:shapeInfo];
    return [action autorelease];
}

+ (DrawAction *)changeBackgroundActionWithColor:(DrawColor *)color
{
    Paint *paint = [Paint paintWithWidth:BACK_GROUND_WIDTH color:color];
    [paint addPoint:CGPointMake(0, 0)];
    [paint addPoint:CGPointMake(0, BACK_GROUND_WIDTH)];
    return [DrawAction actionWithType:DRAW_ACTION_TYPE_DRAW paint:paint];
}


+ (DrawAction *)clearScreenAction
{
    return [DrawAction actionWithType:DRAW_ACTION_TYPE_CLEAN paint:nil];
}

- (BOOL)isChangeBackAction
{
    //for changing from integer to float.
    return self.paint.width > BACK_GROUND_WIDTH/5;
}

- (BOOL)isCleanAction
{
    return self.type == DRAW_ACTION_TYPE_CLEAN;
}

- (BOOL)isDrawAction
{
    return self.type == DRAW_ACTION_TYPE_DRAW;
}

- (BOOL)isShapeAction
{
    return self.type == DRAW_ACTION_TYPE_SHAPE;
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
        if (action.type == DRAW_ACTION_TYPE_CLEAN) {
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
    if (action.type == DRAW_ACTION_TYPE_DRAW) {
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
        DrawAction *dAction = [DrawAction actionWithType:DRAW_ACTION_TYPE_DRAW paint:newPaint];
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

+ (NSMutableArray *)pbNoCompressDrawDataToDrawActionList:(PBNoCompressDrawData *)data
{
    NSMutableArray *drawActionList = [NSMutableArray array];
    for (PBNoCompressDrawAction *action in [data drawActionListList]) {
        DrawAction *dAction = [[DrawAction alloc] initWithPBNoCompressDrawAction:action dataVersion:data.version];
        [drawActionList addObject:dAction];
        PPRelease(dAction);
    }
    return drawActionList;
}
+ (PBNoCompressDrawData *)drawActionListToPBNoCompressDrawData:(NSArray *)drawActionList
{
    if ([drawActionList count] != 0) {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:drawActionList.count];
        for (DrawAction *action in drawActionList) {
            PBNoCompressDrawAction *nAction = [action toPBNoCompressDrawAction];
            [array addObject:nAction];
        }
        PBNoCompressDrawData_Builder *builder = [[PBNoCompressDrawData_Builder alloc] init];
        [builder addAllDrawActionList:array];
        [builder setVersion:[ConfigManager currentDrawDataVersion]];
        PBNoCompressDrawData *nData = [builder build];
        PPRelease(builder);
        return nData;
    }
    return nil;
}

@end
