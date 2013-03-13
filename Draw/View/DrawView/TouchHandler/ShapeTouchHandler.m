//
//  ShapeTouchHandler.m
//  Draw
//
//  Created by gamy on 13-3-9.
//
//

#import "ShapeTouchHandler.h"

@interface ShapeTouchHandler()
{
    DrawAction *action;
}

@end

@implementation ShapeTouchHandler

- (void)addAction:(DrawAction *)drawAction
{
    [self.drawView addDrawAction:drawAction];
}

- (void)dealloc
{
    if ((currentState != TouchStateCancel) && (currentState != TouchStateEnd)) {
        [self handleFailTouch];
    }else{
        [self reset];
    }
    PPRelease(action);
    [super dealloc];
    
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
            if (!action) {
                ShapeInfo *shape = [ShapeInfo shapeWithType:self.drawView.shapeType
                                                    penType:self.drawView.penType
                                                      width:self.drawView.lineWidth
                                                       color:self.drawView.lineColor];
                action = [[DrawAction actionWithShpapeInfo:shape] retain];
                action.shapeInfo.startPoint  = point;
                action.shapeInfo.endPoint = point;
                [self.osManager addDrawAction:action];
            }else{
                action.shapeInfo.startPoint  = point;
                action.shapeInfo.endPoint = point;
                [self.osManager updateLastAction:action];
            }
            break;
        }
            
        case TouchStateEnd:
        case TouchStateMove:
        {
            if (handleFailed) {
                return;
            }
            action.shapeInfo.endPoint = point;
            [self.osManager updateLastAction:action];
            break;
        }

    }
    [self.drawView setNeedsDisplay];
    if (state == TouchStateCancel || state == TouchStateEnd) {
        [self.drawView addDrawAction:action];
        if (action) {
            [self.drawView clearRedoStack];
        }

        [self reset];
    }
}

- (void)handleFailTouch
{
    [super handleFailTouch];
    [self reset];
    [self.osManager cancelLastAction];
//    [[self.osManager enteryScreen] clear];
    [self.drawView setNeedsDisplay];
}

- (DrawAction *)drawAction
{
    return action;
}

@end
