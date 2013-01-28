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
#import "ConfigManager.h"

//#define DEFAULT_PLAY_SPEED  (0.01)
//#define MIN_PLAY_SPEED      (0.001f)

@interface ShowDrawView ()
{
    NSInteger _playingActionIndex;
    NSInteger _playingPointIndex;
    
    BOOL _showPenHidden;
    PenView *pen;

}
@property (nonatomic, retain) Paint *tempPaint;

@end


@implementation ShowDrawView
@synthesize speed = _speed;
@synthesize delegate = _delegate;
@synthesize status = _status;


#pragma mark Action Funtion


- (void)cleanAllActions
{
    [self setStatus:Stop];
    
    _playingActionIndex = 0;
    _playingPointIndex = 0;
    [super cleanAllActions];
}

#define VALUE(x) (ISIPAD ? 2*x : x)
#define SHOWPEN_WIDTH VALUE(31)
#define SHOWPEN_HEIGHT VALUE(36.5)

- (void)movePen
{
    if (pen.superview == nil) {
        [self.superview addSubview:pen];
    }
        if (_currentAction == nil || [_currentAction isCleanAction] ||
            [_currentAction isChangeBackAction]) {
            pen.hidden = YES;
        }else{
            pen.hidden = NO;
            if (_playingPointIndex == 0 && pen.penType != _currentAction.paint.penType) {
                //reset pen type
                [pen setPenType:_currentAction.paint.penType];
            }
            CGPoint point = [_currentAction.paint pointAtIndex:_playingPointIndex];
            
            CGRect rect = CGRectZero;
            if (pen.penType != Eraser) {
                rect = CGRectMake(point.x, point.y-SHOWPEN_HEIGHT, SHOWPEN_WIDTH, SHOWPEN_HEIGHT);
            }else{
                rect = CGRectMake(point.x, point.y, SHOWPEN_WIDTH, SHOWPEN_HEIGHT);
            }
            pen.frame = [pen.superview convertRect:rect fromView:self];
        }
    
}


- (void)playFromDrawActionIndex:(NSInteger)index
{
    _playingActionIndex = index;
    _playingPointIndex = 0;
    if (index < [self.drawActionList count]) {
        _currentAction = [self.drawActionList objectAtIndex:index];        
        self.status = Playing;
        [self playCurrentFrame];
    }else{
        self.status = Stop;
        PPDebug(@"<playFromDrawActionIndex> index out of action array bounds. Stop");
    }
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
}

- (void)show
{
    PPDebug(@"<ShowDrawView> show");
    self.status = Stop;
    [super show];
}

- (CGFloat)showToIndex:(NSInteger)index
{
    CGContextClearRect(showContext, self.bounds);
//    for (NSInteger; <#condition#>; <#increment#>) {
//        <#statements#>
//    }
}


- (void)pause
{
    if(self.status == Playing){
        PPDebug(@"<ShowDrawView> pause");
        self.status = Pause;        
    }else{
        PPDebug(@"<ShowDrawView> not playing, pause failed");
    }
}


- (void)resume
{
    if (self.status == Pause) {
        PPDebug(@"<ShowDrawView> resume");
        self.status = Playing;
        [self playCurrentFrame];
    }else{
        PPDebug(@"<ShowDrawView> not pause, resume failed");
    }
}


- (void)addDrawAction:(DrawAction *)action play:(BOOL)play
{
    [self.drawActionList addObject:action];
    if (play) {
        if (self.status == Playing) {
            return;
        }else if(self.status == Stop){
            [self playFromDrawActionIndex:[self.drawActionList count] -1];
        }
    }else{
        self.status = Stop;
        CGRect rect = [self drawAction1:action inContext:showContext];
        [self setNeedsDisplayInRect:rect showCacheLayer:NO];
    }
}



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.status = Stop;
        self.speed = PlaySpeedTypeNormal;
        _drawActionList = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor whiteColor];      
        
        //set pen
        pen = [[PenView alloc] initWithPenType:Pencil];
        [self setShowPenHidden:NO];
        pen.hidden = YES;
        pen.userInteractionEnabled = NO;
        
        pen.penType = 0;
        self.playSpeed = [ConfigManager getDefaultPlayDrawSpeed];
        [self.superview addSubview:pen];
    }
    return self;
}

