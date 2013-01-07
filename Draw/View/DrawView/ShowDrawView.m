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
    [super cleanAllActions];
}

- (void)startTimer
{
//    PPDebug(@"ShowDrawView startTimer");
    self.playTimer = [NSTimer scheduledTimerWithTimeInterval:self.playSpeed target:self selector:@selector(handleTimer:) userInfo:nil repeats:NO];
}

- (void)movePen
{
    if (pen.superview == nil) {
        [self.superview addSubview:pen];
    }
    if (!_showPenHidden) {
        if ([_currentDrawAction isCleanAction] || 
            [_currentDrawAction isChangeBackAction]) {
            if (pen.hidden == NO) {
                pen.hidden = YES;                
            }
        }else{
            if (pen.hidden) {
                pen.hidden = NO;                
            }
            if (_playingPointIndex == 0 && pen.penType != _currentDrawAction.paint.penType) {                
                [pen setPenType:_currentDrawAction.paint.penType];
                PPDebug(@"penType = %d",pen.penType);
                if ([pen isRightDownRotate]) {
                    [pen.layer setTransform:CATransform3DMakeRotation(0.8, 0, 0, 1)];        
                }else{
                    [pen.layer setTransform:CATransform3DMakeRotation(4, 0, 0, 1)];
                }
            }
            CGPoint point = [_currentDrawAction.paint pointAtIndex:_playingPointIndex];
            if (![DrawUtils isIllegalPoint:point]) {
                CGFloat xOffset = self.frame.origin.x - self.superview.frame.origin.x;        
                CGFloat yOffset = self.frame.origin.y - self.superview.frame.origin.y;                
                point.x += xOffset;
                point.y += yOffset;
                if ([pen isRightDownRotate]) {                    
                    pen.center = CGPointMake(point.x + pen.frame.size.width / 3.1, point.y + pen.frame.size.height / 10.3);
                }else{
                    pen.center = CGPointMake(point.x + pen.frame.size.width / 2.5, point.y - pen.frame.size.height / 4.3);                                        
                }
            }
        }
    }
}

- (void)drawPoint
{
//    PPDebug(@"ShowDrawView draw Point");
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
//    drawBox.origin.x        -= lineWidth * 1;
//    drawBox.origin.y        -= lineWidth * 1;
//    drawBox.size.width      += lineWidth * 2;
//    drawBox.size.height     += lineWidth * 2;
    
    drawBox.origin.x        = (NSInteger)(drawBox.origin.x - lineWidth * 1) - 1;
    drawBox.origin.y        = (NSInteger)(drawBox.origin.y - lineWidth * 1) - 1;
    drawBox.size.width      = (NSInteger)(drawBox.size.width + lineWidth * 2) + 1;
    drawBox.size.height     = (NSInteger)(drawBox.size.height + lineWidth * 2) + 1;

//    PPDebug(@"rect = %@", NSStringFromCGRect(drawBox));
    
    UIGraphicsBeginImageContext(drawBox.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    self.curImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    _drawRectType = DrawRectTypeLine;
    
    
//    PPDebug(@"mid1=%@,mid2=%@", NSStringFromCGPoint(mid1),NSStringFromCGPoint(mid2));
//    PPDebug(@"setNeedsDisplayInRect rect = %@",NSStringFromCGRect(drawBox));
    [self setNeedsDisplayInRect:drawBox];
}

- (void)handleTimer:(NSTimer *)timer
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
//    PPDebug(@"showDrawView handleTimer, timer = %@",[timer description]);
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
        }else if([_currentDrawAction isChangeBackAction]){
            _playingActionIndex++;
            _playingPointIndex = 0;
            _drawRectType = DrawRectTypeChangeBack;
            _changeBackColor = _currentDrawAction.paint.color.CGColor;
            [self setNeedsDisplay];            
        }else if([_currentDrawAction isDrawAction] &&
                 [_currentDrawAction pointCount] > 0){
            [self movePen];
            //set the points
            if (_playingPointIndex == 0) {
                _previousPoint1 = _previousPoint2 = _currentPoint = [_currentDrawAction.paint pointAtIndex:_playingPointIndex];
            }else{
                _previousPoint2 = _previousPoint1;
                _previousPoint1 = _currentPoint;
                _currentPoint = [_currentDrawAction.paint pointAtIndex:_playingPointIndex];
            }
//            PPDebug(@"action Index = %d, pointIndex = %d, point = %@",_playingActionIndex, _playingPointIndex,NSStringFromCGPoint(_currentPoint));
            [self drawPoint];
            
            if (++_playingPointIndex >= [_currentDrawAction pointCount]) {
                _playingActionIndex++;
                _playingPointIndex = 0;
            }
        }else{
            
        }
        [self startTimer];
    }else if(_status != Stop){
        if (self.delegate && [self.delegate respondsToSelector:@selector(didPlayDrawView:)]) {
            [self.delegate didPlayDrawView:self];
        }
        [self setStatus:Stop];
        self.playTimer = nil;
        pen.hidden = YES;
    }
    });
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
    PPDebug(@"<ShowDrawView> play");
    [self playFromDrawActionIndex:0];
}
- (void)stop
{
    PPDebug(@"<ShowDrawView> stop");
    self.status = Stop;
    _drawRectType = DrawRectTypeNo; 
}


- (void)stopTimer
{
    if([_playTimer isValid])
    {
        [_playTimer invalidate];
    }
    _playTimer = nil;
}

- (void)show
{
    PPDebug(@"<ShowDrawView> show");
    self.status = Stop;
    [self stopTimer];
    [super show];
}
- (void)pause
{
    PPDebug(@"<ShowDrawView> pause");
    [self stopTimer];
}


- (void)resume
{
    PPDebug(@"<ShowDrawView> resume");
    if (![_playTimer isValid]) {
        [self stopTimer];
        [self startTimer];        
    }
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
    PPDebug(@"<performTapGuesture>");
    if(self.delegate && [self.delegate respondsToSelector:@selector(didClickShowDrawView:)]){
        [self.delegate didClickShowDrawView:self];
    }
}
- (void)performLongTapGuesture:(UILongPressGestureRecognizer *)tap
{
    PPDebug(@"<performLongTapGuesture>");
    if(self.delegate && [self.delegate respondsToSelector:@selector(didLongClickShowDrawView:)]){
        [self.delegate didLongClickShowDrawView:self];
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

- (void)addGestures
{
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(performTapGuesture:)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    [tap release];

    UILongPressGestureRecognizer *ltap = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(performLongTapGuesture:)];
    ltap.delegate = self;
    [self addGestureRecognizer:ltap];
    [ltap release];

}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.status = Stop;
        self.playSpeed = DEFAULT_PLAY_SPEED;
        _drawActionList = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor whiteColor];      
        //add tap guesture
        
        [self addGestures];
        
        //set pen
        pen = [[PenView alloc] initWithPenType:Pencil];
        [self setShowPenHidden:NO];
        pen.hidden = YES;
        pen.userInteractionEnabled = NO;
        pen.layer.transform = CATransform3DMakeRotation(-0.8, 0, 0, 1);
        [self.superview addSubview:pen];
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


//- (void)drawRect:(CGRect)rect
//{
//    if (_drawRectType == DrawRectTypeShowImage) {
//        [self stop];
//        [_image drawInRect:self.bounds];
//        PPDebug(@"<ShowDrawView> show Image");
//    }else{
//        [super drawRect:rect];
//    }
//}
@end
