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
#define DEFAULT_SIMPLING_DISTANCE (5.0)
#define DEFAULT_LINE_WIDTH (4.0 * 1.414)

@implementation DrawView
@synthesize drawEnabled = _drawEnable;
//@synthesize paintList = _paintList;
@synthesize lineColor = _lineColor;
@synthesize lineWidth = _lineWidth;
@synthesize status = _status;
@synthesize playSpeed= _playSpeed;
@synthesize delegate = _delegate;
@synthesize simplingDistance = _simplingDistance;
@synthesize drawActionList = _drawActionList;
#pragma mark Action Funtion


- (void)clear
{
    DrawAction *drawAction = [DrawAction actionWithType:DRAW_ACTION_TYPE_CLEAN paint:nil];
    [self.drawActionList addObject:drawAction];
    _currentDrawAction = drawAction;
    _status = Unplaying;
    [self setNeedsDisplay];
}

- (void)playFromDrawActionIndex:(NSInteger)index
{
    _status = Playing;
    _playingAction = [self.drawActionList objectAtIndex:index];
    _playingPointIndex = -1;
    _playingActionIndex = index;
    [self setDrawEnabled:NO];
    _playTimer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(nextFrame:) userInfo:nil repeats:NO];
}

- (void)play
{
    [self playFromDrawActionIndex:0];
}


- (void)addDrawAction:(DrawAction *)action play:(BOOL)play
{
    if (play) {
        [self.drawActionList addObject:action];
        if (self.status == Playing) {
            return;
        }
        [self playFromDrawActionIndex:[self.drawActionList count] -1];
    }else{
        [self.drawActionList addObject:action];
        [self setNeedsDisplay];
    }
}


#pragma mark function called by player


- (NSInteger)pointCountForDrawAction:(DrawAction *)drawAction
{
    if (drawAction.type == DRAW_ACTION_TYPE_CLEAN) {
        return 0;
    }else{
        Paint *paint = [drawAction paint];
        return paint.pointCount;
    }
}

- (void)nextFrame:(NSTimer *)theTimer;
{

    NSInteger pointCount = [self pointCountForDrawAction:_playingAction];
    _playingPointIndex ++;
    if (_playingPointIndex < pointCount) {
        //can play this action
    }else{
        //play next action
        _playingPointIndex = 0;
        _playingActionIndex ++;
        if ([self.drawActionList count] > _playingActionIndex) {
            _playingAction = [self.drawActionList objectAtIndex:_playingActionIndex];

        }else{
            //illegal
            _status = Unplaying;
            return;
        }
    }

    [self setNeedsDisplay];
    
}

- (void)setDrawEnabled:(BOOL)drawEnabled
{
    pan.enabled = drawEnabled;
    tap.enabled = drawEnabled;
    _drawEnable = drawEnabled;
}

