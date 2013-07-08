//
//  ClipTouchHandler.m
//  Draw
//
//  Created by gamy on 13-7-8.
//
//

#import "ClipTouchHandler.h"
#import "ShapeAction.h"
#import "PaintAction.h"
#import "ClipAction.h"

@interface ClipTouchHandler()
{
    ClipAction *action;
}

@end

@implementation ClipTouchHandler
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


CGPoint realStartPoint;

- (void)updateEndPoint
{
    action.shape.startPoint = realStartPoint;
    if ([ShapeInfo point1:action.shape.startPoint equalToPoint:action.shape.endPoint]) {
        action.shape.endPoint = CGPointMake(action.shape.endPoint.x + self.drawView.lineWidth/2,
                                            action.shape.endPoint.y + self.drawView.lineWidth/2);
        action.shape.startPoint = CGPointMake(action.shape.startPoint.x - self.drawView.lineWidth/2,
                                              action.shape.startPoint.y - self.drawView.lineWidth/2);
        
    }
}

#define STROKE_WIDTH 2



- (void)handlePoint:(CGPoint)point forTouchState:(TouchState)state
{
    [super handlePoint:point forTouchState:state];
    switch (state) {
        case TouchStateBegin:
        {
            handleFailed = NO;
            ShapeInfo *shape = nil;
            realStartPoint = point;
            if (!action) {
                
                
                
                shape = [ShapeInfo shapeWithType:self.drawView.shapeType
                                         penType:self.drawView.penType
                                           width:self.drawView.lineWidth
                                           color:self.drawView.lineColor];
                
                [shape setStroke:self.drawView.strokeShape];
                action = [[ShapeAction shapeActionWithShape:shape] retain];
                action.shadow = self.drawView.shadow;
                
                [self.cdManager updateLastAction:action];
                shape.startPoint = shape.endPoint = point;
                
                
                //Add at DrawDataVersion == 4, May edit in the future. By Gamy
                ////=====start====////
                
                if (shape.type != ShapeTypeBeeline) {
                    shape.width = STROKE_WIDTH;
                }
                [self updateEndPoint];
                ////=====end=====/////
                
                
                //                [self.drawView drawDrawAction:action show:YES];
            }else{
                shape.startPoint = shape.endPoint = point;
                [self updateEndPoint];
                [self.drawView updateLastAction:action show:YES];
            }
            
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
            [self.drawView updateLastAction:action show:YES];
            break;
        }
        default:
            break;
    }
    
    if (state == TouchStateCancel || state == TouchStateEnd) {
        [self.drawView addDrawAction:action];
        [self.cdManager finishDrawAction:action];
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
    //    [self.osManager cancelLastAction];
    [self.cdManager cancelLastAction];
    [self.drawView setNeedsDisplay];
}

- (DrawAction *)drawAction
{
    return action;
}
@end
