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
    ShapeAction *action;
}

@end

@implementation ShapeTouchHandler

- (void)dealloc
{
    if ((currentState != TouchStateCancel) && (currentState != TouchStateEnd)) {
        [self handleFailTouch];
    }    
    [self reset];
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

#define STROKE_WIDTH 2

- (DrawAction *)createDrawAction
{
    if (action == nil) {
 
        DrawInfo *info = self.drawView.drawInfo;
        
        ShapeInfo *shape = [ShapeInfo shapeWithType:info.shapeType
                                 penType:info.penType
                                   width:info.penWidth
                                   color:info.penColor];
        [shape setStroke:info.strokeShape];

        action = [[ShapeAction shapeActionWithShape:shape] retain];
        action.shadow = info.shadow;

        
        
        
        //Add at DrawDataVersion == 4, May edit in the future. By Gamy
        ////=====start====////
        
        if (shape.type != ShapeTypeBeeline) {
            shape.width = STROKE_WIDTH;
        }
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

            action = [self createDrawAction];
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
    [self reset];
    [self.drawView cancelLastAction];
}

- (DrawAction *)drawAction
{
    return action;
}

@end