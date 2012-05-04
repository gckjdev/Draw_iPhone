//
//  DrawAction.m
//  Draw
//
//  Created by  on 12-3-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DrawAction.h"
#import "Paint.h"

@implementation DrawAction

@synthesize type = _type;
@synthesize paint = _paint;

- (void)dealloc
{
    [_paint release];
    [super dealloc];
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


+ (DrawAction *)actionWithType:(DRAW_ACTION_TYPE)aType paint:(Paint*)aPaint
{
    return [[[DrawAction alloc] initWithType:aType paint:aPaint]autorelease];
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
    DrawAction *action = [actionList lastObject];
    if (action.type == DRAW_ACTION_TYPE_DRAW && action.pointCount > 0){
        return NO;
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
        for (NSValue *value in paint.pointList) {
            CGPoint point = [value CGPointValue];
            point.x = point.x * xScale;
            point.y = point.y * yScale;
            NSValue *pValue = [NSValue valueWithCGPoint:point];
            [list addObject:pValue];
        }
        Paint *newPaint = [Paint paintWithWidth:paint.width * yScale color:paint.color];
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


@end
