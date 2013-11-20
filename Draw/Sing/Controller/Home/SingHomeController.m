//
//  SingHomeController.m
//  Draw
//
//  Created by 王 小涛 on 13-6-7.
//
//

#import "SingHomeController.h"
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
#import "DrawImageManager.h"

static NSDictionary* SING_MENU_TITLE_DICT = nil;
static NSDictionary* SING_MENU_IMAGE_DICT = nil;

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
    [self showActivityWithText:NSLS(@"kMatchingOpus")];
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
                                @(HomeMenuTypeTask),
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
            
        case HomeMenuTypeDrawContest:
        {
            POSTMSG(NSLS(@"kContestWillComeSoon"));
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
    [self hideActivity];
    if (resultCode == 0 && feed != nil){
        [OfflineGuessDrawController startOfflineGuess:feed fromController:self];
    }
    else{
        POSTMSG2(NSLS(@"kFailMatchOpus"), 2.5);
    }
}

#pragma mark - menu methods

int *getSingMainMenuTypeListWithFreeCoins()
{
    int static list[] = {
        HomeMenuTypeSing,
        HomeMenuTypeTask,
        HomeMenuTypeDrawBBS,
        HomeMenuTypeDrawRank,
        HomeMenuTypeDrawContest,
        HomeMenuTypeGuessSing,
        HomeMenuTypeEnd,
    };
    return list;
}

int *getSingMainMenuTypeListWithoutFreeCoins()
{
    int static list[] = {
        HomeMenuTypeSing,
        HomeMenuTypeTask,
        HomeMenuTypeDrawBBS,
        HomeMenuTypeDrawRank,
        HomeMenuTypeDrawContest,
        HomeMenuTypeGuessSing,
        HomeMenuTypeEnd,        
    };
    return list;
}

int *getSingBottomMenuTypeList()
{
    int static list[] = {
        HomeMenuTypeDrawTimeline,
        HomeMenuTypeSingDraft,
        HomeMenuTypeDrawFriend,
        HomeMenuTypeDrawMessage,
        HomeMenuTypeDrawShop,
        HomeMenuTypeEnd
    };
    return list;
}


+ (int *)getMainMenuList
{
    return ([PPConfigManager freeCoinsEnabled] ? getSingMainMenuTypeListWithFreeCoins() : getSingMainMenuTypeListWithoutFreeCoins());
}

+ (int *)getBottomMenuList
{
    return getSingBottomMenuTypeList();
}


+ (NSDictionary*)menuTitleDictionary
{    
    static dispatch_once_t singMenuTitleOnceToken;
    dispatch_once(&singMenuTitleOnceToken, ^{
        SING_MENU_TITLE_DICT = @{
                                 @(HomeMenuTypeSing) : NSLS(@"kSing"),
                                 @(HomeMenuTypeGuessSing) : NSLS(@"kGuessSing"),
                                 @(HomeMenuTypeDrawRank) : NSLS(@"kSingTop"),
                                 };
        
        [SING_MENU_TITLE_DICT retain];  // make sure you retain the dictionary here for futher usage
        
    });
    
    return SING_MENU_TITLE_DICT;
}

+ (NSDictionary*)menuImageDictionary
{
    
    static dispatch_once_t singMenuImageOnceToken;
    dispatch_once(&singMenuImageOnceToken, ^{
        DrawImageManager *imageManager = [DrawImageManager defaultManager];

        SING_MENU_IMAGE_DICT = @{
                                 // main
                                 @(HomeMenuTypeSing) : [imageManager singHomeSing],
                                 @(HomeMenuTypeGuessSing) : [imageManager singHomeGuess],
                                 @(HomeMenuTypeDrawContest) : [imageManager singHomeContest],
                                 
                                 // bottom
                                 @(HomeMenuTypeSingDraft) : [imageManager drawHomeOpus],
                                 };
        
        [SING_MENU_IMAGE_DICT retain];  // make sure you retain the dictionary here for futher usage
        
    });
    
    return SING_MENU_IMAGE_DICT;
}

+ (int)homeDefaultMenuType
{
    return HomeMenuTypeSing;
}


@end
