//
//  CommonUserInfoView.m
//  Draw
//
//  Created by Orange on 12-6-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DrawUserInfoView.h"
#import "ShareImageManager.h"
#import "AnimationManager.h"
#import "LocaleUtils.h"
#import "MyFriend.h"
#import "StableView.h"
#import "DeviceDetection.h"
#import "FriendManager.h"
#import "CommonMessageCenter.h"
#import "UserFeedController.h"
#import "ChatDetailController.h"
//#import "SelectWordController.h"
#import "LocaleUtils.h"
#import "WordManager.h"
#import "CommonSnsInfoView.h"
#import "MessageStat.h"
#import "GameApp.h"
#import "Bbs.pb.h"
#import "SelectHotWordController.h"
#import "SuperUserManageAction.h"
#import "BBSPermissionManager.h"

#define RUN_OUT_TIME 0.2
#define RUN_IN_TIME 0.4

@interface DrawUserInfoView ()
@property (retain, nonatomic) SuperUserManageAction* superUserManageAction;
@end

@implementation DrawUserInfoView
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
@synthesize levelLabel;
@synthesize targetFriend;
@synthesize superViewController = _superViewController;

- (void)dealloc {
    PPRelease(backgroundImageView);
    PPRelease(mask);
    PPRelease(contentView);
    PPRelease(userName);
    PPRelease(snsTagImageView);
    PPRelease(genderLabel);
    PPRelease(locationLabel);
    PPRelease(playWithUserLabel);
    PPRelease(chatToUserLabel);
    PPRelease(drawToUserButton);
    PPRelease(exploreUserFeedButton);
    PPRelease(chatToUserButton);
    PPRelease(followUserButton);
    PPRelease(statusLabel);
    PPRelease(levelLabel);
    PPRelease(_superUserManageAction);
    PPRelease(_superUserManageButton);
    [_blackFriendButton release];
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

- (void)initTitle
{
    [self.playWithUserLabel setText:NSLS(@"kPlayWithHim")];
    [self.chatToUserLabel setText:NSLS(@"kChatToHim")];
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
    CGRect rect = AVATAR_FRAME;
    AvatarView* view = [[[AvatarView alloc] initWithUrlString:targetFriend.avatar
                                                       frame:rect
                                                      gender:targetFriend.isMale
                                                       level:targetFriend.level] autorelease];
    view.tag = SUBVIEW_AVATAR_TAG;
    [self.contentView addSubview:view];
    view.delegate = self;
}

- (void)initButton
{
    [self.chatToUserButton setTitle:NSLS(@"kChat") forState:UIControlStateNormal];
    [self.chatToUserButton setBackgroundImage:[ShareImageManager defaultManager].orangeImage forState:UIControlStateNormal];
    [self.drawToUserButton setTitle:NSLS(@"kDrawToHim") forState:UIControlStateNormal];
    [self.drawToUserButton setBackgroundImage:[ShareImageManager defaultManager].orangeImage forState:UIControlStateNormal];
    [self.exploreUserFeedButton setTitle:NSLS(@"kExploreHim") forState:UIControlStateNormal];
    [self.exploreUserFeedButton setBackgroundImage:[ShareImageManager defaultManager].orangeImage forState:UIControlStateNormal];
    
    [self.superUserManageButton setBackgroundImage:[ShareImageManager defaultManager].orangeImage forState:UIControlStateNormal];
    
    if ([[BBSPermissionManager defaultManager] canCharge]
          && [[BBSPermissionManager defaultManager] canForbidUserIntoBlackUserList]) {
        [self.superUserManageButton setHidden:NO];
    }
    
}

- (void)initLevelAndName
{
    [self.levelLabel setText:[NSString stringWithFormat:@"LV.%d",targetFriend.level]];
    NSString *nickName = targetFriend.nickName;
    [self.userName setText:targetFriend.nickName];
    if (nickName) {
        
        UIFont* font = [DeviceDetection isIPAD]?[UIFont systemFontOfSize:26]:[UIFont systemFontOfSize:13];
        float maxWidth = [DeviceDetection isIPAD]?224:101;
        CGSize nameSize = [nickName sizeWithFont:font];
        if (nameSize.width < maxWidth) {
            [self.userName setFrame:CGRectMake(self.userName.frame.origin.x, 
                                               self.userName.frame.origin.y, 
                                               nameSize.width, 
                                               self.userName.frame.size.height)];
            [self.levelLabel setFrame:CGRectMake(self.userName.frame.origin.x
                                                 +nameSize.width, 
                                                 self.levelLabel.frame.origin.y, 
                                                 self.levelLabel.frame.size.width, 
                                                 self.levelLabel.frame.size.height)];
        }
    }

}

- (void)initLocation
{
    NSString* location = [LocaleUtils isTraditionalChinese]?[WordManager changeToTraditionalChinese:targetFriend.location]:targetFriend.location;
    [self.locationLabel setText:location];
}

- (void)initGender
{
    NSString* gender = [targetFriend genderDesc];
    [self.genderLabel setText:gender];
}

- (void)initSNSInfo
{

    CommonSnsInfoView* view = [[[CommonSnsInfoView alloc] 
                                initWithFrame:self.snsTagImageView.frame                                 
                                hasSina:targetFriend.isSinaUser
                                hasQQ:targetFriend.isQQUser
                                hasFacebook:targetFriend.isFacebookUser]
                               autorelease];
    view.tag = SUBVIEW_SNSVIEW_TAG;
    [self.contentView addSubview:view];
}

- (void)initFollowStatus
{
    //set followbutton or statusLabel
    self.statusLabel.hidden = self.followUserButton.hidden = YES;
    [self.followUserButton setBackgroundImage:[[ShareImageManager defaultManager] normalButtonImage] forState:UIControlStateNormal];

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
        [self.followUserButton setTitle:NSLS(@"kFollowMe") forState:UIControlStateNormal];
    }
}

