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
#import "PPSNSCommonService.h"
#import "PPSNSIntegerationService.h"
#import "GameSNSService.h"
#import "SNSUtils.h"
#import "CommonDialog.h"
#import "ConfigManager.h"
#import "ShareImageManager.h"
#import "SelectHotWordController.h"
#import "FriendService.h"
#import "ChatDetailController.h"
#import "MessageStat.h"
#import "UserDetailRoundButton.h"

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
    [_pbUser release];
    PPRelease(_superViewController);
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
    return NO;
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
        PBGameUser_Builder* builder = [PBGameUser builder];
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
    return [SNSUtils hasSNSType:snsType inpbSnsUserArray:[[self getUser] snsUsersList]];
}

- (PBGameUser*)getUser
{
    return self.pbUser;
}

- (void)loadUser:(PPTableViewController*)viewController
{
    [viewController showActivityWithText:NSLS(@"kLoading")];
    [[UserService defaultService] getUserInfo:[self getUserId] resultBlock:^(int resultCode, PBGameUser *user, int relation) {
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
    if ([MyFriend hasBlack:[self relation]]) {
        [[FriendService defaultService] unblackFriend:[self getUserId] successBlock:^{
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kUnblackUserSuccess") delayTime:1.5];
            if ([MyFriend hasBlack:[self relation]]) {
                [self setRelation:([self relation] - RelationTypeBlack)];
            }
            [viewController.dataTableView reloadData];
        }];
        
    } else {
        
        [[FriendService defaultService] blackFriend:[self getUserId] successBlock:^{
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kBlackUserSuccess") delayTime:1.5];
            [self setRelation:RelationTypeBlack];
            [viewController.dataTableView reloadData];
        }];
    }
}
- (void)superManageUser:(PPTableViewController*)viewController
{
    if ([[UserManager defaultManager] isSuperUser]) {
        self.manageAction = [[[SuperUserManageAction alloc] initWithTargetUserId:[self getUserId] nickName:[self getUser].nickName balance:[self getUser].coinBalance] autorelease];
        [self.manageAction showInController:viewController];
    }
}

- (void)askFollowUserWithSnsType:(int)snsType
                           snsId:(NSString*)snsId
                        nickName:(NSString*)nickName
                  viewController:(UIViewController*)viewController
{
    __block PPSNSCommonService* snsService = [[PPSNSIntegerationService defaultService] snsServiceByType:snsType];
    if ([snsService supportFollow] == NO)
        return;
    
    CommonDialog* dialog = [CommonDialog createDialogWithTitle:[NSString stringWithFormat:NSLS(@"kAskFollowSNSUserTitle"), [SNSUtils snsNameOfType:snsType]] message:[NSString stringWithFormat:NSLS(@"kAskFollowSNSUserMessage"), [SNSUtils snsNameOfType:snsType]] style:CommonDialogStyleDoubleButton delegate:nil clickOkBlock:^{
        [snsService followUser:nickName userId:snsId successBlock:^(NSDictionary *userInfo) {
            [[CommonMessageCenter defaultCenter] postMessageWithText:[NSString stringWithFormat:NSLS(@"kFollowSNSSucc"), [SNSUtils snsNameOfType:snsType]]
                                                           delayTime:1.5
                                                             isHappy:YES];
        } failureBlock:^(NSError *error) {
            //
        }];
    } clickCancelBlock:^{
        //
    }];
    [dialog showInView:viewController.view];
}


- (void)clickSina:(UIViewController*)viewController
{
    if ([[UserManager defaultManager] hasBindSinaWeibo] && ![[[PPSNSIntegerationService defaultService] snsServiceByType:TYPE_SINA] isAuthorizeExpired]) {
        PBSNSUser* user = [SNSUtils snsUserWithType:TYPE_SINA inpbSnsUserArray:[[self getUser] snsUsersList]];
        [self askFollowUserWithSnsType:TYPE_SINA snsId:user.userId nickName:user.nickName viewController:viewController];
    } else {
        [SNSUtils bindSNS:TYPE_SINA succ:^{
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kBindSinaWeibo") delayTime:1 isHappy:YES];
        } failure:^{
            //
        }];
    }
    
}
- (void)clickQQ:(UIViewController*)viewController
{
    if ([[UserManager defaultManager] hasBindQQWeibo] && ![[[PPSNSIntegerationService defaultService] snsServiceByType:TYPE_QQ] isAuthorizeExpired]) {
        PBSNSUser* user = [SNSUtils snsUserWithType:TYPE_QQ inpbSnsUserArray:[[self getUser] snsUsersList]];
        [self askFollowUserWithSnsType:TYPE_QQ snsId:user.userId nickName:user.nickName viewController:viewController];
    } else {
        [SNSUtils bindSNS:TYPE_QQ succ:^{
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kBindQQWeibo") delayTime:1 isHappy:YES];
        } failure:^{
            //
        }];
    }
}
- (void)clickFacebook:(UIViewController*)viewController
{
    if ([[UserManager defaultManager] hasBindFacebook] && ![[[PPSNSIntegerationService defaultService] snsServiceByType:TYPE_FACEBOOK] isAuthorizeExpired]) {
        PBSNSUser* user = [SNSUtils snsUserWithType:TYPE_FACEBOOK inpbSnsUserArray:[[self getUser] snsUsersList]];
        [self askFollowUserWithSnsType:TYPE_FACEBOOK snsId:user.userId nickName:user.nickName viewController:viewController];
    } else {
        [SNSUtils bindSNS:TYPE_FACEBOOK succ:^{
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kBindFacebook") delayTime:1 isHappy:YES];
        } failure:^{
            
        }];
    }
}


- (void)clickSNSBtnType:(int)snsType
         viewController:(PPTableViewController*)viewController
{
    switch (snsType) {
        case TYPE_SINA: {
            [self clickSina:viewController];
        }break;
        case TYPE_QQ: {
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

//- (UILabel*)labelWithText:(NSString*)text
//{
//    UILabel* label = [[[UILabel alloc] init] autorelease];
//    [label setText:text];
//    [label setFont:[UIFont systemFontOfSize:(ISIPAD?24:12)]];
//    [label setTextAlignment:NSTextAlignmentCenter];
//    [label setUserInteractionEnabled:NO];
//    [label setBackgroundColor:[UIColor clearColor]];
//    [label setTextColor:[UIColor whiteColor]];
//    return label;
//    
//}
//
//- (void)addButton:(UIButton*)button
//           number:(NSInteger)number
//            title:(NSString*)title
//{
//    [button setTitle:nil forState:UIControlStateNormal];
//    
//    UILabel* numberLabel = (UILabel*)[button viewWithTag:BTN_NUMBER_TAG];
//    if (numberLabel) {
//        [numberLabel setText:[NSString stringWithFormat:@"%d", number]];
//    } else {
//        UILabel* numberLabel = [self labelWithText:[NSString stringWithFormat:@"%d", number]];
//        [numberLabel setFrame:CGRectMake(button.frame.size.width*0.15, button.frame.size.height*0.15, button.frame.size.width*0.7, button.frame.size.height*0.35)];
//        numberLabel.tag = BTN_NUMBER_TAG;
//        [button addSubview:numberLabel];
//    }
//    
//    UILabel* titleLabel = (UILabel*)[button viewWithTag:BTN_TITLE_TAG];
//    if (!titleLabel) {
//        UILabel* titleLabel = [self labelWithText:title];
//        [titleLabel setFrame:CGRectMake(button.frame.size.width*0.15, button.frame.size.height/2, button.frame.size.width*0.7, button.frame.size.height*0.35)];
//        titleLabel.tag = BTN_TITLE_TAG;
//        [button addSubview:titleLabel];
//    }
//    
//    
//}


- (void)initUserActionButton:(UserDetailRoundButton*)button atIndex:(int)index
{
    PBGameUser* user = [self getUser];
    switch (index) {
        case UserDetailActionFollowCount:
            [self addButton:button number:user.followCount title:NSLS(@"kFollow")];
            break;
        case UserDetailActionDrawTo: {
            
        } break;
        case UserDetailActionFollow: {
            BOOL hasFollow = [MyFriend hasFollow:[self relation]];
            [button setTitle:(hasFollow?NSLS(@"kUnfollow"):NSLS(@"kFollow")) forState:UIControlStateNormal];
            UIImage* followBtnBg = hasFollow?[[ShareImageManager defaultManager] userDetailUnfollowUserBtnBg]:[[ShareImageManager defaultManager] userDetailFollowUserBtnBg];
            [button setBackgroundImage:followBtnBg forState:UIControlStateNormal];
        } break;
        case UserDetailActionChatTo: {
            
        } break;
        case UserDetailActionFanCount: {
            [self addButton:button number:user.fanCount title:NSLS(@"kFans")];
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
    PBGameUser* pbUser = [self getUser];
    MyFriend* targetFriend = [MyFriend friendWithFid:[self getUserId] nickName:pbUser.nickName avatar:pbUser.avatar gender:pbUser.gender?@"m":@"f" level:pbUser.level];
    MessageStat *stat = [MessageStat messageStatWithFriend:targetFriend];
    ChatDetailController *controller = [[ChatDetailController alloc] initWithMessageStat:stat];
    [viewController.navigationController pushViewController:controller
                                         animated:YES];
    [controller release];
    
}
- (void)didClickDrawToButton:(PPTableViewController*)viewController
{
    SelectHotWordController *vc = [[[SelectHotWordController alloc] initWithTargetUid:[self getUserId]] autorelease];
    vc.superController = viewController;
    [viewController.navigationController pushViewController:vc animated:YES];
    
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
}

@end
