//
//  ZJHHomeViewController.m
//  Draw
//
//  Created by gamy on 12-12-10.
//
//

#import "ZJHHomeViewController.h"
#import "StringUtil.h"
#import "UserManager.h"
#import "LevelService.h"
#import "MyFeedController.h"
#import "BBSBoardController.h"
#import "UserSettingController.h"

#import "FriendController.h"
#import "ChatListController.h"
#import "FeedbackController.h"
#import "VendingController.h"


@interface ZJHHomeViewController ()
{
    
}
@end

ZJHHomeViewController *_staticZJHHomeViewController = nil;

@implementation ZJHHomeViewController

+ (id)defaultInstance
{
    if (_staticZJHHomeViewController == nil) {
        _staticZJHHomeViewController = [[ZJHHomeViewController alloc] init];
    }
    return _staticZJHHomeViewController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    PPDebug(@"ZJHHomeViewController view did load");
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
    switch (type) {
        case HomeMenuTypeZJHHelp: {
            break;
        }
        case HomeMenuTypeZJHStart: {
            break;
        }
        case HomeMenuTypeDrawBBS: {
            BBSBoardController *bbs = [[BBSBoardController alloc] init];
            [self.navigationController pushViewController:bbs animated:YES
             ];
            PPRelease(bbs);
            break;
        }
        case HomeMenuTypeZJHRichSite: {
            break;
        } 
        case HomeMenuTypeZJHNormalSite: {
            break;
        } 
        case HomeMenuTypeZJHVSSite: {
            break;
        }
        default:
            break;
    }
}

- (void)homeBottomMenuPanel:(HomeBottomMenuPanel *)bottomMenuPanel
               didClickMenu:(HomeMenuView *)menu
                   menuType:(HomeMenuType)type
{
    PPDebug(@"<homeBottomMenuPanel>, click type = %d", type);
    
    switch (type) {
            //For Bottom Menus
        case HomeMenuTypeDrawSetting:
        {
            UserSettingController *settings = [[UserSettingController alloc] init];
            [self.navigationController pushViewController:settings animated:YES];
            [settings release];
        }
            
            break;
        case HomeMenuTypeDrawFriend:
        {
            FriendController *mfc = [[FriendController alloc] init];
            [self.navigationController pushViewController:mfc animated:YES];
            [mfc release];
            [menu updateBadge:0];
        }
            break;
        case HomeMenuTypeDrawMessage:
        {
            ChatListController *controller = [[ChatListController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
            [controller release];
            [menu updateBadge:0];
            
        }
            break;
        case HomeMenuTypeDrawMore:
        {
            FeedbackController* feedBack = [[FeedbackController alloc] init];
            [self.navigationController pushViewController:feedBack animated:YES];
            [feedBack release];
            
        }
            break;
            
        default:
            break;
    }
}


@end