//
//  DrawTouchHandler.m
//  Draw
//
//  Created by gamy on 13-3-9.
//
//

#import "DrawTouchHandler.h"

@interface DrawTouchHandler()
{
    DrawAction *action;
}

@end

@implementation DrawTouchHandler

- (DrawAction *)createDrawAction
{
    if (action == nil) {
        Paint *currentPaint = nil;
        if (action == nil) {
            DrawInfo *info = self.drawView.drawInfo;
            
            currentPaint = [Paint paintWithWidth:info.penWidth
                                           color:info.penColor
                                         penType:info.penType
                                       pointList:nil];

            action.shadow = info.shadow;            
            action = [[PaintAction paintActionWithPaint:currentPaint] retain];            
        }
    }
    return action;
}


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

- (void)addPoint:(CGPoint)point
{
    if (handleFailed) {
        return;
    }
    action = [self createDrawAction];
    [action addPoint:point inRect:self.drawView.bounds];

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
            [self addPoint:point];
            [self.drawView updateLastAction:action refresh:YES];
            break;
        }
        case TouchStateEnd:
        case TouchStateCancel:
        {
            [self finishAddPoints];
            break;
        }
        default:
            break;
    }
}

#define FORCE_END_POINT_COUNT_WHEN_CANCEL 15

- (void)handleFailTouch
{
    if ([action pointCount] >= FORCE_END_POINT_COUNT_WHEN_CANCEL) {
        [self finishAddPoints];
        return;
    }
    [super handleFailTouch];
    [self reset];
    [self.drawView cancelLastAction];
}


- (DrawAction *)drawAction
{
    return action;
}
@end