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


- (void)addCleanAction
{
    DrawAction *cleanAction = [DrawAction actionWithType:DRAW_ACTION_TYPE_CLEAN paint:nil];
    [self addAction:cleanAction];
//    pen.hidden = YES;
}
- (void)addAction:(DrawAction *)drawAction
{
    [self.drawActionList addObject:drawAction];
    if (drawAction.type == DRAW_ACTION_TYPE_CLEAN) {
        startDrawActionIndex = [self.drawActionList count];
    }
    [self setNeedsDisplay];
}

- (void)clearAllActions
{
    [self.drawActionList removeAllObjects];
    startDrawActionIndex = 0;
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
        point.x = MAX(point.x, 0);
        point.y = MAX(point.y, 0);
        point.x = MIN(point.x, self.bounds.size.width);
        point.y = MIN(point.y, self.bounds.size.height);
        
        CGPoint lastPoint = ILLEGAL_POINT;
        if ([self.drawActionList count] != 0) {
            //simpling the point distance
            Paint *paint = [drawAction paint];
            NSInteger index = paint.pointCount - 1;
            if (index >= 0) {
                lastPoint = [paint pointAtIndex:index];
                if ([DrawUtils distanceBetweenPoint:lastPoint point2:point] <= _simplingDistance) {
                    return;
                }
            }
        }
        
        [drawAction.paint addPoint:point];   
            
        if (![DrawUtils isIllegalPoint:lastPoint]) {
            CGRect rect = [DrawUtils constructWithPoint1:lastPoint point2:point edgeWidth:_lineWidth];        
            [self setNeedsDisplayInRect:rect];
        }else{
            [self setNeedsDisplay];
        }
        
//        if (pen.hidden) {
//            pen.hidden = NO;
//        }
//        if ([pen isRightDownRotate]) {
//            pen.center = CGPointMake(point.x + pen.frame.size.width / 3.1, point.y + pen.frame.size.height / 3.3);                    
//        }else{
//            pen.center = CGPointMake(point.x + pen.frame.size.width / 2.5, point.y - pen.frame.size.height / 4.3);                                        
//        }
    }
}
- (void)setPenType:(ItemType)penType
{
//    pen.penType = penType;
    _penType = penType;
//    if ([pen isRightDownRotate]) {
//        [pen.layer setTransform:CATransform3DMakeRotation(-0.8, 0, 0, 1)];        
//    }else{
//        [pen.layer setTransform:CATransform3DMakeRotation(0.8, 0, 0, 1)];        
//    }
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
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
        if ([self isEventLegal:event]) {
        CGPoint point = [self touchPoint:event];
        Paint *currentPaint = [Paint paintWithWidth:self.lineWidth color:self.lineColor penType:_penType];
        _currentDrawAction = [DrawAction actionWithType:DRAW_ACTION_TYPE_DRAW paint:currentPaint];
        [self.drawActionList addObject:_currentDrawAction];
        [self addPoint:point toDrawAction:_currentDrawAction];
        if (self.delegate && [self.delegate respondsToSelector:@selector(didStartedTouch:)]) {
            [self.delegate didStartedTouch:currentPaint];
        }
    }    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self isEventLegal:event]) {
        CGPoint point = [self touchPoint:event];
        [self addPoint:point toDrawAction:_currentDrawAction];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didDrawedPaint:)]) {
            [self.delegate didDrawedPaint:_currentDrawAction.paint];
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self isEventLegal:event]) {
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
        
//        pen = [[PenView alloc] initWithPenType:Pencil];
//        pen.hidden = YES;
//        pen.userInteractionEnabled = NO;
//        pen.layer.transform = CATransform3DMakeRotation(-0.8, 0, 0, 1);
//        [self addSubview:pen];
    }
    
    
    return self;
}

- (void)dealloc
{
    PPRelease(_drawActionList);
    PPRelease(_lineColor);
//    PPRelease(pen);
    [super dealloc];
}

#pragma mark drawRect

- (void)drawRect:(CGRect)rect
{
    
    CGContextRef context = UIGraphicsGetCurrentContext(); 
//    CGContextSetLineCap(context, kCGLineCapRound);
    
    
    for (int j = startDrawActionIndex; j < self.drawActionList.count; ++ j) {
        
        DrawAction *drawAction = [self.drawActionList objectAtIndex:j];
        Paint *paint = drawAction.paint;
        if (drawAction.type == DRAW_ACTION_TYPE_DRAW) { //if is draw action 
            CGContextSetStrokeColorWithColor(context, paint.color.CGColor);
            CGContextSetFillColorWithColor(context, paint.color.CGColor);
            
            UIBezierPath *path;
            path = [UIBezierPath bezierPath];
            for (int i = 0; i < [paint pointCount]; ++ i) {
                CGPoint point = [paint pointAtIndex:i];
                if (i == 0) {
                    [path moveToPoint:point];
                    [path setLineWidth:paint.width];
                    [path setLineCapStyle:kCGLineCapRound];
                    [path setLineJoinStyle:kCGLineJoinRound];
                }
                [path addLineToPoint:point];
            }
            [path stroke];
        }
        
        
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


- (BOOL)isViewBlank
{
    return [DrawAction isDrawActionListBlank:self.drawActionList];
}



@end