#pragma mark Gesture Handler
- (void)addPoint:(CGPoint)point toPaint:(Paint *)paint
{
//    [self printListCount:nil];

    if (paint) {
        point.x = MAX(point.x, 0);
        point.y = MAX(point.y, 0);
        point.x = MIN(point.x, self.bounds.size.width);
        point.y = MIN(point.y, self.bounds.size.height);

        CGPoint lastPoint = ILLEGAL_POINT;
        if ([self.drawActionList count] != 0) {
            //simpling the point distance
            DrawAction *drawAction = [self.drawActionList lastObject];
            Paint *paint = [drawAction paint];
            NSInteger index = paint.pointCount - 1;
            if (index >= 0) {
                lastPoint = [paint pointAtIndex:index];
                if ([DrawUtils distanceBetweenPoint:lastPoint point2:point] <= _simplingDistance) {
                    return;
                }
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
        if (self.delegate && [self.delegate respondsToSelector:@selector(didStartedTouch)]) {
            [self.delegate didStartedTouch];
        }
        currentPaint = [[Paint alloc] initWithWidth:self.lineWidth color:self.lineColor];
        DrawAction *drawAction = [DrawAction actionWithType:DRAW_ACTION_TYPE_DRAW paint:currentPaint];
        _currentDrawAction = drawAction;
        [self.drawActionList addObject:drawAction];
        [currentPaint release];
        [self addPoint:point toPaint:currentPaint];

    }else if(panGestuereReconizer.state == UIGestureRecognizerStateChanged)
    {
        [self addPoint:point toPaint:currentPaint];

    }else if(panGestuereReconizer.state == UIGestureRecognizerStateEnded)
    {
        [self addPoint:point toPaint:currentPaint];
        if (self.delegate && [self.delegate respondsToSelector:@selector(didDrawedPaint:)]) {
            [self.delegate didDrawedPaint:currentPaint];
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
        currentPaint = [[Paint alloc] initWithWidth:self.lineWidth color:self.lineColor];
//        [self.paintList addObject:currentPaint];
        DrawAction *drawAction = [DrawAction actionWithType:DRAW_ACTION_TYPE_DRAW paint:currentPaint];
        _currentDrawAction = drawAction;
        [self.drawActionList addObject:drawAction];
        
        [currentPaint release];
        [self addPoint:point toPaint:currentPaint];
        if (self.delegate && [self.delegate respondsToSelector:@selector(didDrawedPaint:)]) {
            [self.delegate didDrawedPaint:currentPaint];
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

        _status = Unplaying;
        self.lineColor = [DrawColor blackColor];
        self.lineWidth = DEFAULT_LINE_WIDTH;
        self.simplingDistance = DEFAULT_SIMPLING_DISTANCE;
        self.playSpeed = DEFAULT_PLAY_SPEED;
        _drawActionList = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor whiteColor];
        
        //add gesture recognizer;
        pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(performPan:)];
        [self addGestureRecognizer:pan];
        [pan release];
        
        tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(performTap:)];
        [self addGestureRecognizer:tap];
        [tap release];
        
        [self setDrawEnabled:YES];
        
    }
    
    
    return self;
}

- (void)dealloc
{
    [_drawActionList release];
    [_lineColor release];
    [super dealloc];
}

- (NSInteger)lastCleanActionIndex
{
    int i = 0;
    for (DrawAction *action in self.drawActionList) {
        if (action.type == DRAW_ACTION_TYPE_CLEAN) {
            return i;
        }
        ++ i;
    }
    return  -1;
}

- (NSInteger)startPlayIndex
{
    NSInteger index = 0;
    NSInteger ans = 0;
    for (;index < self.drawActionList.count; ++index) {
        DrawAction *drawAction = [self.drawActionList objectAtIndex:index];
        if (_status == Playing) {
            if (index == _playingActionIndex) {
                return ans;
            }            
        }else {
            if (_currentDrawAction == drawAction) {
                return ans;
            }
        }
        if (drawAction.type == DRAW_ACTION_TYPE_CLEAN) {
            ans = index + 1;
        }
    }
    return 0;
}

#pragma mark drawRect

- (void)drawRect:(CGRect)rect
{

    CGContextRef context = UIGraphicsGetCurrentContext(); 
    CGContextSetLineCap(context, kCGLineCapRound);

    if (_status == Unplaying && _currentDrawAction && _currentDrawAction.type == DRAW_ACTION_TYPE_CLEAN)
    {
        return;
    }
    
    NSInteger startPlayIndex = [self startPlayIndex];
    for (int j = startPlayIndex; j < self.drawActionList.count; ++ j) {
        
        DrawAction *drawAction = [self.drawActionList objectAtIndex:j];
        int i = 0;

        Paint *paint = drawAction.paint;
        if (drawAction.type == DRAW_ACTION_TYPE_DRAW && paint) { //if is draw action 
            CGContextSetStrokeColorWithColor(context, paint.color.CGColor);
            CGContextSetLineWidth(context, paint.width);
            for (i = 0; i < [paint pointCount]; ++ i) {
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
                if (self.status == Playing && drawAction == _playingAction && i == _playingPointIndex) {
                    CGContextStrokePath(context);            
                    _playTimer = [NSTimer scheduledTimerWithTimeInterval:_playSpeed target:self selector:@selector(nextFrame:) userInfo:nil repeats:NO];
                    return;
                }
            }
        }else{ // if is clean action 
            //if is playing then play the next frame
            if (self.status == Playing && drawAction == _playingAction && i == _playingPointIndex) {
                CGContextStrokePath(context);            
                _playTimer = [NSTimer scheduledTimerWithTimeInterval:_playSpeed target:self selector:@selector(nextFrame:) userInfo:nil repeats:NO];
                return;
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

- (UIImage*)createImageByActions:(NSArray*)drawActions
{
//    [self.paintList removeAllObjects];
//    if (drawActions) {
//        for (DrawAction* action in drawActions) {
//            if (action.type == DRAW_ACTION_TYPE_DRAW) {
//                [self.paintList addObject:action.paint];
//            }
//        }
//    }
    return [self createImage];
}

//- (void)playDrawActionList:(NSArray*)actionList
//{
//    for (DrawAction* action in actionList) {
//        if (action.type == DRAW_ACTION_TYPE_DRAW) {
//            [self addPaint:action.paint play:YES];
//            NSLog(@"draw a paint");
//                } else {
//                    NSLog(@"clear");
//            }
//    }
//    
//}

@end
