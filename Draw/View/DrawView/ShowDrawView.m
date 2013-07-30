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
#import "CanvasRect.h"
#import "DrawHolderView.h"
#import "ClipAction.h"
//#define DEFAULT_PLAY_SPEED  (0.01)
//#define MIN_PLAY_SPEED      (0.001f)

@interface ShowDrawView ()
{
    NSInteger _playingActionIndex;
    NSInteger _playingPointIndex;
    
    BOOL _showPenHidden;
    BOOL _supportLongPress;
    PenView *pen;

}
//@property (nonatomic, retain) Paint *tempPaint;
@property (nonatomic, retain) PaintAction *tempAction;
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
//    self.tempPaint = nil;
    self.tempAction = nil;
    _currentAction = nil;

    [super cleanAllActions];
}


- (void)resetView
{
    [self setStatus:Stop];
    _playingActionIndex = 0;
    _playingPointIndex = 0;

    self.tempAction = nil;
    _currentAction = nil;
    [dlManager reset];
    pen.hidden = YES;

}

#define VALUE(x) (ISIPAD ? 2*x : x)
#define SHOWPEN_WIDTH VALUE(31)
#define SHOWPEN_HEIGHT VALUE(36.5)

- (void)movePen
{
    if (pen.superview == nil) {
        [self.superview addSubview:pen];
    }
    
    if ([_currentAction isKindOfClass:[PaintAction class]]) {
        pen.hidden = NO;
        PaintAction *paintAction = (PaintAction *)_currentAction;
        if (_playingPointIndex == 0 && pen.penType != paintAction.paint.penType) {
            //reset pen type
            ItemType penType = paintAction.paint.penType;
/*
            if (isLearnDrawApp()) {
                if (penType != Eraser) {
                    penType = Pencil;
                }
            }
 */
            [pen setPenType:penType];
        }
        CGPoint point = [paintAction.paint pointAtIndex:_playingPointIndex];
//        CGRect rect = CGRectZero;
        point= [pen.superview convertPoint:point fromView:self];
        if (pen.penType != Eraser) {
            pen.frame = CGRectMake(point.x, point.y-SHOWPEN_HEIGHT, SHOWPEN_WIDTH, SHOWPEN_HEIGHT);
        }else{
            pen.frame = CGRectMake(point.x, point.y, SHOWPEN_WIDTH, SHOWPEN_HEIGHT);
        }
    
    }else{
        pen.hidden = YES;
    }
}


- (BOOL)playFromDrawActionIndex:(NSInteger)index
{
    _playingActionIndex = index;
    _playingPointIndex = 0;
    if (index < [self.drawActionList count]) {
        _currentAction = [self.drawActionList objectAtIndex:index];        
        self.status = Playing;
        [self playCurrentFrame];
        return YES;
    }else{
        self.status = Stop;
        PPDebug(@"<playFromDrawActionIndex> index out of action array bounds. Stop");
        return NO;
    }
}

- (void)play
{
    PPDebug(@"<ShowDrawView> play");
    [self resetView];
    [self setNeedsDisplay];
    [self playFromDrawActionIndex:0];

}
- (void)stop
{
    PPDebug(@"<ShowDrawView> stop");
    self.status = Stop;
    pen.hidden = YES;
}

- (void)show
{
    PPDebug(@"<ShowDrawView> show");
    [self resetView];
    [super show];
}

- (void)showToIndex:(NSInteger)index
{
    if (index < 0) {
        index = 0;
    }
    if (index > [self.drawActionList count]) {
        index = [self.drawActionList count];
    }
    
    [self resetView];

//    if (_playingActionIndex > index || _playingActionIndex <= 0) {
//        [self resetView];
//    }else{
//        [self setStatus:Stop];
//        [[osManager enteryScreen] clear];
//        _playingPointIndex = 0;
//        self.tempAction = nil;
//        _currentAction = nil;
//        pen.hidden = YES;
//    }

//    for (NSInteger i = _playingActionIndex; i < index; ++ i, ++_playingActionIndex) {
//        DrawAction *action = [_drawActionList objectAtIndex:i];
//        [[osManager bottomScreen] drawAction:action clear:NO];
//        [cdManager addDrawAction:action];
//    }
    
    
    if (index >= [self.drawActionList count]) {
        self.status = Stop;
    }else{
        self.status = Playing;
    }
    
    [self setNeedsDisplay];            
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
        if (_currentAction == nil) {
            _playingActionIndex --;
            [self updateNextPlayIndex];
        }

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
//        dlManager addDrawAction:<#(DrawAction *)#> show:<#(BOOL)#>
//        CGRect rect = [osManager addDrawAction:action];
//        CGRect rect = [cdManager addDrawAction:action];
//        [self setNeedsDisplayInRect:rect];
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
        
//        cdManager = [[CacheDrawManager managerWithRect:self.bounds] retain];
//        cdManager.drawActionList = self.drawActionList;
//        cdManager.useCachedImage = NO;        
    }
    return self;
}

