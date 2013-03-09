//
//  TouchHandler.h
//  Draw
//
//  Created by gamy on 13-3-9.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    TouchStateBegin = 0,
    TouchStateMove = 1,
    TouchStateEnd = 2,
    TouchStateFail = 3,
}TouchState;



@class DrawView;
@class OffscreenManager;

@interface TouchHandler : NSObject


@property(nonatomic, assign)DrawView *drawView;
@property(nonatomic, assign)OffscreenManager *osManager;

- (void)handlePoint:(CGPoint)point forTouchState:(TouchState)state;
- (void)handleFailTouch;

@end
