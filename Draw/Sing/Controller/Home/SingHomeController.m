//
//  SingHomeController.m
//  Draw
//
//  Created by 王 小涛 on 13-6-7.
//
//

#import "SingHomeController.h"
//#import "SongSelectController.h"
//#import "SingOpusDetailController.h"
#import "SingGuessController.h"
#import "OpusManageController.h"
#import "UserDetailViewController.h"
#import "SelfUserDetail.h"
#import "FriendController.h"
#import "UserSettingController.h"
#import "ChatListController.h"
#import "BBSBoardController.h"
#import "StoreController.h"
#import "SingController.h"
#import "HotController.h"
#import "MyFeedController.h"
#import "AnalyticsManager.h"
#import "DrawDataService.h"
#import "OfflineGuessDrawController.h"

@interface SingHomeController ()<DrawDataServiceDelegate>

@end

@implementation SingHomeController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)enterSing
{
    SingController *vc = [[[SingController alloc] init] autorelease];
    [self.navigationController pushViewController:vc animated:YES];    
}

- (void)enterGuessSing
{
    [[DrawDataService defaultService] matchOpus:self];    
}

// it's strange to define them here, should be moved to model
#define SING_MY_OPUS_DB     @"sing_my_opus.db"
#define SING_FAVORITE_DB    @"sing_favorite.db"
#define SING_DRAFT_DB       @"sing_draft.db"

- (void)enterSingDraft
{
    OpusManageController* vc = [[[OpusManageController alloc] initWithClass:NSClassFromString(@"SingOpus")
                                                                     selfDb:SING_MY_OPUS_DB
                                                                 favoriteDb:SING_FAVORITE_DB
                                                                    draftDb:SING_DRAFT_DB] autorelease];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark Panel delegate

- (NSArray*)noCheckedMenuTypes
{
    NSArray *noCheckedTypes = @[@(HomeMenuTypeSing),
                                @(HomeMenuTypeDrawContest),
                                @(HomeMenuTypeDrawBBS),
                                @(HomeMenuTypeDrawRank),
                                @(HomeMenuTypeGuessSing),
                                @(HomeMenuTypeDrawMore),
                                ];
    
    return noCheckedTypes;
}

- (BOOL)handleClickMenu:(HomeMainMenuPanel *)mainMenuPanel
                   menu:(HomeMenuView *)menu
               menuType:(HomeMenuType)type
{
    
    BOOL isProcessed = YES;
    
    switch (type) {

        case HomeMenuTypeSing:
        {
            [self enterSing];
            break;
        }
            
        case HomeMenuTypeGuessSing:
        {
            [self enterGuessSing];
            break;
        }
            
        default:
        {
            isProcessed = NO;
            break;
        }
    }
    
    return isProcessed;
}

- (BOOL)handleClickBottomMenu:(HomeBottomMenuPanel *)bottomMenuPanel
                         menu:(HomeMenuView *)menu
                     menuType:(HomeMenuType)type
{
    BOOL isProcessed = YES;
    
    switch (type) {
            
        case HomeMenuTypeSingDraft:
        {
            [self enterSingDraft];
            break;
        }
                        
        default:
        {
            isProcessed = NO;
            break;
        }
    }
    
    return isProcessed;
}

- (void)homeHeaderPanel:(HomeHeaderPanel *)headerPanel didClickFriendButton:(UIButton *)button
{
    [self enterFriend];
}

- (void)dealloc {
    [super dealloc];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)didMatchDraw:(DrawFeed *)feed result:(int)resultCode
{
    [OfflineGuessDrawController startOfflineGuess:feed fromController:self];
}


@end