- (void)initBlackStatus
{
    BOOL isMe = [[[UserManager defaultManager] userId]
                 isEqualToString:targetFriend.friendUserId];
    
    if (isMe) {
        [self.blackFriendButton setHidden:YES];
    }else if([targetFriend hasBlack]){
        [self.blackFriendButton setHidden:NO];
        [self.blackFriendButton setTitle:NSLS(@"kUnblackFriend") forState:UIControlStateNormal];
    }else{
        [self.blackFriendButton setHidden:NO];
        [self.blackFriendButton setTitle:NSLS(@"kBlackFriend") forState:UIControlStateNormal];
    }
    
}

- (void)updateCommonView
{
    //common info
    [self.backgroundImageView setImage:[ShareImageManager defaultManager].friendDetailBgImage];
    [self initTitle];
    [self initButton];    
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
    [self initBlackStatus];
}
- (void)initView
{
    [self updateCommonView];
    [self updateUserInfoView];
}

+ (DrawUserInfoView*)createUserInfoView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"DrawUserInfoView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create <DrawUserInfoView> but cannot find cell object from Nib");
        return nil;
    }
    DrawUserInfoView* view =  (DrawUserInfoView*)[topLevelObjects objectAtIndex:0];
    
    CAAnimation *runIn = [AnimationManager scaleAnimationWithFromScale:0.1 toScale:1 duration:RUN_IN_TIME delegate:self removeCompeleted:NO];
    [view.contentView.layer addAnimation:runIn forKey:@"runIn"];
    
    return view;
}




#pragma mark - show and dismiss animations
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

#pragma mark - click action.
- (IBAction)clickMask:(id)sender
{
    [self startRunOutAnimation];
}

- (IBAction)clickFollowButton:(id)sender
{
    [[FriendService defaultService] followUser:targetFriend.friendUserId withDelegate:self];
    [self.superViewController showActivityWithText:NSLS(@"kFollowing")];
}

