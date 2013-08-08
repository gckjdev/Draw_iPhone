//
//  ShapeClipTouchHandler.m
//  Draw
//
//  Created by gamy on 13-7-8.
//
//

#import "ShapeClipTouchHandler.h"
#import "PaintAction.h"
#import "ClipAction.h"

@interface ShapeClipTouchHandler()
{
    ClipAction *action;
}

@end

@implementation ShapeClipTouchHandler

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


CGPoint realStartPoint;

- (void)updateEndPoint
{
    
    DrawInfo *info = self.drawView.drawInfo;
    action.shape.startPoint = realStartPoint;
    if ([ShapeInfo point1:action.shape.startPoint equalToPoint:action.shape.endPoint]) {
        action.shape.endPoint = CGPointMake(action.shape.endPoint.x + info.penWidth/2,
                                            action.shape.endPoint.y + info.penWidth/2);
        action.shape.startPoint = CGPointMake(action.shape.startPoint.x - info.penWidth/2,
                                              action.shape.startPoint.y - info.penWidth/2);
        
    }
}



- (ClipAction *)createDrawAction
{
    if (action == nil) {
        ShapeInfo *shape = [ShapeInfo shapeWithType:self.shapeType
                                            penType:[DrawColor grayColor]
                                              width:Pencil
                                              color:nil];
        
        action = [[ClipAction clipActionWithShape:shape] retain];
        action.clipTag = [self genClipTag];
        shape.width = STROKE_WIDTH;
    }
    return action;
}



- (void)handlePoint:(CGPoint)point forTouchState:(TouchState)state
{
    [super handlePoint:point forTouchState:state];
    switch (state) {
        case TouchStateBegin:
        {
            handleFailed = NO;
            realStartPoint = point;
            action = (id)[self createDrawAction];
            ShapeInfo *shape = action.shape;
            shape.startPoint = shape.endPoint = point;
            [self updateEndPoint];
            [self.drawView addDrawAction:action show:YES];
            break;
        }
            
        case TouchStateEnd:
        case TouchStateMove:
        {
            if (handleFailed) {
                return;
            }
            [action addPoint:point inRect:self.drawView.bounds];
            [self updateEndPoint];
            [self.drawView updateLastAction:action refresh:YES];
            
            break;
        }
        default:
            break;
    }
    
    if (state == TouchStateCancel || state == TouchStateEnd) {
        [self.drawView finishLastAction:action refresh:YES];
        [self reset];
    }
}

- (void)handleFailTouch
{
    [super handleFailTouch];

    if (action) {
        [self.drawView cancelLastAction];
    }

    [self reset];
}

- (DrawAction *)drawAction
{
    return action;
}
@end
