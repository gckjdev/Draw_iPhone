//
//  ViewUserDetail.m
//  Draw
//
//  Created by Kira on 13-3-18.
//
//

#import "ViewUserDetail.h"
#import "GameBasic.pb.h"
#import "UserManager.h"
#import "UserService.h"
#import "PPTableViewController.h"
#import "UserDetailCell.h"
#import "MyFriend.h"
#import "CommonMessageCenter.h"
#import "FriendService.h"
#import "SuperUserManageAction.h"
//#import "PPSNSCommonService.h"
//#import "PPSNSIntegerationService.h"
#import "GameSNSService.h"
#import "SNSUtils.h"
#import "CommonDialog.h"
#import "PPConfigManager.h"
#import "ShareImageManager.h"
#import "SelectHotWordController.h"
#import "FriendService.h"
#import "ChatDetailController.h"
#import "MessageStat.h"
#import "UserDetailRoundButton.h"
#import "MWPhoto.h"
#import "BBSPostListController.h"
#import "BBSService.h"
#import "GameApp.h"
#import "ImagePlayer.h"
#import "SingController.h"

@interface ViewUserDetail () {

}

@property (retain, nonatomic) PBGameUser* pbUser;

@property (retain, nonatomic) SuperUserManageAction* manageAction;

@property (retain, nonatomic) PPTableViewController* superViewController;

@end

@implementation ViewUserDetail

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc
{
    PPRelease(_pbUser);
    self.superViewController = nil;
//    PPRelease(_superViewController);
    PPRelease(_manageAction);
    [super dealloc];
}

- (NSString*)getUserId
{
    return self.pbUser.userId;
}
- (PBGameUser*)queryUser
{
    return self.pbUser;
}
- (BOOL)canEdit
{
    return NO;
}
- (BOOL)needUpdate
{
    return YES;
}

- (BOOL)hasFeedTab
{
    return YES;
}

- (BOOL)isPrivacyVisable
{
    PBGameUser* user = [self getUser];
    if (user.openInfoType == PBOpenInfoTypeOpenAll) {
        return YES;
    } else if (user.openInfoType == PBOpenInfoTypeOpenNo) {
        return NO;
    } else {
        return [MyFriend hasFollow:self.relation]&&[MyFriend isMyFan:self.relation];
    }
    
}

- (id)initWithUserId:(NSString*)userId
              avatar:(NSString*)avatar
            nickName:(NSString*)nickName
{
    self = [self init];
    if (self) {
        PBGameUserBuilder* builder = [PBGameUser builder];
        [builder setUserId:userId];
        [builder setAvatar:avatar];
        [builder setNickName:nickName];
        self.pbUser = [builder build];
    }
    return self;
}

+ (ViewUserDetail*)viewUserDetailWithUserId:(NSString *)userId
                                     avatar:(NSString *)avatar
                                   nickName:(NSString *)nickName
{
    return [[[ViewUserDetail alloc] initWithUserId:userId avatar:avatar nickName:nickName] autorelease];
}

+ (ViewUserDetail*)viewUserDetailWithUser:(PBGameUser *)user
{
    ViewUserDetail *vud = [[ViewUserDetail alloc] init];
    [vud setPbGameUser:user];
    return [vud autorelease];    
}

- (void)setPbGameUser:(PBGameUser *)pbUser
{
    self.pbUser = pbUser;
}
- (BOOL)canFollow
{
    return YES;
}
- (BOOL)canChat
{
    return YES;
}
- (BOOL)canDraw
{
    return YES;
}
- (BOOL)isBlackBtnVisable
{
    return YES;
}

- (BOOL)isSuperManageBtnVisable
{
    return [[UserManager defaultManager] isSuperUser];
}

- (BOOL)isSNSBtnVisable:(int)snsType
{
    return [SNSUtils hasSNSType:snsType inpbSnsUserArray:[[self getUser] snsUsers]];
}

- (PBGameUser*)getUser
{
    return self.pbUser;
}

- (void)loadUser:(PPTableViewController*)viewController
{
    [viewController showActivityWithText:NSLS(@"kLoading")];
    [[UserService defaultService] getUserInfo:[self getUserId] resultBlock:^(int resultCode, PBGameUser *user, int relation) {
        [viewController hideActivity];
        if (resultCode == 0){

            self.pbUser = user;
            [self setRelation:relation];
            
            // reload data
            [viewController.dataTableView reloadData];
        }
    }];
    
}



