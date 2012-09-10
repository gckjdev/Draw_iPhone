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
@synthesize penType = _penType;

//CGPoint midPoint(CGPoint p1, CGPoint p2)
//{
//    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
//}


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
    [self.drawActionList addObject:action];
    _startDrawActionIndex = [self.drawActionList count] - 1;
    _drawRectType = DrawRectTypeChangeBack;
    _changeBackColor = color.CGColor;
    [self setNeedsDisplay];
    return action;
}



- (void)setDrawEnabled:(BOOL)enabled
{
    self.userInteractionEnabled = enabled;
}

- (CGFloat)correctValue:(CGFloat)value max:(CGFloat)max min:(CGFloat)min
{
    if (value < min) 
        return min;
    if(value > max)
        return max;
    return value;
}

#pragma mark Gesture Handler
- (void)addPoint:(CGPoint)point toDrawAction:(DrawAction *)drawAction
{    
    if (drawAction) {
        
        point.x = [self correctValue:point.x max:self.bounds.size.width min:0];
        point.y = [self correctValue:point.y max:self.bounds.size.height min:0];
//        PPDebug(@"add point = %@", NSStringFromCGPoint(point));
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
    
//    PPDebug(@"touch began");
    UITouch *touch = [touches anyObject];
    
    _previousPoint1 = [touch previousLocationInView:self];
    _previousPoint2 = [touch previousLocationInView:self];
    _currentPoint = [touch locationInView:self];
    [self addNewPaint];
    [self touchesMoved:touches withEvent:event];
    if (self.delegate && [self.delegate 
                            respondsToSelector:@selector(didStartedTouch:)]) {
            [self.delegate didStartedTouch:_currentDrawAction.paint];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    PPDebug(@"touch end");
    [self touchesMoved:touches withEvent:event];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didDrawedPaint:)]) {
        [self.delegate didDrawedPaint:_currentDrawAction.paint];
    }
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {

    
    UITouch *touch  = [touches anyObject];
    
    _previousPoint2  = _previousPoint1;
    _previousPoint1  = _currentPoint;
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
    drawBox.origin.x        -= self.lineWidth * 0.8;
    drawBox.origin.y        -= self.lineWidth * 0.8;
    drawBox.size.width      += self.lineWidth * 1.6;
    drawBox.size.height     += self.lineWidth * 1.6;
    
    
    UIGraphicsBeginImageContext(drawBox.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    self.curImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();
    
//    PPDebug(@"mid1=%@,mid2=%@", NSStringFromCGPoint(mid1),NSStringFromCGPoint(mid2));
//    PPDebug(@"setNeedsDisplayInRect rect = %@",NSStringFromCGRect(drawBox));
    
    _drawRectType = DrawRectTypeLine;
    
    [self setNeedsDisplayInRect:drawBox];
    
    [self addPoint:_currentPoint toDrawAction:_currentDrawAction];

}
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
}



#pragma mark Constructor & Destructor

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.lineColor = [DrawColor blackColor];
        self.lineWidth = DEFAULT_LINE_WIDTH;
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
