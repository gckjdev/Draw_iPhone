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
#import "RankView.h"
#import "MKBlockActionSheet.h"
#import "AddLearnDrawView.h"
#import "ReplayView.h"
#import "Draw.h"
#import "LearnDrawPreViewController.h"

@interface LearnDrawHomeController ()
{
    NSInteger  _tryTimes;
}

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

#define MAX_TRYTIMES 3

- (void)updateBoughtList
{
    
    __block LearnDrawHomeController *cp = self;
    [[LearnDrawService defaultService] getAllBoughtLearnDrawIdListWithResultHandler:^(NSArray *array, NSInteger resultCode) {
        if (resultCode != 0 && (++_tryTimes)  < MAX_TRYTIMES) {
            [cp updateBoughtList];
        }
    }];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateBoughtList];    
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


//rank view delegate


- (void)playFeed:(DrawFeed *)aFeed
{
    __block LearnDrawHomeController *cp = self;
    [[FeedService defaultService] getPBDrawByFeed:aFeed handler:^(int resultCode, NSData *pbDrawData, DrawFeed *feed, BOOL fromCache) {
        if (resultCode == 0 && pbDrawData) {
            ReplayView *replay = [ReplayView createReplayView];
            feed.pbDrawData = pbDrawData;
            [feed parseDrawData];
            [replay showInController:cp
                      withActionList:feed.drawData.drawActionList
                        isNewVersion:[feed.drawData isNewVersion]
                                size:feed.drawData.canvasSize];
            feed.drawData = nil;
        }else{
            //TODO show error message
        }
    } downloadDelegate:nil]; //TODO show download progress...

}

- (void)showFeed:(DrawFeed *)feed placeHolder:(UIImage *)placeHolder
{
    if ([[LearnDrawManager defaultManager] hasBoughtDraw:feed.feedId]) {
        [self playFeed:feed];
    }else{
        [LearnDrawPreViewController presentLearnDrawPreviewControllerFrom:self drawFeed:feed placeHolderImage:placeHolder];
    }
}

- (void)didClickRankView:(RankView *)rankView
{
    
    if (![[BBSPermissionManager defaultManager] canPutDrawOnCell]) {
        [self showFeed:rankView.feed placeHolder:rankView.drawImage.image];
    }else{
        MKBlockActionSheet *sheet = [[MKBlockActionSheet alloc]
                                     initWithTitle:[NSString stringWithFormat:@"%@<警告！你正在使用超级管理权限>", NSLS(@"kOpusOperation")]
                                     delegate:nil
                                     cancelButtonTitle:NSLS(@"kCancel")
                                     destructiveButtonTitle:NSLS(@"kOpusDetail")
                                     otherButtonTitles:NSLS(@"kManageLearnDraw"),
                                     NSLS(@"kRemoveLearnDraw"),
                                     NSLS(@"Buy Test"), nil];
        
        __block LearnDrawHomeController *cp = self;
        
        [sheet setActionBlock:^(NSInteger buttonIndex){
            PPDebug(@"click button index = %d", buttonIndex);
            if (buttonIndex == 0) {
                [cp showFeed:rankView.feed placeHolder:rankView.drawImage.image];
            }else if(buttonIndex == 1){
                AddLearnDrawView* alView = [AddLearnDrawView createViewWithOpusId:rankView.feed.feedId];
                [alView showInView:cp.view];
                [alView setPrice:rankView.feed.learnDraw.price];
                [alView setType:rankView.feed.learnDraw.type];
            }else if(buttonIndex == 2){
                [[LearnDrawService defaultService] removeLearnDraw:rankView.feed.feedId
                                                     resultHandler:^(NSDictionary *dict, NSInteger resultCode) {
                                                        if (resultCode == 0) {
                                                            [cp finishDeleteData:rankView.feed ForTabID:[cp currentTab].tabID];
                                                        }else{
                                                            [cp failLoadDataForTabID:[cp currentTab].tabID];
                                                        }
                }];
            }else if(buttonIndex == 3){
                
                DrawFeed *feed = rankView.feed;
                
                [[LearnDrawService defaultService] buyLearnDraw:feed.feedId price:feed.learnDraw.price fromView:self.view resultHandler:^(NSDictionary *dict, NSInteger resultCode) {
                                                      if (resultCode == 0) {
                                                          [cp.dataTableView reloadData];
                                                      }else{
                                                          //TODO deal with the error result.
                                                      }

                }];
            }
        }];
        
        [sheet showInView:self.view];
        [sheet release];
        
    }
    
}



//table view delegate





#define NORMAL_CELL_VIEW_NUMBER 3
#define WIDTH_SPACE 1

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = [super tableView:tableView numberOfRowsInSection:section];
    return  count / NORMAL_CELL_VIEW_NUMBER + (count % NORMAL_CELL_VIEW_NUMBER != 0);
}

- (void)setNormalRankCell:(UITableViewCell *)cell
                WithFeeds:(NSArray *)feeds
{
    CGFloat width = [RankView widthForRankViewType:RankViewTypeDrawOnCell];
    CGFloat height = [RankView heightForRankViewType:RankViewTypeDrawOnCell];
    
    CGFloat space =  WIDTH_SPACE;
    CGFloat x = 0;
    CGFloat y = 0;
    for (DrawFeed *feed in feeds) {
        RankView *rankView = [RankView createRankView:self type:RankViewTypeDrawOnCell];
        [rankView setViewInfo:feed];
        [cell.contentView addSubview:rankView];
        rankView.frame = CGRectMake(x, y, width, height);
        x += width + space;
    }
}

- (NSObject *)saveGetObjectForIndex:(NSInteger)index
{
    NSArray *list = [self tabDataList];
    if (index < 0 || index >= [list count]) {
        return nil;
    }
    return [list objectAtIndex:index];
}

- (void)clearCellSubViews:(UITableViewCell *)cell{
    for (UIView *view in cell.contentView.subviews) {
        if ([view isKindOfClass:[RankView class]]) {
            [view removeFromSuperview];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [RankView heightForRankViewType:RankViewTypeDrawOnCell] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    TableTab *tab = [self currentTab];
    
    
        
        NSString *CellIdentifier = @"RankCell";//[RankFirstCell getCellIdentifier];
        UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }else{
            [self clearCellSubViews:cell];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        NSInteger startIndex = (indexPath.row * NORMAL_CELL_VIEW_NUMBER);
        NSMutableArray *list = [NSMutableArray array];
        for (NSInteger i = startIndex; i < startIndex+NORMAL_CELL_VIEW_NUMBER; ++ i) {
            NSObject *object = [self saveGetObjectForIndex:i];
            if (object) {
                [list addObject:object];
            }
        }
        [self setNormalRankCell:cell WithFeeds:list];
        return cell;

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
    
    __block LearnDrawHomeController *cp = self;
    [self showActivityWithText:NSLS(@"kLoading")];
    [[LearnDrawService defaultManager] getLearnDrawOpusListWithType:[self typeFromTabID:tabID]
                                                           sortType:SortTypeTime
                                                             offset:tab.offset
                                                              limit:tab.limit
                                                      ResultHandler:^(NSArray *array, NSInteger resultCode) {
                                                          PPDebug(@"array count = %d", [array count]);
                                                          if (resultCode == 0) {
                                                              [cp finishLoadDataForTabID:tabID resultList:array];
                                                          }else{
                                                              [cp failLoadDataForTabID:tabID];
                                                          }
                                                    
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