- (void)blackUser:(PPTableViewController*)viewController
{
    NSString* msg = [MyFriend hasBlack:[self relation]]?NSLS(@"kUnblackUserMsg"):NSLS(@"kBlackUserMsg");

    __block ViewUserDetail* vd = self;
    
    CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"kBlackUserTitle") message:msg style:CommonDialogStyleDoubleButton];
    
    [dialog setClickOkBlock:^(UILabel *label){
        if ([MyFriend hasBlack:[vd relation]]) {
            [[FriendService defaultService] unblackFriend:[self getUserId] successBlock:^{
                [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kUnblackUserSuccess") delayTime:1.5];
                if ([MyFriend hasBlack:[vd relation]]) {
                    [vd setRelation:([vd relation] - RelationTypeBlack)];
                }
                [viewController.dataTableView reloadData];
            }];
            
        } else {
            
            [[FriendService defaultService] blackFriend:[self getUserId] successBlock:^{
                [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kBlackUserSuccess") delayTime:1.5];
                [vd setRelation:RelationTypeBlack];
                [viewController.dataTableView reloadData];
            }];
            
        }
        
    }];
    
    [dialog showInView:viewController.view];
}

- (void)superManageUser:(PPTableViewController*)viewController
{
    if ([[UserManager defaultManager] isSuperUser]) {
        self.manageAction = [[[SuperUserManageAction alloc] initWithPBGameUser:[self getUser]] autorelease];
        [self.manageAction showInController:viewController];
    }
}

- (void)askFollowUserWithSnsType:(int)snsType
                           snsId:(NSString*)snsId
                        nickName:(NSString*)nickName
                  viewController:(UIViewController*)viewController
{
    
    
    CommonDialog* dialog = [CommonDialog createDialogWithTitle:[NSString stringWithFormat:NSLS(@"kAskFollowSNSUserTitle"), [SNSUtils snsNameOfType:snsType]] message:[NSString stringWithFormat:NSLS(@"kAskFollowSNSUserMessage"), [SNSUtils snsNameOfType:snsType]] style:CommonDialogStyleDoubleButton];
    
    [dialog setClickOkBlock:^(UILabel *label){
        
        [[GameSNSService defaultService] followUser:snsType weiboId:snsId weiboName:nickName];

    }];
    
    [dialog showInView:viewController.view];
}


- (void)clickSina:(PPTableViewController*)viewController
{
    PBSNSUser* user = [SNSUtils snsUserWithType:TYPE_SINA inpbSnsUserArray:[[self getUser] snsUsers]];
    [self askFollowUserWithSnsType:TYPE_SINA snsId:user.userId nickName:user.nickName viewController:viewController];

    
}
- (void)clickQQ:(PPTableViewController*)viewController
{
    PBSNSUser* user = [SNSUtils snsUserWithType:TYPE_QQSPACE inpbSnsUserArray:[[self getUser] snsUsers]];
    [self askFollowUserWithSnsType:TYPE_QQSPACE snsId:user.userId nickName:user.nickName viewController:viewController];

}
- (void)clickFacebook:(PPTableViewController*)viewController
{
    PBSNSUser* user = [SNSUtils snsUserWithType:TYPE_FACEBOOK inpbSnsUserArray:[[self getUser] snsUsers]];
    [self askFollowUserWithSnsType:TYPE_FACEBOOK snsId:user.userId nickName:user.nickName viewController:viewController];
}


- (void)clickSNSBtnType:(int)snsType
         viewController:(PPTableViewController*)viewController
{
    switch (snsType) {
        case TYPE_SINA: {
            [self clickSina:viewController];
        }break;
        case TYPE_QQSPACE: {
            [self clickQQ:viewController];
        }break;
        case TYPE_FACEBOOK: {
            [self clickFacebook:viewController];
        } break;
        default:
            break;
    }
}



- (NSString*)blackUserBtnTitle
{
    BOOL hasBlack = [MyFriend hasBlack:[self relation]];
    return hasBlack?NSLS(@"kUnblackFriend"):NSLS(@"kBlackFriend");
}

- (void)initSNSButton:(UIButton*)button withType:(int)snsType
{
    [button setHidden:![self isSNSBtnVisable:snsType]];
}


- (void)initUserActionButton:(UserDetailRoundButton*)button atIndex:(int)index
{
    PBGameUser* user = [self getUser];
    NSString* heStr = [user gender]?NSLS(@"kHim"):NSLS(@"kHer");
    switch (index) {
            
        case UserDetailActionFollowCount: {
            [button.upLabel setText:[NSString stringWithFormat:@"%d", user.followCount]];
            [button.downLabel setText:NSLS(@"kDetailFollower")];
        }break;
            
        case UserDetailActionDrawTo: {
            NSString *title = nil;
            if (isDrawApp()) {
                title = [NSString stringWithFormat:NSLS(@"kDetailDrawTo"), heStr];
            }else if (isSingApp()){
                
                title = [NSString stringWithFormat:NSLS(@"kDetailGiftTo"), heStr];
            }
            [button.downLabel setText:title];
            
            UIImage *image = [GameApp getGiftToSbImage];
            [button setBackgroundImage:image forState:UIControlStateNormal];
            
        } break;
            
        case UserDetailActionFollow: {
            
            BOOL hasFollow = [MyFriend hasFollow:[self relation]];
            [button.downLabel setText:(hasFollow?NSLS(@"kUnfollow"):[NSString stringWithFormat:NSLS(@"kDetailFollow"), heStr])];
            UIImage* followBtnBg = hasFollow?[[ShareImageManager defaultManager] userDetailUnfollowUserBtnBg]:[[ShareImageManager defaultManager] userDetailFollowUserBtnBg];
            [button setBackgroundImage:followBtnBg forState:UIControlStateNormal];
        } break;
            
        case UserDetailActionChatTo: {
            [button.downLabel setText:[NSString stringWithFormat:NSLS(@"kDetailChat"), heStr]];
        } break;
            
        case UserDetailActionFanCount: {
            [button.upLabel setText:[NSString stringWithFormat:@"%d", user.fanCount]];
            [button.downLabel setText:NSLS(@"kFans")];
        } break;
            
        default:
            break;
    }
}

- (void)clickUserActionButtonAtIndex:(int)index
                      viewController:(PPTableViewController *)viewController
{
    switch (index) {
        case UserDetailActionFollowCount:
            //
            break;
        case UserDetailActionDrawTo: {
            [self didClickDrawToButton:viewController];
        } break;
        case UserDetailActionFollow: {
            [self didClickFollowButton:viewController];
        } break;
        case UserDetailActionChatTo: {
            [self didClickChatButton:viewController];
        } break;
        case UserDetailActionFanCount: {
            
        } break;
        default:
            break;
    }
}

- (void)didClickFollowButton:(PPTableViewController*)viewController
{
    PBGameUser* user = [self getUser];
    MyFriend* friend = [MyFriend friendWithFid:user.userId nickName:user.nickName avatar:user.avatar gender:nil level:user.level];
    if ([MyFriend hasFollow:[self relation]]) {
        [[FriendService defaultService] unFollowUser:friend delegate:self];
        [viewController showActivityWithText:NSLS(@"kUnfollowing")];
    } else {
        [[FriendService defaultService] followUser:friend delegate:self];
        [viewController showActivityWithText:NSLS(@"kFollowing")];
    }
    self.superViewController = viewController;
    
}
- (void)didClickChatButton:(PPTableViewController*)viewController
{
    ChatDetailController *controller = [self createChatDetailController];
    [viewController.navigationController pushViewController:controller
                                         animated:YES];    
}

- (void)didClickDrawToButton:(PPTableViewController*)viewController
{
    if (isDrawApp()) {
        [OfflineDrawViewController startDraw:[Word cusWordWithText:@""] fromController:viewController startController:viewController targetUid:[self getUserId]];
    }else if (isSingApp()){
        
        SingController *vc = [[[SingController alloc] initWithTargetUser:self.getUser] autorelease];
        [viewController.navigationController pushViewController:vc animated:YES];
    }
}

- (ChatDetailController *)createChatDetailController
{
    PBGameUser* pbUser = [self getUser];
    MyFriend* targetFriend = [MyFriend friendWithFid:[self getUserId] nickName:pbUser.nickName avatar:pbUser.avatar gender:pbUser.gender?@"m":@"f" level:pbUser.level];
    MessageStat *stat = [MessageStat messageStatWithFriend:targetFriend];
    ChatDetailController *controller = [[[ChatDetailController alloc] initWithMessageStat:stat] autorelease];
    return controller;
}

#pragma mark - friendService delegate
- (void)didFollowFriend:(MyFriend *)myFriend resultCode:(int)resultCode
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
    }
    [self setRelation:(([self relation]) | RelationTypeFollow)];
    [self.superViewController.dataTableView reloadData];
    self.superViewController = nil;
}

