//
//  ZJHAvatarView.m
//  Draw
//
//  Created by Kira on 12-10-25.
//
//

#import "ZJHAvatarView.h"
#import "GameBasic.pb.h"
#import "HKGirlFontLabel.h"
#import "ZJHImageManager.h"
#import "ShareImageManager.h"
#import "AnimationManager.h"
#import "ExpressionManager.h"
#import "ZJHSoundManager.h"
#import "AudioManager.h"

@interface ZJHAvatarView ()

@end

@implementation ZJHAvatarView
@synthesize roundAvatar = _roundAvatar;
@synthesize roundAvatarPlaceView = _roundAvatarPlaceView;
@synthesize backgroundImageView = _backgroundImageView;
@synthesize nickNameLabel = _nickNameLabel;
@synthesize delegate = _delegate;
@synthesize userInfo = _userInfo;

- (void)dealloc
{
    [_roundAvatar release];
    [_backgroundImageView release];
    [_nickNameLabel release];
    [_userInfo release];
    [_roundAvatarPlaceView release];
    [_rewardCoinView release];
    [_rewardCoinLabel release];
    [_coinImageView release];
    [super dealloc];
}

+ (id)createAvatarView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ZJHAvatarView" owner:self options:nil];
    // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    
    return [topLevelObjects objectAtIndex:0];
}

+ (ZJHAvatarView*)createZJHAvatarView
{
    ZJHAvatarView* view = [ZJHAvatarView createAvatarView];
    
    view.roundAvatar = [[[DiceAvatarView alloc] initWithFrame:view.roundAvatarPlaceView.frame] autorelease];
    [view sendSubviewToBack:view.roundAvatar];
    [view.roundAvatar setProgressBarWidth:0.07];
    //        _roundAvatar.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    [view addSubview:view.roundAvatar];
//    view.roundAvatar.delegate = view;
    [view initRewardLabel];
    [view addTapGuesture];
    
    return view;
}

- (void)initRewardLabel
{
    self.rewardCoinLabel.shadowColor = nil;
    self.rewardCoinLabel.shadowOffset = CGSizeMake(0.0f, 2.0f);
    self.rewardCoinLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.75f];
    self.rewardCoinLabel.shadowBlur = 5.0f;
}


- (void)addTapGuesture
{
    [self.roundAvatar setGestureRecognizerEnable:NO];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickOnAvatar)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self addGestureRecognizer:tapGestureRecognizer];    
    [tapGestureRecognizer release];
}

- (CGRect)calculateRoundAvatarFrame
{
    if (self.frame.size.height >= self.frame.size.width) {
        return CGRectMake(self.frame.size.width*0.19, self.frame.size.height-self.frame.size.width*0.815, self.frame.size.width*0.6, self.frame.size.width*0.6);
    }
    return CGRectMake(self.frame.size.height*0.1, self.frame.size.height*0.1, self.frame.size.height*0.8, self.frame.size.height*0.8);
}

- (CGRect)calculateNicknameLabelFrame
{
    if (self.frame.size.height >= self.frame.size.width) {
        return CGRectMake(self.frame.size.width*0.1, 0, self.frame.size.width*0.8, self.frame.size.width*0.3);
    }
    return CGRectMake(self.roundAvatar.frame.size.width, 0, self.frame.size.width - self.roundAvatar.frame.size.width, self.frame.size.height*0.3);
}

//
//- (id)initWithCoder:(NSCoder *)aDecoder
//{
//    self = [super initWithCoder:aDecoder];
//    if (self) {
//        
//        _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
//        [self addSubview:_backgroundImageView];
//        
//        _roundAvatar = [[DiceAvatarView alloc] initWithFrame:[self calculateRoundAvatarFrame]];
////        _roundAvatar.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
//        [self addSubview:_roundAvatar];
//        self.roundAvatar.delegate = self;
//        
//        _nickNameLabel = [[UILabel alloc] initWithFrame:[self calculateNicknameLabelFrame]];
//        [_nickNameLabel setTextColor:[UIColor whiteColor]];
//        [_nickNameLabel setBackgroundColor:[UIColor clearColor]];
//        [_nickNameLabel setAdjustsFontSizeToFitWidth:YES];
//        [self addSubview:_nickNameLabel];
//        
//        [self addTapGuesture];
//    }
//    return self;
//}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self addTapGuesture];
    }
    return self;
}


