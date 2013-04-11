//
//  LearnDrawHomeController.m
//  Draw
//
//  Created by gamy on 13-4-11.
//
//

#import "LearnDrawHomeController.h"

@interface LearnDrawHomeController ()

@end

@implementation LearnDrawHomeController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)homeBottomMenuPanel:(HomeBottomMenuPanel *)bottomMenuPanel
               didClickMenu:(HomeMenuView *)menu
                   menuType:(HomeMenuType)type
{
    switch (type) {
            
        case HomeMenuTypeLearnDrawDraft:
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
            break;
        case HomeMenuTypeLearnDrawMore:
        {
            [[AnalyticsManager sharedAnalyticsManager] reportClickHomeElements:HOME_BOTTOM_MORE];
            
            FeedbackController* feedBack = [[FeedbackController alloc] init];
            [self.navigationController pushViewController:feedBack animated:YES];
            [feedBack release];
        }
            break;
            
            
        case HomeMenuTypeLearnDrawShop:
        {
            [[AnalyticsManager sharedAnalyticsManager] reportClickHomeMenu:HOME_ACTION_SHOP];
            
            StoreController *vc = [[[StoreController alloc] init] autorelease];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
        default:
            break;
    }
    [menu updateBadge:0];
}
@end
