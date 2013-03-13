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
                                            penType:self.drawView.penType];
        action = [[DrawAction actionWithType:DRAW_ACTION_TYPE_DRAW paint:currentPaint] retain];
        [currentPaint addPoint:point];
        [self.osManager updateDrawPenWithPaint:currentPaint];
        [self.drawView drawDrawAction:action show:YES];
    }else{
        currentPaint = action.paint;
        [currentPaint addPoint:point];
        [self.osManager updateDrawPenWithPaint:currentPaint];
        [self.drawView drawPaint:action.paint show:YES];
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
//            [self addPoint:point];
            [action.paint finishAddPoint];
            [self addAction:action];
            if (action) {
                [self.drawView clearRedoStack];
            }
            [self reset];
            break;
        }
        default:
            break;
    }
}
- (void)handleFailTouch
{
    [super handleFailTouch];
    [self reset];
    [self.osManager cancelLastAction];
    [self.drawView setNeedsDisplay];
}


- (DrawAction *)drawAction
{
    return action;
}
@end
