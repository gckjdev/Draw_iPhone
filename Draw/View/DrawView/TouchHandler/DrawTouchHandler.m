//
//  DrawTouchHandler.m
//  Draw
//
//  Created by gamy on 13-3-9.
//
//

#import "DrawTouchHandler.h"
#import "BrushAction.h"
#import "BrushStroke.h"

@interface DrawTouchHandler()
{
    DrawAction *action;
//    BrushAction *brushAction;
}

@end

@implementation DrawTouchHandler

- (DrawAction *)createDrawAction
{
    if (action == nil) {
        Paint *currentPaint = nil;
        if (action == nil) {
            DrawInfo *info = self.drawView.drawInfo;
            ShareDrawInfo *shareDrawInfo = self.drawView.shareDrawInfo;

            currentPaint = [Paint paintWithWidth:[shareDrawInfo itemWidth]
                                           color:[shareDrawInfo itemColor]
                                         penType:shareDrawInfo.penType
                                       pointList:nil];

            action.shadow = info.shadow;            
            action = [[PaintAction paintActionWithPaint:currentPaint] retain];
        }
    }
    return action;
}

- (DrawAction*)createBrushAction
{
    if (action == nil) {
        DrawInfo *info = self.drawView.drawInfo;
        ShareDrawInfo *shareDrawInfo = self.drawView.shareDrawInfo;
        
        BrushStroke* brushStroke = nil;
        brushStroke = [BrushStroke brushStrokeWithWidth:[shareDrawInfo itemWidth]
                                                  color:[shareDrawInfo itemColor]
                                              brushType:shareDrawInfo.penType
                                              pointList:nil];
        
        action.shadow = info.shadow;
        action = [[BrushAction brushActionWithBrushStroke:brushStroke] retain];
        [action setCanvasSize:self.drawView.bounds.size];
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

- (BOOL)isBrush
{
    if (self.drawView.shareDrawInfo.penType >= ItemTypeBrushBegin &&
        self.drawView.shareDrawInfo.penType <= ItemTypeBrushEnd){
        return YES;
    }
    else{
        
//#ifdef BRUSH
//        if (self.drawView.shareDrawInfo.penType >= WaterPen &&
//            self.drawView.shareDrawInfo.penType <= PenCount){
//            self.drawView.shareDrawInfo.penType = ItemTypeBrushBegin + 1 + self.drawView.shareDrawInfo.penType - WaterPen;
//            return YES;
//        }
//#endif
        
        return NO;
    }
}

- (void)addPoint:(CGPoint)point
{
    if (handleFailed) {
        return;
    }
    
    if ([self isBrush]){
        action = [self createBrushAction];
    }
    else{
        action = [self createDrawAction];
    }

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