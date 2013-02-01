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
#import "DiceGameService.h"


#define TAG_OFFSET_BOTTOM      110
#define TAG_OFFSET_DICE  1001

//#define FRAME_SELF      (([DeviceDetection isIPAD]) ? CGRectMake(0, 0, 96, 96) : CGRectMake(0, 0, 48, 48))

#define FRAME_BOTTOM(scale)    (([DeviceDetection isIPAD]) ? CGRectMake(0, 24*scale, 96*scale, 72*scale) : CGRectMake(0, 12*scale, 48*scale, 36*scale))  

#define WIDTH_DICE(scale)      (([DeviceDetection isIPAD]) ? 34*scale : 17*scale )
#define HEIGHT_DICE(scale)     (([DeviceDetection isIPAD]) ? 40*scale : 20*scale )
#define FRAME_DICE_1(scale)    (([DeviceDetection isIPAD]) ? CGRectMake(32*scale, 10*scale, WIDTH_DICE(scale), HEIGHT_DICE(scale)) : CGRectMake(16*scale, 5*scale, WIDTH_DICE(scale), HEIGHT_DICE(scale)))
#define FRAME_DICE_2(scale)    (([DeviceDetection isIPAD]) ? CGRectMake(8*scale, 24*scale, WIDTH_DICE(scale), WIDTH_DICE(scale)) : CGRectMake(4*scale, 12*scale, WIDTH_DICE(scale), WIDTH_DICE(scale)) )
#define FRAME_DICE_3(scale)    (([DeviceDetection isIPAD]) ? CGRectMake(56*scale, 24*scale, WIDTH_DICE(scale), WIDTH_DICE(scale)) : CGRectMake(28*scale, 12*scale, WIDTH_DICE(scale), WIDTH_DICE(scale)) )
#define FRAME_DICE_4(scale)    (([DeviceDetection isIPAD]) ? CGRectMake(18*scale, 48*scale, WIDTH_DICE(scale), WIDTH_DICE(scale)) : CGRectMake(9*scale, 24*scale, WIDTH_DICE(scale), WIDTH_DICE(scale)) )
#define FRAME_DICE_5(scale)    (([DeviceDetection isIPAD]) ? CGRectMake(48*scale, 48*scale, WIDTH_DICE(scale), WIDTH_DICE(scale)) : CGRectMake(24*scale, 24*scale, WIDTH_DICE(scale), WIDTH_DICE(scale)) )

#define FACTOR_RESULT_ZOOMIN 1.4
#define FACTOR_DICE_ZOOMIN 2

@interface DicesResultView ()
{
    CGPoint _originCenter;
    CGPoint _targetCenter;
    PBDiceType _diceType;
    int _finalDiceCount;
}

@end

@implementation DicesResultView

@synthesize delegate = _delegate;

- (void)dealloc
{
    [super dealloc];
}

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
        
        
        _originCenter = self.center;
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

//- (void)adjustDiceResultType:(NSArray *)diceList
//                  resultDice:(int)resultDice
//                       wilds:(BOOL)wilds
//                    ruleType:(DiceGameRuleType)ruleType
//{
//    int arr[10] = {0};
//    
//    for (PBDice *dice in diceList) {
//        arr[dice.dice] ++;
//    }
//    
//    int count = 0;
//    for (int i = 0; i < 10; i ++) {
//        if (arr[i] != 0) {
//            count ++;
//        } 
//    }
//    
//    _resultDiceCount = arr[resultDice] + wilds ? 0 : arr[1];
//
//    if (ruleType == DiceGameRuleTypeNormal) {
//        _resultType = NormalDice;
//    }else if ((ruleType == DiceGameRuleTypeHigh) || (ruleType == DiceGameRuleTypeSuperHigh)) {
//        if (count == 1) {
//            if (_resultDiceCount == 5) {
//                _resultType = NetDice;
//                _resultDiceCount = 7;
//            }
//        }else if (count == 2) {
//            if (_resultDiceCount == 5) {
//                _resultType = WaiDice;
//                _resultDiceCount = 6;
//            }
//        }else if (count == 5) {
//            _resultType = SnakeDice;
//            _resultDiceCount = 0;
//        }else {
//            _resultType = NormalDice;
//        }
//    }
//    
//    
//}