- (void)resetFrameSize:(CGSize)size
{
    CGRect rect = CGRectZero;
    rect.size = size;
    self.frame = rect;
    if ([self.superview isKindOfClass:[DrawHolderView class]]) {
        [(DrawHolderView *)self.superview updateContentScale];
    }
}

+ (ShowDrawView *)showView
{
    return [[[ShowDrawView alloc] initWithFrame:[CanvasRect defaultRect]] autorelease];
}

+ (ShowDrawView *)showViewWithFrame:(CGRect)frame
                drawActionList:(NSArray *)actionList
                      delegate:(id<ShowDrawViewDelegate>)delegate
{
    ShowDrawView *showView = [[[ShowDrawView alloc] initWithFrame:frame] autorelease];
    
    if ([actionList isKindOfClass:[NSMutableArray class]]) {
        showView.drawActionList = (NSMutableArray *)actionList;
    }else{
        showView.drawActionList = [NSMutableArray arrayWithArray:actionList];
    }
    showView.delegate = delegate;
    showView.frame = frame;
    return showView;
}

+ (BOOL)canPlayDrawVersion:(NSInteger)version
{
    return [ConfigManager currentDrawDataVersion] >= version;
}


- (void)dealloc
{
    [self stop];
    PPRelease(_drawActionList);
    PPRelease(pen);
//    PPRelease(_tempPaint);
    PPRelease(_tempAction);
    [super dealloc];
}

- (NSInteger)lastCleanActionIndex
{
    int i = 0, ans = -1;
    for (DrawAction *action in self.drawActionList) {
        if (action.type == DrawActionTypeClean) {
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
    if ( ++_playingPointIndex >= [_currentAction pointCount]) {
        _playingPointIndex = 0;

        //next action
        if (++ _playingActionIndex < [self.drawActionList count]) {
            _currentAction = [self.drawActionList objectAtIndex:_playingActionIndex];
        }else{
            _currentAction = nil;
            _status = Stop;
        }
//        PPDebug(@"<updateNextPlayIndex> index = %d, action Type = %d", _playingActionIndex, _currentAction.type);
//        if (_currentAction.type == DrawActionTypeShape) {
//            PPDebug(@"Stop!!!");
//        }
    }else{
        _playingPointIndex = MIN([_currentAction pointCount]-1, _playingPointIndex + 1); //self.speed);
    }
    
}


- (void)updateTempAction
{
    
    if ([_currentAction isKindOfClass:[PaintAction class]]) {
//        PaintAction *paintAction = (PaintAction *)_currentAction;
        Paint *currentPaint = [(PaintAction *)_currentAction paint];
        if (self.tempAction == nil) {
            Paint *paint = [Paint paintWithWidth:currentPaint.width color:currentPaint.color penType:currentPaint.penType pointList:nil];
            self.tempAction = [PaintAction paintActionWithPaint:paint];
            self.tempAction.shadow = [_currentAction shadow];
            self.tempAction.clipAction = _currentAction.clipAction;
        }
        NSInteger i = [self.tempAction pointCount];
        for (; i <= _playingPointIndex; ++ i) {
            CGPoint p = [currentPaint pointAtIndex:i];
            [self.tempAction addPoint:p inRect:self.bounds];
        }
        
        if (i >= [currentPaint pointCount]){
            [self.tempAction finishAddPoint];
        }
    }else{
        self.tempAction = nil;//_currentAction;
    }
    
//    PPDebug(@"<updateTempAction>actionIndex = %d, pointIndex = %d, currentAction = %@, tempAction = %@", _playingActionIndex, _playingPointIndex,_currentAction,_tempAction);
//    
}


- (void)callDidDrawPaintDelegate
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didPlayDrawView:AtActionIndex:pointIndex:)]) {
        [self.delegate didPlayDrawView:self AtActionIndex:_playingActionIndex pointIndex:_playingPointIndex];
    }    
    if(_playingActionIndex >= [self.drawActionList count]-1){
//        cdManager.currentClip = nil;
        [self setNeedsDisplay];
        if(self.delegate && [self.delegate respondsToSelector:@selector(didPlayDrawView:)]){
            [self.delegate didPlayDrawView:self];
            
            self.status = Stop;
            _playingActionIndex = _playingPointIndex = 0;
            _currentAction =  nil;
        }
    }
    self.tempAction = nil;

}

