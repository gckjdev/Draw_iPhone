//
//  CommonUserInfoView.m
//  Draw
//
//  Created by Orange on 12-6-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommonUserInfoView.h"
#import "AnimationManager.h"
#import "LocaleUtils.h"
#import "MyFriend.h"
#import "StableView.h"
#import "DeviceDetection.h"
#import "FriendManager.h"
#import "CommonMessageCenter.h"
#import "UserFeedController.h"
#import "ChatDetailController.h"
#import "SelectWordController.h"
#import "LocaleUtils.h"
#import "WordManager.h"
#import "CommonSnsInfoView.h"
#import "MessageStat.h"
#import "CommonRoundAvatarView.h"
#import "CommonImageManager.h"
#import "StringUtil.h"


#import "DrawUserInfoView.h"
#import "DiceUserInfoView.h"
#import "ZJHUserInfoView.h"

#define RUN_OUT_TIME 0.2
#define RUN_IN_TIME 0.4

@implementation CommonUserInfoView

- (void)dealloc {
    PPRelease(_backgroundImageView);
    PPRelease(_mask);
    PPRelease(_userName);
    PPRelease(_snsTagImageView);
    PPRelease(_genderLabel);
    PPRelease(_locationLabel);
    PPRelease(_chatToUserButton);
    PPRelease(_followUserButton);
    PPRelease(_statusLabel);
    PPRelease(_levelLabel);
    [_genderImageView release];
    [_coinsLabel release];
    [_avatarView release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#define AVATAR_FRAME [DeviceDetection isIPAD]?CGRectMake(43, 100, 100, 91):CGRectMake(18, 46, 42, 42)
#define LEVEL_LABEL_FRAME [DeviceDetection isIPAD]?CGRectMake(0, 0, 30, 21):CGRectMake(0, 0, 60, 45)

#define SUBVIEW_AVATAR_TAG 201210241
#define SUBVIEW_SNSVIEW_TAG 201210242
- (void)cleanSubViews
{
    UIView *view = [self.contentView viewWithTag:SUBVIEW_AVATAR_TAG];
    [view removeFromSuperview];
    view = [self.contentView viewWithTag:SUBVIEW_SNSVIEW_TAG];
    [view removeFromSuperview];
    
}

- (void)initAvatar
{
//    CGRect rect = AVATAR_FRAME;
//    AvatarView* view = [[[AvatarView alloc] initWithUrlString:_targetFriend.avatar
//                                                       frame:rect
//                                                      gender:_targetFriend.isMale
//                                                       level:_targetFriend.level] autorelease];
//    view.tag = SUBVIEW_AVATAR_TAG;
//    [self.contentView addSubview:view];
    [self.avatarView setUrlString:_targetFriend.avatar
                           userId:_targetFriend.friendUserId
                           gender:[@"m" isEqualToString:_targetFriend.gender ]
                            level:_targetFriend.level
                       drunkPoint:0
                           wealth:_targetFriend.coins];
    [self.avatarView setAvatarStyle:AvatarViewStyle_Square];
}

- (void)initLevelAndName
{
    [self.levelLabel setText:[NSString stringWithFormat:@"LV.%d",_targetFriend.level]];
    [self.userName setText:_targetFriend.nickName];
}

- (void)initLocation
{
    NSString* location = [LocaleUtils isTraditionalChinese]?[WordManager changeToTraditionalChinese:_targetFriend.location]:_targetFriend.location;
    [self.locationLabel setText:location];
}

- (void)initGender
{
    CommonImageManager* manager = [CommonImageManager defaultManager];
    UIImage* image = [@"m" isEqualToString:_targetFriend.gender]?manager.maleImage:manager.femaleImage;
    [self.genderImageView setImage:image];
}

- (void)initBalance
{
    [self.coinsLabel setText:[NSString stringWithInt:_targetFriend.coins]];
}

- (void)initSNSInfo
{

    CommonSnsInfoView* view = [[[CommonSnsInfoView alloc] 
                                initWithFrame:self.snsTagImageView.frame                                 
                                hasSina:_targetFriend.isSinaUser
                                hasQQ:_targetFriend.isQQUser
                                hasFacebook:_targetFriend.isFacebookUser]
                               autorelease];
    view.tag = SUBVIEW_SNSVIEW_TAG;
    [self.contentView addSubview:view];
}

- (void)initFollowStatus
{
    //set followbutton or statusLabel
    self.statusLabel.hidden = self.followUserButton.hidden = YES;

    BOOL isMe = [[[UserManager defaultManager] userId] 
                 isEqualToString:_targetFriend.friendUserId];
    
    if (isMe) {
        _statusLabel.hidden = NO;
        _statusLabel.text = NSLS(@"kMyself");
    }else if(_targetFriend.hasFollow){
        _statusLabel.hidden = NO;
        _statusLabel.text = NSLS(@"kAlreadyBeFriend");
    }else{
        self.followUserButton.hidden = NO; 
        [self.followUserButton setTitle:NSLS(@"kFollowMe") forState:UIControlStateNormal];
    }
}

- (void)updateUserInfoView
{
    //user info
    [self cleanSubViews];    
    [self initLevelAndName];
    [self initLocation];
    [self initGender];
    [self initSNSInfo];
    [self initAvatar];
    [self initFollowStatus];
    [self initBalance];
}

- (void)initView
{
    
}

+ (CommonUserInfoView*)createUserInfoView
{
    return (CommonUserInfoView*)[self createInfoViewByXibName:@"CommonUserInfoView"];
}

#pragma mark - click action.
- (IBAction)clickMask:(id)sender
{
    [self disappear];
}

- (IBAction)clickFollowButton:(id)sender
{
    [[FriendService defaultService] followUser:_targetFriend.friendUserId withDelegate:self];
    [_superViewController showActivityWithText:NSLS(@"kFollowing")];
}

- (void)didFollowUser:(int)resultCode
{
    [_superViewController hideActivity];
    if (resultCode != 0) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kFollowFailed")
                                                       delayTime:1.5 
                                                         isHappy:NO];        
    } else {        
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kFollowSuccessfully")
                                                       delayTime:1.5 
                                                         isHappy:YES];
        [self.followUserButton setHidden:YES];
        [self.statusLabel setText:NSLS(@"kAlreadyBeFriend")];
        self.targetFriend.relation |= FriendTypeFollow;
    }
}

