//
//  PolygonClipTouchHandler.m
//  Draw
//
//  Created by gamy on 13-7-8.
//
//

#import "PolygonClipTouchHandler.h"

#import "ClipAction.h"

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

- (void)addPoint:(CGPoint)point
{
    if (handleFailed) {
        return;
    }
    Paint *currentPaint = nil;
    if (action == nil) {
        currentPaint = [Paint paintWithWidth:2
                                       color:[DrawColor grayColor]
                                     penType:PolygonPen
                                   pointList:nil];
        
        action = [[ClipAction clipActionWithPaint:currentPaint] retain];
    }
    [action addPoint:point inRect:self.drawView.bounds];
    [self.cdManager startClipAction:action];
    [self.drawView updateLastAction:action show:YES];
    
}
- (void)replaceLastPoint:(CGPoint)point
{
    [action.paint updateLastPoint:point inRect:self.drawView.bounds];
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
    
//    ClipAction *tempAction = action;
//    [tempAction autorelease];
    
    [self reset];
    
    //ignore the warning By Gamy...
    //for history issue, the action always passed nil.
    if (_delegate && [_delegate respondsToSelector:@selector(didPolygonClipTouchHandler:finishAddPointsToAction:)]) {
        [_delegate didPolygonClipTouchHandler:self finishAddPointsToAction:nil];
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
            break;
        }
        case TouchStateMove:
        {
//            [self addPoint:point];
            [self replaceLastPoint:point];
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
