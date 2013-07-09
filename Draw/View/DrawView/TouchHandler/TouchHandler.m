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
#import "PathClipTouchHandler.h"
#import "ShapeClipTouchHandler.h"
#import "PolygonClipTouchHandler.h"

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
            
        //clip action
        case TouchActionTypeClipPath:
            return [[[PathClipTouchHandler alloc] init] autorelease];
        case TouchActionTypeClipEllipse:
        {
            ShapeClipTouchHandler * handler = [[[ShapeClipTouchHandler alloc] init] autorelease];
            handler.shapeType = ShapeTypeEllipse;
            return handler;
        }
        case TouchActionTypeClipRectangle:
        {
            ShapeClipTouchHandler * handler = [[[ShapeClipTouchHandler alloc] init] autorelease];
            handler.shapeType = ShapeTypeRectangle;
            return handler;
        }
        case TouchActionTypeClipPolygon:
            return [[[PolygonClipTouchHandler alloc] init] autorelease];
            
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
