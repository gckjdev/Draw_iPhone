//
//  SingHomeController.m
//  Draw
//
//  Created by 王 小涛 on 13-6-7.
//
//

#import "SingHomeController.h"
#import "SongSelectController.h"

@interface SingHomeController ()

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
            
        }
            break;

        case HomeMenuTypeSingTop: {
            PPDebug(@"HomeMenuTypeSingTop");
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


@end
