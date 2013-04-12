//
//  LearnDrawHomeController.m
//  Draw
//
//  Created by gamy on 13-4-11.
//
//

#import "LearnDrawHomeController.h"
#import "AnalyticsManager.h"
#import "ShareController.h"
#import "FeedbackController.h"
#import "StoreController.h"
#import "HomeBottomMenuPanel.h"
#import "UIViewUtils.h"
#import "StatisticManager.h"
#import "LearnDrawManager.h"
#import "LearnDrawService.h"
#import "OfflineDrawViewController.h"
#import "HotController.h"
#import "BBSPermissionManager.h"


@interface LearnDrawHomeController ()

//@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIButton *gmButton;
@property(nonatomic, retain)HomeBottomMenuPanel *homeBottomMenuPanel;
- (IBAction)clickGMButton:(id)sender;

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

- (void)dealloc
{
    PPRelease(_homeBottomMenuPanel);
    [_gmButton release];
    [super dealloc];
}

- (void)addBottomMenuView
{
    self.homeBottomMenuPanel = [HomeBottomMenuPanel createView:self];
    [self.view addSubview:self.homeBottomMenuPanel];
    [self.homeBottomMenuPanel updateOriginY:CGRectGetHeight(self.view.bounds) - CGRectGetHeight(self.homeBottomMenuPanel.bounds)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([[BBSPermissionManager defaultManager] canPutDrawOnCell]) {
        [self.gmButton setHidden:NO];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addBottomMenuView];
    [self initTabButtons];
    self.gmButton.hidden = YES;
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
            
        case HomeMenuTypeLearnDrawDraw:
        {
            [[AnalyticsManager sharedAnalyticsManager] reportClickHomeElements:HOME_BOTTOM_LEARN_DRAW_DRAFT];
            
            [OfflineDrawViewController startDraw:[Word wordWithText:NSLS(@"kLearnDrawWord") level:1] fromController:self startController:self targetUid:nil];
            break;
        }
        
        case HomeMenuTypeLearnDrawDraft:
        {
            [[AnalyticsManager sharedAnalyticsManager] reportClickHomeElements:HOME_BOTTOM_LEARN_DRAW_DRAFT];
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
            [[AnalyticsManager sharedAnalyticsManager] reportClickHomeElements:HOME_BOTTOM_LEARN_DRAW_MORE];
            
            FeedbackController* feedBack = [[FeedbackController alloc] init];
            [self.navigationController pushViewController:feedBack animated:YES];
            [feedBack release];
        }
            break;
            
            
        case HomeMenuTypeLearnDrawShop:
        {
            [[AnalyticsManager sharedAnalyticsManager] reportClickHomeMenu:HOME_BOTTOM_LEARN_DRAW_SHOP];
            
            StoreController *vc = [[[StoreController alloc] init] autorelease];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
        default:
            break;
    }
    [menu updateBadge:0];
}



//table tab manager


#define OFFSET 100

- (LearnDrawType)typeFromTabID:(int)tabID
{
    return tabID - OFFSET;
}

- (int)tabIDFromeType:(LearnDrawType)type
{
    return type + OFFSET;
}

- (NSInteger)tabCount //default 1
{
    return 5;
}
- (NSInteger)currentTabIndex //default 0
{
    return _defaultTabIndex;
}
- (NSInteger)fetchDataLimitForTabIndex:(NSInteger)index //default 20
{
    return 15;
}
- (NSInteger)tabIDforIndex:(NSInteger)index
{
    
    int types[] = {
        LearnDrawTypeAll,
        LearnDrawTypeCartoon,
        LearnDrawTypeCharater,
        LearnDrawTypeScenery,
        LearnDrawTypeOther};
    
    return [self tabIDFromeType:types[index]];
}
- (NSString *)tabTitleforIndex:(NSInteger)index
{
    NSString *titles[] = {NSLS(@"kLearnDrawAll"),NSLS(@"kLearnDrawCartoon"),NSLS(@"kLearnDrawCharater"),NSLS(@"kLearnDrawScenery"),NSLS(@"kLearnDrawOther")};
    return titles[index];
}
- (void)serviceLoadDataForTabID:(NSInteger)tabID
{
    TableTab *tab = [_tabManager tabForID:tabID];
    [[LearnDrawService defaultManager] getLearnDrawOpusListWithType:[self typeFromTabID:tabID]
                                                           sortType:SortTypeTime
                                                             offset:tab.offset
                                                              limit:tab.limit
                                                      ResultHandler:^(NSArray *array, NSInteger resultCode) {
        PPDebug(@"array count = %d", [array count]);
    }];
}
- (void)viewDidUnload {
    [self setTitleLabel:nil];
    [self setGmButton:nil];
    [super viewDidUnload];
}
- (IBAction)clickGMButton:(id)sender {
    HotController *hot = [[HotController alloc] initWithDefaultTabIndex:2];
    [self.navigationController pushViewController:hot animated:YES];
}
@end
