//
//  DrawView.m
//  Draw
//
//  Created by  on 12-3-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ShowDrawView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageExt.h"
#import "UIImageUtil.h"
#import "PenView.h"
#import "Paint.h"

#define DEFAULT_PLAY_SPEED (1/30.0)
#define DEFAULT_SIMPLING_DISTANCE (5.0)
#define DEFAULT_LINE_WIDTH (4.0 * 1.414)

@implementation ShowDrawView
@synthesize playSpeed= _playSpeed;
@synthesize delegate = _delegate;

@synthesize status = _status;
@synthesize playTimer = _playTimer;
#pragma mark Action Funtion


- (DrawAction *)playingAction
{
    if (_playingActionIndex >= 0 && _playingActionIndex < [self.drawActionList count]) {
        return [self.drawActionList objectAtIndex:_playingActionIndex];
    }
    return nil;
}

- (void)cleanAllActions
{
    [self setStatus:Stop];
    
    // Add by Benson
    if ([_playTimer isValid]){
        [_playTimer invalidate];
    }
    
    self.playTimer = nil;
    _playingActionIndex = 0;
    _playingPointIndex = 0;
//    _startPlayIndex = 0;
//    _showDraw = NO;
    [super cleanAllActions];
}

- (void)startTimer
{
    PPDebug(@"ShowDrawView startTimer");
    self.playTimer = [NSTimer scheduledTimerWithTimeInterval:self.playSpeed target:self selector:@selector(handleTimer:) userInfo:nil repeats:NO];
}

- (void)movePen
{
    if (!_showPenHidden) {
        if ([_currentDrawAction isCleanAction] || 
            [_currentDrawAction isChnageBackAction]) {
            if (pen.hidden == NO) {
                pen.hidden = YES;                
            }
        }else{
            if (pen.hidden) {
                pen.hidden = NO;                
            }
            if (_playingPointIndex == 0 && pen.penType != _currentDrawAction.paint.penType) {                
                [pen setPenType:_currentDrawAction.paint.penType];
                if ([pen isRightDownRotate]) {
                    [pen.layer setTransform:CATransform3DMakeRotation(-0.8, 0, 0, 1)];        
                }else{
                    [pen.layer setTransform:CATransform3DMakeRotation(0.8, 0, 0, 1)];        
                }
            }
            CGPoint point = [_currentDrawAction.paint pointAtIndex:_playingPointIndex];
            if (![DrawUtils isIllegalPoint:point]) {
                if ([pen isRightDownRotate]) {
                    pen.center = CGPointMake(point.x + pen.frame.size.width / 3.1, point.y + pen.frame.size.height / 3.3);                    
                }else{
                    pen.center = CGPointMake(point.x + pen.frame.size.width / 2.5, point.y - pen.frame.size.height / 4.3);                                        
                }
            }
        }
    }
}

