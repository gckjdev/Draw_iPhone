//
//  FeedListController.m
//  Draw
//
//  Created by qqn_pipi on 14-7-1.
//
//

#import "FeedListController.h"
#import "HotController.h"
#import "TableTabManager.h"
#import "ShareImageManager.h"
#import "ShowFeedController.h"
#import "UserDetailViewController.h"
#import "ViewUserDetail.h"
#import "UseItemScene.h"
#import "MyFriend.h"
#import "PPConfigManager.h"
#import "UserManager.h"
#import "CommonMessageCenter.h"
#import "MKBlockActionSheet.h"
#import "BBSPermissionManager.h"
#import "UINavigationController+UINavigationControllerAdditions.h"
#import "PurchaseVipController.h"
//#import "SingHotCell.h"
//#import "NSArray+Ext.h"
#import "CellManager.h"
#import "OpusClassInfoManager.h"
#import "ShowOpusClassListController.h"

@interface FeedListController ()

@end

@implementation FeedListController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.feedType = FeedListTypeHot;
    }
    return self;
}

- (void)dealloc
{
    PPRelease(_opusClassInfo);
    [super dealloc];
}

- (void)viewDidLoad
{
    [self setPullRefreshType:PullRefreshTypeBoth];
    
    UITableView* tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.dataTableView = tableView;
    [self.view addSubview:tableView];
    [tableView release];

    [super viewDidLoad];

    //use local data
    [self initListWithLocalData];
    
    self.canDragBack = NO;
    TableTab *tab = [self currentTab];
    [self clickTab:tab.tabID];

	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.dataTableView reloadData];
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initListWithLocalData
{
    NSArray* list = [[FeedService defaultService] getCachedFeedList:_feedType];
    PPDebug(@"<initListWithLocalData> list count = %d", [list count]);
    if ([list count] != 0) {
        [self.tabDataList addObjectsFromArray:list];
    }
}

- (void)showCachedFeedList:(int)tabID
{
    // TODO set class ID
    NSArray *feedList = [[FeedService defaultService] getCachedFeedList:_feedType];
    self.dataList = feedList;

//    FeedListType type = tabID;
//    if (type != FeedListTypeUnknow) {
//        if (_opusClassInfo){
//            type = [self getFeedTypeForOpusClass:type];
//        }
//        
//        NSArray *feedList = [[FeedService defaultService] getCachedFeedList:type];
//        if ([feedList count] != 0) {
//            [self finishLoadDataForTabID:tabID resultList:feedList];
//        }
//    }
}

#pragma mark - table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (_displayStyle){
        case FEED_DISPLAY_BIG3:
            return [CellManager getHotStyleCellHeightWithIndexPath:indexPath];;
            
        default:
            return [CellManager getLastStyleCellHeightWithIndexPath:indexPath];
    }
    
//    switch ([[self currentTab] tabID]) {
//            
//        case RankTypeHistory:
//        case RankTypeHot:
//            return [CellManager getHotStyleCellHeightWithIndexPath:indexPath];
//            break;
//            
//        case RankTypeRecommend:
//        case RankTypeNew:
//        default:
//            return [CellManager getLastStyleCellHeightWithIndexPath:indexPath];
//    }
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (_displayStyle){
        case FEED_DISPLAY_BIG3:
            return [CellManager getHotStyleCell:theTableView
                                      indexPath:indexPath
                                       delegate:self
                                       dataList:self.tabDataList];
            
        default:
            return [CellManager getLastStyleCell:theTableView
                                       indexPath:indexPath
                                        delegate:self
                                        dataList:self.tabDataList];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = [super tableView:tableView numberOfRowsInSection:section];
    switch (_displayStyle){
        case FEED_DISPLAY_BIG3:
            return [CellManager getHotStyleCellCountWithDataCount:count
                                                       roundingUp:NO];
            
        default:
            return [CellManager getLastStyleCellCountWithDataCount:count
                                                        roundingUp:NO];
    }

}

#pragma mark - feed service delegate

- (void)didGetFeedList:(NSArray *)feedList
          feedListType:(FeedListType)type
            resultCode:(NSInteger)resultCode
{
    PPDebug(@"<didGetFeedList> list count = %d ", [feedList count]);
    if (resultCode == 0) {
        if (self.currentTab.offset == 0) {
            [self.tabDataList removeAllObjects];
        }
        [self finishLoadDataForTabID:self.currentTab.tabID resultList:feedList];
        if ([feedList count] < [PPConfigManager getHotOpusCountOnce]) {
            [self.currentTab setHasMoreData:NO];
        }
    }else{
        [self failLoadDataForTabID:self.currentTab.tabID];
    }
}

#pragma mark Rank View delegate

- (void)showFeed:(DrawFeed *)feed
{
    ShowFeedController *sc = [[ShowFeedController alloc] initWithFeed:feed scene:[UseItemScene createSceneByType:UseSceneTypeShowFeedDetail feed:feed]];
    [sc showOpusImageBrower];
    sc.feedList = [self dataList];
    [self.navigationController pushViewController:sc animated:YES];
    [sc release];
}

- (void)showFeed:(DrawFeed *)feed animatedWithTransition:(UIViewAnimationTransition)transition
{
    ShowFeedController *sc = [[ShowFeedController alloc] initWithFeed:feed scene:[UseItemScene createSceneByType:UseSceneTypeShowFeedDetail feed:feed]];
    sc.feedList = [self dataList];
    [self.navigationController pushViewController:sc animatedWithTransition:transition duration:1];
    [sc release];
    
    
}

- (void)brower:(OpusImageBrower *)brower didSelecteFeed:(DrawFeed *)feed{
    
    [self showFeed:feed animatedWithTransition:UIViewAnimationTransitionCurlUp];
}

- (void)didClickRankView:(RankView *)rankView
{
    [self showFeed:rankView.feed];
}

#pragma mark - common tab controller delegate

- (NSInteger)tabCount
{
    return 1;
}
- (NSInteger)currentTabIndex
{
    return 0;
}

- (NSInteger)fetchDataLimitForTabIndex:(NSInteger)index
{
    return [PPConfigManager getHotOpusCountOnce];;
}

- (NSInteger)tabIDforIndex:(NSInteger)index
{
    return 20140701;
}

- (NSString *)tabTitleforIndex:(NSInteger)index
{
    return nil;
}

- (void)serviceLoadDataForTabID:(NSInteger)tabID
{
    TableTab *tab = [_tabManager tabForID:tabID];
    [[FeedService defaultService] getFeedList:_feedType
                                      classId:_opusClassInfo.classId
                                       offset:tab.offset
                                        limit:tab.limit
                                     delegate:self];
}

- (NSString *)tabNoDataTipsforIndex:(NSInteger)index
{
    return NSLS(@"kNoOpus");
}



@end