+ (ShowDrawView *)showView
{
    return [[[ShowDrawView alloc] initWithFrame:DRAW_VIEW_FRAME] autorelease];
}

+ (ShowDrawView *)showViewWithFrame:(CGRect)frame
                drawActionList:(NSArray *)actionList
                      delegate:(id<ShowDrawViewDelegate>)delegate
{
    ShowDrawView *showView = [ShowDrawView showView];
    if ([actionList isKindOfClass:[NSMutableArray class]]) {
        showView.drawActionList = (NSMutableArray *)actionList;
    }else{
        showView.drawActionList = [NSMutableArray arrayWithArray:actionList];
    }
    showView.delegate = delegate;
    [showView resetFrameSize:frame.size];
    showView.center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
    return showView;
}

+ (BOOL)canPlayDrawVersion:(NSInteger)version
{
    return [ConfigManager currentDrawDataVersion] >= version;
}

- (void)resetFrameSize:(CGSize)size
{
    CGFloat xScale = size.width / CGRectGetWidth(DRAW_VIEW_FRAME);
    CGFloat yScele = size.height / CGRectGetHeight(DRAW_VIEW_FRAME);
    [self.layer setTransform:CATransform3DMakeScale(xScale, yScele, 1)];
}


- (void)dealloc
{
    [self stop];
    PPRelease(_drawActionList);
    PPRelease(pen);
    PPRelease(_tempPaint);
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

- (void)updateNextPlayIndex
{
    if ( ++_playingPointIndex >= [_currentAction.paint pointCount]) {
        _playingPointIndex = 0;

        //next action
        if (++ _playingActionIndex < [self.drawActionList count]) {
            _currentAction = [self.drawActionList objectAtIndex:_playingActionIndex];
        }else{
            _currentAction = nil;
            _status = Stop;
        }
    }else{
        _playingPointIndex = MIN([_currentAction pointCount]-1, _playingPointIndex + 1); //self.speed);
    }
    
//    PPDebug(@"<updateNextPlayIndex> action=%d, index=%d ", _playingActionIndex, _playingPointIndex);
}

- (void)updateTempPaint
{
    Paint *cPaint = _currentAction.paint;
    int currentPaintPointCount = [cPaint pointCount];
    if (cPaint != nil &&  _playingPointIndex < currentPaintPointCount) {
        if (cPaint.pointCount > 0) {
            if (self.tempPaint == nil) {
                self.tempPaint = [Paint paintWithWidth:cPaint.width color:cPaint.color];
            }
            NSInteger i = [self.tempPaint pointCount];
            for (; i <= _playingPointIndex; ++ i) {
                CGPoint p = [cPaint pointAtIndex:i];
                [self.tempPaint addPoint:p];
            }
            
            if (i >= currentPaintPointCount){
                [self.tempPaint finishAddPoint];
            }
        }
    }else{
        self.tempPaint = nil;
    }
}

- (void)callDidDrawPaintDelegate
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didPlayDrawView:AtActionIndex:pointIndex:)]) {
        [self.delegate didPlayDrawView:self AtActionIndex:_playingActionIndex pointIndex:_playingPointIndex];
    }    
    if(_playingActionIndex >= [self.drawActionList count]-1 && self.delegate && [self.delegate respondsToSelector:@selector(didPlayDrawView:)]){
        [self.delegate didPlayDrawView:self];
    }
}

