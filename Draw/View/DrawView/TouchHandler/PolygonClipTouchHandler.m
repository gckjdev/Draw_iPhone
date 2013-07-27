//
//  PolygonClipTouchHandler.m
//  Draw
//
//  Created by gamy on 13-7-8.
//
//

#import "PolygonClipTouchHandler.h"

#import "ClipAction.h"


#define STROKE_WIDTH 2

@interface PolygonClipTouchHandler()
{
    ClipAction *action;
}
@end


@implementation PolygonClipTouchHandler

- (void)dealloc
{
    if ((currentState != TouchStateCancel) &&
        (currentState != TouchStateEnd)) {
        [self handleFailTouch];
    }else{
        [self reset];
    }
    PPRelease(action);
    [super dealloc];
}


- (ClipAction *)createDrawAction
{
    if (action == nil) {
        Paint *currentPaint = [Paint paintWithWidth:STROKE_WIDTH
                                       color:[DrawColor grayColor]
                                     penType:PolygonPen
                                   pointList:nil];
        
        action = [[ClipAction clipActionWithPaint:currentPaint] retain];
    }
    return action;
}

- (void)addPoint:(CGPoint)point
{
    if (handleFailed) {
        return;
    }
    action = [self createDrawAction];
}
- (void)replaceLastPoint:(CGPoint)point
{
    [action.paint updateLastPoint:point inRect:self.drawView.bounds];
}


- (void)reset
{
    PPRelease(action);
}


- (void)finishAddPoints
{
    currentState = TouchStateEnd;
    [action finishAddPoint];
    [self.drawView finishLastAction:action refresh:YES];    
    [self reset];
    
    //for history issue, the action always passed nil.
    if (_delegate && [_delegate respondsToSelector:@selector(didPolygonClipTouchHandler:finishAddPointsToAction:)]) {
        [_delegate performSelector:@selector(didPolygonClipTouchHandler:finishAddPointsToAction:) withObject:self withObject:nil];
    }
    

}

#define MAX_DISTANCE 25

- (BOOL)canFinishWithPoint:(CGPoint)point
{
    NSInteger count = action.paint.pointCount;
    if (count < 3) {
        return NO;
    }
    CGPoint  firstPoint = [action.paint pointAtIndex:0];
    return CGPointDistance(point, firstPoint) <= MAX_DISTANCE;
}

- (void)handlePoint:(CGPoint)point forTouchState:(TouchState)state
{
    [super handlePoint:point forTouchState:state];
    switch (state) {
        case TouchStateBegin:
        {
            handleFailed = NO;
            [self addPoint:point];
            [self.drawView addDrawAction:action show:YES];
            break;
        }
        case TouchStateMove:
        {
            [self replaceLastPoint:point];
            [self.drawView updateLastAction:action refresh:YES];
            break;
        }
        case TouchStateEnd:
        case TouchStateCancel:
        {
            if ([self canFinishWithPoint:point]) {
                [self finishAddPoints];
            }else{
                [self replaceLastPoint:point];
            }
            
            break;
        }
        default:
            break;
    }
}

#define FORCE_END_POINT_COUNT_WHEN_CANCEL 15

- (void)handleFailTouch
{
//    if ([action pointCount] >= FORCE_END_POINT_COUNT_WHEN_CANCEL) {
//        [self finishAddPoints];
//        return;
//    }
    [super handleFailTouch];
    [self.drawView cancelLastAction];
    [self reset];
}


- (DrawAction *)drawAction
{
    return action;
}
@end
