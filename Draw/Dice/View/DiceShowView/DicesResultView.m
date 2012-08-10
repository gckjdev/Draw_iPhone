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


#define TAG_OFFSET_BOTTOM      110
#define TAG_OFFSET_DICE  1001

//#define FRAME_SELF      (([DeviceDetection isIPAD]) ? CGRectMake(0, 0, 96, 96) : CGRectMake(0, 0, 48, 48))

#define FRAME_BOTTOM(scale)    (([DeviceDetection isIPAD]) ? CGRectMake(0, 24*scale, 96*scale, 72*scale) : CGRectMake(0, 12*scale, 48*scale, 36*scale))  

#define WIDTH_DICE(scale)      (([DeviceDetection isIPAD]) ? 34*scale : 17*scale )
#define HEIGHT_DICE(scale)     (([DeviceDetection isIPAD]) ? 40*scale : 20*scale )
#define FRAME_DICE_1(scale)    (([DeviceDetection isIPAD]) ? CGRectMake(32*scale, 10*scale, WIDTH_DICE(scale), HEIGHT_DICE(scale)) : CGRectMake(16*scale, 5*scale, WIDTH_DICE(scale), HEIGHT_DICE(scale)))
#define FRAME_DICE_2(scale)    (([DeviceDetection isIPAD]) ? CGRectMake(8, 24, WIDTH_DICE(scale), WIDTH_DICE(scale)) : CGRectMake(4*scale, 12*scale, WIDTH_DICE(scale), WIDTH_DICE(scale)) )
#define FRAME_DICE_3(scale)    (([DeviceDetection isIPAD]) ? CGRectMake(52, 22, WIDTH_DICE(scale), WIDTH_DICE(scale)) : CGRectMake(28*scale, 11*scale, WIDTH_DICE(scale), WIDTH_DICE(scale)) )
#define FRAME_DICE_4(scale)    (([DeviceDetection isIPAD]) ? CGRectMake(18, 48, WIDTH_DICE(scale), WIDTH_DICE(scale)) : CGRectMake(9*scale, 24*scale, WIDTH_DICE(scale), WIDTH_DICE(scale)) )
#define FRAME_DICE_5(scale)    (([DeviceDetection isIPAD]) ? CGRectMake(48, 48, WIDTH_DICE(scale), WIDTH_DICE(scale)) : CGRectMake(24*scale, 24*scale, WIDTH_DICE(scale), WIDTH_DICE(scale)) )

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
        CGFloat scale;
        if([DeviceDetection isIPAD])
        {
            scale = self.frame.size.width / 96.0;
        }else {
            scale = self.frame.size.width / 48.0;
        }
        
        
        _center = self.center;
        UIImageView *bottomView = [[UIImageView alloc] initWithFrame:FRAME_BOTTOM(scale)];
        bottomView.tag = TAG_OFFSET_BOTTOM;
        [self addSubview:bottomView];
        [bottomView release];
        
        for (int index = 0; index < 5; index++) {
            CGRect diceFrame;
            
            switch (index) {
                case 0:
                    diceFrame = FRAME_DICE_1(scale);
                    break;
                case 1:
                    diceFrame = FRAME_DICE_2(scale);
                    break;
                case 2:
                    diceFrame = FRAME_DICE_3(scale);
                    break;
                case 3:
                    diceFrame = FRAME_DICE_4(scale);
                    break;
                case 4:
                    diceFrame = FRAME_DICE_5(scale);
                    break;
                default:
                    break;
            }
            
            UIButton *diceView = [[[UIButton alloc] initWithFrame:diceFrame] autorelease];
            diceView.userInteractionEnabled = NO;
            
            diceView.tag = TAG_OFFSET_DICE + index;
            
            [self addSubview:diceView];
        }
    }
    return self;
}

- (UIImageView *)buttonView
{
    return (UIImageView*)[self viewWithTag:TAG_OFFSET_BOTTOM];
}

- (UIButton *)diceViewOfIndex:(int)index
{
    return (UIButton *)[self viewWithTag:TAG_OFFSET_DICE + index];
}

- (void)setDices:(NSArray *)diceList resultDice:(int)resultDice
{
    [self clearDices];
    self.hidden = NO;
    
    DiceImageManager *imageManage = [DiceImageManager defaultManager];
    [[self buttonView] setImage:[imageManage diceBottomImage]];
    
    int index = 0;
    for (PBDice *dice in diceList) {
        UIImage *defaultImage = [imageManage openDiceImageWithDice:dice.dice];
        UIImage *selectedImage = [imageManage openDiceImageWithDice:dice.dice];

        [[self diceViewOfIndex:index] setImage:defaultImage forState:UIControlStateNormal];
        [[self diceViewOfIndex:index] setImage:selectedImage forState:UIControlStateSelected];
        
        if (dice.dice == resultDice) {
            [[self diceViewOfIndex:index] setSelected:YES];
        }else {
            [[self diceViewOfIndex:index] setSelected:NO];
        }
                
        index ++;
        if (index > 5) {
            break;
        }
    }
}

