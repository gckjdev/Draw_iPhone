//
//  TouchHandler.m
//  Draw
//
//  Created by gamy on 13-3-9.
//
//

#import "TouchHandler.h"
#import "DrawTouchHandler.h"
#import "StrawTouchHandler.h"
#import "ShapeTouchHandler.h"

@implementation TouchHandler

@synthesize drawView = _drawView;
//@synthesize osManager = _osManager;
@synthesize cdManager = _cdManager;

- (void)handlePoint:(CGPoint)point forTouchState:(TouchState)state
{
    currentState = state;
}
- (void)handleFailTouch
{
    handleFailed = YES;
}
+ (id)touchHandlerWithTouchActionType:(TouchActionType)type
{
    switch (type) {
        case TouchActionTypeDraw:
            return [[[DrawTouchHandler alloc] init] autorelease];
        case TouchActionTypeShape:
            return [[[ShapeTouchHandler alloc] init] autorelease];
        case TouchActionTypeGetColor:
            return [[[StrawTouchHandler alloc] init] autorelease];
        default:
            return nil;
    }
}

- (void)reset
{
    
}


- (BOOL)handleFailed
{
    return handleFailed;
}

@end
