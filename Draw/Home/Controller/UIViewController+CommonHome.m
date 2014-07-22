//
//  UIViewController+CommonHome.m
//  Draw
//
//  Created by qqn_pipi on 14-7-9.
//
//

#import "UIViewController+CommonHome.h"
#import "HomeMenuView.h"
#import "ChargeController.h"
#import "StatisticManager.h"
#import "UserManager.h"
#import "UserSettingController.h"
#import "LmWallService.h"
#import "UIUtils.h"
#import "BulletinView.h"
#import "AnalyticsManager.h"
#import "BulletinService.h"
#import "NotificationName.h"
#import "CommonGameNetworkService.h"
#import "AudioManager.h"
#import "UserDetailViewController.h"
#import "SelfUserDetail.h"
#import "HomeMenuView.h"
#import "DrawImageManager.h"
#import "DrawHomeHeaderPanel.h"
#import "DrawMainMenuPanel.h"
#import "MyFeedController.h"
#import "StoreController.h"
#import "BBSBoardController.h"
#import "FeedbackController.h"
#import "HotController.h"
#import "ChatListController.h"
#import "FriendController.h"
#import "TaskController.h"
#import "DrawImageManager.h"
#import "ContestController.h"
#import "PainterController.h"
#import "GroupHomeController.h"
#import "FreeIngotController.h"
#import "ShowOpusClassListController.h"
#import "UserTutorialMainController.h"
#import "FeedListController.h"
#import "NewHotController.h"
#import "MetroHomeController.h"
#import "ShareController.h"
#import "OnlineGuessDrawController.h"
#import "GuessModesController.h"
#import "DrawRoomListController.h"
#import "ICETutorialController.h"
#import "GuidePageManager.h"
#import "ResultSharePageViewController.h"
@implementation UIViewController (CommonHome)

- (void)enterUserTimeline
{
    [[AnalyticsManager sharedAnalyticsManager] reportClickHomeMenu:HOME_ACTION_TIMELINE];
    [MyFeedController enterControllerWithIndex:0 fromController:self animated:YES];
    [[StatisticManager defaultManager] setTimelineOpusCount:0];
}

- (void)enterShop
{
    [[AnalyticsManager sharedAnalyticsManager] reportClickHomeMenu:HOME_ACTION_SHOP];
    StoreController *vc = [[[StoreController alloc] init] autorelease];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)enterGroup
{
    [[AnalyticsManager sharedAnalyticsManager] reportClickHomeMenu:HOME_ACTION_GROUP];
    GroupHomeController *grp = [[GroupHomeController alloc] init];
    [self.navigationController pushViewController:grp animated:YES];
    [grp release];
}

- (void)enterBBS
{
    [[AnalyticsManager sharedAnalyticsManager] reportClickHomeMenu:HOME_ACTION_BBS];
    BBSBoardController *bbs = [[BBSBoardController alloc] init];
    [self.navigationController pushViewController:bbs animated:YES];
    [bbs release];
}

- (void)enterTask{
    
#ifdef DEBUG
    // for test user tutorial
    UserTutorialMainController* ut = [[UserTutorialMainController alloc] init];
    [self.navigationController pushViewController:ut animated:YES];
    [ut release];
    return;
#endif
    
    TaskController *vc = [[[TaskController alloc] init] autorelease];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)enterOfflineDraw
{
    [[AnalyticsManager sharedAnalyticsManager] reportClickHomeMenu:HOME_ACTION_DRAW];
    [OfflineDrawViewController startDraw:[Word cusWordWithText:@""] fromController:self startController:self targetUid:nil];
}

- (void)enterTimeline
{
    [[AnalyticsManager sharedAnalyticsManager] reportClickHomeMenu:HOME_ACTION_TIMELINE];
    
    [MyFeedController enterControllerWithIndex:0 fromController:self animated:YES];
    [[StatisticManager defaultManager] setTimelineOpusCount:0];    
}

