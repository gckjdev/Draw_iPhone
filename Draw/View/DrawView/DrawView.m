//
//  DrawView.m
//  Draw
//
//  Created by  on 12-3-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DrawView.h"
#import "Paint.h"
#import "DrawColor.h"
#import "DrawUtils.h"
#import "DrawAction.h"
#import <QuartzCore/QuartzCore.h>
#import "PPDebug.h"


typedef enum{
    
    DrawRectTypeLine = 1,//touch draw
    DrawRectTypeClean = 2,//clean the screen
    DrawRectTypeRedraw = 3,//show the previous action list
    DrawRectTypeChangeBack = 4,//show the previous action list
    
}DrawRectType;

@interface DrawView()
{
//    BOOL _drawFullRect;
    DrawRectType _drawRectType;
    CGPoint _currentPoint;
    CGPoint _previousPoint1;
    CGPoint _previousPoint2;
    UIImage *_curImage;
    
    CGColorRef _changeBackColor;
}
#pragma mark Private Helper function

CGPoint midPoint(CGPoint p1, CGPoint p2);
- (void)drawPaint:(Paint *)paint;
@end

#define DEFAULT_PLAY_SPEED (1/40.0)
#define DEFAULT_SIMPLING_DISTANCE (5.0)
#define DEFAULT_LINE_WIDTH (2.0 * 1.414)

@implementation DrawView

@synthesize lineColor = _lineColor;
@synthesize lineWidth = _lineWidth;
@synthesize delegate = _delegate;
@synthesize simplingDistance = _simplingDistance;
@synthesize drawActionList = _drawActionList;
@synthesize penType = _penType;

#pragma mark Action Funtion

CGPoint midPoint(CGPoint p1, CGPoint p2)
{
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
}

- (void)resetStartIndex
{
    int count = [self.drawActionList count];
    while (count > 0) {
        DrawAction *action = [self.drawActionList objectAtIndex:--count];
        if (action && action.type == DRAW_ACTION_TYPE_CLEAN) {
            startDrawActionIndex = count+1;
            return;
        }else if ([action isChnageBackAction]) {
            startDrawActionIndex = count;
            _changeBackColor = action.paint.color.CGColor;
            return;
        }
    }
    startDrawActionIndex = 0;
}

- (void)addCleanAction
{
    DrawAction *cleanAction = [DrawAction actionWithType:DRAW_ACTION_TYPE_CLEAN paint:nil];
    [self.drawActionList addObject:cleanAction];
    startDrawActionIndex = [self.drawActionList count];
    _drawRectType = DrawRectTypeClean;
    [self setNeedsDisplay];
}

- (DrawAction *)addChangeBackAction:(DrawColor *)color
{
    DrawAction *action = [DrawAction changeBackgroundActionWithColor:color];
    _changeBackColor = color.CGColor;
    [self.drawActionList addObject:action];
    startDrawActionIndex = [self.drawActionList count] - 1;
    _drawRectType = DrawRectTypeChangeBack;
    [self setNeedsDisplay];
    return action;
}

- (void)clearAllActions
{
    [self.drawActionList removeAllObjects];
    startDrawActionIndex = 0;
    _drawRectType = DrawRectTypeClean;
    [self setNeedsDisplay];
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
        CGPoint mid1    = midPoint(_previousPoint1, _previousPoint2); 
        CGPoint mid2    = midPoint(_currentPoint, _previousPoint1);
        
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
        _curImage = UIGraphicsGetImageFromCurrentImageContext();
        [_curImage retain];
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
        startDrawActionIndex = 0;
    }
    
    
    return self;
}

- (void)dealloc
{
    PPRelease(_drawActionList);
    PPRelease(_lineColor);
    [super dealloc];
}

#pragma mark drawRect

- (void)drawPoint:(CGFloat)width color:(CGColorRef)cgColor
{
    CGPoint mid1 = midPoint(_previousPoint1, _previousPoint2); 
    CGPoint mid2 = midPoint(_currentPoint, _previousPoint1);
    
    CGContextRef context = UIGraphicsGetCurrentContext(); 
    
    [self.layer renderInContext:context];
    
    CGContextMoveToPoint(context, mid1.x, mid1.y);
    CGContextAddQuadCurveToPoint(context, _previousPoint1.x, _previousPoint1.y, mid2.x, mid2.y); 
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, width);
//    PPDebug(@"drawPoint width = %f", width);
    
    CGContextSetStrokeColorWithColor(context, cgColor);
    
    CGContextStrokePath(context);

}

- (void)drawPaint:(Paint *)paint
{ 
//    CGContextRef context = UIGraphicsGetCurrentContext(); 
    if ([paint pointCount] != 0) {
        _currentPoint = _previousPoint1 = _previousPoint2 = [paint pointAtIndex:0];
//        CGPoint mid1 = midPoint(_previousPoint1, _previousPoint2); 
//        CGContextMoveToPoint(context, mid1.x, mid1.y);
//        CGContextSetLineCap(context, kCGLineCapRound);
//        CGContextSetLineWidth(context, paint.width);
//        CGContextSetStrokeColorWithColor(context, paint.color.CGColor);

    }
    for (int i = 0; i < [paint pointCount]; ++ i) {
        _currentPoint = [paint pointAtIndex:i];
        [self drawPoint:paint.width color:paint.color.CGColor];
//        [self drawPoint:paint.width color:paint.color.CGColor];
        
//        CGPoint mid1 = midPoint(_previousPoint1, _previousPoint2); 
//        CGPoint mid2 = midPoint(_currentPoint, _previousPoint1);
    
//        [self.layer renderInContext:context];
        
//        CGContextAddQuadCurveToPoint(context, _previousPoint1.x, _previousPoint1.y, mid2.x, mid2.y); 
        _previousPoint2 = _previousPoint1;
        _previousPoint1 = _currentPoint;
    }
//    CGContextStrokePath(context);
}

- (void)drawRectRedraw:(CGRect)rect
{
    for (int j = startDrawActionIndex; j < self.drawActionList.count; ++ j) {
        DrawAction *drawAction = [self.drawActionList objectAtIndex:j];
        if (drawAction.type == DRAW_ACTION_TYPE_DRAW) {        
            Paint *paint = drawAction.paint;
            [self drawPaint:paint];

        }
    }
}

- (void)drawRect:(CGRect)rect
{
    
    switch (_drawRectType) {
        case DrawRectTypeLine:
        {
            [_curImage drawAtPoint:CGPointMake(0, 0)];
            [self drawPoint:self.lineWidth color:self.lineColor.CGColor];
            [super drawRect:rect];
            [_curImage release];
        }
            break;
        case DrawRectTypeRedraw:
            [self drawRectRedraw:rect];
            break;
        case DrawRectTypeChangeBack:
        {
            CGContextRef context = UIGraphicsGetCurrentContext(); 
            CGContextSetFillColorWithColor(context, _changeBackColor);
            CGContextFillRect(context, self.bounds);
        }
            break;
        case DrawRectTypeClean:

        default:
            break;
    }    
}


- (UIImage*)createImage
{
    CGRect rect = self.frame;
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

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

- (BOOL)isViewBlank
{
    return [DrawAction isDrawActionListBlank:self.drawActionList];
}


- (void)show
{
    [self resetStartIndex];
    _drawRectType = DrawRectTypeRedraw;
    [self setNeedsDisplay];
}
@end
