//
//  DiceAvatarView.m
//  Draw
//
//  Created by Orange on 12-7-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DiceAvatarView.h"
#import "DACircularProgressView.h"
#import "HJManagedImageV.h"
#import "DiceImageManager.h"
#import "PPApplication.h"
#import "PPDebug.h"
#import "DeviceDetection.h"
#import "ShareImageManager.h"
#import "AnimationManager.h"
#import "HKGirlFontLabel.h"
#import "UIImage+FiltrrCompositions.h"

#define PROGRESS_UPDATE_TIME    0.01

@implementation DiceAvatarView
@synthesize score = _score;
@synthesize userId = _userId;
@synthesize delegate = _delegate;
@synthesize hasPen = _hasPen;

- (void)dealloc
{
    [imageView release];
//    [markButton release];
    [_userId release];
    [progressView release];
    [bgView release];
    [_timer release];
    [_rewardCoinLabel release];
    [_rewardCoinView release];
    [_rewardView release];
    [super dealloc];
}

- (void)removeFromSuperview
{
    if (_timer) {
        if ([_timer isValid]) {
            [_timer invalidate];
        }
    }
    _timer = nil;
    _delegate = nil;
    [super removeFromSuperview];
}

- (void)addTapGuesture
{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickOnAvatar)];    
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self addGestureRecognizer:tapGestureRecognizer];
    [tapGestureRecognizer release];
}

#define EDGE_WIDTH_TIMES 13
#define EDGE_HEIGHT_TIMES 13
- (CGRect)calAvatarFrame
{
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    CGFloat wEdge = -progressView.progressBarWidth;//width / EDGE_WIDTH_TIMES;
    CGFloat hEdge = -progressView.progressBarWidth;//height / EDGE_HEIGHT_TIMES;
    return CGRectMake(wEdge, hEdge, width - 2 * wEdge, height - 2 * hEdge);
}

- (CGRect)calSqureAvatarFrame
{
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    CGFloat wEdge = -3.1;//width / EDGE_WIDTH_TIMES;
    CGFloat hEdge = -3.1;//height / EDGE_HEIGHT_TIMES;
    return CGRectMake(wEdge, hEdge, width - 2 * wEdge, height - 3 * hEdge);
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        bgView = [[UIImageView alloc] initWithFrame:[self calSqureAvatarFrame]];
        [self addSubview:bgView];
        
        float width = MIN(self.bounds.size.width, self.bounds.size.height);
        imageView = [[HJManagedImageV alloc] initWithFrame:CGRectMake(0, 0, width, width)];
        [imageView setCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)];
        imageView.layer.cornerRadius = self.frame.size.width/2;
        imageView.layer.masksToBounds = YES;
        [imageView setImage:[[DiceImageManager defaultManager] 
                             whiteSofaImage]];
        [self addSubview:imageView];
        
        progressView = [[DACircularProgressView alloc] init];
        progressView.progressBarWidth = width*0.05;
        [progressView setFrame:[self calAvatarFrame]];
        progressView.trackTintColor = [UIColor clearColor];
        progressView.progressTintColor = [UIColor greenColor];
        progressView.hidden = YES;
        progressView.clockwise = YES;
        [self addSubview:progressView];
        
        _rewardView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height/3)];
        _rewardCoinView = [[UIImageView alloc] initWithImage:[ShareImageManager defaultManager].rewardCoin];
        [_rewardCoinView setFrame:CGRectMake(_rewardView.frame.size.width/2-_rewardView.frame.size.height, 0, _rewardView.frame.size.height, _rewardView.frame.size.height)];
        _rewardCoinLabel = [[HKGirlFontLabel alloc] initWithFrame:CGRectMake(_rewardView.frame.size.width/2, 0, _rewardView.frame.size.width, _rewardView.frame.size.height) pointSize:13];
        [_rewardCoinLabel setTextColor:[UIColor whiteColor]];
        [_rewardCoinLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        //[_rewardCoinLabel setTextAlignment:UITextAlignmentCenter];
        [_rewardView addSubview:_rewardCoinView];
        [_rewardView addSubview:_rewardCoinLabel];
        _rewardView.hidden = YES;
        [self addSubview:_rewardView];
        
        [self addTapGuesture];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

    }
    return self;
}

- (void)setProgress:(CGFloat)progress{
    progressView.hidden = NO;
    progressView.progress = progress;
}

- (void)setProgressHidden:(BOOL)hidden
{
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDuration:1];
    if (hidden) {
        progressView.hidden = YES;
    } else {
        progressView.hidden = NO;
    }
    [UIView commitAnimations];
}

