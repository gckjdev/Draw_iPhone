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

@interface SingHomeController ()

- (IBAction)clickTest:(id)sender;

@end

@implementation SingHomeController


- (void)viewDidLoad
{
    [super viewDidLoad];
#ifdef DEBUG

    [self.view bringSubviewToFront:self.testBtn];
#endif
    // Do any additional setup after loading the view from its nib.
}

#ifdef DEBUG
#define SING_MY_OPUS_DB     @"sing_my_opus.db"
#define SING_FAVORITE_DB    @"sing_favorite.db"
#define SING_DRAFT_DB       @"sing_draft.db"
- (IBAction)clickTest:(id)sender
{
    OpusManageController* vc = [[[OpusManageController alloc] initWithClass:NSClassFromString(@"SingOpus") selfDb:SING_MY_OPUS_DB favoriteDb:SING_FAVORITE_DB draftDb:SING_DRAFT_DB] autorelease];
    [self.navigationController pushViewController:vc animated:YES];
}
#endif

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

        case HomeMenuTypeSingTop: {
            PPDebug(@"HomeMenuTypeSingTop");
            SingGuessController *vc = [[[SingGuessController alloc] init] autorelease];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;

        case HomeMenuTypeSingShop: {
            PPDebug(@"HomeMenuTypeSingShop");
        }
            break;

        case HomeMenuTypeSingFreeCoins: {
            PPDebug(@"HomeMenuTypeSingFreeCoins");
        }
            break;

        case HomeMenuTypeSingBBS:{
            PPDebug(@"HomeMenuTypeSingBBS");
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
            PPDebug(@"HomeMenuTypeSingDraft");

        }
            break;
            
        case HomeMenuTypeSingFriend:{
            PPDebug(@"HomeMenuTypeSingFriend");

        }
            break;
            
        case HomeMenuTypeSingChat:{
            PPDebug(@"HomeMenuTypeSingChat");

        }
            break;
            
        case HomeMenuTypeSingSetting:{
            PPDebug(@"HomeMenuTypeSingSetting");

        }
            break;
            
        default:
            break;
    }
}


- (void)dealloc {
    [_testBtn release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setTestBtn:nil];
    [super viewDidUnload];
}
@end
