//
//  DrawView.m
//  Draw
//
//  Created by  on 12-3-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DrawView.h"
#import <QuartzCore/QuartzCore.h>



@interface DrawView()
{
//    BOOL _drawFullRect;
    

}
#pragma mark Private Helper function

@end

#define DEFAULT_PLAY_SPEED (1/40.0)
#define DEFAULT_SIMPLING_DISTANCE (5.0)
#define DEFAULT_LINE_WIDTH (2.0 * 1.414)

@implementation DrawView

@synthesize lineColor = _lineColor;
@synthesize lineWidth = _lineWidth;
@synthesize delegate = _delegate;
@synthesize simplingDistance = _simplingDistance;
@synthesize penType = _penType;



- (void)addCleanAction
{
    DrawAction *cleanAction = [DrawAction actionWithType:DRAW_ACTION_TYPE_CLEAN paint:nil];
    [self.drawActionList addObject:cleanAction];
    _startDrawActionIndex = [self.drawActionList count];
    _drawRectType = DrawRectTypeClean;
    [self setNeedsDisplay];
}

- (DrawAction *)addChangeBackAction:(DrawColor *)color
{
    DrawAction *action = [DrawAction changeBackgroundActionWithColor:color];
    _changeBackColor = color.CGColor;
    [self.drawActionList addObject:action];
    _startDrawActionIndex = [self.drawActionList count] - 1;
    _drawRectType = DrawRectTypeChangeBack;
    [self setNeedsDisplay];
    return action;
}



- (void)setDrawEnabled:(BOOL)enabled
{
    self.userInteractionEnabled = enabled;
}

#pragma mark Gesture Handler
- (void)addPoint:(CGPoint)point toDrawAction:(DrawAction *)drawAction
{    
    if (drawAction) {
        
        if (point.x <= 0 && point.y <= 0) {
            return;
        }
        
        if (point.x >= self.bounds.size.width && point.y >= self.bounds.size.height) {
            return;
        }
        [drawAction.paint addPoint:point];   
    }
}
- (void)setPenType:(ItemType)penType
{
    _penType = penType;
}

- (BOOL)isEventLegal:(UIEvent *)event
{
    if(event && ([[event allTouches] count] == 1))
    {
        return YES;
    }
    return NO;
}
- (CGPoint)touchPoint:(UIEvent *)event
{
    for (UITouch *touch in [event allTouches]) {
        CGPoint point = [touch locationInView:self];
        return point;
    }    
    return ILLEGAL_POINT;
}

- (void)addNewPaint
{
    Paint *currentPaint = [Paint paintWithWidth:self.lineWidth color:self.lineColor penType:_penType];
    _currentDrawAction = [DrawAction actionWithType:DRAW_ACTION_TYPE_DRAW paint:currentPaint];
    [self.drawActionList addObject:_currentDrawAction];

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if ([self isEventLegal:event]) {
        UITouch *touch = [touches anyObject];
        _previousPoint1 = [touch previousLocationInView:self];
        _previousPoint2 = [touch previousLocationInView:self];
        CGPoint point = [self touchPoint:event];
        if (![DrawUtils isIllegalPoint:point]) {
            _currentPoint = point;
            [self addNewPaint];
            if (self.delegate && [self.delegate 
                                  respondsToSelector:@selector(didStartedTouch:)]) {
                [self.delegate didStartedTouch:_currentDrawAction.paint];
            }
            [self touchesMoved:touches withEvent:event];
        }
        
    }    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self isEventLegal:event]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didDrawedPaint:)]) {
            [self.delegate didDrawedPaint:_currentDrawAction.paint];
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self isEventLegal:event]) {
        
        UITouch *touch  = [touches anyObject];
        
        _previousPoint2  = _previousPoint1;
        _previousPoint1  = [touch previousLocationInView:self];
        _currentPoint    = [touch locationInView:self];
        
        // calculate mid point
        
        CGPoint mid1 = [DrawUtils midPoint1:_previousPoint1
                                     point2:_previousPoint2];
        
        CGPoint mid2 = [DrawUtils midPoint1:_currentPoint
                                     point2:_previousPoint1];
                
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, mid1.x, mid1.y);
        CGPathAddQuadCurveToPoint(path, NULL, _previousPoint1.x, _previousPoint1.y, mid2.x, mid2.y);
        CGRect bounds = CGPathGetBoundingBox(path);
        CGPathRelease(path);
        
        CGRect drawBox = bounds;
        
        //Pad our values so the bounding box respects our line width
        drawBox.origin.x        -= self.lineWidth * 2;
        drawBox.origin.y        -= self.lineWidth * 2;
        drawBox.size.width      += self.lineWidth * 4;
        drawBox.size.height     += self.lineWidth * 4;
        
        
        UIGraphicsBeginImageContext(drawBox.size);
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        self.curImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        _drawRectType = DrawRectTypeLine;
        [self setNeedsDisplayInRect:drawBox];

        
        CGPoint point = [self touchPoint:event];
        [self addPoint:point toDrawAction:_currentDrawAction];
    }
}

#pragma mark Constructor & Destructor

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.lineColor = [DrawColor blackColor];
        self.lineWidth = DEFAULT_LINE_WIDTH;
        self.simplingDistance = DEFAULT_SIMPLING_DISTANCE;
        _drawActionList = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor whiteColor];        
        _startDrawActionIndex = 0;
    }
    
    
    return self;
}

- (void)dealloc
{
    PPDebug(@"%@ dealloc", [self description]);
    PPRelease(_drawActionList);
    PPRelease(_lineColor);
    [super dealloc];
}



#pragma mark - Revoke

- (BOOL)canRevoke
{
    return [_drawActionList count] > 0;
}
- (void)revoke
{
    if ([self canRevoke]) {
        [_drawActionList removeLastObject];
        [self resetStartIndex];
        _drawRectType = DrawRectTypeRedraw;
        [self setNeedsDisplay];        
    }
}

@end
