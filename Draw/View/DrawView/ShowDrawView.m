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
@synthesize playSpeed= _playSpeed;
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


- (void)movePen
{
    if (pen.superview == nil) {
        [self.superview addSubview:pen];
    }
    if (!_showPenHidden) {
        if ([_currentAction isCleanAction] || 
            [_currentAction isChangeBackAction]) {
            if (pen.hidden == NO) {
                pen.hidden = YES;                
            }
        }else{
            if (pen.hidden) {
                pen.hidden = NO;                
            }
            if (_playingPointIndex == 0 && pen.penType != _currentAction.paint.penType) {                
                [pen setPenType:_currentAction.paint.penType];
                PPDebug(@"penType = %d",pen.penType);
                if ([pen isRightDownRotate]) {
                    pen.layer.anchorPoint = CGPointMake(0.5, 1);
                    [pen.layer setTransform:CATransform3DMakeRotation(0.8, 0, 0, 1)];
                }else{
                    pen.layer.anchorPoint = CGPointMake(0.5, 0);
                    [pen.layer setTransform:CATransform3DMakeRotation(4, 0, 0, 1)];
                }
            }
            CGPoint point = [_currentAction.paint pointAtIndex:_playingPointIndex];
            
            if (![DrawUtils isIllegalPoint:point]) {
                CGFloat xOffset = self.frame.origin.x - self.superview.frame.origin.x;        
                CGFloat yOffset = self.frame.origin.y - self.superview.frame.origin.y;                
                point.x += xOffset;
                point.y += yOffset;
                pen.center = point;
//                if ([pen isRightDownRotate]) {                    
//                    pen.center = CGPointMake(point.x + pen.frame.size.width / 3.1, point.y );//+ pen.frame.size.height / 3.3);
//                }else{
//                    pen.center = CGPointMake(point.x + pen.frame.size.width / 2.5, point.y - pen.frame.size.height / 4.3);                                        
//                }
            }
        }
    }
}


- (void)playFromDrawActionIndex:(NSInteger)index
{
    _playingActionIndex = index;
    _playingPointIndex = 0;
    _currentAction = [self.drawActionList objectAtIndex:index];
    self.status = Playing;
    [self playCurrentFrame];
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
- (void)pause
{
    PPDebug(@"<ShowDrawView> pause");
    self.status = Stop;
}


- (void)resume
{
    self.status = Playing;
    [self playCurrentFrame];
}


- (void)addDrawAction:(DrawAction *)action play:(BOOL)play
{
    PPDebug(@"<addDrawAction> is play = %d",play);
    [self.drawActionList addObject:action];
    if (play) {
        if (self.status == Playing) {
            return;
        }else if(self.status == Stop){
//            if ([action isCleanAction] || [action isChangeBackAction]) {
//                PPDebug(@"is clean or change back action");
//                [self drawAction:action inContext:showContext];
//                [self setNeedsDisplayShowCacheLayer:NO];
//            }else{
            PPDebug(@"play from index = %d",[self.drawActionList count] -1);
            [self playFromDrawActionIndex:[self.drawActionList count] -1];
//            }
        }
    }else{
        self.status = Stop;
        [self drawAction:action inContext:showContext];
        [self setNeedsDisplayShowCacheLayer:NO];
    }
}



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.status = Stop;
        self.playSpeed = DEFAULT_PLAY_SPEED;
        _drawActionList = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor whiteColor];      
        
        //set pen
        pen = [[PenView alloc] initWithPenType:Pencil];
        [self setShowPenHidden:NO];
        pen.hidden = YES;
        pen.userInteractionEnabled = NO;
        
        pen.penType = 0;
        
        [self.superview addSubview:pen];
    }
    return self;
}

+ (ShowDrawView *)showView
{
    return [[ShowDrawView alloc] initWithFrame:DRAW_VIEW_FRAME];
}

- (void)resetFrameSize:(CGSize)size
{
    CGFloat xScale = size.width / CGRectGetWidth(DRAW_VIEW_FRAME);
    CGFloat yScele = size.height / CGRectGetHeight(DRAW_VIEW_FRAME);
    [self.layer setTransform:CATransform3DMakeScale(xScale, yScele, 1)];
}


- (void)dealloc
{
    PPDebug(@"%@ dealloc", [self description]);
    [self stop];
    
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
    }
}

- (void)updateTempPaint
{
    Paint *cPaint = _currentAction.paint;
    if (cPaint != nil &&  _playingPointIndex < [cPaint pointCount]) {
        if (_playingPointIndex == 0) {
            self.tempPaint = [Paint paintWithWidth:cPaint.width color:cPaint.color];
        }
        CGPoint p = [cPaint pointAtIndex:_playingPointIndex];
        [self.tempPaint addPoint:p];
    }else{
        self.tempPaint = nil;
    }
}

- (void)playCurrentFrame
{
    [self updateTempPaint];
    if (self.status == Playing) {
        if (self.tempPaint) {
            //last point or only one point
            if ([self.tempPaint pointCount] == [_currentAction.paint pointCount]) {
                PPDebug(@"draw action At index = %d",_playingActionIndex);
                [self drawAction:_currentAction inContext:showContext];
                [self setNeedsDisplayShowCacheLayer:NO];
            }else if ([self.tempPaint pointCount] == 1) {
                //first point
                [self setStrokeColor:self.tempPaint.color lineWidth:self.tempPaint.width inContext:cacheContext];
                [self strokePaint:self.tempPaint inContext:cacheContext clear:YES];
                [self setNeedsDisplayShowCacheLayer:YES];
            }else{
                [self strokePaint:self.tempPaint inContext:cacheContext clear:YES];
                [self setNeedsDisplayShowCacheLayer:YES];
            }
        }else{
            [self drawAction:_currentAction inContext:showContext];
            [self setNeedsDisplayShowCacheLayer:NO];
        }
    }
}

- (void)playNextFrame
{
    [self updateNextPlayIndex];
    [self playCurrentFrame];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    if (Playing == self.status && self.playSpeed > 0) {
        [self performSelector:@selector(playNextFrame) withObject:nil afterDelay:0.08];//self.playSpeed];
    }
}

@end
