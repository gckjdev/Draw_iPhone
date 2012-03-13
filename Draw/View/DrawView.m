//
//  DrawView.m
//  Draw
//
//  Created by  on 12-3-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DrawView.h"
#import "Paint.h"

#define DEFAULT_PLAY_SPEED (1/40.0)

@implementation DrawView
@synthesize drawEnabled = _drawEnable;
@synthesize paintList = _paintList;
@synthesize lineColor = _lineColor;
@synthesize lineWidth = _lineWidth;
@synthesize status = _status;
@synthesize playSpeed= _playSpeed;


#pragma mark Action Funtion

- (void)clear
{
    [self.paintList removeAllObjects];
    [self setDrawEnabled:YES];
    _status = Drawing;
    [self setNeedsDisplay];
}

- (void)play
{
    _status = Playing;
    _paintPosition = CGPointMake(0, -1);
    
    [self setDrawEnabled:NO];
    [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(nextFrame:) userInfo:nil repeats:NO];
}

#pragma mark function called by player

- (CGPoint)pointForPaintPosition:(CGPoint)position
{
    NSInteger x = position.x;
    NSInteger y = position.y;
    if (x < 0 || x >= [self.paintList count]) {
        return ILLEGAL_POINT;
    }
    Paint *paint = [self.paintList objectAtIndex:x];
    if (y < 0 || y >= [paint pointCount]) {
        return ILLEGAL_POINT;
    }
    return [paint pointAtIndex:y];
}

- (BOOL)increasePaintPosition
{
    NSInteger x = _paintPosition.x;
    NSInteger y = _paintPosition.y;
    if (x < [self.paintList count]) {
        Paint *paint = [self.paintList objectAtIndex:x];
        if (y < [paint pointCount]) {
            _paintPosition.y ++;
            NSInteger count = [paint pointCount];
            if (_paintPosition.y == count) {
                _paintPosition.y = 0;
                _paintPosition.x ++;
            }
            return YES;
        }
    }
    return NO;
}

- (void)nextFrame:(NSTimer *)theTimer;
{
    CGPoint lastPoint = [self pointForPaintPosition:_paintPosition];
    BOOL flag = [self increasePaintPosition];
    if (!flag) {
        [theTimer invalidate];
        theTimer = nil;
        _status = Drawing;
        return;
    }
    CGPoint currentPoint = [self pointForPaintPosition:_paintPosition];
    if (![DrawUtils isIllegalPoint:lastPoint] && ![DrawUtils isIllegalPoint:currentPoint]) {
        CGRect rect = [DrawUtils constructWithPoint1:lastPoint point2:currentPoint];
        [self setNeedsDisplayInRect:rect];
    }
    [self setNeedsDisplay];
}

- (void)setDrawEnabled:(BOOL)drawEnabled
{
    pan.enabled = drawEnabled;
    tap.enabled = drawEnabled;
}

#pragma mark Gesture Handler
- (void)addPoint:(CGPoint)point toPaint:(Paint *)paint
{
    if (paint) {
        
        CGPoint lastPoint = ILLEGAL_POINT;
        if ([self.paintList count] != 0) {
            Paint *paint = [self.paintList lastObject];
            NSInteger index = paint.pointCount - 1;
            if (index >= 0) {
                lastPoint = [paint pointAtIndex:index];
            }
        }

        [paint addPoint:point];   
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
        currentPaint = [[Paint alloc] initWithWidth:self.lineWidth color:self.lineColor];
        [self.paintList addObject:currentPaint];
        [currentPaint release];
        [self addPoint:point toPaint:currentPaint];

    }else if(panGestuereReconizer.state == UIGestureRecognizerStateChanged)
    {
        [self addPoint:point toPaint:currentPaint];

    }else if(panGestuereReconizer.state == UIGestureRecognizerStateEnded)
    {
        [self addPoint:point toPaint:currentPaint];

    }
}

- (void) performTap:(UITapGestureRecognizer *)tapGestuereReconizer
{
    
    if(tapGestuereReconizer.state == UIGestureRecognizerStateEnded)
    {
        CGPoint point = [tapGestuereReconizer locationInView:self];
        currentPaint = [[Paint alloc] initWithWidth:self.lineWidth color:self.lineColor];
        [self.paintList addObject:currentPaint];
        [currentPaint release];
        [self addPoint:point toPaint:currentPaint];
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

        _status = Drawing;
        self.lineColor = [UIColor blackColor];
        self.lineWidth = 5.0;
        self.playSpeed = DEFAULT_PLAY_SPEED;
        _paintList = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor whiteColor];
        
        //add gesture recognizer;
        pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(performPan:)];
        [self addGestureRecognizer:pan];
        [pan release];
        
        tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(performTap:)];
        [self addGestureRecognizer:tap];
        [tap release];
        
    }
    return self;
}

- (void)dealloc
{
    [_paintList release];
    [_lineColor release];
    [super dealloc];
}



#pragma mark drawRect

- (void)drawRect:(CGRect)rect
{

    CGContextRef context = UIGraphicsGetCurrentContext(); 
    CGContextSetLineCap(context, kCGLineCapRound);

    int k = 0;
    for (Paint *paint in self.paintList) {
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
            if (self.status == Playing && k == _paintPosition.x && i == _paintPosition.y) {
                CGContextStrokePath(context);            
                [NSTimer scheduledTimerWithTimeInterval:_playSpeed target:self selector:@selector(nextFrame:) userInfo:nil repeats:NO];
                return;
            }
        }
        
        CGContextStrokePath(context);            
        ++ k;

    }
}


@end
