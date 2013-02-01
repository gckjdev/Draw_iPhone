//
//  DiceUserInfoView.m
//  Draw
//
//  Created by Orange on 12-8-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DiceUserInfoView.h"
#import "LocaleUtils.h"
#import "DiceAvatarView.h"
#import "DeviceDetection.h"
#import "PPDebug.h"
#import "WordManager.h"
#import "CommonSnsInfoView.h"
#import "ShareImageManager.h"
#import "FriendManager.h"
#import "GameBasic.pb.h"
#import "Friend.h"
#import "StringUtil.h"
#import "AnimationManager.h"
#import "UserService.h"
#import "CommonMessageCenter.h"
#import "DiceColorManager.h"
#import "DiceImageManager.h"
#import "ChatDetailController.h"
#import "MessageStat.h"

@implementation DiceUserInfoView
@synthesize genderImageView;
@synthesize backgroundImageView;
@synthesize mask;
@synthesize userName;
@synthesize snsTagImageView;
@synthesize genderLabel;
@synthesize locationLabel;
@synthesize followUserButton;
@synthesize statusLabel;
@synthesize targetFriend;
@synthesize superViewController = _superViewController;
@synthesize avatar;
@synthesize chatButton;
//@synthesize userId;
//@synthesize userAvatar;
//@synthesize userNickName;
//@synthesize userLocation;
//@synthesize userGender;
//@synthesize hasQQ;
//@synthesize hasSina;
//@synthesize hasFacebook;
//@synthesize userLevel;
//@synthesize coins = _coins;
@synthesize levelLabel;
@synthesize coinsLabel = _coinsLabel;

- (void)dealloc {
    [backgroundImageView release];
    [mask release];
    [userName release];
    [snsTagImageView release];
    [genderLabel release];
    [locationLabel release];
    [followUserButton release];
    [statusLabel release];
//    [userAvatar release];
//    [userNickName release];
//    [userGender release];
//    [userLocation release];
//    [userId release];
    [levelLabel release];
    [avatar release];
    [genderImageView release];
    [chatButton release];
    [_coinsLabel release];
    [super dealloc];
}

- (void)initTitle
{

}

- (void)initAvatar
{

    [self.avatar setUrlString:targetFriend.avatar userId:targetFriend.friendUserId gender:[@"m" isEqualToString:targetFriend.gender] level:targetFriend.level drunkPoint:0 wealth:0];
    [self.avatar setAvatarStyle:AvatarViewStyle_Square];
}

- (void)initButton
{
//    [self.followUserButton setRoyButtonWithColor:[DiceColorManager dialogRedColor]];
//    [self.chatButton setRoyButtonWithColor:[DiceColorManager dialoggreenColor]];
//    [self.chatButton.fontLable setText:NSLS(@"kChatToHim")];
}

- (void)initLevelAndName
{
    [self.levelLabel setText:[NSString stringWithFormat:@"LV.%d",targetFriend.level]];
    [self.userName setText:targetFriend.nickName];    
}

- (void)initLocation
{
    NSString* location = [LocaleUtils isTraditionalChinese]?[WordManager changeToTraditionalChinese:targetFriend.location]:targetFriend.location;
    [self.locationLabel setText:location];
}

- (void)initGender
{
    UIImage* genderImage = [@"m" isEqualToString:targetFriend.gender]?[[DiceImageManager defaultManager] maleImage]:[[DiceImageManager defaultManager] femaleImage];
//    [self.genderLabel setText:gender];
    [self.genderImageView setImage:genderImage];
}

- (void)initSNSInfo
{
    CommonSnsInfoView* view = [[[CommonSnsInfoView alloc] initWithFrame:self.snsTagImageView.frame 
                                                                hasSina:targetFriend.isSinaUser 
                                                                  hasQQ:targetFriend.isQQUser 
                                                            hasFacebook:targetFriend.isFacebookUser] autorelease];
    [self.contentView addSubview:view];
}