- (NSArray *)selectedDiceViews
{
    NSMutableArray *array = [NSMutableArray array];
    for (int index = 0; index < 5; index ++) {
        UIButton *diceView = [self diceViewOfIndex:index];
        if (diceView.selected == YES) {
            [array addObject:diceView];
        } 
    }
    
    return array;
}

- (void)showAnimation:(CGPoint)center delegate:(id)delegate
{
    // 移到桌子中央动画
    CAAnimation *moveToScreenCenter = [AnimationManager translationAnimationFrom:self.center to:center duration:MOVE_TO_CENTER_DURATION];
    moveToScreenCenter.beginTime = 0;
    moveToScreenCenter.removedOnCompletion = NO;
    
    CAAnimation *zoomIn = [AnimationManager scaleAnimationWithScale:ZOOMIN_FACTOR duration:MOVE_TO_CENTER_DURATION delegate:self removeCompeleted:NO];
    zoomIn.beginTime = 0;
    
    // 停顿动画
    [self showResultDiceAnimation];
    CAAnimation *stayPoint = [AnimationManager translationAnimationFrom:center to:center duration:STAY_DURATION];
    stayPoint.beginTime = moveToScreenCenter.beginTime + moveToScreenCenter.duration;
    CAAnimation *stayScale = [AnimationManager scaleAnimationWithFromScale:ZOOMIN_FACTOR toScale:ZOOMIN_FACTOR duration:STAY_DURATION delegate:nil removeCompeleted:NO];
    stayScale.beginTime = stayPoint.beginTime;
    
    // 移回原位动画
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

- (void)showResultDiceAnimation
{
    for (UIButton *diceView in [self selectedDiceViews]) {
        CAAnimation *zoomIn1 = [AnimationManager scaleAnimationWithScale:2 duration:STAY_DURATION/4.0 delegate:self removeCompeleted:NO];

        zoomIn1.beginTime = MOVE_TO_CENTER_DURATION;
        
        CAAnimation *zoomOut1 = [AnimationManager scaleAnimationWithScale:1 duration:STAY_DURATION/4.0 delegate:nil removeCompeleted:NO];
        zoomOut1.beginTime = MOVE_TO_CENTER_DURATION+STAY_DURATION/4.0;
        
        CAAnimation *zoomIn2 = [AnimationManager scaleAnimationWithScale:2 duration:STAY_DURATION/4.0 delegate:self removeCompeleted:NO];
        zoomIn2.beginTime = MOVE_TO_CENTER_DURATION+STAY_DURATION/2.0;
        
        CAAnimation *zoomOut2 = [AnimationManager scaleAnimationWithScale:1 duration:STAY_DURATION/4.0 delegate:nil removeCompeleted:NO];
        zoomOut2.beginTime = MOVE_TO_CENTER_DURATION+STAY_DURATION*3.0/4.0;

        
        //method2:放入动画数组，统一处理！
        CAAnimationGroup* animGroup    = [CAAnimationGroup animation];
        
        //设置动画代理
        animGroup.delegate = nil;
        
        animGroup.removedOnCompletion = NO;
//        animGroup.beginTime = MOVE_TO_CENTER_DURATION;
        
        animGroup.duration            = MOVE_TO_CENTER_DURATION + STAY_DURATION + MOVE_TO_BACK_DURATION;
        animGroup.timingFunction      = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];    
        animGroup.repeatCount         = 1;
        animGroup.fillMode            = kCAFillModeForwards;
        animGroup.animations          = [NSArray arrayWithObjects:zoomIn1, zoomOut1, zoomIn2, zoomOut2, nil];
        //对视图自身的层添加组动画
        [diceView.layer addAnimation:animGroup forKey:@""];
    }
}


- (void)clearDices
{    
    UIImageView *bottomImageView = (UIImageView*)[self viewWithTag:TAG_OFFSET_BOTTOM];
    [bottomImageView setImage:nil];
    
    for (int index = 0; index < 6 ; index ++) {
        [[self diceViewOfIndex:index] setImage:nil forState:UIControlStateNormal];
        [[self diceViewOfIndex:index] setImage:nil forState:UIControlStateSelected];
        [[self diceViewOfIndex:index] setSelected:NO];
    }
}

@end