- (void)setDicesWithDiceList:(NSArray *)diceList
                       wilds:(BOOL)wilds 
                  resultDice:(int)resultDice
{
    [self setDicesWithDiceList:diceList 
                         wilds:wilds 
                    resultDice:resultDice 
                      diceType:[[CustomDiceManager defaultManager] getMyDiceType]];
}

- (void)setDicesWithDiceList:(NSArray *)diceList
                       wilds:(BOOL)wilds 
                  resultDice:(int)resultDice 
                    diceType:(CustomDiceType)diceType
{
    [self clearDices];
    
    self.hidden = NO;
    
    DiceImageManager *imageManage = [DiceImageManager defaultManager];
    CustomDiceManager *customDiceManager = [CustomDiceManager defaultManager];
    [[self buttonView] setImage:[imageManage diceBottomImage]];
    
    int index = 0;
    for (PBDice *dice in diceList) {
        UIImage *defaultImage = [customDiceManager openDiceImageForType:diceType dice:dice.dice];
        UIImage *selectedImage = [customDiceManager openDiceImageForType:diceType dice:dice.dice];
        
        [[self diceViewOfIndex:index] setImage:defaultImage forState:UIControlStateNormal];
        [[self diceViewOfIndex:index] setImage:selectedImage forState:UIControlStateSelected];
        
        
        
        // 叫斋之后，1就不能当其他骰子用了。
        if (wilds && dice.dice == 1) {
            [[self diceViewOfIndex:index] setSelected:NO];
        }
        
        // 没有叫斋，则1可以当作任何骰子用
        if (!wilds && dice.dice == 1) {
            [[self diceViewOfIndex:index] setSelected:YES];
        }
        
        if (dice.dice == resultDice) {
            [[self diceViewOfIndex:index] setSelected:YES];
        }
        
        if (_diceType == PBDiceTypeDiceSnake) {
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

- (void)showUserResult:(NSString *)userId toCenter:(CGPoint)center customDiceType:(CustomDiceType)type
{
    _originCenter = self.center;
    DiceGameSession *diceSession = [[DiceGameService defaultService] diceSession];
    NSArray *diceList = [[diceSession userDiceList] objectForKey:userId];
    BOOL wilds = diceSession.wilds;
    int resultDice = diceSession.lastCallDice;
    
    PBDiceFinalCount *finalCount = [diceSession.finalCount objectForKey:userId];
    _diceType = finalCount.type;
    _finalDiceCount = finalCount.finalDiceCount;
    
    [self setDicesWithDiceList:diceList 
                         wilds:wilds
                    resultDice:resultDice diceType:type];
    
    _targetCenter = center;
            
    [UIView animateWithDuration:DURATION_MOVE_TO_CENTER delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
        self.center = center;
        self.transform = CGAffineTransformMakeScale(FACTOR_RESULT_ZOOMIN, FACTOR_RESULT_ZOOMIN);
    } completion:^(BOOL finished) {
        [_delegate stayDidStart:_finalDiceCount];
        [UIView animateWithDuration:DURATION_STAY delay:DURATION_MOVE_TO_CENTER options:UIViewAnimationCurveEaseInOut animations:^{
            [self showResultDiceAnimation];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:DURATION_MOVE_TO_BACK delay:DURATION_STAY options:UIViewAnimationCurveEaseInOut animations:^{
                self.center = _originCenter;
                self.transform = CGAffineTransformMakeScale(1, 1);
            } completion:^(BOOL finished) {
                [_delegate moveBackDidStop:_finalDiceCount];
            }];
        }];
    }];
}

//- (void)animationDidStart:(CAAnimation *)anim
//{
//    if (anim == [self.layer animationForKey:ANIMATION_GROUP_MOVE_TO_CENTER]) {
//        PPDebug(@"ANIMATION_GROUP_MOVE_TO_CENTER start");
//        if ([_delegate respondsToSelector:@selector(moveToCenterDidStart:)]) {
//            [_delegate moveToCenterDidStart:[[self selectedDiceViews] count]];
//        }
//    }
//    
//    if (anim == [self.layer animationForKey:ANIMATION_GROUP_STAY]) {
//        PPDebug(@"ANIMATION_GROUP_STAY start");
//        if ([_delegate respondsToSelector:@selector(stayDidStart:)]) {
//            [_delegate stayDidStart:[[self selectedDiceViews] count]];
//        }
//    }
//    
//    if (anim == [self.layer animationForKey:ANIMATION_GROUP_MOVE_BACK]) {
//        PPDebug(@"ANIMATION_GROUP_MOVE_BACK start");
//        if ([_delegate respondsToSelector:@selector(moveBackDidStart:)]) {
//            [_delegate moveBackDidStart:[[self selectedDiceViews] count]];
//        }
//    }
//}

- (CAAnimationGroup *)animationGroupWithArray:(NSArray *)animations
                                     duration:(int)duration
                          removedOnCompletion:(BOOL)removedOnCompletion
                                     delegate:(id)delegate
{
    CAAnimationGroup* groupAnimation = [CAAnimationGroup animation];
    groupAnimation.delegate = delegate;
    groupAnimation.removedOnCompletion = removedOnCompletion;
    groupAnimation.duration = duration;
    groupAnimation.animations = animations;
    
    return groupAnimation;
}

//- (void)moveToPoint:(CGPoint)point
//{
//    // 移到桌子中央动画
//    CAAnimation *moveToScreenCenter = [AnimationManager translationAnimationFrom:_originCenter to:_targetCenter duration:DURATION_MOVE_TO_CENTER];
//    CAAnimation *zoomIn = [AnimationManager scaleAnimationWithScale:FACTOR_RESULT_ZOOMIN duration:DURATION_MOVE_TO_CENTER delegate:self removeCompeleted:NO];
//    
//    // 添加到animation group中.
//    NSArray *animations = [NSArray arrayWithObjects:moveToScreenCenter, zoomIn, nil];
//    CAAnimationGroup *moveToPointCenterGroup = [self animationGroupWithArray:animations
//                                                                    duration:DURATION_MOVE_TO_CENTER
//                                                         removedOnCompletion:NO
//                                                                    delegate:self];
//    
//    //对视图自身的层,添加组动画
//    [self.layer addAnimation:moveToPointCenterGroup forKey:ANIMATION_GROUP_MOVE_TO_CENTER];    
//}

//- (void)stayStill
//{
//    // 停顿动画
//    CAAnimation *stayPoint = [AnimationManager translationAnimationFrom:_targetCenter to:_targetCenter duration:DURATION_STAY];
//    CAAnimation *stayScale = [AnimationManager scaleAnimationWithFromScale:FACTOR_RESULT_ZOOMIN toScale:FACTOR_RESULT_ZOOMIN duration:DURATION_STAY delegate:nil removeCompeleted:NO];
//    
//    // 添加到animation group中.
//    NSArray *animations = [NSArray arrayWithObjects:stayPoint, stayScale, nil];
//    CAAnimationGroup *stayGroup = [self animationGroupWithArray:animations
//                                                       duration:DURATION_STAY
//                                            removedOnCompletion:NO
//                                                       delegate:self];
//    
//    //对视图自身的层,添加组动画
//    [self.layer addAnimation:stayGroup forKey:ANIMATION_GROUP_STAY];
//}

//- (void)moveBack
//{
//    // 移回原位动画
//    CAAnimation *moveBack = [AnimationManager translationAnimationFrom:_targetCenter to:_originCenter duration:DURATION_MOVE_TO_BACK];
//    CAAnimation *zoomOut = [AnimationManager scaleAnimationWithFromScale:FACTOR_RESULT_ZOOMIN toScale:1 duration:DURATION_STAY delegate:nil removeCompeleted:NO];
//    
//    // 添加到animation group中.
//    NSArray *animations = [NSArray arrayWithObjects:moveBack, zoomOut,nil];
//    CAAnimationGroup *moveBackGroup = [self animationGroupWithArray:animations
//                                                           duration:DURATION_MOVE_TO_BACK  
//                                                removedOnCompletion:NO
//                                                           delegate:self];
//    
//    //对视图自身的层,添加组动画
//    [self.layer addAnimation:moveBackGroup forKey:ANIMATION_GROUP_MOVE_BACK];
//}

//- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
//{
//    if (anim == [self.layer animationForKey:ANIMATION_GROUP_MOVE_TO_CENTER]) {
//        PPDebug(@"ANIMATION_GROUP_MOVE_TO_CENTER end");
//        
//        [self showResultDiceAnimation];
//        [self stayStill];
//        
//        if ([_delegate respondsToSelector:@selector(moveToCenterDidStop:)]) {
//            [_delegate moveToCenterDidStop:[[self selectedDiceViews] count]];
//        }
//    }
//    
//    if (anim == [self.layer animationForKey:ANIMATION_GROUP_STAY]) {
//        PPDebug(@"ANIMATION_GROUP_STAY end");
//        if ([_delegate respondsToSelector:@selector(stayDidStop:)]) {
//            [_delegate stayDidStop:[[self selectedDiceViews] count]];
//        }
//        
//        [self moveBack];
//    }
//    
//    if (anim == [self.layer animationForKey:ANIMATION_GROUP_MOVE_BACK]) {
//        PPDebug(@"ANIMATION_GROUP_MOVE_BACK end");
//        if ([_delegate respondsToSelector:@selector(moveBackDidStop:)]) {
//            [_delegate moveBackDidStop:[[self selectedDiceViews] count]];
//        }
//    }
//}

- (NSString *)diceTypeString
{
    NSString *str = nil;
    switch (_diceType) {
        case PBDiceTypeDiceSnake:
            str = NSLS(@"kDiceSnake"); 
            break;
            
        case PBDiceTypeDiceNet:
            str = NSLS(@"kDiceNet");
            break;
            
        case PBDiceTypeDiceWai:
            str = NSLS(@"kDiceWai");
            break;
            
        default:
            break;
    }
    
    return str;
}

- (void)showResultDiceAnimation
{
    NSString *str = [self diceTypeString];
    if (str != nil) {
        CGFloat pointSize = [DeviceDetection isIPAD] ? 38 : 19;
        CGRect frame = [DeviceDetection isIPAD] ? CGRectMake(0, 0, 200, 200) : CGRectMake(0, 0, 100, 100);
        UILabel *label = [[[UILabel alloc] initWithFrame:frame] autorelease];
        [label setFont:[UIFont systemFontOfSize:pointSize]];
        label.textAlignment = UITextAlignmentCenter;
        label.center = self.center;
        label.text = str;
        [self addSubview:label];

        [UIView animateWithDuration:DURATION_STAY/2 delay:0 options:UIViewAnimationCurveEaseIn animations:^{
            label.frame = self.bounds;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:DURATION_STAY/2 delay:DURATION_STAY/2 options:UIViewAnimationCurveEaseIn animations:^{
                label.alpha = 0;
            } completion:^(BOOL finished) {
                [label removeFromSuperview];
            }];
        }];
    }
    
    for (UIButton *diceView in [self selectedDiceViews]) {
        
        CAAnimation *zoomIn1 = [AnimationManager scaleAnimationWithScale:FACTOR_DICE_ZOOMIN duration:DURATION_STAY/4.0 delegate:self removeCompeleted:NO];
        zoomIn1.beginTime = 0;
        
        CAAnimation *zoomOut1 = [AnimationManager scaleAnimationWithScale:1 duration:DURATION_STAY/4.0 delegate:nil removeCompeleted:NO];
        zoomOut1.beginTime = 0+DURATION_STAY/4.0;
        
        CAAnimation *zoomIn2 = [AnimationManager scaleAnimationWithScale:FACTOR_DICE_ZOOMIN duration:DURATION_STAY/4.0 delegate:self removeCompeleted:NO];
        zoomIn2.beginTime = 0+DURATION_STAY/2.0;
        
        CAAnimation *zoomOut2 = [AnimationManager scaleAnimationWithScale:1 duration:DURATION_STAY/4.0 delegate:nil removeCompeleted:NO];
        zoomOut2.beginTime = 0+DURATION_STAY*3.0/4.0;
        
        NSArray *animations          = [NSArray arrayWithObjects:zoomIn1, zoomOut1, zoomIn2, zoomOut2, nil];
        CAAnimationGroup *animGroup = [self animationGroupWithArray:animations
                                                           duration:DURATION_STAY
                                                removedOnCompletion:YES
                                                           delegate:self];
        
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
