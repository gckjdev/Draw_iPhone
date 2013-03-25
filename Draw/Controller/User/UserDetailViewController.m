//
//  UserDetailViewController.m
//  Draw
//
//  Created by Kira on 13-3-18.
//
//

#import "UserDetailViewController.h"
#import "GameBasic.pb.h"
#import "UserDetailCell.h"
#import "UserService.h"
#import "UserSettingController.h"
#import "FriendController.h"
#import "FriendService.h"
#import "ChatDetailController.h"
#import "MyFriend.h"
#import "MessageStat.h"
#import "SelectHotWordController.h"
#import "CommonMessageCenter.h"
#import "ChangeAvatar.h"
#import "UserService.h"
#import "SuperUserManageAction.h"
#import "PPSNSCommonService.h"
#import "CommonRoundAvatarView.h"
#import "SNSUtils.h"
#import "PPSNSIntegerationService.h"
#import "CommonMessageCenter.h"
#import "CommonDialog.h"


#define    ROW_COUNT 1


@interface UserDetailViewController () {
    ChangeAvatar* _changeAvatar;
}

@end

@implementation UserDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.detail && [self.detail needUpdate]) {
        [[UserService defaultService] getUserInfo:[self.detail getUserId] resultBlock:^(int resultCode, PBGameUser *user, int relation) {
            if (resultCode == 0 &&[self.detail respondsToSelector:@selector(setPbGameUser:)]
                                && user != nil) {
                [self.detail setPbGameUser:user];
                [self.detail setRelation:relation];
                [self.dataTableView reloadData];
                
                // TODO update relation
            }
        }];
    }
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_backgroundImageView release];
    [_detail release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setBackgroundImageView:nil];
    [super viewDidUnload];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserDetailCell* cell = [UserDetailCell createCell:self];
    
    if (cell) {
        [cell setCellWithUserDetail:self.detail];
        cell.detailDelegate = self;
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ROW_COUNT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [UserDetailCell getCellHeight];
}

- (id)initWithUserDetail:(NSObject<UserDetailProtocol>*)detail
{
    self = [super init];
    if (self) {
        self.detail = detail;
    }
    return self;
}


#pragma mark - user detail cell delegate
- (void)didClickEdit
{
    [self.navigationController pushViewController:[[[UserSettingController alloc] init] autorelease] animated:YES];
}

- (void)didClickFanCountButton
{
    if (![self.detail canFollow]) {
        [self.navigationController pushViewController:[[[FriendController alloc] init] autorelease] animated:YES];
    }
}
- (void)didClickFollowCountButton
{
    if (![self.detail canFollow]) {
        [self.navigationController pushViewController:[[[FriendController alloc] init] autorelease] animated:YES];
    }
}
- (void)didClickFollowButton
{
    if ([self.detail canFollow]) {
        [[FriendService defaultService] followUser:[self.detail getUserId] withDelegate:self];
        [self showActivityWithText:NSLS(@"kFollowing")];
    }
   
}
- (void)didClickChatButton
{
    if ([self.detail canChat]) {
        PBGameUser* pbUser = [self.detail queryUser];
        MyFriend* targetFriend = [MyFriend friendWithFid:[self.detail getUserId] nickName:pbUser.nickName avatar:pbUser.avatar gender:pbUser.gender level:pbUser.level];
        MessageStat *stat = [MessageStat messageStatWithFriend:targetFriend];
        ChatDetailController *controller = [[ChatDetailController alloc] initWithMessageStat:stat];
        [self.navigationController pushViewController:controller
                                             animated:YES];
        [controller release];
    }
    
}
- (void)didClickDrawToButton
{
    if ([self.detail canDraw]) {
        SelectHotWordController *vc = [[[SelectHotWordController alloc] initWithTargetUid:[self.detail getUserId]] autorelease];
        vc.superController = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
   
}

- (void)didClickAvatar
{
    if ([self.detail canEdit]) {
        if (_changeAvatar == nil) {
            _changeAvatar = [[ChangeAvatar alloc] init];
            _changeAvatar.autoRoundRect = NO;
        }
        [_changeAvatar showSelectionView:self];
    }
    
}
- (void)didclickBlack
{
    if ([self.detail canBlack]) {
        [[FriendService defaultService] unblackFriend:[self.detail getUserId] successBlock:^{
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kUnblackUserSuccess") delayTime:1.5];
        }];
    }
   
}
- (void)didclickManage
{
    if ([[UserManager defaultManager] isSuperUser]) {
        SuperUserManageAction* action = [[[SuperUserManageAction alloc] initWithTargetUserId:[self.detail getUserId] nickName:[self.detail queryUser].nickName balance:[self.detail queryUser].coinBalance] autorelease];
        [action showInController:self];
    }
    
}

- (void)askFollowUserWithSnsType:(int)snsType
                           snsId:(NSString*)snsId
                        nickName:(NSString*)nickName
{
    __block PPSNSCommonService* snsService = [[PPSNSIntegerationService defaultService] snsServiceByType:snsType];
    if ([snsService supportFollow] == NO)
        return;
    
//    [snsService askFollowWithTitle:[NSString stringWithFormat:NSLS(@"kAskFollowSNSUserTitle"),[SNSUtils snsNameOfType:snsType]]
//                    displayMessage:[NSString stringWithFormat:NSLS(@"kAskFollowSNSUserMessage"),[SNSUtils snsNameOfType:snsType]]
//                           weiboId:snsId
//                      successBlock:^(NSDictionary *userInfo) {
//                          
//                      } failureBlock:^(NSError *error) {
//                          
//                      }];
    
    CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"kAskFollowSNSUserTitle") message:NSLS(@"kAskFollowSNSUserMessage") style:CommonDialogStyleDoubleButton delegate:nil clickOkBlock:^{
        [snsService followUser:nickName userId:snsId successBlock:^(NSDictionary *userInfo) {
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kFollowSucc")
                                                           delayTime:1.5
                                                             isHappy:YES];
        } failureBlock:^(NSError *error) {
            //
        }];
    } clickCancelBlock:^{
        //
    }];
    [dialog showInView:self.view];
}