- (IBAction)talkToHim:(id)sender
{
    if ([_superViewController isKindOfClass:[ChatDetailController class]]) {
        ChatDetailController *currentController = (ChatDetailController *)_superViewController;
        if ([currentController.fid isEqualToString:_targetFriend.friendUserId])
        {
            [self clickMask:_mask];
        }
    }
    else {
        MessageStat *stat = [MessageStat messageStatWithFriend:_targetFriend];
        ChatDetailController *controller = [[ChatDetailController alloc] initWithMessageStat:stat];
        [_superViewController.navigationController pushViewController:controller
                                                                 animated:YES];
        [controller release];
    }
}


#pragma mark - main process methods.
- (void)initViewWithFriend:(MyFriend *)afriend
           superController:(PPViewController *)superController
{
    self.targetFriend = afriend;
    _superViewController = superController;
    
    [self initView];
}


- (void)show
{
    [self showInView:_superViewController.view];
}

- (void)updateInfoFromService
{
    if ([_targetFriend.friendUserId length] != 0) {
        [[UserService defaultService] getUserSimpleInfoByUserId:_targetFriend.friendUserId
                                                       delegate:self];
    }
}

+ (void)showFriend:(MyFriend*)afriend 
        infoInView:(PPViewController*)superController
        needUpdate:(BOOL)needUpdate //if need update the info from service.
{
    if ([[UserManager defaultManager] isMe:afriend.friendUserId]) {
        return;
    }
    
    CommonUserInfoView *view = [CommonUserInfoView createUserInfoView];
    [view initViewWithFriend:afriend superController:superController];
    [view show];
    if (needUpdate) {
        [view updateInfoFromService];
    }
}

+ (void)showFriend:(MyFriend *)afriend
      inController:(PPViewController *)superController
        needUpdate:(BOOL)needUpdate
           canChat:(BOOL)canChat
{
    if (isDrawApp()) {
        [DrawUserInfoView showFriend:afriend
                          infoInView:superController
                          needUpdate:needUpdate];
        return;
    }
    if (isDiceApp()) {
        [DiceUserInfoView showFriend:afriend
                          infoInView:superController
                             canChat:canChat
                          needUpdate:needUpdate];
        return;
    }
    if (isZhajinhuaApp()) {
        [ZJHUserInfoView showFriend:afriend
                         infoInView:superController
                         needUpdate:needUpdate];
        return;
    }
    [CommonUserInfoView showFriend:afriend
                        infoInView:superController
                        needUpdate:needUpdate];
}

#pragma mark - user service delegate

- (void)didGetUserInfo:(MyFriend *)user resultCode:(NSInteger)resultCode
{
    if (resultCode == 0 && user != nil) {
        self.targetFriend = user;
        [self updateUserInfoView];
    }
}

@end