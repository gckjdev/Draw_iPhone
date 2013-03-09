//
//  TouchHandler.h
//  Draw
//
//  Created by gamy on 13-3-9.
//
//

#import <Foundation/Foundation.h>
#import "DrawAction.h"
#import "DrawView.h"
#import "OffscreenManager.h"


typedef enum {
    TouchStateBegin = 0,
    TouchStateMove = 1,
    TouchStateEnd = 2,
    TouchStateCancel = 3,
}TouchState;



@class DrawView;
@class OffscreenManager;

@interface TouchHandler : NSObject
{
    TouchState currentState;
    BOOL handleFailed;
}

@property(nonatomic, assign)DrawView *drawView;
@property(nonatomic, assign)OffscreenManager *osManager;

- (void)handlePoint:(CGPoint)point forTouchState:(TouchState)state;
- (void)handleFailTouch;
+ (id)touchHandlerWithTouchActionType:(TouchActionType)type;


@end