- (void)didFollowUser:(int)resultCode
{
    [self.superViewController hideActivity];
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

- (IBAction)drawToHim:(id)sender
{
//    [SelectWordController startSelectWordFrom:self.superViewController targetUid:targetFriend.friendUserId];
    SelectHotWordController *vc = [[[SelectHotWordController alloc] initWithTargetUid:targetFriend.friendUserId] autorelease];
    vc.superController = self.superViewController;
    [self.superViewController.navigationController pushViewController:vc animated:YES];
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


- (IBAction)seeHisFeed:(id)sender
{
    UserFeedController *userFeed = [[UserFeedController alloc] 
                                    initWithUserId: targetFriend.friendUserId 
                                    nickName:targetFriend.nickName];
    [self.superViewController.navigationController
     pushViewController:userFeed animated:YES];
    [userFeed release];
}

- (void)didClickOnAvatar:(NSString*)userId
{
    PPDebug(@"<clickAvatar> url = %@",self.targetFriend.avatar);
    if ([self.targetFriend.avatar length] != 0) {
        MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
        // Modal
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
        nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [_superViewController presentModalViewController:nc animated:YES];
        [browser release];
        [nc release];
        
    }
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return 1;
}
- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    NSURL *URL = [NSURL URLWithString:self.targetFriend.avatar];
    return [MWPhoto photoWithURL:URL];
}

#pragma mark - main process methods.
- (void)initViewWithFriend:(MyFriend *)afriend 
           superController:(PPViewController *)superController
{
    self.targetFriend = afriend;
    self.superViewController = superController;
    self.drawToUserButton.enabled = NO;
    self.chatToUserButton.enabled = NO;
    self.superUserManageButton.enabled = NO;
    self.exploreUserFeedButton.enabled = NO;
}


- (void)show
{
    self.frame = self.superViewController.view.frame;
    [self initView];
    self.followUserButton.hidden = YES;
    [self.superViewController.view addSubview:self];
}

- (void)updateInfoFromService
{
    if ([targetFriend.friendUserId length] != 0) {
        [[UserService defaultService] getUserSimpleInfoByUserId:targetFriend.friendUserId
                                                       delegate:self];
    }
}

+ (void)showFriend:(MyFriend*)afriend 
        infoInView:(PPViewController*)superController
        needUpdate:(BOOL)needUpdate //if need update the info from service.
{
    if ([[UserManager defaultManager] isMe: friend.friendUserId]) {
        [superController popupMessage:NSLS(@"kCannotShowYourself") title:nil];
        return;
    }
    
    DrawUserInfoView *view = [DrawUserInfoView createUserInfoView];
    [view initViewWithFriend:afriend superController:superController];
    [view show];
    if (needUpdate) {
        [view updateInfoFromService];
    } else {
        [view activeAllButtons];
    }
}

+ (void)showPBBBSUser:(PBBBSUser *)user
           infoInView:(PPViewController *)superController
           needUpdate:(BOOL)needUpdate //if need update the info from service.
{
    MyFriend *friend = [MyFriend friendWithFid:user.userId
                                      nickName:user.nickName
                                        avatar:user.avatar
                                        gender:user.gender?@"m":@"f"
                                         level:1];
    [self showFriend:friend infoInView:superController needUpdate:needUpdate];
}

- (void)activeAllButtons
{
    self.drawToUserButton.enabled = YES;
    self.chatToUserButton.enabled = YES;
    self.superUserManageButton.enabled = YES;
    self.exploreUserFeedButton.enabled = YES;
}

#pragma mark - user service delegate

- (void)didGetUserInfo:(MyFriend *)user resultCode:(NSInteger)resultCode
{
    if (resultCode == 0 && user != nil) {
        self.targetFriend = user;
        [self updateUserInfoView];
        [self activeAllButtons];
    }
}

- (IBAction)clickSuperUserManageButton:(id)sender
{
    self.superUserManageAction = [[[SuperUserManageAction alloc] initWithTargetUserId:self.targetFriend.friendUserId nickName:self.targetFriend.nickName balance:self.targetFriend.coins] autorelease];
    [self.superUserManageAction showInController:_superViewController];
}

- (IBAction)clickBlackFriend:(id)sender
{
    if ([self.targetFriend hasBlack]) {
        [[FriendService defaultService] unblackFriend:self.targetFriend.friendUserId successBlock:^{
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kUnblackUserSuccess") delayTime:1.5];
            [self clickMask:nil];
        }];
    } else {
        [[FriendService defaultService] blackFriend:self.targetFriend.friendUserId successBlock:^{
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kBlackUserSuccess") delayTime:1.5];
            [self clickMask:nil];
        }];
    }
    
}

@end