- (void)playCurrentFrame
{
    [self updateTempPaint];
    if (self.status == Playing) {
        if (self.tempPaint) {
            CGRect drawBox; // = [DrawUtils rectForPath:_tempPaint.path withWidth:_tempPaint.width bounds:self.bounds];
            if ([self.tempPaint pointCount] == [_currentAction.paint pointCount]) {
                self.tempPaint = nil;
                drawBox = [self drawAction1:_currentAction inContext:showContext];
                [self setNeedsDisplayInRect:drawBox showCacheLayer:NO];
                [self callDidDrawPaintDelegate];
                
            }else
            {
                [self setStrokeColor:self.tempPaint.color lineWidth:self.tempPaint.width inContext:cacheContext];
                drawBox = [self strokePaint1:self.tempPaint inContext:cacheContext clear:YES];
                [self setNeedsDisplayInRect:drawBox showCacheLayer:YES];
            }
        }else{
            CGRect drawBox = [self drawAction1:_currentAction inContext:showContext];
            [self setNeedsDisplayInRect:drawBox showCacheLayer:NO];
        }
    }
    if(!_showPenHidden){
        [self movePen];
    }
}

- (void)playNextFrame
{
    [self updateNextPlayIndex];
    _playFrameTime = CACurrentMediaTime();
    [self playCurrentFrame];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    if (Playing == self.status) {
        [self performSelector:@selector(playNextFrame) withObject:nil afterDelay:self.playSpeed];

        /*
        double now = CACurrentMediaTime();
//        double delay = DEFAULT_PLAY_SPEED;
        if (now - _playFrameTime > DEFAULT_PLAY_SPEED){
//            PPDebug(@"Exceed max delay");
            [self performSelector:@selector(playNextFrame) withObject:nil afterDelay:MIN_PLAY_SPEED];
        }
        else{
//            PPDebug(@"Normal delay");
            [self performSelector:@selector(playNextFrame) withObject:nil afterDelay:DEFAULT_PLAY_SPEED];
        }
        */
    }
}

#define LEVEL_TIMES 50

- (void)setDrawActionList:(NSMutableArray *)drawActionList
{
    [super setDrawActionList:drawActionList];
    NSInteger count = [self.drawActionList count];
    if (count < PlaySpeedTypeNormal * LEVEL_TIMES) {
        self.speed = PlaySpeedTypeLow;
    }else if(count < PlaySpeedTypeHigh * LEVEL_TIMES){
        self.speed = PlaySpeedTypeNormal;
    }else if(count < PlaySpeedTypeSuper* LEVEL_TIMES){
        self.speed = PlaySpeedTypeHigh;
    }else{
        self.speed = PlaySpeedTypeSuper;
    }
    PPDebug(@"<setDrawActionList>auto set speed: %d,actionCount = %d",self.speed, count);
}

@end



@implementation ShowDrawView (PressAction)

- (void)handlePress:(id)sender
{
    PPDebug(@"<handlePress>");
    if(_delegate && [self.delegate respondsToSelector:@selector(didClickShowDrawView:)])
    {
        [_delegate didClickShowDrawView:self];
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)lp
{
    if (lp.state == UIGestureRecognizerStateEnded) {
        PPDebug(@"<handleLongPress>");
        if (_delegate && [_delegate respondsToSelector:@selector(didLongClickShowDrawView:)]) {
            [_delegate didLongClickShowDrawView:self];
        }
    }
}

- (void)setPressEnable:(BOOL)enable
{
    self.userInteractionEnabled = enable;
    PPDebug(@"gesture recognizer count = %d",[self.gestureRecognizers count]);
    if (enable == YES ) {
        [self addTarget:self action:@selector(handlePress:) forControlEvents:UIControlEventTouchUpInside];
        if ([self.gestureRecognizers count] == 0) {
            //add long press gesture
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
            [self addGestureRecognizer:longPress];
            [longPress release];
        }

    }else{
        [self removeTarget:self action:@selector(handlePress:) forControlEvents:UIControlEventTouchUpInside];
    }
    
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return  gestureRecognizer.view == self;
}
@end