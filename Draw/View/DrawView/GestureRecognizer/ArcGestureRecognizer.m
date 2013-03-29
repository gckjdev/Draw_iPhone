//
//  ArcGestureRecognizer.m
//  SourceProfile
//
//  Created by gamy on 13-3-11.
//  Copyright (c) 2013年 ict. All rights reserved.
//

#import "ArcGestureRecognizer.h"
#import "DrawUtils.h"


#define DETECT_POINT_NUMBER 4
#define DETECT_RADIAN 0.09
#define SUM_RADIAN 2
#define MIN_RADIAN 0.07

@interface TouchTrace : NSObject
{
    NSInteger count;
    CGPoint p1;
    CGPoint p2;
    CGPoint lastPoint10;
    NSInteger clockwistPointCont;
    NSInteger antiClockwistPointCont;

}
@property(nonatomic, retain)UITouch *touch;

@property(nonatomic, assign, readonly) CGFloat radian;
@property(nonatomic, assign, readonly) BOOL direction;
@property(nonatomic, assign) NSInteger index;
@property(nonatomic, assign) CGPoint startPoint;
//- (BOOL)isCircle;
- (void)update;
- (void)reset;
- (void)start;
- (NSInteger)pointCount;
@end

@implementation TouchTrace

- (void)dealloc
{
    [_touch dealloc];
    [super dealloc];
}

- (NSInteger)pointCount
{
    return count;
}

#define LAST_POINT_NUMBER 7

- (void)updateClockPoints:(BOOL)clockWise
{
    if (clockWise) {
        if (antiClockwistPointCont > 0) {
            antiClockwistPointCont --;
        }else if(clockwistPointCont < LAST_POINT_NUMBER * 2){
            clockwistPointCont ++;
        }
    }else{
        if (clockwistPointCont > 0) {
            clockwistPointCont --;
        }else if (antiClockwistPointCont < LAST_POINT_NUMBER * 2){
            antiClockwistPointCont ++;
        }
    }
    if (clockwistPointCont >= antiClockwistPointCont && !_direction) {
        _direction = YES;
        _radian = 0;
    }else if(antiClockwistPointCont >= clockwistPointCont && _direction){
        _direction = NO;
        _radian = 0;
    }
}

- (BOOL)directionStartPoint:(CGPoint)start lastPoint:(CGPoint) lastPoint endPoint:(CGPoint)end
{
    CGPoint a = lastPoint;
    CGPoint b = start;
    CGPoint c = end;
    float area = a.x * b.y - a.y * b.x + a.y * c.x - a.x * c.y + b.x * c.y - c.x * b.y;
    
    return area < 0;
}

- (void)start
{
    _startPoint = lastPoint10 = [self.touch locationInView:self.touch.view];
//    NSLog(@" TT %d START POINT = %@", _index, NSStringFromCGPoint(startPoint));
    count = 1;
    _radian = 0;
}

- (void)reset
{
    self.touch = nil;
    count = 0;
    _radian = 0;
    antiClockwistPointCont = clockwistPointCont = 0;
    lastPoint10 = _startPoint = CGPointZero;
}

//- (BOOL)isCircle
//{
//    NSLog(@"<isCircle> %d TT count = %d, radian = %f",_index, count, self.radian);
//    return (count >= DETECT_POINT_NUMBER) && (self.radian >= DETECT_RADIAN);
//}

- (void)updateRadianWithPoint:(CGPoint)point
{
    
    count ++;
    if (count % 10 == 0) {
        _startPoint = lastPoint10;
        lastPoint10 = point;
    }
    p1 = p2;
    p2 = point;
    if (count > 2) {
        CGFloat r = CGPointRadian(CGPointVector(_startPoint, p1), CGPointVector(_startPoint, p2));
        
//        NSLog(@" TT %d p1 = %@, p2 = %@  radian = %f",_index, NSStringFromCGPoint(p1), NSStringFromCGPoint(p2), r);
        
        if (r != 0) {
            
            BOOL drt = [self directionStartPoint:_startPoint lastPoint:p1 endPoint:p2];
            [self updateClockPoints:drt];
            _radian += r;
//            NSLog(@"direction = %d, drt = %d, radian = %f", self.direction, drt, _radian);
        }
        
    }
}