- (void)drawPoint
{
    PPDebug(@"ShowDrawView draw Point");
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
    
    CGFloat lineWidth = [_currentDrawAction.paint width];
    
    //Pad our values so the bounding box respects our line width
    drawBox.origin.x        -= lineWidth * 2;
    drawBox.origin.y        -= lineWidth * 2;
    drawBox.size.width      += lineWidth * 4;
    drawBox.size.height     += lineWidth * 4;
    
    UIGraphicsBeginImageContext(drawBox.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    self.curImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    _drawRectType = DrawRectTypeLine;
    [self setNeedsDisplayInRect:drawBox];
}

- (void)handleTimer:(NSTimer *)timer
{
    PPDebug(@"showDrawView handleTimer, timer = %@",[timer description]);
    _currentDrawAction = [self playingAction];
    if (_currentDrawAction && self.status == Playing) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didPlayDrawView:AtActionIndex:pointIndex:)]) {
            [self.delegate didPlayDrawView:self AtActionIndex:_playingActionIndex 
                                pointIndex:_playingPointIndex];
        }

        
        if ([_currentDrawAction isCleanAction]) {
            _playingActionIndex++;
            _playingPointIndex = 0;
            _drawRectType = DrawRectTypeClean;
            [self setNeedsDisplay];
        }else if([_currentDrawAction isChnageBackAction]){
            _playingActionIndex++;
            _playingPointIndex = 0;
            _drawRectType = DrawRectTypeChangeBack;
            [self setNeedsDisplay];            
        }else if([_currentDrawAction isDrawAction] &&
                 [_currentDrawAction pointCount] > 0){
//            [self movePen];
            //set the points
            if (_playingPointIndex == 0) {
                _previousPoint1 = _previousPoint2 = _currentPoint = [_currentDrawAction.paint pointAtIndex:_playingPointIndex];
            }else{
                _previousPoint2 = _previousPoint1;
                _previousPoint1 = _currentPoint;
                _currentPoint = [_currentDrawAction.paint pointAtIndex:_playingPointIndex];
            }
            
            [self drawPoint];
            
            if (++_playingPointIndex >= [_currentDrawAction pointCount]) {
                _playingActionIndex++;
                _playingPointIndex = 0;
            }


        }else{
            
        }
        [self startTimer];
    }else{
//        [self stop];
        [self setStatus:Stop];
        self.playTimer = nil;
    }
    
}

- (void)playFromDrawActionIndex:(NSInteger)index
{
    _playingActionIndex = index;
    _playingPointIndex = 0;
    self.status = Playing;
    [self startTimer];
}

- (void)play
{
    [self playFromDrawActionIndex:0];
}
- (void)stop
{
    self.status = Stop;
    _drawRectType = DrawRectTypeNo; 
}
- (void)show
{
    PPDebug(@"<ShowDrawView> show");
    self.status = Stop;
    [super show];
}
- (void)addDrawAction:(DrawAction *)action play:(BOOL)play
{
    if (play) {
        [self.drawActionList addObject:action];
        if (self.status == Playing) {
            return;
        }else{
            [self playFromDrawActionIndex:[self.drawActionList count] -1];
        }
    }else{
        [self.drawActionList addObject:action];
        [self show];
    }
}


- (void)performTapGuesture:(UITapGestureRecognizer *)tap
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(didClickShowDrawView:)]){
        [self.delegate didClickShowDrawView:self];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (gestureRecognizer.view == self) {
        return YES;
    }
    return NO;
}


#pragma mark Constructor & Destructor

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.status = Stop;
        self.playSpeed = DEFAULT_PLAY_SPEED;
        _drawActionList = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor whiteColor];      
        //add tap guesture
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(performTapGuesture:)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
        [tap release];
        
        //set pen
        pen = [[PenView alloc] initWithPenType:Pencil];
        [self setShowPenHidden:NO];
        pen.hidden = YES;
        pen.userInteractionEnabled = NO;
        pen.layer.transform = CATransform3DMakeRotation(-0.8, 0, 0, 1);
        [self addSubview:pen];
    }
    return self;
}

- (void)dealloc
{
    PPDebug(@"%@ dealloc", [self description]);
    _status = Stop;
    [self stop];
    // Add by Benson
    if ([_playTimer isValid]){
        PPDebug(@"<Debug> ShowDRawView Clear Play Timer");
        [_playTimer invalidate];
    }    

    PPRelease(_playTimer);
    PPRelease(_drawActionList);
    PPRelease(pen);
    [super dealloc];
}

- (NSInteger)lastCleanActionIndex
{
    int i = 0, ans = -1;
    for (DrawAction *action in self.drawActionList) {
        if (action.type == DRAW_ACTION_TYPE_CLEAN) {
            ans = i;
        }
        ++ i;
    }
    return  ans;
}


- (void)setShowPenHidden:(BOOL)showPenHidden
{
    _showPenHidden = showPenHidden;
    pen.hidden = showPenHidden;
}
- (BOOL)isShowPenHidden
{
    return _showPenHidden;
}


@end