- (void)didUnFollowFriend:(MyFriend *)myFriend resultCode:(int)resultCode
{
    [self.superViewController hideActivity];
    if (resultCode != 0) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kUnfollowFailed")
                                                       delayTime:1.5
                                                         isHappy:NO];
    } else {
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kUnfollowSuccessfully")
                                                       delayTime:1.5
                                                         isHappy:YES];
    }
    if ([MyFriend hasFollow:[self relation]]) {
        [self setRelation:(([self relation]) - RelationTypeFollow)];
    }
    [self.superViewController.dataTableView reloadData];
    self.superViewController = nil;
}

- (void)clickAvatar:(PPTableViewController *)viewController didSelectBlock:(void (^)(UIImage *))aBlock
{
    NSURL *url = [NSURL URLWithString:[[self getUser] avatar]];
    [[ImagePlayer defaultPlayer] playWithUrl:url
                         displayActionButton:NO
                            onViewController:viewController];
}

#pragma mark - mwPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return 1;
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    return [MWPhoto photoWithURL:[NSURL URLWithString:[[self getUser] avatar]]];
}

- (void)clickCustomBg:(PPTableViewController <ChangeAvatarDelegate>*)viewController didSelectBlock:(void (^)(UIImage *))aBlock
{
    // do nothing
}

- (BOOL)shouldShow
{
    return ![[UserManager defaultManager] isMe:[self getUserId]];
}

- (void)viewBBSPost:(PPViewController*)controller
{
    PPDebug(@"<viewBBSPost> view user post");
    PBBBSUserBuilder* builder = [PBBBSUser builder];
    [builder setUserId:[[self getUser] userId]];
    [builder setNickName:[[self getUser] nickName]];
    PBBBSUser* user = [builder build];
    [BBSPostListController enterPostListControllerWithBBSUser:user
                                               fromController:controller];
}

@end