- (void)didclickSina
{
    if ([[UserManager defaultManager] hasBindSinaWeibo] && ![[[PPSNSIntegerationService defaultService] snsServiceByType:TYPE_SINA] isAuthorizeExpired]) {
        PBSNSUser* user = [SNSUtils snsUserWithType:TYPE_SINA inpbSnsUserArray:[[self.detail queryUser] snsUsersList]];
        [self askFollowUserWithSnsType:TYPE_SINA snsId:user.userId nickName:user.nickName];
    } else {
        [SNSUtils bindSNS:TYPE_SINA succ:^{
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kBindSinaWeibo") delayTime:1 isHappy:YES];
        } failure:^{
            //
        }];
    }
    
}
- (void)didclickQQ
{
    if ([[UserManager defaultManager] hasBindQQWeibo] && ![[[PPSNSIntegerationService defaultService] snsServiceByType:TYPE_QQ] isAuthorizeExpired]) {
        PBSNSUser* user = [SNSUtils snsUserWithType:TYPE_QQ inpbSnsUserArray:[[self.detail queryUser] snsUsersList]];
        [self askFollowUserWithSnsType:TYPE_QQ snsId:user.userId nickName:user.nickName];
    } else {
        [SNSUtils bindSNS:TYPE_QQ succ:^{
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kBindQQWeibo") delayTime:1 isHappy:YES];
        } failure:^{
            //
        }];
    }
}
- (void)didclickFacebook
{
    if ([[UserManager defaultManager] hasBindFacebook] && ![[[PPSNSIntegerationService defaultService] snsServiceByType:TYPE_FACEBOOK] isAuthorizeExpired]) {
        PBSNSUser* user = [SNSUtils snsUserWithType:TYPE_FACEBOOK inpbSnsUserArray:[[self.detail queryUser] snsUsersList]];
        [self askFollowUserWithSnsType:TYPE_FACEBOOK snsId:user.userId nickName:user.nickName];
    } else {
        [SNSUtils bindSNS:TYPE_FACEBOOK succ:^{
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kBindFacebook") delayTime:1 isHappy:YES];
        } failure:^{
//            UISegmentedControl
            //
        }];
    }
}

#pragma mark - friendService delegate
- (void)didFollowUser:(int)resultCode
{
    [self hideActivity];
    if (resultCode != 0) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kFollowFailed")
                                                       delayTime:1.5
                                                         isHappy:NO];
    } else {
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kFollowSuccessfully")
                                                       delayTime:1.5
                                                         isHappy:YES];
    }
}

#pragma mark - changeAvatarDelegate

- (void)didImageSelected:(UIImage *)image
{
    UserDetailCell* cell = (UserDetailCell*)[self.dataTableView cellForRowAtIndexPath:0];
    [cell.avatarView setImage:image];
    
}

@end
