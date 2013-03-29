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
#import "GameSNSService.h"

@interface SelfUserDetail() {
    
}

@property (nonatomic, assign) PPTableViewController* superViewController;


@end

@implementation SelfUserDetail


- (id)init
{
    self = [super init];
    if (self) {
        self.relation = RelationTypeSelf;
    }
    return self;
}

- (void)dealloc
{
    PPRelease(_superViewController);
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

- (BOOL)hasFeedTab
{
    return YES;
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



- (void)blackUser:(PPTableViewController *)viewController
{
    
}
- (void)superManageUser:(PPTableViewController *)viewController
{
    
}

- (void)clickSina:(UIViewController*)viewController
{
    [GameSNSService askRebindSina:viewController];
}
- (void)clickQQ:(UIViewController*)viewController
{
    [GameSNSService askRebindQQ:viewController];
}
- (void)clickFacebook:(UIViewController*)viewController
{
    [GameSNSService askRebindFacebook:viewController];
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
    return nil;
}
@end
