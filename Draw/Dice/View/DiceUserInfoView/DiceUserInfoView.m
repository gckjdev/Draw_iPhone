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
#import "FontButton.h"
#import "ChatDetailController.h"
#import "HKGirlFontLabel.h"

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
@synthesize targetFriend = _targetFriend;
@synthesize superViewController = _superViewController;
@synthesize avatar;
@synthesize chatButton;
@synthesize userId;
@synthesize userAvatar;
@synthesize userNickName;
@synthesize userLocation;
@synthesize userGender;
@synthesize hasQQ;
@synthesize hasSina;
@synthesize hasFacebook;
@synthesize userLevel;
@synthesize levelLabel;
@synthesize coins = _coins;
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
    [userAvatar release];
    [userNickName release];
    [userGender release];
    [userLocation release];
    [userId release];
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

    [self.avatar setUrlString:self.userAvatar userId:self.userId gender:[@"m" isEqualToString:self.userGender] level:self.userLevel drunkPoint:0 wealth:0];
    [self.avatar setAvatarStyle:AvatarViewStyle_Square];
}

- (void)initButton
{
    [self.followUserButton setRoyButtonWithColor:[DiceColorManager dialogRedColor]];
    [self.chatButton setRoyButtonWithColor:[DiceColorManager dialoggreenColor]];
    [self.chatButton.fontLable setText:NSLS(@"kChatToHim")];
}

- (void)initLevelAndName
{
    [self.levelLabel setText:[NSString stringWithFormat:@"LV.%d",self.userLevel]];
    [self.userName setText:self.userNickName];
//    if (self.userNickName) {
//        
//        UIFont* font = [DeviceDetection isIPAD]?[UIFont systemFontOfSize:26]:[UIFont systemFontOfSize:13];
//        float maxWidth = [DeviceDetection isIPAD]?224:101;
//        CGSize nameSize = [self.userNickName sizeWithFont:font];
//        if (nameSize.width < maxWidth) {
//            [self.userName setFrame:CGRectMake(self.userName.frame.origin.x, 
//                                               self.userName.frame.origin.y, 
//                                               nameSize.width, 
//                                               self.userName.frame.size.height)];
//            [self.levelLabel setFrame:CGRectMake(self.userName.frame.origin.x
//                                                 +nameSize.width, 
//                                                 self.levelLabel.frame.origin.y, 
//                                                 self.levelLabel.frame.size.width, 
//                                                 self.levelLabel.frame.size.height)];
//        }
//    }
    
}

- (void)initLocation
{
    NSString* location = [LocaleUtils isTraditionalChinese]?[WordManager changeToTraditionalChinese:self.userLocation]:self.userLocation;
    [self.locationLabel setText:location];
}

- (void)initGender
{
    UIImage* genderImage = [@"m" isEqualToString:self.userGender]?[[DiceImageManager defaultManager] maleImage]:[[DiceImageManager defaultManager] femaleImage];
//    [self.genderLabel setText:gender];
    [self.genderImageView setImage:genderImage];
}

- (void)initSNSInfo
{
    CommonSnsInfoView* view = [[[CommonSnsInfoView alloc] initWithFrame:self.snsTagImageView.frame 
                                                                hasSina:self.hasSina 
                                                                  hasQQ:self.hasQQ 
                                                            hasFacebook:self.hasFacebook] autorelease];
    [self.contentView addSubview:view];
}

- (void)initFollowStatus
{
    //set followbutton or statusLabel
    //[self.followUserButton setBackgroundImage:[[ShareImageManager defaultManager] normalButtonImage] forState:UIControlStateNormal];
    [self.followUserButton.fontLable setText:NSLS(@"kAddAsFriend")];
    if ([[[UserManager defaultManager] userId] isEqualToString:self.userId]){
        statusLabel.hidden = NO;
        self.followUserButton.hidden = YES;
        statusLabel.text = NSLS(@"kMyself");
    }else if ([[FriendManager defaultManager] isFollowFriend:self.userId]) {
        statusLabel.hidden = NO;
        self.followUserButton.hidden = YES;
        statusLabel.text = NSLS(@"kAlreadyBeFriend");
    }
    else {
        statusLabel.hidden = YES;
        self.followUserButton.hidden = NO; 
    }
}