- (void)enterOpusClass{
    //    ShowOpusClassListController* vc = [[ShowOpusClassListController alloc] init];
    //    [self.navigationController pushViewController:vc animated:YES];
    //    [vc release];
    
    //    FeedListController* vc = [[FeedListController alloc] init];
    //    [self.navigationController pushViewController:vc animated:YES];
    //    [vc release];
    
    NewHotController* vc = [[NewHotController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
    
}

- (void)enterMore
{
    [[AnalyticsManager sharedAnalyticsManager] reportClickHomeElements:HOME_BOTTOM_MORE];
    
    FeedbackController* feedBack = [[FeedbackController alloc] init];
    [self.navigationController pushViewController:feedBack animated:YES];
    [feedBack release];
}

- (void)enterTopOpus
{
    [[AnalyticsManager sharedAnalyticsManager] reportClickHomeMenu:HOME_ACTION_TOP];
    HotController *hc = [[HotController alloc] init];
    [self.navigationController pushViewController:hc animated:YES];
    [hc release];
}

- (void)enterContest{
    
//#ifdef DEBUG
//    MetroHomeController *mc = [[MetroHomeController alloc] init];
//    [self.navigationController pushViewController:mc animated:YES];
//    [mc release];
//    return;
//#endif
    
    [[AnalyticsManager sharedAnalyticsManager] reportClickHomeMenu:HOME_ACTION_CONTEST];
    
    ContestController *cc = [[ContestController alloc] init];
    [self.navigationController pushViewController:cc animated:YES];
    [cc release];
}


- (void)enterChat
{
    [[AnalyticsManager sharedAnalyticsManager] reportClickHomeElements:HOME_BOTTOM_CHAT];
    
    ChatListController *controller = [[ChatListController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

- (void)enterFriend
{
    [[AnalyticsManager sharedAnalyticsManager] reportClickHomeElements:HOME_BOTTOM_FRIEND];
    FriendController *mfc = [[FriendController alloc] init];
    if ([[StatisticManager defaultManager] fanCount] > 0) {
        [mfc setDefaultTabIndex:FriendTabIndexFan];
    }
    [self.navigationController pushViewController:mfc animated:YES];
    [mfc release];
}

- (void)enterUserSetting
{
    UserSettingController *settings = [[UserSettingController alloc] init];
    [self.navigationController pushViewController:settings animated:YES];
    [settings release];
}

- (void)enterPainter
{
    PainterController *pc = [[PainterController alloc] init];
    [self.navigationController pushViewController:pc animated:YES];
    [pc release];
}

- (void)enterDraftBox
{
    [[AnalyticsManager sharedAnalyticsManager] reportClickHomeElements:HOME_BOTTOM_OPUS];
    ShareController* share = [[ShareController alloc] init];
    int count = [[StatisticManager defaultManager] recoveryCount];
    if (count > 0) {
        [share setDefaultTabIndex:2];
        [[StatisticManager defaultManager] setRecoveryCount:0];
    }
    [self.navigationController pushViewController:share animated:YES];
    [share release];
}

- (BOOL)isRegistered
{
    if ([[UserManager defaultManager] hasXiaojiNumber]){
        return YES;
    }
    
    if ([[UserManager defaultManager] isOldUserWithoutXiaoji]){
        return YES;
    }
    
    return NO;
}

- (BOOL)toRegister
{
    // change by Benson for new xiaoji number login and logout
    return [[UserService defaultService] checkAndAskLogin:self.view];
}

- (void)enterUserDetail
{
    if ([self toRegister]){
        return;
    }
    if ([[UserManager defaultManager] isOldUserWithoutXiaoji]){
        [self askShake];
        return;
    }
    
    UserDetailViewController* us = [[UserDetailViewController alloc] initWithUserDetail:[SelfUserDetail createDetail]];
    [self.navigationController pushViewController:us animated:YES];
    [us release];
}

- (void)enterFreeCoins
{
    [[AnalyticsManager sharedAnalyticsManager] reportClickHomeMenu:HOME_ACTION_FREE_COINS];
    FreeIngotController* fc = [[[FreeIngotController alloc] init] autorelease];
    [self.navigationController pushViewController:fc animated:YES];
}

-(void)enterGuess{
    
    GuessModesController *vc =[[[GuessModesController alloc] init] autorelease];
    [self.navigationController pushViewController:vc animated:YES];
    
}
-(void)enterOnlineDraw{
    [[AnalyticsManager sharedAnalyticsManager] reportClickHomeMenu:HOME_ACTION_ONLINE];
    UIViewController* rc = [[[DrawRoomListController alloc] init] autorelease];
    [self.navigationController pushViewController:rc animated:YES];
}

- (void)askShake
{
    CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"kMessage")
                                                       message:NSLS(@"kTryShakeXiaoji")
                                                         style:CommonDialogStyleDoubleButtonWithCross];
    
    [dialog.oKButton setTitle:NSLS(@"kTryTakeNumber") forState:UIControlStateNormal];
    [dialog.cancelButton setTitle:NSLS(@"kViewMyProfile") forState:UIControlStateNormal];
    
    [dialog setClickOkBlock:^(id infoView){
        [[UserService defaultService] showXiaojiNumberView:self.view];
    }];
    
    [dialog setClickCancelBlock:^(id infoView){
        [self gotoMyDetail];
    }];
    
    [dialog showInView:self.view];
}

- (void)gotoMyDetail
{
    UserDetailViewController* us = [[UserDetailViewController alloc] initWithUserDetail:[SelfUserDetail createDetail]];
    [self.navigationController pushViewController:us animated:YES];
    [us release];
}

- (void)showBulletinView
{
    [[AnalyticsManager sharedAnalyticsManager] reportClickHomeElements:HOME_TOP_BULLETIN];
    
    BulletinView *v = [BulletinView createWithSuperController:(PPViewController*)self];
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kBulletin") customView:v style:CommonDialogStyleCross];
    [dialog showInView:self.view];
}

//ChaoSo 7.21 2014
//test
-(void)goToGuidePage{
    ICETutorialController* guidePage = [[GuidePageManager alloc] initGuidePage];
    [self.navigationController pushViewController:guidePage animated:YES];
 
}
-(void)enterMetroHome{
    MetroHomeController *mc = [[MetroHomeController alloc] init];
    [self.navigationController pushViewController:mc animated:YES];
    [mc release];
    
}
-(void)enterResultSharePage{
    ResultSharePageViewController *rspc = [[ResultSharePageViewController alloc] init];
    [self.navigationController pushViewController:rspc
                                         animated:YES];
    [rspc release];
    
}



@end
