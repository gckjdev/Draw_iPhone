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

#define RUN_OUT_TIME 0.2
#define RUN_IN_TIME 0.4

@implementation DiceUserInfoView
@synthesize backgroundImageView;
@synthesize mask;
@synthesize contentView;
@synthesize userName;
@synthesize snsTagImageView;
@synthesize genderLabel;
@synthesize locationLabel;
@synthesize followUserButton;
@synthesize statusLabel;
@synthesize targetFriend = _targetFriend;
@synthesize superViewController = _superViewController;
@synthesize avatar;
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

- (void)dealloc {
    [backgroundImageView release];
    [mask release];
    [contentView release];
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
    [super dealloc];
}

- (void)initTitle
{

}

#define AVATAR_FRAME [DeviceDetection isIPAD]?CGRectMake(43, 100, 100, 91):CGRectMake(18, 46, 42, 42)
#define LEVEL_LABEL_FRAME [DeviceDetection isIPAD]?CGRectMake(0, 0, 30, 21):CGRectMake(0, 0, 60, 45)
- (void)initAvatar
{

    [self.avatar setUrlString:self.userAvatar userId:self.userId gender:[@"m" isEqualToString:self.userGender] level:self.userLevel drunkPoint:0 wealth:0];
    [self.avatar setAvatarStyle:AvatarViewStyle_Square];
}

- (void)initButton
{
    [self.followUserButton setRoyButtonWithColor:[DiceColorManager dialogRedColor]];
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
    NSString* gender = [@"m" isEqualToString:self.userGender]?NSLS(@"kMale"):NSLS(@"kFemale");
    [self.genderLabel setText:gender];
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

- (void)resetUserInfo
{
    [self initLevelAndName];
    [self initLocation];
    [self initGender];
    [self initSNSInfo];
    [self initAvatar];
    [self initFollowStatus];
    
}

- (void)initView
{
    [self initTitle];
    [self initButton];
    [self resetUserInfo];
    [self.backgroundImageView setImage:[DiceImageManager defaultManager].popupBackgroundImage];
    
}

- (void)initViewWithPBGameUser:(PBGameUser*)aUser
{  
//    NSString* nickName = nil;
//    aUser.snsUsersList
//    if (aUser.nickName && [aUser.nickName length] != 0) {
//        nickName = aUser.nickName;
//    }
//    else if (aFriend.sinaNick && [aFriend.sinaNick length] != 0){
//        nickName = aFriend.sinaNick;
//    }
//    else if (aFriend.qqNick && [aFriend.qqNick length] != 0){
//        nickName = aFriend.qqNick;
//    }
//    else if (aFriend.facebookNick && [aFriend.facebookNick length] != 0){
//        nickName = aFriend.facebookNick;
//    }
    
    [self initViewWithUserId:aUser.userId 
                    nickName:aUser.nickName 
                      avatar:aUser.avatar 
                      gender:(aUser.gender?@"m":@"f")
                    location:aUser.location 
                       level:aUser.userLevel
                     hasSina:NO
                       hasQQ:NO
                 hasFacebook:NO 
     ];
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
    
    CAAnimation *runIn = [AnimationManager scaleAnimationWithFromScale:0.1 toScale:1 duration:RUN_IN_TIME delegate:self removeCompeleted:NO];
    [view.contentView.layer addAnimation:runIn forKey:@"runIn"];
    
    return view;
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
    if (![[[UserManager defaultManager] userId] isEqualToString:userId]) {
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
    [self resetUserInfo];
    [self.superViewController hideActivity];
    [self.superViewController.view addSubview:self];
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
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
