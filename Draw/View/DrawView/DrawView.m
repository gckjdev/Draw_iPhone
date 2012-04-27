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


#define DEFAULT_PLAY_SPEED (1/40.0)
#define DEFAULT_SIMPLING_DISTANCE (1.0)
#define DEFAULT_LINE_WIDTH (4.0 * 1.414)

@implementation DrawView

@synthesize lineColor = _lineColor;
@synthesize lineWidth = _lineWidth;
@synthesize delegate = _delegate;
@synthesize simplingDistance = _simplingDistance;
@synthesize drawActionList = _drawActionList;
#pragma mark Action Funtion


- (void)addCleanAction
{
    DrawAction *cleanAction = [DrawAction actionWithType:DRAW_ACTION_TYPE_CLEAN paint:nil];
    [self addAction:cleanAction];
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
//    [self printListCount:nil];

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
        
    }

}

- (void) performPan:(UIPanGestureRecognizer *)panGestuereReconizer
{
    CGPoint point = [panGestuereReconizer locationInView:self];
    if (panGestuereReconizer.state == UIGestureRecognizerStateBegan) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didStartedTouch)]) {
            [self.delegate didStartedTouch];
        }
        Paint *currentPaint = [Paint paintWithWidth:self.lineWidth color:self.lineColor];
        _currentDrawAction = [DrawAction actionWithType:DRAW_ACTION_TYPE_DRAW paint:currentPaint];
        [self.drawActionList addObject:_currentDrawAction];
        [self addPoint:point toDrawAction:_currentDrawAction];

    }else if(panGestuereReconizer.state == UIGestureRecognizerStateChanged)
    {
        [self addPoint:point toDrawAction:_currentDrawAction];

    }else if(panGestuereReconizer.state == UIGestureRecognizerStateEnded)
    {
        [self addPoint:point toDrawAction:_currentDrawAction];
        if (self.delegate && [self.delegate respondsToSelector:@selector(didDrawedPaint:)]) {
            [self.delegate didDrawedPaint:_currentDrawAction.paint];
        }

    }
}

- (void) performTap:(UITapGestureRecognizer *)tapGestuereReconizer
{
    
    if(tapGestuereReconizer.state == UIGestureRecognizerStateEnded)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didStartedTouch)]) {
            [self.delegate didStartedTouch];
        }
        CGPoint point = [tapGestuereReconizer locationInView:self];
        Paint *currentPaint = [Paint paintWithWidth:self.lineWidth color:self.lineColor];
        _currentDrawAction = [DrawAction actionWithType:DRAW_ACTION_TYPE_DRAW paint:currentPaint];
        [self.drawActionList addObject:_currentDrawAction];
        [self addPoint:point toDrawAction:_currentDrawAction];
        
        [self addPoint:point toDrawAction:_currentDrawAction];
        if (self.delegate && [self.delegate respondsToSelector:@selector(didDrawedPaint:)]) {
            [self.delegate didDrawedPaint:_currentDrawAction.paint];
        }
    }
}

#pragma mark Gesture Delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return (gestureRecognizer.view == self);
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
        originalActionList = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor whiteColor];        
//        self.backgroundColor = [UIColor yellowColor];
        //add gesture recognizer;
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(performPan:)];
        [self addGestureRecognizer:pan];
        [pan release];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(performTap:)];
        [self addGestureRecognizer:tap];
        [tap release];
        
        startDrawActionIndex = 0;
        
    }
    
    
    return self;
}

- (void)dealloc
{
    [_drawActionList release];
    [_lineColor release];
    [originalActionList release];
    [super dealloc];
}

#pragma mark drawRect

- (void)drawRect:(CGRect)rect
{

    CGContextRef context = UIGraphicsGetCurrentContext(); 
    CGContextSetLineCap(context, kCGLineCapRound);

    
    for (int j = startDrawActionIndex; j < self.drawActionList.count; ++ j) {
        
        DrawAction *drawAction = [self.drawActionList objectAtIndex:j];
        Paint *paint = drawAction.paint;
        if (drawAction.type == DRAW_ACTION_TYPE_DRAW) { //if is draw action 
            CGContextSetStrokeColorWithColor(context, paint.color.CGColor);
            CGContextSetLineWidth(context, paint.width);
            for (int i = 0; i < [paint pointCount]; ++ i) {
                CGPoint point = [paint pointAtIndex:i];
                if ([paint pointCount] == 1) {
                    //if tap gesture, draw a circle
                    CGContextSetFillColorWithColor(context, paint.color.CGColor);
                    CGFloat r = paint.width / 2;
                    CGFloat x = point.x - r;
                    CGFloat y = point.y - r;
                    CGFloat width = paint.width;
                    CGRect rect = CGRectMake(x, y, width, width);
                    CGContextFillEllipseInRect(context, rect);
                }else{
                    //if is pan gesture, draw a line.
                    if (i == 0) {
                        CGContextMoveToPoint(context, point.x, point.y);   
                    }else{
                        CGContextAddLineToPoint(context, point.x, point.y);
                        CGContextSetLineJoin(context, kCGLineJoinRound);
                    }
                }
            //if is playing then play the next frame
            }
        }

        CGContextStrokePath(context); 
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
