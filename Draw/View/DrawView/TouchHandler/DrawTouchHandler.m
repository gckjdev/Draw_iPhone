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
    Paint *currentPaint = nil;
    if (action == nil) {
        currentPaint = [Paint paintWithWidth:self.drawView.lineWidth
                                       color:self.drawView.lineColor
                                     penType:self.drawView.penType
                                   pointList:nil];
        
        action = [[PaintAction paintActionWithPaint:currentPaint] retain];
        [action addPoint:point inRect:self.drawView.bounds];
        [self addAction:action];
        [self.drawView drawDrawAction:action show:YES];
    }else{
        [action addPoint:point inRect:self.drawView.bounds];
        [self.drawView updateLastAction:action show:YES];
    }
}

- (void)addAction:(DrawAction *)drawAction
{
    [self.drawView addDrawAction:drawAction];
}


- (void)reset
{
    PPRelease(action);
}


- (void)finishAddPoints
{
    currentState = TouchStateEnd;
    [action finishAddPoint];
//    [self addAction:action];
    if (action) {
        [self.drawView clearRedoStack];
    }
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
            break;
        }
        case TouchStateMove:
        {
            [self addPoint:point];
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

//    [self.osManager cancelLastAction];
    if (action) {
        [self.osManager cancelLastAction];
        [self.drawView.drawActionList removeObject:action];
    }

    [self.drawView setNeedsDisplay];
    [self reset];
}


- (DrawAction *)drawAction
{
    return action;
}
@end
