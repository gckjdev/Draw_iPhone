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
    return [SNSUtils hasSNSType:snsType inpbSnsUserArray:[[self getUser] snsUsersList]] && ![[[PPSNSIntegerationService defaultService] snsServiceByType:snsType] isAuthorizeExpired];
}

- (BOOL)hasFeedTab
{
    return YES;
}

- (BOOL)isPrivacyVisable
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
    if ([[UserManager defaultManager] hasBindSinaWeibo] && ![[[PPSNSIntegerationService defaultService] snsServiceByType:TYPE_SINA] isAuthorizeExpired]) {
        [GameSNSService askRebindSina:viewController];
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
        [GameSNSService askRebindQQ:viewController];
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
        [GameSNSService askRebindFacebook:viewController];
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
    return nil;
}

- (void)initSNSButton:(UIButton *)button withType:(int)snsType
{
    [button setHighlighted:![self isSNSBtnVisable:snsType]];
}
@end
