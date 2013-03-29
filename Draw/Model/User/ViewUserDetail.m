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

@interface ViewUserDetail () {
   
}

@property (retain, nonatomic) PBGameUser* pbUser;

@property (retain, nonatomic) SuperUserManageAction* manageAction;

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
        [GameSNSService askRebindSina:viewController];
    }
    
}
- (void)clickQQ:(UIViewController*)viewController
{
    if ([[UserManager defaultManager] hasBindQQWeibo] && ![[[PPSNSIntegerationService defaultService] snsServiceByType:TYPE_QQ] isAuthorizeExpired]) {
        PBSNSUser* user = [SNSUtils snsUserWithType:TYPE_QQ inpbSnsUserArray:[[self getUser] snsUsersList]];
        [self askFollowUserWithSnsType:TYPE_QQ snsId:user.userId nickName:user.nickName viewController:viewController];
    } else {
        [GameSNSService askRebindQQ:viewController];
    }
}
- (void)clickFacebook:(UIViewController*)viewController
{
    if ([[UserManager defaultManager] hasBindFacebook] && ![[[PPSNSIntegerationService defaultService] snsServiceByType:TYPE_FACEBOOK] isAuthorizeExpired]) {
        PBSNSUser* user = [SNSUtils snsUserWithType:TYPE_FACEBOOK inpbSnsUserArray:[[self getUser] snsUsersList]];
        [self askFollowUserWithSnsType:TYPE_FACEBOOK snsId:user.userId nickName:user.nickName viewController:viewController];
    } else {
        [GameSNSService askRebindFacebook:viewController];
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

@end
