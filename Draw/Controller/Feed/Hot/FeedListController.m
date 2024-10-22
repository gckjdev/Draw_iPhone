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

@property (nonatomic, assign) dispatch_once_t onceToken;

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

- (id)initWithFeedType:(FeedListType)feedType
         opusClassInfo:(OpusClassInfo*)opusClassInfo
          displayStyle:(int)displayStyle
   superViewController:(UIViewController*)superViewController
                 title:(NSString*)title
{
    self = [super init];
    if (self){
        self.superViewController = superViewController;
        self.displayStyle = displayStyle;
        self.opusClassInfo = opusClassInfo;
        self.feedType = feedType;
        self.title = title;
        if (title == nil){
            self.title = @"";
        }
        
        self.isShowIndependent = NO;
    }
    return self;
}

- (id)initWithFeedType:(FeedListType)feedType
            tutorialId:(NSString*)tutorialId
               stageId:(NSString*)stageId
          displayStyle:(int)displayStyle
   superViewController:(UIViewController*)superViewController
                 title:(NSString*)title
{
    self = [super init];
    if (self){
        self.superViewController = superViewController;
        self.displayStyle = displayStyle;
        self.opusClassInfo = nil;
        self.feedType = feedType;
        self.tutorialId = tutorialId;
        self.stageId = stageId;
        self.title = title;
        self.isShowIndependent = YES;
        if (title == nil){
            self.title = @"";
        }
    }
    return self;
}

- (void)dealloc
{
    PPRelease(_opusClassInfo);
    PPRelease(_stageId);
    PPRelease(_tutorialId);
    self.superViewController = nil;
    [super dealloc];
}

- (void)viewDidLoad
{
    
    
    if(self.feedType == FeedListTypeConquerDrawStageTop){
        [self setPullRefreshType:PullRefreshTypeHeader];
    }else{
        [self setPullRefreshType:PullRefreshTypeBoth];
    }
    
    
    if (_isShowIndependent){
        // set title view
        [CommonTitleView createTitleView:self.view];
        [[CommonTitleView titleView:self.view] setTitle:self.title];
        [[CommonTitleView titleView:self.view] setTarget:self];
        [[CommonTitleView titleView:self.view] setBackButtonSelector:@selector(clickBack:)];
        [[CommonTitleView titleView:self.view] setRightButtonAsRefresh];
        [[CommonTitleView titleView:self.view] setRightButtonSelector:@selector(clickRefreshButton:)];
    }
    
    CGRect frame;
    if (_isShowIndependent){
        CGFloat height = ([UIScreen mainScreen].bounds.size.height - COMMON_TITLE_VIEW_HEIGHT - STATUS_BAR_HEIGHT);
        frame = CGRectMake(0, COMMON_TITLE_VIEW_HEIGHT, self.view.bounds.size.width, height);
    }
    else{
        CGFloat height = ([UIScreen mainScreen].bounds.size.height - COMMON_TAB_BUTTON_HEIGHT - COMMON_TITLE_VIEW_HEIGHT - STATUS_BAR_HEIGHT);
        frame = CGRectMake(0, 0, self.view.bounds.size.width, height);
    }
    
    UITableView* tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    self.dataTableView = tableView;

    [self.view addSubview:tableView];
    [tableView release];
    
    self.dataTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.dataTableView.separatorColor = [UIColor clearColor];

    [super viewDidLoad];

    if (self.feedType == FeedListTypeConquerDrawStageTop){
        self.dataTableView.backgroundColor = [UIColor whiteColor];
    }

    
    self.canDragBack = NO;

	// Do any additional setup after loading the view.
    if (_isShowIndependent){
        [self firstLoadData];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.view.hidden == YES){
        return;
    }
    
    [super viewDidAppear:animated];
}

- (void)firstLoadData
{
    dispatch_once(&_onceToken, ^{
        
        PPDebug(@"viewDidAppear local local data and call remote");
        //use local data
        [self initListWithLocalData];
        
        TableTab *tab = [self currentTab];
        [self clickTab:tab.tabID];
    });
    
    PPDebug(@"viewDidAppear");
    [self.dataTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cleanDataBeforeRemoveView
{
    self.view.hidden = YES;
}

- (void)initListWithLocalData
{
    NSArray* list = [[FeedService defaultService] getCachedFeedList:_feedType
                                                            classId:self.opusClassInfo.classId];
    PPDebug(@"<initListWithLocalData> list count = %d", [list count]);
    if ([list count] != 0) {
        [self.tabDataList addObjectsFromArray:list];
    }
}

- (void)showCachedFeedList:(int)tabID
{
    NSArray *feedList = [[FeedService defaultService] getCachedFeedList:_feedType
                                                                classId:_opusClassInfo.classId];
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
            return [CellManager getHotStyleCellHeightWithIndexPath:indexPath];
            
        case FEED_DISPLAY_PRIZE:
            return [CellManager getPrizeStyleTowCellheight];
            
        default:
            return [CellManager getLastStyleCellHeightWithIndexPath:indexPath];
    }
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (_displayStyle){
        case FEED_DISPLAY_BIG3:
            return [CellManager getHotStyleCell:theTableView
                                      indexPath:indexPath
                                       delegate:self
                                       dataList:self.tabDataList];
        case FEED_DISPLAY_PRIZE:
            return [CellManager getPrizeStyleTowCell:theTableView
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
        case FEED_DISPLAY_PRIZE:
            return [CellManager getPrizeStyleTowCellCountWithDataCount:count];
            
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
    sc.feedList = [self tabDataList];
    [self.superViewController.navigationController pushViewController:sc animated:YES];
    [sc release];
}

- (void)showFeed:(DrawFeed *)feed animatedWithTransition:(UIViewAnimationTransition)transition
{
    ShowFeedController *sc = [[ShowFeedController alloc] initWithFeed:feed scene:[UseItemScene createSceneByType:UseSceneTypeShowFeedDetail feed:feed]];
    sc.feedList = [self tabDataList];
    [self.superViewController.navigationController pushViewController:sc animatedWithTransition:transition duration:1];
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
    if (self.feedType == FeedListTypeConquerDrawStageTop){
        return [PPConfigManager getRankOpusCountOnce];
    }
    else{
        return [PPConfigManager getHotOpusCountOnce];
    }
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
                                   tutorialId:_tutorialId
                                      stageId:_stageId
                                       offset:tab.offset
                                        limit:tab.limit
                                     delegate:self];
}

- (NSString *)tabNoDataTipsforIndex:(NSInteger)index
{
    return NSLS(@"kNoOpus");
}



@end
