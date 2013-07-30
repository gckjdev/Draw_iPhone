//
//  PathClipTouchHandler.m
//  Draw
//
//  Created by gamy on 13-7-8.
//
//

#import "PathClipTouchHandler.h"
#import "ClipAction.h"

@interface PathClipTouchHandler()
{
    ClipAction *action;
}
@end

@implementation PathClipTouchHandler

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
        if (action == nil) {            
            Paint *currentPaint = [Paint paintWithWidth:STROKE_WIDTH
                                                  color:[DrawColor grayColor]
                                                penType:Pencil
                                              pointList:nil];
            
            action = [[ClipAction clipActionWithPaint:currentPaint] retain];
        }
    }
    return action;
}

- (void)addPoint:(CGPoint)point
{
    if (handleFailed) {
        return;
    }
    action = (id)[self createDrawAction];
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
//    [self.drawView addDrawAction:action show:YES];
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
            [self.drawView finishLastAction:action refresh:YES];
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
//        
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