- (void)delayShowAction:(DrawAction *)drawAction
{
    [self delayShowAction:drawAction stop:NO];
}

- (void)delayShowActionStop:(DrawAction *)drawAction
{
    [self delayShowAction:drawAction stop:YES];
}

- (void)delayShowAction:(DrawAction *)drawAction stop:(BOOL)stop
{
    
    
//    [self drawDrawAction:drawAction show:YES];
    
//    PPDebug(@"<delayShowAction>actionIndex = %d, pointIndex = %d, currentAction = %@, tempAction = %@", _playingActionIndex, _playingPointIndex,_currentAction,_tempAction);

    
    [self callDidDrawPaintDelegate];

    if (!stop) {
        [self performSelector:@selector(playNextFrame) withObject:nil afterDelay:self.playSpeed];
    }else{
        [self setStatus:Stop];
    }
}



- (void)playCurrentFrame
{
    _playFrameTime = CACurrentMediaTime();
    
//    [self updateTempPaint];
    [self updateTempAction];
    if (self.status == Playing) {
        if (self.tempAction) {
            
//            if (cdManager.currentClip && self.tempAction.clipAction != cdManager.currentClip) {
//                //clean the
//                cdManager.currentClip = self.tempAction.clipAction;
//                [self updateLastAction:self.tempAction show:NO];
//                [self setNeedsDisplay];
//            }else{
//                [self updateLastAction:self.tempAction show:YES];
//            }
            
            if ([self.tempAction hasFinishAddPoint]) {
                [self callDidDrawPaintDelegate];                
                //TEST CODE
//                [cdManager finishDrawAction:_currentAction];
            }
            
            double delay = (CACurrentMediaTime() - _playFrameTime - self.playSpeed);
            delay = MIN(self.playSpeed, delay);
            delay = MAX(0, self.playSpeed);
            
            [self performSelector:@selector(playNextFrame) withObject:nil afterDelay:delay];

        }else{
            if (![_currentAction isPaintAction]) {
                if([_currentAction isClipAction]){
//                    cdManager.currentClip = (id)_currentAction;
                }
                
                [self delayShowAction:_currentAction];
                
            } else {
                [self delayShowActionStop:_currentAction];
            }
        }
    }
    if(!_showPenHidden){
        [self movePen];
    }
}

- (void)playNextFrame
{
    if (Playing == self.status) {
//        BOOL slow = ![_currentAction isKindOfClass:[PaintAction class]];
        
        [self updateNextPlayIndex];
        [self playCurrentFrame];
        
//        if (slow) {
//            [self performSelector:@selector(playCurrentFrame) withObject:nil afterDelay:0.4];
//        }else{
//            [self playCurrentFrame];
//        }
    }
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
}

- (void)setNeedsDisplay
{
    [super setNeedsDisplay];
}

- (void)setNeedsDisplayInRect:(CGRect)rect
{
    [super setNeedsDisplayInRect:rect];
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
//    [cdManager setDrawActionList:drawActionList];
}

- (void)changeRect:(CGRect)rect
{
    self.transform = CGAffineTransformIdentity;
    self.bounds = rect;
    self.frame = rect;

//    PPRelease(cdManager);
//    cdManager = [[CacheDrawManager managerWithRect:rect] retain];
//    cdManager.drawActionList = self.drawActionList;
//    cdManager.useCachedImage = NO;
    [(DrawHolderView *)self.superview updateContentScale];
    [self setNeedsDisplay];
}
@end



@implementation ShowDrawView (PressAction)

- (void)gestureRecognizerManager:(GestureRecognizerManager *)manager
                   didGestureEnd:(UIGestureRecognizer *)gestureRecognizer
{
    if (_supportLongPress && [gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        if(_delegate && [self.delegate respondsToSelector:@selector(didLongClickShowDrawView:)])
        {
            [_delegate didLongClickShowDrawView:self];
        }
    }else if (_supportLongPress && [gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        if(_delegate && [self.delegate respondsToSelector:@selector(didClickShowDrawView:)])
        {
            [_delegate didClickShowDrawView:self];
        }
    }
}

- (void)setPressEnable:(BOOL)enable
{
    if (!_supportLongPress && enable) {
        [_gestureRecognizerManager addLongPressGestureReconizerToView:self];
        [_gestureRecognizerManager addTapGestureReconizerToView:self];
    }
    _supportLongPress = enable;
}


@end