- (void)initCoins
{
    [self.coinsLabel setText:[NSString stringWithFormat:@"%ld",self.coins]];
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


- (void)initViewWithUserId:(NSString*)aUserId 
                  nickName:(NSString*)nickName 
                    avatar:(NSString*)anAvatar 
                    gender:(NSString*)aGender 
                  location:(NSString*)location 
                     level:(int)level
                   hasSina:(BOOL)didHasSina 
                     hasQQ:(BOOL)didHasQQ 
               hasFacebook:(BOOL)didHasFacebook
{
    
    
    self.userId = aUserId;
    self.userNickName = nickName;
    self.userAvatar = anAvatar;
    self.userGender = aGender;
    self.hasQQ = didHasQQ;
    self.hasSina = didHasSina;
    self.hasFacebook = didHasFacebook;
    self.userLocation = location;
    self.userLevel = level;
    
    [self initView];
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

+ (void)showUser:(PBGameUser*)aUser 
      infoInView:(PPViewController*)superController
{
    NSString* aGender = aUser.gender?@"m":@"f";
    [self showUser:aUser.userId 
          nickName:aUser.nickName 
            avatar:aUser.avatar 
            gender:aGender 
          location:aUser.location 
             level:aUser.userLevel 
           hasSina:NO 
             hasQQ:NO 
       hasFacebook:NO 
        infoInView:superController];
}


+ (void)showUser:(NSString*)userId 
        nickName:(NSString*)nickName 
          avatar:(NSString*)avatar 
          gender:(NSString*)aGender 
        location:(NSString*)location 
           level:(int)level
         hasSina:(BOOL)didHasSina 
           hasQQ:(BOOL)didHasQQ 
     hasFacebook:(BOOL)didHasFacebook
      infoInView:(PPViewController*)superController
{
    if (![[UserManager defaultManager] isMe:userId]) {
        DiceUserInfoView* view = [DiceUserInfoView createUserInfoView];
        [view initViewWithUserId:userId 
                        nickName:nickName 
                          avatar:avatar 
                          gender:aGender 
                        location:location 
                           level:level
                         hasSina:didHasSina 
                           hasQQ:didHasQQ 
                     hasFacebook:didHasFacebook];
        view.superViewController = superController;
        [superController showActivityWithText:NSLS(@"kQuerying")];
        [[UserService defaultService] getUserSimpleInfoByUserId:userId delegate:view];
        //[superController.view addSubview:view];
    }
    
}

+ (void)showUser:(NSString*)userId 
        nickName:(NSString*)nickName 
          avatar:(NSString*)avatar 
          gender:(NSString*)aGender 
        location:(NSString*)location 
           level:(int)level
         hasSina:(BOOL)didHasSina 
           hasQQ:(BOOL)didHasQQ 
     hasFacebook:(BOOL)didHasFacebook
infoInView:(PPViewController*)superController 
         canChat:(BOOL)canChat
{
    if (![[UserManager defaultManager] isMe:userId]) {
        DiceUserInfoView* view = [DiceUserInfoView createUserInfoView];
        [view initViewWithUserId:userId 
                        nickName:nickName 
                          avatar:avatar 
                          gender:aGender 
                        location:location 
                           level:level
                         hasSina:didHasSina 
                           hasQQ:didHasQQ 
                     hasFacebook:didHasFacebook];
        view.superViewController = superController;
        [view.chatButton setHidden:!canChat];
        [superController showActivityWithText:NSLS(@"kQuerying")];
        [[UserService defaultService] getUserSimpleInfoByUserId:userId delegate:view];
        //[superController.view addSubview:view];
    }
    
}


- (IBAction)clickMask:(id)sender
{
    [self disappear];
}

- (IBAction)clickFollowButton:(id)sender
{
    [[FriendService defaultService] followUser:self.userId withDelegate:self];
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
- (void)didGetUserNickName:(NSString*)nickName
                UserAvatar:(NSString*)anAvatar
                UserGender:(NSString*)gender
              UserLocation:(NSString*)location 
                 UserLevel:(NSString*)level 
                  SinaNick:(NSString*)sinaNick 
                    QQNick:(NSString*)qqNick 
                      qqId:(NSString*)qqId
                FacebookId:(NSString*)facebookId
                     coins:(NSString *)coins
{
    if (nickName != nil) {
        self.userNickName = nickName;
    }
    
    if (avatar != nil) {
        self.userAvatar = anAvatar;
    }
    
    if (gender != nil) {
        self.userGender = gender;
    }
    
    if (location != nil) {
        self.userLocation = location;
    }
    
    if (level != nil) {
        self.userLevel = level.intValue;
    }
    
    if (sinaNick != nil) {
        self.hasSina = YES;
    }
    
    if (qqNick != nil) {
        self.hasQQ = YES;
    }
    
    if (facebookId != nil) {
        self.hasFacebook = YES;
    }
    if (coins != nil && coins.length > 0) {
        self.coins = coins.intValue;
    } else {
        self.coins = 0;
    }
    [self resetUserInfo];
    [self.superViewController hideActivity];
    [self showInView:self.superViewController.view];
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
        if ([currentController.friendUserId isEqualToString:self.userId])
        {
            [self clickMask:mask];
        }
    }
    else {
        ChatDetailController *controller = [[ChatDetailController alloc] initWithFriendUserId:self.userId
                                                                               friendNickname:self.userNickName
                                                                                 friendAvatar:self.userAvatar
                                                                                 friendGender:self.userGender];
        [self.superViewController.navigationController pushViewController:controller animated:YES];
        [controller release];
    }
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
