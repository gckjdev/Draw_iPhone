//
//  SelfUserDetail.m
//  Draw
//
//  Created by Kira on 13-3-18.
//
//

#import "SelfUserDetail.h"
#import "UserManager.h"
#import "PPTableViewController.h"
#import "FriendService.h"
#import "UserDetailCell.h"
#import "PPSNSCommonService.h"
#import "PPSNSIntegerationService.h"
#import "SNSUtils.h"
#import "CommonDialog.h"
#import "CommonMessageCenter.h"
#import "ConfigManager.h"

@interface SelfUserDetail() {
    LoadFeedFinishBlock _finishBlock;
}

@property (nonatomic, assign) PPTableViewController* superViewController;

@property (retain, nonatomic) NSMutableArray* opusList;
@property (retain, nonatomic) NSMutableArray* guessedList;
@property (retain, nonatomic) NSMutableArray* favouriateList;

@end

@implementation SelfUserDetail


- (id)init
{
    self = [super init];
    if (self) {
        self.relation = RelationTypeSelf;
        _opusList = [[NSMutableArray alloc] init];
        _guessedList = [[NSMutableArray alloc] init];
        _favouriateList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    PPRelease(_superViewController);
    PPRelease(_opusList);
    PPRelease(_guessedList);
    PPRelease(_favouriateList);
    [super dealloc];
}

+ (id<UserDetailProtocol>)createDetail
{
    return [[[SelfUserDetail alloc] init] autorelease];
}

- (NSString*)getUserId
{
    return [[UserManager defaultManager] userId];
}
//- (PBGameUser*)queryUser
//{
//    return [UserManager defaultManager].pbUser;
//}
- (BOOL)canEdit
{
    return YES;
}

- (BOOL)needUpdate
{
    return NO;
}

- (BOOL)canFollow
{
    return NO;
}
- (BOOL)canChat
{
    return NO;
}
- (BOOL)canDraw
{
    return NO;
}

- (BOOL)isBlackBtnVisable
{
    return NO;
}

- (BOOL)isSuperManageBtnVisable
{
    return NO;
}

- (BOOL)isSNSBtnVisable:(int)snsType
{
    return [SNSUtils hasSNSType:snsType inpbSnsUserArray:[[self getUser] snsUsersList]];
}

- (RelationType)relation
{
    return RelationTypeSelf;
}

- (void)setRelation:(RelationType)relation
{
    
}

- (PBGameUser*)getUser
{
    return [UserManager defaultManager].pbUser;
}

- (void)loadUser:(PPTableViewController*)viewController
{
    
    PBGameUser* user = [self getUser];
    if (user.fanCount == 0 || user.followCount == 0){
        self.superViewController = viewController;
        [viewController showActivityWithText:NSLS(@"kLoading")];
        [[FriendService defaultService] getRelationCount:self];
        return;
    }
    else{
        [viewController.dataTableView reloadData];
    }
    
}

- (void)didGetFanCount:(NSInteger)fanCount
           followCount:(NSInteger)followCount
            blackCount:(NSInteger)blackCount
            resultCode:(NSInteger)resultCode
{
    [[UserManager defaultManager] setFanCount:fanCount];
    [[UserManager defaultManager] setFollowCount:followCount];
    
    [_superViewController hideActivity];
    [_superViewController.dataTableView reloadData];
    self.superViewController = nil;
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

- (void)blackUser:(PPTableViewController *)viewController
{
    
}
- (void)superManageUser:(PPTableViewController *)viewController
{
    
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
    [self askRebindSina:viewController];
}
- (void)clickQQ:(UIViewController*)viewController
{
    [self askRebindQQ:viewController];
}
- (void)clickFacebook:(UIViewController*)viewController
{
    [self askRebindFacebook:viewController];
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
    return nil;
}
@end