- (void)setAvatarStyle:(AvatarViewStyle)style
{
    if (style == Square) {
        progressView.hidden = YES;
        imageView.layer.cornerRadius = 0;
        _currentStyle = Square;
        [bgView setImage:[[ShareImageManager defaultManager] avatarUnSelectImage]];
    } else {
        progressView.hidden = NO;
        imageView.layer.cornerRadius = imageView.frame.size.width/2;
        _currentStyle = Round;
        [bgView setImage:nil];
    }
    imageView.layer.masksToBounds = YES;
}

- (void)startReciprocol:(CFTimeInterval)reciprocolTime
{
    _currentProgress = 1.0f;
    _reciprocolTime = reciprocolTime;
    if (_timer != nil){
        if ([_timer isValid]){
            [_timer invalidate];
        }
        _timer = nil;
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:(reciprocolTime*PROGRESS_UPDATE_TIME) target:self selector:@selector(updateTimer:) userInfo:nil repeats:YES];
}

- (void)stopReciprocol
{
    [_timer invalidate];
    _timer = nil;
    [self setProgressHidden:YES];
}



- (void)setImage:(UIImage *)image
{
    [imageView clear];
    [imageView setImage:image];
    [GlobalGetImageCache() manage:imageView];
}

- (void)updateTimer:(id)sender
{
    _currentProgress -= PROGRESS_UPDATE_TIME;
    if (_currentProgress <= 0) {
        [self stopReciprocol];
        if (_delegate && [_delegate respondsToSelector:@selector(reciprocalEnd:)]) {
            PPDebug(@"<test>stop, delegate = %@ , avatar = %@",[_delegate description], [self description]);
            [_delegate reciprocalEnd:self];
        }
        return;
    }
    [self setProgress:_currentProgress];
}

- (void)clickOnAvatar
{

    if (_delegate && [_delegate respondsToSelector:@selector(didClickOnAvatar:)]) {
        [_delegate didClickOnAvatar:self];
    }
    
    
}

- (void)setAvatarUrl:(NSString *)url gender:(BOOL)gender
{
    [imageView clear];
    if (gender) {
        [imageView setImage:[[ShareImageManager defaultManager] 
                             maleDefaultAvatarImage]];
    }else{
        [imageView setImage:[[ShareImageManager defaultManager] 
                             femaleDefaultAvatarImage]];                
    }
    if ([url length] > 0){
        [imageView setUrl:[NSURL URLWithString:url]];
        [GlobalGetImageCache() manage:imageView];
    }
    _isBlackAndWhite = NO;
    _originAvatar = nil;
}

- (void)setUrlString:(NSString *)urlString 
              userId:(NSString*)userId
              gender:(BOOL)gender 
               level:(int)level 
          drunkPoint:(int)drunkPint 
              wealth:(int)wealth
{
    [self setAvatarUrl:urlString gender:gender];
    [self setUserId:userId];
    _isBlackAndWhite = NO;
    _originAvatar = nil;
}

- (void)rewardCoins:(int)coinsCount 
           duration:(float)duration
{
    _rewardView.hidden = NO;
    [_rewardCoinLabel setText:[NSString stringWithFormat:@"%+d",coinsCount]];
    
    CAAnimationGroup* animGroup = [CAAnimationGroup animation];
    CAAnimation* raise = [AnimationManager translationAnimationFrom:CGPointMake(self.frame.size.width/2, self.frame.size.height + _rewardView.frame.size.height) to:CGPointMake(self.frame.size.width/2                                                            , -3*_rewardView.frame.size.height) duration:duration*2];
    CAAnimation* disMiss = [AnimationManager missingAnimationWithDuration:duration];
    disMiss.beginTime = duration;
    animGroup.animations = [NSArray arrayWithObjects:raise, disMiss, nil];
    animGroup.removedOnCompletion = NO;
    animGroup.duration = duration*2;
    animGroup.timingFunction      = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];    
    animGroup.repeatCount         = 1;//FLT_MAX;  //"forever";
    animGroup.fillMode             = kCAFillModeForwards;
    
    [_rewardView.layer addAnimation:animGroup forKey:@"popReward"];
}

- (void)setGrayAvatar:(BOOL)isGray
{
    if (isGray != _isBlackAndWhite) {
        if (isGray) {
            _originAvatar = imageView.imageView.image;
            [self  setImage:[imageView.imageView.image blackAndWhite]];
        } else {
            if (_originAvatar) {
                [self setImage:_originAvatar];
            }
        }
    }
    _isBlackAndWhite = isGray;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
