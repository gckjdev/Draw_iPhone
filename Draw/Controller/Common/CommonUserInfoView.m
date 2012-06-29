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
#import "FriendManager.h"
#import "CommonMessageCenter.h"
#import "UserFeedController.h"
#import "ChatDetailController.h"
#import "SelectWordController.h"
#import "LocaleUtils.h"
#import "WordManager.h"

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
@synthesize statusLabel;
@synthesize targetFriend = _targetFriend;
@synthesize superViewController = _superViewController;
@synthesize userAvatar;
@synthesize userNickName;
@synthesize userLocation;
@synthesize userGender;

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

#define AVATAR_FRAME [DeviceDetection isIPAD]?CGRectMake(0, 0, 0, 0):CGRectMake(18, 46, 42, 42)
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
    self.targetFriend = aFriend;
    [self.userName setText:aFriend.nickName];
    
    NSString* location = [LocaleUtils isTraditionalChinese]?[WordManager changeToTraditionalChinese:aFriend.location]:aFriend.location;
    [self.locationLabel setText:location];
    
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
    
    //set followbutton or statusLabel
    [self.followUserButton setBackgroundImage:[[ShareImageManager defaultManager] normalButtonImage] forState:UIControlStateNormal];
    [self.followUserButton setTitle:NSLS(@"kAddAsFriend") forState:UIControlStateNormal];
    if ([[[UserManager defaultManager] userId] isEqualToString:aFriend.friendUserId]){
        statusLabel.hidden = NO;
        self.followUserButton.hidden = YES;
        statusLabel.text = NSLS(@"kMyself");
    }else if ([[FriendManager defaultManager] isFollowFriend:aFriend.friendUserId]) {
        statusLabel.hidden = NO;
        self.followUserButton.hidden = YES;
        statusLabel.text = NSLS(@"kAlreadyBeFriend");
    }
    else {
        statusLabel.hidden = YES;
        self.followUserButton.hidden = NO; 
    }

    
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
      infoInView:(PPViewController<FriendServiceDelegate>*)superController
{
    CommonUserInfoView* view = [CommonUserInfoView createUserInfoView];
    [view initViewWithFriend:afriend];
    view.superViewController = superController;
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

- (IBAction)clickFollowButton:(id)sender
{
    [[FriendService defaultService] followUser:self.targetFriend.friendUserId withDelegate:self];
    [self.superViewController showActivityWithText:NSLS(@"kFollowing")];
}

- (void)didFollowUser:(int)resultCode
{
    [self.superViewController hideActivity];
    if (resultCode) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kFollowFailed")
                                                       delayTime:1.5 
                                                         isHappy:NO];        
    } else {        
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kFollowSuccessfully")
                                                       delayTime:1.5 
                                                         isHappy:YES];
        [self.followUserButton setHidden:YES];
        [self.statusLabel setText:NSLS(@"kAlreadyBeFriend")];
    }
}

- (IBAction)drawToHim:(id)sender
{
    [SelectWordController startSelectWordFrom:self.superViewController targetUid:self.targetFriend.friendUserId];
}

- (IBAction)talkToHim:(id)sender
{
    ChatDetailController *controller = [[ChatDetailController alloc] initWithFriendUserId:self.targetFriend.friendUserId
                                                                           friendNickname:self.targetFriend.nickName
                                                                             friendAvatar:self.targetFriend.avatar
                                                                             friendGender:self.targetFriend.gender];
    [self.superViewController.navigationController pushViewController:controller animated:YES];
    [controller release];
}

- (IBAction)seeHisFeed:(id)sender
{
    UserFeedController *userFeed = [[UserFeedController alloc] initWithUserId:self.targetFriend.friendUserId nickName:self.targetFriend.nickName];
    [self.superViewController.navigationController pushViewController:userFeed animated:YES];
    [userFeed release];
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
    [statusLabel release];
    [super dealloc];
}
@end