- (void)update
{
//    NSLog(@"TT update");
    [self updateRadianWithPoint:[self.touch locationInView:self.touch.view]];
}


@end


@interface ArcGestureRecognizer()
{
    TouchTrace *tTrace1;
    TouchTrace *tTrace2;
    BOOL _isTwoFingers;
    NSMutableSet *touchSet;
    NSTimeInterval start;
    BOOL failed;
    
}

@end





@implementation ArcGestureRecognizer
@synthesize direction = _direction;

- (BOOL)turnFailWithTouches:(NSSet *)touches
{
    for (UITouch *touch in touches) {
        CGPoint p = [touch locationInView:touch.view];
        CGPoint lp;
        CGFloat distance = 0;
        if (tTrace1.touch == touch) {
            lp = tTrace1.startPoint;
            distance = CGPointDistance(p, lp);
        }else {
            lp = tTrace2.startPoint;
            distance = CGPointDistance(p, lp);
        }
        PPDebug(@"distance = %f",distance);
        if (distance > 4) {
            [self removeTarget:self action:@selector(recognizerBegan)];
            return YES;
        }
    }
    return NO;
}

- (BOOL)direction
{
    if(tTrace1.direction == tTrace2.direction){
        _direction = tTrace1.direction;
    }
    return _direction;
}


- (CGFloat)radian
{
    return MAX(tTrace1.radian, tTrace2.radian);
}

- (id)initWithTarget:(id)target action:(SEL)action
{
    self = [super initWithTarget:target action:action];
    if (self) {
        tTrace2 = [[TouchTrace alloc] init];
        tTrace1 = [[TouchTrace alloc] init];
        tTrace1.index = 1;
        tTrace2.index = 2;
        touchSet = [[NSMutableSet alloc] initWithCapacity:2];

    }
    return self;
}


- (void)dealloc
{
    [tTrace2 release];
    [tTrace1 release];
    [touchSet release];
    [super dealloc];
}

- (void)reset
{
    [super reset];
    [tTrace1 reset];
    [tTrace2 reset];
    [touchSet removeAllObjects];
    start = 0;
    _isTwoFingers = NO;
}


- (void)startWith:(NSSet *)touches
{
    for (UITouch *touch in touches) {
        if (tTrace1.touch == nil) {
            tTrace1.touch = touch;
            [tTrace1 start];
        }else{
            tTrace2.touch = touch;
            [tTrace2 start];
        }
    }
}


- (void)recognizerBegan
{
    if (!failed) {
        self.state = UIGestureRecognizerStateBegan;
    }
}

- (void)updateWithTouches:(NSSet *)touches
{
    for (UITouch *touch in touches) {
        [touchSet addObject:touch];
    }
    if ([touchSet count] == 2 && !_isTwoFingers) {
        [self startWith:touchSet];
        _isTwoFingers = YES;
        [self performSelector:@selector(recognizerBegan) withObject:nil afterDelay:0.7];
        start = time(0);
    }else if([touchSet count] > 3){
        
        //TODO 
    }
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    failed = NO;
    [super touchesBegan:touches withEvent:event];
    [self updateWithTouches:touches];
}



- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    
    if (self.state == UIGestureRecognizerStateFailed) {
        return;
    }
    
    if (self.state == UIGestureRecognizerStatePossible) {
        [self updateWithTouches:touches];
        if ([self turnFailWithTouches:touches]) {
            self.state = UIGestureRecognizerStateFailed;
            failed = YES;
        }
    }else if([self state] == UIGestureRecognizerStateBegan || [self state] == UIGestureRecognizerStateChanged){
        [tTrace1 update];
        [tTrace2 update];
        self.state = UIGestureRecognizerStateChanged;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    NSLog(@"ARC End");
    failed = YES;
    self.state = UIGestureRecognizerStateRecognized;
    if (self.state == UIGestureRecognizerStateFailed) {
        return;
    }
    [tTrace1 update];
    [tTrace2 update];


}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"ARC Cancel");
    failed = YES;
    self.state = UIGestureRecognizerStateFailed;
    [super touchesCancelled:touches withEvent:event];

}


@end