- (void)startReciprocal:(CFTimeInterval)reciprocalTime
{
    [self bringSubviewToFront:self.roundAvatar];
    [self.roundAvatar startReciprocol:reciprocalTime];
}

- (void)startReciprocal:(CFTimeInterval)reciprocalTime
           fromProgress:(float)progress
{
    [self.roundAvatar startReciprocol:reciprocalTime
                         fromProgress:progress];
    
}

- (void)stopReciprocal
{
    [self.roundAvatar stopReciprocol];
}



- (void)setImage:(UIImage *)image
{
    [self.roundAvatar setImage:image];
}

- (void)clickOnAvatar
{
    [[AudioManager defaultManager] playSoundByURL:[ZJHSoundManager defaultManager].clickButtonSound];
    if (_delegate && [_delegate respondsToSelector:@selector(didClickOnAvatar:)]) {
        [_delegate didClickOnAvatar:self];
    }
}

- (void)setAvatarUrl:(NSString *)url gender:(BOOL)gender
{
    [self.roundAvatar setAvatarUrl:url
                            gender:gender];
}


- (void)setGrayAvatar:(BOOL)isGray
{
    [self.roundAvatar setGrayAvatar:isGray];
}

- (void)setGestureRecognizerEnable:(BOOL)enable
{
    self.userInteractionEnabled = enable;
}

- (void)resetAvatar
{
    [self.backgroundImageView setImage:[ZJHImageManager defaultManager].noUserAvatarBackground];
    [self.roundAvatar setImage:[ZJHImageManager defaultManager].noUserAvatarBackground];
    [self.nickNameLabel setText:nil];
    self.roundAvatar.hidden = YES;
    self.userInfo = nil;
    self.delegate = nil;
    self.roundAvatar.delegate = nil;
}

- (void)updateBackgroundByUser:(PBGameUser*)user
{
    if (self.frame.size.width > self.frame.size.height) {
        [self.backgroundImageView setImage:[ZJHImageManager defaultManager].myAvatarBackground];
    } else {
        [self.backgroundImageView setImage:[ZJHImageManager defaultManager].avatarBackground];
    }
}

- (void)updateNicknameByUser:(PBGameUser*)user
{
    if (user) {
        [self.nickNameLabel setText:user.nickName];
    }
}

- (void)updateAvatarByUser:(PBGameUser*)user
{
    if (user) {
        self.roundAvatar.hidden = NO;
        [self.roundAvatar setAvatarUrl:user.avatar gender:user.gender];
    }
}

- (void)updateByPBGameUser:(PBGameUser*)user
{
//    [self resetAvatar];
    [self updateBackgroundByUser:user];
    [self updateNicknameByUser:user];
    [self updateAvatarByUser:user];
    [self setUserInfo:user];
}

- (void)didClickOnAvatar:(DiceAvatarView *)view
{
    if (_delegate && [_delegate respondsToSelector:@selector(didClickOnAvatar:)]) {
        [_delegate didClickOnAvatar:self];
    }
}

- (void)reciprocalEnd:(DiceAvatarView *)view
{
    PPDebug(@"<test> zjh avatar = %@, seciprocal end",[self description]);
    if (_delegate && [_delegate respondsToSelector:@selector(reciprocalEnd:)]) {
        [_delegate reciprocalEnd:self];
    }
}

