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
        
        action = [[ClipAction clipActionWithPaint:currentPaint] retain];
    }
    [action addPoint:point inRect:self.drawView.bounds];
    [self.cdManager startClipAction:action];
    [self.drawView updateLastAction:action show:YES];
    
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
    [self addAction:action];
    BOOL needRedraw = [self.cdManager finishDrawAction:action];
    
    if (needRedraw) {
        [self.drawView setNeedsDisplay];
    }else{
        [self.drawView setNeedsDisplayInRect:[action redrawRectInRect:self.drawView.bounds]];
    }
    
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