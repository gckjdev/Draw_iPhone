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
#import "SNSUtils.h"
#import "CommonDialog.h"
#import "ConfigManager.h"

@interface ViewUserDetail () {
    LoadFeedFinishBlock _finishBlock;
}

@property (retain, nonatomic) PBGameUser* pbUser;

@property (retain, nonatomic) NSMutableArray* opusList;
@property (retain, nonatomic) NSMutableArray* guessedList;
@property (retain, nonatomic) NSMutableArray* favouriateList;
@property (retain, nonatomic) SuperUserManageAction* manageAction;

@end

@implementation ViewUserDetail

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

- (void)dealloc
{
    [_pbUser release];
    PPRelease(_opusList);
    PPRelease(_guessedList);
    PPRelease(_favouriateList);
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

- (void)loadFeedByTabAction:(int)tabAction finishBLock:(LoadFeedFinishBlock)block
{
    switch (tabAction) {
        case DetailTabActionClickFavouriate: {
            
        } break;
        case DetailTabActionClickGuessed: {
            [[FeedService defaultService] getUserFeedList:[self getUserId] offset:self.guessedList.count limit:[ConfigManager getDefaultDetailOpusCount] delegate:self];
        } break;
        case DetailTabActionClickOpus: {
            [[FeedService defaultService] getUserOpusList:[self getUserId] offset:self.opusList.count limit:[ConfigManager getDefaultDetailOpusCount] type:FeedListTypeUserOpus delegate:self];
        } break;
        default:
            break;
    }
    RELEASE_BLOCK(_finishBlock);
    COPY_BLOCK(_finishBlock, block);
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

- (void)askRebindQQ:(UIViewController*)viewController
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
    [dialog showInView:viewController.view];
}

- (void)askRebindSina:(UIViewController*)viewController
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
    [dialog showInView:viewController.view];
}

- (void)askRebindFacebook:(UIViewController*)viewController
{
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kMessage") message:NSLS(@"kRebindFacebook") style:CommonDialogStyleDoubleButton delegate:nil clickOkBlock:^{
        [SNSUtils bindSNS:TYPE_FACEBOOK succ:^{
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kBindFacebook") delayTime:1 isHappy:YES];
        } failure:^{
            
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
        [self askRebindSina:viewController];
    }
    
}
- (void)clickQQ:(UIViewController*)viewController
{
    if ([[UserManager defaultManager] hasBindQQWeibo] && ![[[PPSNSIntegerationService defaultService] snsServiceByType:TYPE_QQ] isAuthorizeExpired]) {
        PBSNSUser* user = [SNSUtils snsUserWithType:TYPE_QQ inpbSnsUserArray:[[self getUser] snsUsersList]];
        [self askFollowUserWithSnsType:TYPE_QQ snsId:user.userId nickName:user.nickName viewController:viewController];
    } else {
        [self askRebindQQ:viewController];
    }
}
- (void)clickFacebook:(UIViewController*)viewController
{
    if ([[UserManager defaultManager] hasBindFacebook] && ![[[PPSNSIntegerationService defaultService] snsServiceByType:TYPE_FACEBOOK] isAuthorizeExpired]) {
        PBSNSUser* user = [SNSUtils snsUserWithType:TYPE_FACEBOOK inpbSnsUserArray:[[self getUser] snsUsersList]];
        [self askFollowUserWithSnsType:TYPE_FACEBOOK snsId:user.userId nickName:user.nickName viewController:viewController];
    } else {
        [self askRebindFacebook:viewController];
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

#pragma mark - feed service delegate
- (void)didGetFeedList:(NSArray *)feedList
            targetUser:(NSString *)userId
                  type:(FeedListType)type
            resultCode:(NSInteger)resultCode
{
    //    [self hideActivity];
    if (resultCode == 0) {
        switch (type) {
            case FeedListTypeUserFeed: {
                for (Feed* feed in feedList) {
                    if ([feed isKindOfClass:[GuessFeed class]]) {
                        [self.guessedList addObject:((GuessFeed*)feed).drawFeed];
                        PPDebug(@"<UserDetailViewController> get opus - <%@>", ((GuessFeed*)feed).drawFeed.wordText);
                    }
                }
                EXECUTE_BLOCK(_finishBlock, resultCode, self.guessedList);                
                //                [[self detailCell] setDrawFeedList:self.guessedList];
            } break;
            case FeedListTypeUserOpus: {
                for (Feed* feed in feedList) {
                    if ([feed isKindOfClass:[DrawFeed class]]) {
                        [self.opusList addObject:feed];
                        PPDebug(@"<UserDetailViewController> get opus - <%@>", ((DrawFeed*)feed).wordText);
                    }
                }
                //                UserDetailCell* cell = [self detailCell];
                //                [cell setDrawFeedList:self.opusList];
                
                EXECUTE_BLOCK(_finishBlock, resultCode, self.opusList);
            }
            default:
                break;
        }
    } else {
        EXECUTE_BLOCK(_finishBlock, resultCode, nil);
    }
}

- (NSString*)blackUserBtnTitle
{
    BOOL hasBlack = [MyFriend hasBlack:[self relation]];
    return hasBlack?NSLS(@"kUnblackFriend"):NSLS(@"kBlackFriend");
}

@end
