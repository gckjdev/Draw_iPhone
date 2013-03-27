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
#import "FeedService.h"
#import "Feed.h"
#import "UserFeedController.h"
#import "ShowFeedController.h"

#define    ROW_COUNT 1


@interface UserDetailViewController () {
    ChangeAvatar* _changeAvatar;
}

@property (retain, nonatomic) NSMutableArray* opusList;
@property (retain, nonatomic) NSMutableArray* guessedList;
@property (retain, nonatomic) NSMutableArray* favouriateList;
@property (retain, nonatomic) UserDetailCell* detailCell;

@end

@implementation UserDetailViewController

- (id)init
{
    self = [super init];
    if (self) {
        _opusList = [[NSMutableArray alloc] init];
        _guessedList = [[NSMutableArray alloc] init];
        _favouriateList = [[NSMutableArray alloc] init];
    }
    
    return self;
}

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
    PPRelease(_favouriateList);
    PPRelease(_opusList);
    PPRelease(_guessedList);
    PPRelease(_detailCell);
    [super dealloc];
}
- (void)viewDidUnload {
    [self setBackgroundImageView:nil];
    [super viewDidUnload];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.detailCell) {
        self.detailCell = [UserDetailCell createCell:self];
        self.detailCell.detailDelegate = self;
    }
    if (self.detailCell) {
        [self.detailCell setCellWithUserDetail:self.detail];
    }
    
    return self.detailCell;
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
    self = [self init];
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
- (void)didClickMore
{
    UserFeedController* uc = [[UserFeedController alloc] initWithUserId:[self.detail getUserId]
                                                               nickName:[self.detail queryUser].nickName];
    [self.navigationController pushViewController:uc animated:YES];
    [uc release];
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

- (void)askRebindQQ
{
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kMessage") message:NSLS(@"kRebindQQ") style:CommonDialogStyleDoubleButton delegate:nil clickOkBlock:^{
        [SNSUtils bindSNS:TYPE_QQ succ:^{
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kBindQQWeibo") delayTime:1 isHappy:YES];
        } failure:^{
            //
        }];
    } clickCancelBlock:^{
        //
    }];
    [dialog showInView:self.view];
}

- (void)askRebindSina
{
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kMessage") message:NSLS(@"kRebindSina") style:CommonDialogStyleDoubleButton delegate:nil clickOkBlock:^{
        [SNSUtils bindSNS:TYPE_SINA succ:^{
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kBindSinaWeibo") delayTime:1 isHappy:YES];
        } failure:^{
            //
        }];
    } clickCancelBlock:^{
        //
    }];
    [dialog showInView:self.view];
}

- (void)askRebindFacebook
{
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kMessage") message:NSLS(@"kRebindFacebook") style:CommonDialogStyleDoubleButton delegate:nil clickOkBlock:^{
        [SNSUtils bindSNS:TYPE_FACEBOOK succ:^{
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kBindFacebook") delayTime:1 isHappy:YES];
        } failure:^{
            
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
        [self askRebindSina];
    }
    
}
- (void)didclickQQ
{
    if ([[UserManager defaultManager] hasBindQQWeibo] && ![[[PPSNSIntegerationService defaultService] snsServiceByType:TYPE_QQ] isAuthorizeExpired]) {
        PBSNSUser* user = [SNSUtils snsUserWithType:TYPE_QQ inpbSnsUserArray:[[self.detail queryUser] snsUsersList]];
        [self askFollowUserWithSnsType:TYPE_QQ snsId:user.userId nickName:user.nickName];
    } else {
        [self askRebindQQ];
    }
}
- (void)didclickFacebook
{
    if ([[UserManager defaultManager] hasBindFacebook] && ![[[PPSNSIntegerationService defaultService] snsServiceByType:TYPE_FACEBOOK] isAuthorizeExpired]) {
        PBSNSUser* user = [SNSUtils snsUserWithType:TYPE_FACEBOOK inpbSnsUserArray:[[self.detail queryUser] snsUsersList]];
        [self askFollowUserWithSnsType:TYPE_FACEBOOK snsId:user.userId nickName:user.nickName];
    } else {
        [self askRebindFacebook];
    }
}

- (void)didSelectTabAction:(DetailTabAction)tabAction
{
    switch (tabAction) {
        case DetailTabActionClickFavouriate: {
            
        } break;
        case DetailTabActionClickGuessed: {
            [[FeedService defaultService] getUserFeedList:[self.detail getUserId] offset:self.guessedList.count limit:10 delegate:self];
            [self showActivity];
        } break;
        case DetailTabActionClickOpus: {
            [[FeedService defaultService] getUserOpusList:[self.detail getUserId] offset:self.opusList.count limit:10 type:FeedListTypeUserOpus delegate:self];
            [self showActivity];
        } break;
        default:
            break;
    }
}

- (void)didClickDrawFeed:(DrawFeed *)drawFeed
{
    ShowFeedController* sc = [[ShowFeedController alloc] initWithFeed:drawFeed];
    [self.navigationController pushViewController:sc animated:YES];
    [sc release];
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
    [self.detailCell.avatarView setImage:image];
    
}

#pragma mark - feed service delegate
- (void)didGetFeedList:(NSArray *)feedList
            targetUser:(NSString *)userId
                  type:(FeedListType)type
            resultCode:(NSInteger)resultCode
{
    [self hideActivity];
    if (resultCode == 0) {
        switch (type) {
            case FeedListTypeUserFeed: {
                for (Feed* feed in feedList) {
                    if ([feed isKindOfClass:[GuessFeed class]]) {
                        [self.guessedList addObject:((GuessFeed*)feed).drawFeed];
                    }
                }
                [[self detailCell] setDrawFeedList:self.guessedList];
            } break;
            case FeedListTypeUserOpus: {
                for (Feed* feed in feedList) {
                    if ([feed isKindOfClass:[DrawFeed class]]) {
                        [self.opusList addObject:feed];
                    }
                }
                UserDetailCell* cell = [self detailCell];
                [cell setDrawFeedList:self.opusList];
            }
            default:
                break;
        }
    }
}

@end
