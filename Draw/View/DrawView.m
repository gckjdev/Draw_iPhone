//
//  DrawView.m
//  Draw
//
//  Created by  on 12-3-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DrawView.h"
#import "Paint.h"

#define DEFAULT_PLAY_SPEED (1/30.0)

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
    _paintPosition = CGPointMake(0, 0);
    
    [self setDrawEnabled:NO];
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(nextFrame:) userInfo:nil repeats:NO];
}

#pragma mark function called by player

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
    BOOL flag = [self increasePaintPosition];
    if (!flag) {
        [theTimer invalidate];
        theTimer = nil;
        _status = Drawing;
        return;
    }
    [self setNeedsDisplay];
}

- (void)setDrawEnabled:(BOOL)drawEnabled
{
    pan.enabled = drawEnabled;
}

#pragma mark Gesture Handler
- (void)addPoint:(CGPoint)point toPaint:(Paint *)paint
{
    if (paint) {
        [paint addPoint:point];   
        [self setNeedsDisplay];
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
        self.lineWidth = 2.0;
        self.playSpeed = DEFAULT_PLAY_SPEED;
        _paintList = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor whiteColor];
        
        //add gesture recognizer;
        pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(performPan:)];
        [self addGestureRecognizer:pan];
        [pan release];
        
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
    int k = 0;
    for (Paint *paint in self.paintList) {
        CGContextSetStrokeColorWithColor(context, paint.color.CGColor);
        CGContextSetLineWidth(context, paint.width);
        for (int i = 0; i < [paint pointCount]; ++ i) {
                        
            CGPoint point = [paint pointAtIndex:i];
            if (i == 0) {
                CGContextMoveToPoint(context, point.x, point.y);   
            }else{
                CGContextAddLineToPoint(context, point.x, point.y);
            }
            if (self.status == Playing && k == _paintPosition.x && i == _paintPosition.y) {
                CGContextStrokePath(context);            
                [NSTimer scheduledTimerWithTimeInterval:1/30.0 target:self selector:@selector(nextFrame:) userInfo:nil repeats:NO];
                return;
            }
        }
        
        CGContextStrokePath(context);            
        ++ k;

    }
}


@end
