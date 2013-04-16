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
#import "FriendController.h"
#import "ShareImageManager.h"
#import "AccountManager.h"
#import "UserDetailRoundButton.h"
#import "ChangeAvatar.h"
#import "ChargeController.h"
#import "UserService.h"

@interface SelfUserDetail() {
    ChangeAvatar* _changeAvatar;
}

@property (nonatomic, retain) PPTableViewController* superViewController;

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

- (void)clickSina:(PPTableViewController*)viewController
{
    if ([[UserManager defaultManager] hasBindSinaWeibo] && ![[[PPSNSIntegerationService defaultService] snsServiceByType:TYPE_SINA] isAuthorizeExpired]) {
        [GameSNSService askRebindSina:viewController];
    } else {
        [SNSUtils bindSNS:TYPE_SINA succ:^(NSDictionary *userInfo){
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kBindSinaWeibo") delayTime:1 isHappy:YES];
            [[UserService defaultService] updateUserWithSNSUserInfo:[self getUserId] userInfo:userInfo viewController:nil];
            [viewController.dataTableView reloadData];
        } failure:^{
            //
        }];
    }
         
}
- (void)clickQQ:(PPTableViewController*)viewController
{
    if ([[UserManager defaultManager] hasBindQQWeibo] && ![[[PPSNSIntegerationService defaultService] snsServiceByType:TYPE_QQ] isAuthorizeExpired]) {
        [GameSNSService askRebindQQ:viewController];
    } else {
        [SNSUtils bindSNS:TYPE_QQ succ:^(NSDictionary *userInfo){
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kBindQQWeibo") delayTime:1 isHappy:YES];
            [[UserService defaultService] updateUserWithSNSUserInfo:[self getUserId] userInfo:userInfo viewController:nil];
            [viewController.dataTableView reloadData];
        } failure:^{
            //
        }];
    }
}
- (void)clickFacebook:(PPTableViewController*)viewController
{
    if ([[UserManager defaultManager] hasBindFacebook] && ![[[PPSNSIntegerationService defaultService] snsServiceByType:TYPE_FACEBOOK] isAuthorizeExpired]) {
        [GameSNSService askRebindFacebook:viewController];
    } else {
        [SNSUtils bindSNS:TYPE_FACEBOOK succ:^(NSDictionary *userInfo){
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kBindFacebook") delayTime:1 isHappy:YES];
            [[UserService defaultService] updateUserWithSNSUserInfo:[self getUserId] userInfo:userInfo viewController:nil];
            [viewController.dataTableView reloadData];
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
//    UILabel* numberLabel = [self labelWithText:[NSString stringWithFormat:@"%d", number]];
//    UILabel* titleLabel = [self labelWithText:title];
//    
//    [numberLabel setFrame:CGRectMake(button.frame.size.width*0.15, button.frame.size.height*0.15, button.frame.size.width*0.7, button.frame.size.height*0.35)];
//    [titleLabel setFrame:CGRectMake(button.frame.size.width*0.15, button.frame.size.height/2, button.frame.size.width*0.7, button.frame.size.height*0.35)];
//    
//    [button addSubview:numberLabel];
//    [button addSubview:titleLabel];
//}

- (void)initUserActionButton:(UserDetailRoundButton*)button atIndex:(int)index
{
    PBGameUser* user = [self getUser];
    [button setTitle:nil forState:UIControlStateNormal];
    switch (index) {
        case SelfDetailActionFollowCount: {
            [button.upLabel setText:[NSString stringWithFormat:@"%d", user.followCount]];
            [button.downLabel setText:NSLS(@"kFollow")];
        } break;
        case SelfDetailActionBalance: {
            [button setBackgroundImage:[[ShareImageManager defaultManager] selfDetailBalanceBtnBg] forState:UIControlStateNormal];
            int balance = [[AccountManager defaultManager] getBalanceWithCurrency:PBGameCurrencyCoin];
            [button.upLabel setText:[NSString stringWithFormat:@"%d", balance]];
            [button.downLabel setText:NSLS(@"kCoin")];
        } break;
        case SelfDetailActionExp: {
            [button setBackgroundImage:[[ShareImageManager defaultManager] selfDetailExpBtnBg] forState:UIControlStateNormal];
            [button.upLabel setText:[NSString stringWithFormat:@"%"PRId64, user.experience]];
            [button.downLabel setText:NSLS(@"kExp")];
        } break;
        case SelfDetailActionIngot: {
            [button setBackgroundImage:[[ShareImageManager defaultManager] selfDetailIngotBtnBg] forState:UIControlStateNormal];
            int ingot = [[AccountManager defaultManager] getBalanceWithCurrency:PBGameCurrencyIngot];
            [button.upLabel setText:[NSString stringWithFormat:@"%d", ingot]];
            [button.downLabel setText:NSLS(@"kIngot")];
        } break;
        case SelfDetailActionFanCount: {
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
        case SelfDetailActionFollowCount:
            [self didClickFollowCountButton:viewController];
            break;
        case SelfDetailActionIngot:
        case SelfDetailActionBalance: {
            ChargeController *controller = [[ChargeController alloc] init];
            [viewController.navigationController pushViewController:controller animated:YES];
            [controller release];
        } break;
        case SelfDetailActionExp: {
        } break;
        case SelfDetailActionFanCount: {
            [self didClickFanCountButton:viewController];
        } break;
        default:
            break;
    }
}

- (void)didClickFanCountButton:(PPTableViewController*)viewController
{
    FriendController* vc = [[[FriendController alloc] init] autorelease];
    [vc setDefaultTabIndex:FriendTabIndexFan];
    [viewController.navigationController pushViewController:vc animated:YES];
}

- (void)didClickFollowCountButton:(PPTableViewController*)viewController
{
    FriendController* vc = [[[FriendController alloc] init] autorelease];
    [vc setDefaultTabIndex:FriendTabIndexFollow];
    [viewController.navigationController pushViewController:vc animated:YES];
}

- (void)clickCustomBg:(PPTableViewController <ChangeAvatarDelegate>*)viewController didSelectBlock:(void (^)(UIImage *))aBlock
{
    if (_changeAvatar == nil) {
        _changeAvatar = [[ChangeAvatar alloc] init];
        _changeAvatar.autoRoundRect = NO;
        _changeAvatar.isCompressImage = NO;
    }
    [_changeAvatar showSelectionView:viewController selectedImageBlock:^(UIImage *image) {
        EXECUTE_BLOCK(aBlock, image);
    } didSetDefaultBlock:^{
        EXECUTE_BLOCK(aBlock,  nil);
    } title:NSLS(@"kCustomBg") hasRemoveOption:YES];
}

- (void)clickAvatar:(PPTableViewController <ChangeAvatarDelegate>*)viewController didSelectBlock:(void (^)(UIImage *))aBlock
{
    if (_changeAvatar == nil) {
        _changeAvatar = [[ChangeAvatar alloc] init];
        _changeAvatar.autoRoundRect = NO;
    }
    [_changeAvatar showSelectionView:viewController selectedImageBlock:^(UIImage *image) {
        EXECUTE_BLOCK(aBlock, image);
    } didSetDefaultBlock:^{
        //
    } title:nil hasRemoveOption:NO];
}

- (BOOL)shouldShow
{
    return YES;
}


@end
