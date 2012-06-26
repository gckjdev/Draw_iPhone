//
//  CommonUserInfoView.m
//  Draw
//
//  Created by Orange on 12-6-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommonUserInfoView.h"
#import "ShareImageManager.h"
#import "AnimationManager.h"
#import "LocaleUtils.h"
#import "Friend.h"
#import "StableView.h"
#import "DeviceDetection.h"
#define RUN_OUT_TIME 0.2
#define RUN_IN_TIME 0.4

@implementation CommonUserInfoView
@synthesize backgroundImageView;
@synthesize mask;
@synthesize contentView;
@synthesize userName;
@synthesize snsTagImageView;
@synthesize genderLabel;
@synthesize locationLabel;
@synthesize playWithUserLabel;
@synthesize chatToUserLabel;
@synthesize drawToUserButton;
@synthesize exploreUserFeedButton;
@synthesize chatToUserButton;
@synthesize followUserButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)initTitle
{
    [self.playWithUserLabel setText:NSLS(@"kPlayWithHim")];
    [self.chatToUserLabel setText:NSLS(@"kChatToHim")];
}

#define AVATAR_FRAME [DeviceDetection isIPAD]?CGRectMake(0, 0, 0, 0):CGRectMake(18, 39, 42, 42)
- (void)initAvatar:(Friend*)aFriend
{
    CGRect rect = AVATAR_FRAME;
    AvatarView* view = [[AvatarView alloc] initWithUrlString:aFriend.avatar 
                                                       frame:rect
                                                      gender:([aFriend.gender isEqualToString:@"m"])
                                                       level:aFriend.level.intValue];
    [self.contentView addSubview:view];
}

- (void)initButton
{
    [self.chatToUserButton setTitle:NSLS(@"kChat") forState:UIControlStateNormal];
    [self.chatToUserButton setBackgroundImage:[ShareImageManager defaultManager].orangeImage forState:UIControlStateNormal];
    [self.drawToUserButton setTitle:NSLS(@"kDrawToHim") forState:UIControlStateNormal];
    [self.drawToUserButton setBackgroundImage:[ShareImageManager defaultManager].orangeImage forState:UIControlStateNormal];
    [self.exploreUserFeedButton setTitle:NSLS(@"kExploreHim") forState:UIControlStateNormal];
    [self.exploreUserFeedButton setBackgroundImage:[ShareImageManager defaultManager].orangeImage forState:UIControlStateNormal];
}

- (void)initView
{
    [self.backgroundImageView setImage:[ShareImageManager defaultManager].friendDetailBgImage];
    [self initTitle];
    [self initButton];
    
}

- (void)initViewWithFriend:(Friend*)aFriend
{
    [self initView];
    [self.userName setText:aFriend.nickName];
    [self.locationLabel setText:aFriend.location];
    
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    if (aFriend.sinaNick) {
        self.snsTagImageView.hidden = NO;
        [self.snsTagImageView setImage:[imageManager sinaWeiboImage]];
    }else if (aFriend.qqNick){
        self.snsTagImageView.hidden = NO;
        [self.snsTagImageView setImage:[imageManager qqWeiboImage]];
    }else if (aFriend.facebookNick){
        self.snsTagImageView.hidden = NO;
        [self.snsTagImageView setImage:[imageManager facebookImage]];
    }else {
        self.snsTagImageView.hidden = YES;
    }
    
    NSString* gender = [aFriend.gender isEqualToString:@"m"]?NSLS(@"kMale"):NSLS(@"kFemale");
    [self.genderLabel setText:gender];
    
    [self initAvatar:aFriend];
    
}

+ (CommonUserInfoView*)createUserInfoView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CommonUserInfoView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create <CommonUserInfoView> but cannot find cell object from Nib");
        return nil;
    }
    CommonUserInfoView* view =  (CommonUserInfoView*)[topLevelObjects objectAtIndex:0];
    
    CAAnimation *runIn = [AnimationManager scaleAnimationWithFromScale:0.1 toScale:1 duration:RUN_IN_TIME delegate:self removeCompeleted:NO];
    [view.contentView.layer addAnimation:runIn forKey:@"runIn"];
    
    return view;
}

+ (void)showUser:(Friend*)afriend 
      infoInView:(UIViewController*)superController
{
    CommonUserInfoView* view = [CommonUserInfoView createUserInfoView];
    [view initViewWithFriend:afriend];
    [superController.view addSubview:view];
}

- (void)startRunOutAnimation
{
    CAAnimation *runOut = [AnimationManager scaleAnimationWithFromScale:1 toScale:0.1 duration:RUN_OUT_TIME delegate:self removeCompeleted:NO];
    [runOut setValue:@"runOut" forKey:@"AnimationKey"];
    [self.contentView.layer addAnimation:runOut forKey:@"runOut"];
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    NSString* value = [anim valueForKey:@"AnimationKey"];
    if ([value isEqualToString:@"runOut"]) {
        [self setHidden:YES];
        [self removeFromSuperview];
    }
}

- (IBAction)clickMask:(id)sender
{
    [self startRunOutAnimation];
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
    [backgroundImageView release];
    [mask release];
    [contentView release];
    [userName release];
    [snsTagImageView release];
    [genderLabel release];
    [locationLabel release];
    [playWithUserLabel release];
    [chatToUserLabel release];
    [drawToUserButton release];
    [exploreUserFeedButton release];
    [chatToUserButton release];
    [followUserButton release];
    [super dealloc];
}
@end
