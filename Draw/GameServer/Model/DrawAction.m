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

@implementation DrawAction

@synthesize type = _type;
@synthesize paint = _paint;

- (void)dealloc
{
    [_paint release];
    [super dealloc];
}

- (id)initWithPBNoCompressDrawAction:(PBNoCompressDrawAction *)action
{
    self = [ super init];
    if (self) {
        self.type = action.type;
        if (self.type != DRAW_ACTION_TYPE_CLEAN) {
            DrawColor *color = [[[DrawColor alloc] initWithPBColor:action.color] autorelease];
            CGFloat lineWidth = [action width];
            NSInteger penType = [action penType];
            
            NSMutableArray *pointList = nil;
            NSUInteger count = [[action pointList] count];
            if (count > 0) {
                pointList = [[[NSMutableArray alloc] initWithCapacity:count] autorelease];
                for (PBPoint *point in action.pointList) {
                    CGPoint p = CGPointMake(point.x, point.y);
                    NSValue *value = [NSValue valueWithCGPoint:p];
                    [pointList addObject:value];
                }
            }
            Paint *paint = [[Paint alloc] initWithWidth:lineWidth color:color penType:penType pointList:pointList];
            self.paint = paint;
            PPRelease(paint);
        }
    }
    return self;

}

- (PBNoCompressDrawAction *)toPBNoCompressDrawAction
{
    PBNoCompressDrawAction_Builder *builder = [[PBNoCompressDrawAction_Builder alloc] init];
    [builder setType:self.type];
    if (self.type != DRAW_ACTION_TYPE_CLEAN) {
        Paint *paint = self.paint;
        PBColor *color = [paint.color toPBColor];
        [builder setColor:color];
        [builder setWidth:paint.width];
        [builder setPenType:paint.penType];
        //set point list
        NSUInteger pCount = [paint pointCount];
        if (pCount != 0) {
            NSMutableArray *pList = [NSMutableArray arrayWithCapacity:pCount];
            for (NSValue *value in paint.pointList) {
                CGPoint point = [value CGPointValue];
                PBPoint_Builder *pBuilder = [[PBPoint_Builder alloc] init];
                [pBuilder setX:point.x];
                [pBuilder setY:point.y];
                PBPoint *pp = [pBuilder build];
                PPRelease(pBuilder);
                [pList addObject:pp];
            }
            [builder addAllPoint:pList];
        }
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
        
        if (self.type != DRAW_ACTION_TYPE_CLEAN) {
            NSInteger intColor = [action color];
            CGFloat lineWidth = [action width];        
            NSArray *pointList = [action pointsList];
            NSInteger penType = [action penType];
            Paint *paint = [[Paint alloc] initWithWidth:lineWidth intColor:intColor numberPointList:pointList penType:penType];
            self.paint = paint;
            [paint release];
        }
    }
    return self;
}

+ (DrawAction *)actionWithType:(DRAW_ACTION_TYPE)aType paint:(Paint*)aPaint
{
    return [[[DrawAction alloc] initWithType:aType paint:aPaint]autorelease];
}

#define BACK_GROUND_WIDTH 3000

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
    return self.paint.width > BACK_GROUND_WIDTH - 10;
}

- (BOOL)isCleanAction
{
    return self.type == DRAW_ACTION_TYPE_CLEAN;
}

- (BOOL)isDrawAction
{
    return self.type == DRAW_ACTION_TYPE_DRAW;
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
        if (action.type == DRAW_ACTION_TYPE_DRAW && action.pointCount > 0){
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
        for (NSValue *value in paint.pointList) {
            CGPoint point = [value CGPointValue];
            point.x = point.x * xScale;
            point.y = point.y * yScale;
            NSValue *pValue = [NSValue valueWithCGPoint:point];
            [list addObject:pValue];
        }
        [pool release];

        Paint *newPaint = [Paint paintWithWidth:paint.width * xScale color:paint.color penType:paint.penType];
        [newPaint setPointList:list];
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
- (BOOL)point1:(CGPoint)p1 isEqualPoint2:(CGPoint)p2
{
    return p1.x == p2.x && p1.y == p2.y; 
}

- (NSArray *)intPointListWithXScale:(CGFloat)xScale 
                             yScale:(CGFloat)yScale
{
    NSMutableArray *pointList = [[[NSMutableArray alloc] init] autorelease];
    CGPoint lastPoint = ILLEGAL_POINT;
    int i = 0;
    for (NSValue *pointValue in _paint.pointList) {
        CGPoint point = [pointValue CGPointValue];
        if (i ++ == 0 || ![self point1:lastPoint isEqualPoint2:point]) 
        {
            CGPoint tempPoint = point;
            tempPoint = CGPointMake(point.x / xScale, point.y / yScale);
            NSNumber *pointNumber = [NSNumber numberWithInt:[DrawUtils compressPoint:tempPoint]];
            [pointList addObject:pointNumber];
        }
        lastPoint = point;
    }
    return pointList;
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
        DrawAction *dAction = [[DrawAction alloc] initWithPBNoCompressDrawAction:action];
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
