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
#import "CacheDrawManager.h"

typedef enum {
    TouchStateBegin = 0,
    TouchStateMove = 1,
    TouchStateEnd = 2,
    TouchStateCancel = 3,
}TouchState;


@class DrawView;

@interface TouchHandler : NSObject
{
    TouchState currentState;
    BOOL handleFailed;
}

@property(nonatomic, assign)DrawView *drawView;
@property(nonatomic, assign)CacheDrawManager *cdManager;

- (void)handlePoint:(CGPoint)point forTouchState:(TouchState)state;
- (void)handleFailTouch;
+ (id)touchHandlerWithTouchActionType:(TouchActionType)type;
- (void)reset;
- (BOOL)handleFailed;

@end
