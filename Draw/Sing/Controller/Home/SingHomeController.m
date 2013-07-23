//
//  SingHomeController.m
//  Draw
//
//  Created by 王 小涛 on 13-6-7.
//
//

#import "SingHomeController.h"
#import "SongSelectController.h"
#import "SingOpusDetailController.h"
#import "SingGuessController.h"
#import "OpusManageController.h"
#import "UserDetailViewController.h"
#import "SelfUserDetail.h"
#import "FriendController.h"
#import "UserSettingController.h"
#import "ChatListController.h"
#import "BBSBoardController.h"
#import "StoreController.h"

@interface SingHomeController ()

@end

@implementation SingHomeController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

#define SING_MY_OPUS_DB     @"sing_my_opus.db"
#define SING_FAVORITE_DB    @"sing_favorite.db"
#define SING_DRAFT_DB       @"sing_draft.db"

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark Panel delegate

- (void)homeMainMenuPanel:(HomeMainMenuPanel *)mainMenuPanel
             didClickMenu:(HomeMenuView *)menu
                 menuType:(HomeMenuType)type
{
    if (![self isRegistered]) {
        [self toRegister];
        return;
    }
        
    switch (type) {

        case HomeMenuTypeSing: {
            PPDebug(@"HomeMenuTypeSing");
            SongSelectController *vc = [[[SongSelectController alloc] init] autorelease];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
        case HomeMenuTypeGuessSing: {
            PPDebug(@"HomeMenuTypeGuessSing");
            SingOpusDetailController *vc =  [[[SingOpusDetailController alloc] init] autorelease];
            [self.navigationController pushViewController:vc animated:YES];
            
        }
            break;
            
        case HomeMenuTypeSingContest: {
            PPDebug(@"HomeMenuTypeSingContest");
        }
            break;

        case HomeMenuTypeSingTop: {
            PPDebug(@"HomeMenuTypeSingTop");
            Opus *opus = [Opus opusWithPBOpus:[OpusManager createTestOpus]];
            SingGuessController *vc = [[[SingGuessController alloc] initWithOpus:opus] autorelease];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        

        case HomeMenuTypeSingFreeCoins: {
            PPDebug(@"HomeMenuTypeSingFreeCoins");
        }
            break;

        case HomeMenuTypeSingBBS:{
//            BBSBoardController *bbs = [[BBSBoardController alloc] init];
//            [self.navigationController pushViewController:bbs animated:YES];
//            [bbs release];
        }
            break;
            
        default:
            break;
    }
}

- (void)homeBottomMenuPanel:(HomeBottomMenuPanel *)bottomMenuPanel
               didClickMenu:(HomeMenuView *)menu
                   menuType:(HomeMenuType)type
{
    if (![self isRegistered]) {
        [self toRegister];
        return;
    }
    
    switch (type) {
        case HomeMenuTypeSingTimeline:{
            PPDebug(@"HomeMenuTypeSingTimeline");

        }
            break;
            
        case HomeMenuTypeSingDraft:{
            OpusManageController* vc = [[[OpusManageController alloc] initWithClass:NSClassFromString(@"SingOpus") selfDb:SING_MY_OPUS_DB favoriteDb:SING_FAVORITE_DB draftDb:SING_DRAFT_DB] autorelease];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
        case HomeMenuTypeSingShop:{
            PPDebug(@"HomeMenuTypeSingShop");
            StoreController *vc = [[[StoreController alloc] init] autorelease];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
        case HomeMenuTypeSingChat:{
            ChatListController *controller = [[ChatListController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
            [controller release];
        }
            break;
            
        case HomeMenuTypeSingSetting:{
            UserSettingController *settings = [[UserSettingController alloc] init];
            [self.navigationController pushViewController:settings animated:YES];
            [settings release];
        }
            break;
            
        default:
            break;
    }
}

- (void)homeHeaderPanel:(HomeHeaderPanel *)headerPanel didClickAvatarButton:(UIButton *)button
{
    [super homeHeaderPanel:headerPanel didClickAvatarButton:button];
    UserDetailViewController* us = [[UserDetailViewController alloc] initWithUserDetail:[SelfUserDetail createDetail]];
    [self.navigationController pushViewController:us animated:YES];
    [us release];
}

- (void)homeHeaderPanel:(HomeHeaderPanel *)headerPanel didClickFriendButton:(UIButton *)button
{
    FriendController *controller = [[FriendController alloc] init];
    if ([[StatisticManager defaultManager] fanCount] > 0) {
        [controller setDefaultTabIndex:FriendTabIndexFan];
    }
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)dealloc {
    [super dealloc];
}
- (void)viewDidUnload {
    [super viewDidUnload];
}
@end