- (void)showPopCoinAnimation
{
    CGPoint destination = CGPointMake(self.frame.size.width/2                                                            , -1*_rewardCoinView.frame.size.height);
    //    CAAnimation* moveUp = [AnimationManager translationAnimationFrom:CGPointMake(_rewardCoinView.center.x, self.nickNameLabel.center.y) to:destination duration:duration];
    CAAnimation* moveUp = [AnimationManager translationAnimationFrom:CGPointMake(_rewardCoinView.center.x, self.nickNameLabel.center.y)
                                                                  to:destination
                                                            duration:2
                                                            delegate:self
                                                    removeCompeleted:NO];
    
    CAAnimation* disappear = [AnimationManager disappearAnimationWithDuration:1];
    disappear.beginTime = moveUp.duration;
    disappear.removedOnCompletion = NO;
    
    //method2:放入动画数组，统一处理！
    CAAnimationGroup* animGroup    = [CAAnimationGroup animation];
    
    //设置动画代理
    animGroup.delegate = self;
    
    animGroup.removedOnCompletion = NO;
    
    animGroup.duration             = disappear.beginTime+disappear.duration;
    animGroup.timingFunction      = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    animGroup.repeatCount         = 1;//FLT_MAX;  //"forever";
    animGroup.fillMode             = kCAFillModeForwards;
    animGroup.animations             = [NSArray arrayWithObjects:moveUp, disappear, nil];
    [animGroup setValue:@"MOVE_UP"  forKey:@"ANIM_GROUP"];
    
    [_rewardCoinView.layer addAnimation:animGroup forKey:@"ANIM_GROUP"];
}

- (void)showWinCoins:(int)coinsCount
{
    PPDebug(@"<test>%@ win %d golds", self.nickNameLabel.text, coinsCount);
    
    if (coinsCount == 0) {
        return;
    }
    [_rewardCoinView.layer removeAllAnimations];
    [self.coinImageView setImage:[ShareImageManager defaultManager].coinImage];
    [self bringSubviewToFront:_rewardCoinView];
    [_rewardCoinLabel setText:[NSString stringWithFormat:@"%+d",coinsCount]];
    _rewardCoinLabel.textColor = (coinsCount >= 0) ? [UIColor redColor] : [UIColor greenColor];
    _rewardCoinView.layer.opacity = 1;
    _rewardCoinView.hidden = NO;
    
    [self showPopCoinAnimation];
}

- (void)showLoseCoins:(int)coins
{
    [self showWinCoins:-coins];
    
}

- (void)showExpression:(NSString *)key
{
    GifView *view = [[ExpressionManager defaultManager] gifExpressionForKey:key frame:self.roundAvatarPlaceView.frame];
    view.autoresizingMask =
    !UIViewAutoresizingFlexibleLeftMargin |
    !UIViewAutoresizingFlexibleRightMargin |
    !UIViewAutoresizingFlexibleTopMargin |
    !UIViewAutoresizingFlexibleBottomMargin |
    UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleHeight;
    
    view.center = self.roundAvatarPlaceView.center;
    
    view.userInteractionEnabled = NO;
    [self addSubview:view];
    
    [UIView animateWithDuration:1 delay:6.0 options:UIViewAnimationCurveLinear animations:^{
        view.alpha = 0;
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
    }];
}


//- (void)showExpression:(UIImage *)image
//{
//    UIImageView *view = [[[UIImageView alloc] initWithFrame:self.roundAvatarPlaceView.frame] autorelease];
//    view.transform = CGAffineTransformMakeScale(1.05, 1.05);
//    view.center = self.roundAvatarPlaceView.center;
//    view.image = image;
//    CAAnimation *moveVerticalAni = [AnimationManager moveVerticalAnimationFrom:view.center.y to:view.center.y - ([DeviceDetection isIPAD] ? 20 : 10) duration:0.5];
//    moveVerticalAni.repeatCount = 3;
//    moveVerticalAni.autoreverses = YES;
//    [view.layer addAnimation:moveVerticalAni forKey:nil];
//    
//    CAAnimation *appearAni = [AnimationManager disappearAnimationFrom:1 to:0 delay:3 duration:1];
//    
//    [view.layer addAnimation:appearAni forKey:nil];
//    [self addSubview:view];
//    [view performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:4];
//}



@end
