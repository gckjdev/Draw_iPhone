//
//  FacetimeUserInfoView.m
//  Draw
//
//  Created by Orange on 12-7-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FacetimeUserInfoView.h"
#import "AnimationManager.h"
#import "ShareImageManager.h"
#import "GameBasic.pb.h"
#import "StableView.h"
#import "PPDebug.h"

#define AVATAR_VIEW_TAG 20120727

#define DEFAULT_FACETIME_WATING_TIME (10)
#define START_TIMER_INTERVAL (1)

@implementation FacetimeUserInfoView
@synthesize avatarView;
@synthesize nickNameLabel;
@synthesize genderLabel;
@synthesize locationLabel;
@synthesize followStatusLabel;
@synthesize followButton;
@synthesize startFacetimeButton;
@synthesize changeButton;
@synthesize contentView;
@synthesize contentBackgroundImageView;
@synthesize delegate = _delegate;
@synthesize facetimeId = _facetimeId;
@synthesize startTimer = _startTimer;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)startRunOutAnimation:(CFTimeInterval)timeInterval
{
    CAAnimation *runOut = [AnimationManager scaleAnimationWithFromScale:1 toScale:0.1 duration:timeInterval delegate:self removeCompeleted:NO];
    [runOut setValue:@"runOut" forKey:@"AnimationKey"];
    [self.contentView.layer addAnimation:runOut forKey:@"runOut"];
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    NSString* value = [anim valueForKey:@"AnimationKey"];
    if ([value isEqualToString:@"runOut"]) {
        if (_delegate && [_delegate respondsToSelector:@selector(clickStartChat:)]) {
            [_delegate clickStartChat:self];
        }
        self.hidden = YES;
    }
}

- (void)handleStartTimer:(id)sender
{
    PPDebug(@"<handleStartTimer> fire start game timer, timer count=%d", _currentTimeCounter);
    
    _currentTimeCounter --;
    [self updateStartButton];    
    
    if (_currentTimeCounter <= 0){
       [self startRunOutAnimation:_runInAnimTime];
    }
}


- (void)updateStartButton
{
    [self.startFacetimeButton setTitle:[NSString stringWithFormat:@"%@(%d)",NSLS(@"kBegining"), _currentTimeCounter] forState:UIControlStateNormal];
}

- (void)resetStartTimer
{
    _currentTimeCounter = DEFAULT_FACETIME_WATING_TIME;
    [self updateStartButton];
    if (self.startTimer != nil){
        if ([self.startTimer isValid]){
            [self.startTimer invalidate];
        }
        
        self.startTimer = nil;
    }
}

- (void)scheduleStartTimer
{
    [self resetStartTimer];
    self.startTimer = [NSTimer scheduledTimerWithTimeInterval:START_TIMER_INTERVAL
                                                       target:self 
                                                     selector:@selector(handleStartTimer:) 
                                                     userInfo:nil 
                                                      repeats:YES];
}



+ (FacetimeUserInfoView*)createUserInfoView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"FacetimeUserInfoView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create <FacetimeUserInfoView> but cannot find cell object from Nib");
        return nil;
    }
    FacetimeUserInfoView* view =  (FacetimeUserInfoView*)[topLevelObjects objectAtIndex:0];
    [view.contentBackgroundImageView setImage:[ShareImageManager defaultManager].friendDetailBgImage];
    return view;
}

- (void)showInViewController:(UIViewController<FacetimeUserInfoViewDelegate>*)superController 
                      inTime:(CFTimeInterval)timeInterval
{
    _runInAnimTime = timeInterval;
    _delegate = superController;
    CAAnimation *runIn = [AnimationManager scaleAnimationWithFromScale:0.1 toScale:1 duration:_runInAnimTime delegate:self removeCompeleted:NO];
    [self.contentView.layer addAnimation:runIn forKey:@"runIn"];
}
- (void)showFacetimeUser:(PBGameUser*)user 
          isChosenToInit:(BOOL)isChosenToInit
        inViewController:(UIViewController<FacetimeUserInfoViewDelegate>*)superController 
                  inTime:(CFTimeInterval)timeInterval
{
    self.hidden = NO;
    //set avatar
    if (![self.contentView viewWithTag:AVATAR_VIEW_TAG]) {
        AvatarView* view = [[[AvatarView alloc] initWithUrlString:user.avatar
                                                            frame:self.avatarView.frame
                                                           gender:user.gender
                                                            level:0] autorelease];
        [self.contentView addSubview:view];
    }
    AvatarView* avatar = (AvatarView*)[self.contentView viewWithTag:AVATAR_VIEW_TAG];
    [avatar setAvatarUrl:user.avatar 
                  gender:user.gender ];
    
    [self.nickNameLabel setText:user.nickName];
    [self.locationLabel setText:user.location];
    [self.genderLabel setText:(user.gender)?NSLS(@"kMale"):NSLS(@"kFemale")];
    self.facetimeId = user.facetimeId;
    
    _isChosenToInit = isChosenToInit;
    if (isChosenToInit) {
        [self.startFacetimeButton setTitle:NSLS(@"kBegining") forState:UIControlStateNormal];
        [self scheduleStartTimer];
    } else {
        [self.startFacetimeButton setTitle:NSLS(@"kWaiting") forState:UIControlStateNormal];
    }

    [self showInViewController:superController inTime:timeInterval];
    
}

- (IBAction)clickStart:(id)sender
{
    
}

- (IBAction)clickChange:(id)sender
{
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc {
    [avatarView release];
    [nickNameLabel release];
    [genderLabel release];
    [locationLabel release];
    [followStatusLabel release];
    [followButton release];
    [startFacetimeButton release];
    [changeButton release];
    [contentView release];
    [contentBackgroundImageView release];
    [_facetimeId release];
    [_startTimer release];
    [super dealloc];
}
@end
