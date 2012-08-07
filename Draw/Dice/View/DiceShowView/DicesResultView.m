//
//  DicesResultView.m
//  Draw
//
//  Created by haodong on 12-8-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DicesResultView.h"
#import "PPDebug.h"
#import "DiceImageManager.h"
#import "DeviceDetection.h"
#import "AnimationManager.h"


#define TAG_BOTTOM      1
#define TAG_START_DICE  10

#define FRAME_SELF      (([DeviceDetection isIPAD]) ? CGRectMake(0, 0, 96, 96) : CGRectMake(0, 0, 48, 48))
#define FRAME_BOTTOM    (([DeviceDetection isIPAD]) ? CGRectMake(0, 24, 96, 72) : CGRectMake(0, 12, 48, 36))  

#define WIDTH_DICE      (([DeviceDetection isIPAD]) ? 34 : 17 )
#define HEIGHT_DICE     (([DeviceDetection isIPAD]) ? 40 : 20 )
#define FRAME_DICE_1    (([DeviceDetection isIPAD]) ? CGRectMake(32, 10, WIDTH_DICE, WIDTH_DICE) : CGRectMake(16, 5, WIDTH_DICE, WIDTH_DICE) )
#define FRAME_DICE_2    (([DeviceDetection isIPAD]) ? CGRectMake(8, 24, WIDTH_DICE, WIDTH_DICE) : CGRectMake(4, 12, WIDTH_DICE, WIDTH_DICE) )
#define FRAME_DICE_3    (([DeviceDetection isIPAD]) ? CGRectMake(52, 22, WIDTH_DICE, WIDTH_DICE) : CGRectMake(28, 11, WIDTH_DICE, WIDTH_DICE) )
#define FRAME_DICE_4    (([DeviceDetection isIPAD]) ? CGRectMake(18, 48, WIDTH_DICE, WIDTH_DICE) : CGRectMake(9, 24, WIDTH_DICE, WIDTH_DICE) )
#define FRAME_DICE_5    (([DeviceDetection isIPAD]) ? CGRectMake(48, 48, WIDTH_DICE, WIDTH_DICE) : CGRectMake(24, 24, WIDTH_DICE, WIDTH_DICE) )

#define MOVE_TO_CENTER_DURATION 1.5
#define MOVE_TO_BACK_DURATION 1.0
#define STAY_DURATION 1.5

#define ZOOMIN_FACTOR 1.4




@interface DicesResultView ()
{
    CGPoint _center;
}

@end

@implementation DicesResultView

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        //self.frame = FRAME_SELF;
        _center = self.center;
        UIImageView *bottomView = [[UIImageView alloc] initWithFrame:FRAME_BOTTOM];
        bottomView.tag = TAG_BOTTOM;
        [self addSubview:bottomView];
        [bottomView release];
        
        for (int index = 0; index < 5; index++) {
            CGRect diceFrame;
            
            switch (index) {
                case 0:
                    diceFrame = FRAME_DICE_1;
                    break;
                case 1:
                    diceFrame = FRAME_DICE_2;
                    break;
                case 2:
                    diceFrame = FRAME_DICE_3;
                    break;
                case 3:
                    diceFrame = FRAME_DICE_4;
                    break;
                case 4:
                    diceFrame = FRAME_DICE_5;
                    break;
                default:
                    break;
            }
            
            UIImageView *diceView = [[UIImageView alloc] initWithFrame:diceFrame];
            diceView.tag = TAG_START_DICE + index;
            [self addSubview:diceView];
            [diceView release];
        }
    }
    return self;
}

- (void)setDices:(NSArray *)diceList
{
    [self clearDices];
    self.hidden = NO;
    
    DiceImageManager *imageManage = [DiceImageManager defaultManager];
    
    UIImageView *bottomImageView = (UIImageView*)[self viewWithTag:TAG_BOTTOM];
    [bottomImageView setImage:[imageManage diceBottomImage]];
    
    int index = 0;
    for (PBDice *dice in diceList) {
        UIImage *image = nil;
        image = [imageManage openDiceImageWithDice:dice.dice];
        UIImageView *imageView = (UIImageView *)[self viewWithTag:TAG_START_DICE + index];
        [imageView setImage:image];
        
        index ++;
        if (index > 5) {
            break;
        }
    }
}

- (void)showAnimation:(CGPoint)center delegate:(id)delegate
{
    CAAnimation *moveToScreenCenter = [AnimationManager translationAnimationFrom:self.center to:center duration:MOVE_TO_CENTER_DURATION];
    moveToScreenCenter.beginTime = 0;
    moveToScreenCenter.removedOnCompletion = NO;
    
    CAAnimation *zoomIn = [AnimationManager scaleAnimationWithScale:ZOOMIN_FACTOR duration:MOVE_TO_CENTER_DURATION delegate:self removeCompeleted:NO];
    zoomIn.beginTime = 0;
    
    CAAnimation *stayPoint = [AnimationManager translationAnimationFrom:center to:center duration:STAY_DURATION];
    stayPoint.beginTime = moveToScreenCenter.beginTime + moveToScreenCenter.duration;
    CAAnimation *stayScale = [AnimationManager scaleAnimationWithFromScale:ZOOMIN_FACTOR toScale:ZOOMIN_FACTOR duration:STAY_DURATION delegate:nil removeCompeleted:NO];
    stayScale.beginTime = stayPoint.beginTime;
    
    
    CAAnimation *moveBack = [AnimationManager translationAnimationFrom:center to:_center duration:MOVE_TO_BACK_DURATION];
    moveBack.beginTime = stayPoint.beginTime + stayPoint.duration;
    moveBack.removedOnCompletion = NO;
    
    CAAnimation *zoomOut = [AnimationManager scaleAnimationWithScale:1 duration:MOVE_TO_BACK_DURATION delegate:nil removeCompeleted:NO];
    zoomOut.beginTime = moveBack.beginTime;
    zoomOut.removedOnCompletion = NO;
    
    //method2:放入动画数组，统一处理！
    CAAnimationGroup* animGroup    = [CAAnimationGroup animation];
    
    //设置动画代理
    animGroup.delegate = delegate;
    
    animGroup.removedOnCompletion = NO;
    
    animGroup.duration            = moveBack.beginTime+moveBack.duration;
    animGroup.timingFunction      = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];    
    animGroup.repeatCount         = 1;
    animGroup.fillMode            = kCAFillModeForwards;
    animGroup.animations          = [NSArray arrayWithObjects:moveToScreenCenter, zoomIn, stayPoint, stayScale, moveBack, zoomOut,nil];
    //对视图自身的层添加组动画
    [self.layer addAnimation:animGroup forKey:@""];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    
}

- (void)clearDices
{    
    UIImageView *bottomImageView = (UIImageView*)[self viewWithTag:TAG_BOTTOM];
    [bottomImageView setImage:nil];
    
    for (int index = 0; index < 6 ; index ++) {
        UIImageView *imageView = (UIImageView *)[self viewWithTag:TAG_START_DICE + index];
        [imageView setImage:nil];
    }
}

@end