- (void)initFollowStatus
{
    self.statusLabel.hidden = self.followUserButton.hidden = YES;
    BOOL isMe = [[[UserManager defaultManager] userId] 
                 isEqualToString:targetFriend.friendUserId];
    
    if (isMe) {
        statusLabel.hidden = NO;
        statusLabel.text = NSLS(@"kMyself");
    }else if(targetFriend.hasFollow){
        statusLabel.hidden = NO;
        statusLabel.text = NSLS(@"kAlreadyBeFriend");
    }else{
        self.followUserButton.hidden = NO; 
        [self.followUserButton.titleLabel setText:NSLS(@"kFollowMe")];
    }
}

- (void)initCoins
{
    [self.coinsLabel setText:[NSString stringWithFormat:@"%ld",targetFriend.coins]];
}

- (void)resetUserInfo
{
    [self initLevelAndName];
    [self initLocation];
    [self initGender];
    [self initSNSInfo];
    [self initAvatar];
    [self initFollowStatus];
    [self initCoins];
}

- (void)initView
{
    [self initTitle];
    [self initButton];
    [self resetUserInfo];
    [self.backgroundImageView setImage:[DiceImageManager defaultManager].popupBackgroundImage];
    
}


+ (DiceUserInfoView*)createUserInfoView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"DiceUserInfoView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create <DiceUserInfoView> but cannot find cell object from Nib");
        return nil;
    }
    DiceUserInfoView* view =  (DiceUserInfoView*)[topLevelObjects objectAtIndex:0];
    
    [view appear];
    
    return view;
}


- (void)initWithFriend:(MyFriend *)aFriend       
        infoInView:(PPViewController*)superController 
{
    self.targetFriend = aFriend;
    self.superViewController = superController;
}

- (void)show
{
    self.frame = self.superViewController.view.frame;
    [self.superViewController.view addSubview:self];
}

+ (void)showFriend:(MyFriend*)afriend 
        infoInView:(PPViewController*)superController 
           canChat:(BOOL)canChat
        needUpdate:(BOOL)needUpdate
{
    if ([[UserManager defaultManager] isMe:afriend.friendUserId]) {
        return;//if click my avatar, no response.
    }
    DiceUserInfoView *view = [DiceUserInfoView createUserInfoView];
    [view initWithFriend:afriend infoInView:superController];
    PPDebug(@"show friend = %@", afriend);
    [view initView];
    [view show];
    view.chatButton.hidden = !canChat;
    if (needUpdate) {
        [[UserService defaultService] getUserSimpleInfoByUserId:afriend.friendUserId delegate:view];
    }
}

+ (void)showUser:(PBGameUser*)aUser 
      infoInView:(PPViewController*)superController 
         canChat:(BOOL)canChat
      needUpdate:(BOOL)needUpdate //if need update the info from service.
{
    NSString *genderString = aUser.gender ? @"m" : @"f";
    MyFriend *aFriend = [MyFriend friendWithFid:aUser.userId 
                                       nickName:aUser.nickName
                                         avatar:aUser.avatar
                                         gender:genderString
                                          level:aUser.userLevel];
    [aFriend setLocation:aUser.location];
    [DiceUserInfoView showFriend:aFriend
                      infoInView:superController 
                         canChat:canChat 
                      needUpdate:needUpdate];
}



- (IBAction)clickMask:(id)sender
{
    [self disappear];
}

- (IBAction)clickFollowButton:(id)sender
{
    [[FriendService defaultService] followUser:targetFriend.friendUserId withDelegate:self];
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


#pragma mark - user service delegate

- (void)didGetUserInfo:(MyFriend *)user resultCode:(NSInteger)resultCode
{
    if (resultCode == 0 && user != nil) {
        self.targetFriend = user;
        [self resetUserInfo];
    }
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (IBAction)talkToHim:(id)sender
{
    if ([self.superViewController isKindOfClass:[ChatDetailController class]]) {
        ChatDetailController *currentController = (ChatDetailController *)self.superViewController;
        if ([currentController.fid isEqualToString:targetFriend.friendUserId])
        {
            [self clickMask:mask];
        }
    }
    else {
        MessageStat *stat = [MessageStat messageStatWithFriend:targetFriend];
        ChatDetailController *controller = [[ChatDetailController alloc] initWithMessageStat:stat];
        [self.superViewController.navigationController pushViewController:controller 
                                                                 animated:YES];
        [controller release];

    }
}


@end
