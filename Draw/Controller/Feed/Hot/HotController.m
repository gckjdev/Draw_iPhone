//
//  HotController.m
//  Draw
//
//  Created by  on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

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

typedef enum{

    RankTypeHistory = FeedListTypeHistoryRank,
    RankTypeHot = FeedListTypeHot,
    RankTypeNew = FeedListTypeLatest,
    RankTypeRecommend = FeedListTypeRecommend,
    RankTypeVIP = FeedListTypeVIP,
    
}RankType;


@interface HotController (){
    RankView* _selectedRankView;
    DrawFeed* _selectedFeed;
}

@end

@implementation HotController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        HotIndexType index = [[UserManager defaultManager] hotControllerIndex];
        if (index == HotLatestIndex){
            _defaultTabIndex = 3;
        }
        else if (index == HotTopIndex){
            _defaultTabIndex = 1;
        }
        else{
            _defaultTabIndex = 1;            
        }
        
    }
    return self;
}


- (IBAction)clickSetHot:(id)sender
{
    MKBlockActionSheet *sheet = nil;
    sheet = [[MKBlockActionSheet alloc] initWithTitle:NSLS(@"kHotOption")
                                             delegate:nil
                                    cancelButtonTitle:NSLS(@"kCancel")
                               destructiveButtonTitle:NSLS(@"kSetHotOption")
                                    otherButtonTitles:NSLS(@"kSetLatestOption"), nil];

    HotIndexType index = [[UserManager defaultManager] hotControllerIndex];
    if (index == HotLatestIndex){
        [sheet setDestructiveButtonIndex:1];
    }
    else if (index == HotLatestIndex){
        [sheet setDestructiveButtonIndex:0];
    }
    
    [sheet setActionBlock:^(NSInteger buttonIndex){
        switch (buttonIndex){
            case 0:
                [[UserManager defaultManager] setHotControllerIndex:HotTopIndex];
                POSTMSG(NSLS(@"kSetSuccess"));
                break;
            case 1:
                [[UserManager defaultManager] setHotControllerIndex:HotLatestIndex];
                POSTMSG(NSLS(@"kSetSuccess"));
                break;
            default:
                break;
        }
    }];

    [sheet showInView:self.view];
    [sheet release];
    
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    PPRelease(_hotRankSettingButton);
    [super dealloc];
}

- (void)showCachedFeedList:(int)tabID
{
    FeedListType type = tabID;
    if (type != FeedListTypeUnknow) {
        NSArray *feedList = [[FeedService defaultService] getCachedFeedList:type];
        if ([feedList count] != 0) {
            [self finishLoadDataForTabID:tabID resultList:feedList];
        }        
    }
    TableTab *tab = [_tabManager tabForID:tabID];
    tab.status = TableTabStatusUnload;
    tab.offset = 0;
}

- (void)clickTabButton:(id)sender
{
    int tabID = [(UIButton *)sender tag];
    TableTab *tab = [_tabManager tabForID:tabID];
    if ([tab.dataList count] == 0) {
        [self showCachedFeedList:tabID];
    }
    if (tabID == RankTypeVIP && ![[UserManager defaultManager] isVip]) {
        [self setRightButtonVipInfo];
    }else{
        [self setRightButtonRefresh];
    }
    [super clickTabButton:sender];
    
}


#pragma mark - View lifecycle

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    PPDebug(@"HotController viewDidAppear done");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    PPDebug(@"HotController viewDidLoad");
    
    PPDebug(@"initTabButtons");
    [self initTabButtons];
    PPDebug(@"initTabButtons done!");
    
    NSString* title = isDrawApp() ? NSLS(@"kRank") : NSLS(@"kSingTop");
    self.titleView = [CommonTitleView createTitleView:self.view];
    
    [self.titleView setTitle:title];
    [self.titleView setRightButtonAsRefresh];
    [self.titleView setTarget:self];
    [self.titleView setBackButtonSelector:@selector(clickBackButton:)];
    [self.titleView setRightButtonSelector:@selector(clickRefreshButton:)];
    
    SET_COMMON_TAB_TABLE_VIEW_Y(self.dataTableView);
    CGFloat height = CGRectGetMaxY(self.view.bounds) - CGRectGetMinY(self.dataTableView.frame);
    [self.dataTableView updateHeight:height];

    CGRect rect = [self.titleView rectFromButtonBeforeRightButton];
    [_hotRankSettingButton setFrame:rect];
    [_hotRankSettingButton setBackgroundImage:[[ShareImageManager defaultManager] changeHotTopImage]
                                     forState:UIControlStateNormal];
    
    PPDebug(@"HotController viewDidLoad done!");
 
}


- (void)clickVipInfo:(id)sender
{
    [PurchaseVipController enter:self];
}

- (void)setRightButtonVipInfo
{
    [self.titleView setRightButtonTitle:NSLS(@"kUpgradeVIP")];
    [self.titleView setRightButtonSelector:@selector(clickVipInfo:)];
    [self.hotRankSettingButton setHidden:YES];
}

- (void)setRightButtonRefresh
{
    [self.hotRankSettingButton setHidden:NO];
    [self.titleView setRightButtonAsRefresh];
    [self.titleView setRightButtonSelector:@selector(clickRefreshButton:)];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ([[self currentTab] tabID]) {
            
        case RankTypeHistory:
        case RankTypeHot:
            return [CellManager getHotStyleCellHeightWithIndexPath:indexPath];
            break;
            
        case RankTypeRecommend:
        case RankTypeNew:
        default:
            return [CellManager getLastStyleCellHeightWithIndexPath:indexPath];
    }
    
//    if (isSingApp()){
//        return [SingHotCell getCellHeight];
//    }
//    
//    NSInteger type = self.currentTab.tabID;
//    
//    if (type == RankTypeHot || type == RankTypeHistory) {
//        
//        if (isDrawApp() || isLittleGeeAPP()) {
//            if (indexPath.row == 0) {
//                return [RankView heightForRankViewType:RankViewTypeFirst]+1;
//            }else if(indexPath.row == 1){
//                return [RankView heightForRankViewType:RankViewTypeSecond]+1;
//            }
//        }
//    }
//        
//    return [RankView heightForRankViewType:RankViewTypeNormal]+1;
}

//- (void)clearCellSubViews:(UITableViewCell *)cell{
//    for (UIView *view in cell.contentView.subviews) {
//        if ([view isKindOfClass:[RankView class]]) {
//            [view removeFromSuperview];
//        }
//    }    
//}

//- (void)setFirstRankCell:(UITableViewCell *)cell WithFeed:(DrawFeed *)feed
//{
//    RankView *view = [RankView createRankView:self type:RankViewTypeFirst];
//    [view setViewInfo:feed];
//    [cell.contentView addSubview:view];
//}

//#define NORMAL_CELL_VIEW_NUMBER 3

//#define WIDTH_SPACE 1

//- (void)setSencodRankCell:(UITableViewCell *)cell
//                WithFeed1:(DrawFeed *)feed1 
//                    feed2:(DrawFeed *)feed2
//{
//    RankView *view1 = [RankView createRankView:self type:RankViewTypeSecond];
//    [view1 setViewInfo:feed1];
//    RankView *view2 = [RankView createRankView:self type:RankViewTypeSecond];
//    [view2 setViewInfo:feed2];
//    [cell.contentView addSubview:view1];
//    [cell.contentView addSubview:view2];
//    
//    CGFloat x2 = WIDTH_SPACE + [RankView widthForRankViewType:RankViewTypeSecond];
//    view2.frame = CGRectMake(x2, 0, view2.frame.size.width, view2.frame.size.height);
//}


//- (void)setNormalRankCell:(UITableViewCell *)cell 
//                WithFeeds:(NSArray *)feeds
//{
//    CGFloat width = [RankView widthForRankViewType:RankViewTypeNormal];
//    CGFloat height = [RankView heightForRankViewType:RankViewTypeNormal];
//    CGFloat space = WIDTH_SPACE;
//    CGFloat x = 0;
//    CGFloat y = 0;
//    for (DrawFeed *feed in feeds) {
//        RankView *rankView = [RankView createRankView:self type:RankViewTypeNormal];
//        [rankView setViewInfo:feed];
//        [cell.contentView addSubview:rankView];
//        rankView.frame = CGRectMake(x, y, width, height);
//        x += width + space;
//    }
//}

//#define WIDTH_SPACE 1
//- (void)setTopPlayerCell:(UITableViewCell *)cell
//             WithPlayers:(NSArray *)players isFirstRow:(BOOL)isFirstRow
//{
//    CGFloat width = [TopPlayerView getHeight];
//    CGFloat height = [TopPlayerView getHeight];
//    CGFloat space = WIDTH_SPACE;;
//    CGFloat x = 0;
//    CGFloat y = 0;
//    for (TopPlayer *player in players) {
//        TopPlayerView *playerView = [TopPlayerView createTopPlayerView:self];
//        [playerView setViewInfo:player];
//
//        [cell.contentView addSubview:playerView];
//        playerView.frame = CGRectMake(x, y, width, height);
//        x += width + space;
//    }
//}

//- (NSObject *)saveGetObjectForIndex:(NSInteger)index
//{
//    NSArray *list = [self tabDataList];
//    if (index < 0 || index >= [list count]) {
//        return nil;
//    }
//    return [list objectAtIndex:index];
//}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch ([[self currentTab] tabID]) {
            
        case RankTypeHistory:
        case RankTypeHot:
            return [CellManager getHotStyleCell:theTableView
                                      indexPath:indexPath
                                       delegate:self
                                       dataList:[self tabDataList]];
            break;
            
        case RankTypeRecommend:
        case RankTypeNew:
        default:
            return [CellManager getLastStyleCell:theTableView
                                       indexPath:indexPath
                                        delegate:self
                                        dataList:[self tabDataList]];
            break;
    }
    
//    if (isSingApp()) {
//        
//        return [CellManager getHotStyleCell:theTableView
//                                  indexPath:indexPath
//                                   delegate:self
//                                   dataList:[self tabDataList]];
//    }
//    
//    
//    NSString *CellIdentifier = @"RankCell";//[RankFirstCell getCellIdentifier];
//    UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    
//    if (cell == nil) {
//        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
//    }else{
//        [self clearCellSubViews:cell];
//    }
//
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    cell.accessoryType = UITableViewCellAccessoryNone;
//    TableTab *tab = [self currentTab];
//    
//    if (isDrawApp() || isLittleGeeAPP()) {
//        
//        if (tab.tabID == RankTypeHot || tab.tabID == RankTypeHistory) {
//            
//            if (indexPath.row == 0) {
//                DrawFeed *feed = (DrawFeed *)[self saveGetObjectForIndex:0];
//                [self setFirstRankCell:cell WithFeed:feed];
//            }else if(indexPath.row == 1){
//                DrawFeed *feed1 = (DrawFeed *)[self saveGetObjectForIndex:1];
//                DrawFeed *feed2 = (DrawFeed *)[self saveGetObjectForIndex:2];
//                [self setSencodRankCell:cell WithFeed1:feed1 feed2:feed2];
//            }else{
////                NSMutableArray *list = [NSMutableArray array];
////                for (NSInteger i = startIndex; i < startIndex+NORMAL_CELL_VIEW_NUMBER; ++ i) {
////                    NSObject *object = [self saveGetObjectForIndex:i];
////                    if (object) {
////                        [list addObject:object];
////                    }
////                }
//                
//                NSInteger startIndex = (indexPath.row - 1) * NORMAL_CELL_VIEW_NUMBER;
//                NSArray *list = [[self tabDataList] subarrayWithRangeSafe:NSMakeRange(startIndex, NORMAL_CELL_VIEW_NUMBER)];
//                [self setNormalRankCell:cell WithFeeds:list];
//            }
//            
//        }else if(tab.tabID == RankTypeNew){
////            NSInteger startIndex = (indexPath.row * NORMAL_CELL_VIEW_NUMBER);
////            NSMutableArray *list = [NSMutableArray array];
////            for (NSInteger i = startIndex; i < startIndex+NORMAL_CELL_VIEW_NUMBER; ++ i) {
////                NSObject *object = [self saveGetObjectForIndex:i];
////                if (object) {
////                    [list addObject:object];
////                }
////            }
////            [self setNormalRankCell:cell WithFeeds:list];
//            
//            
//            NSInteger startIndex = indexPath.row * NORMAL_CELL_VIEW_NUMBER;
//            NSArray *list = [[self tabDataList] subarrayWithRangeSafe:NSMakeRange(startIndex, NORMAL_CELL_VIEW_NUMBER)];
//            [self setNormalRankCell:cell WithFeeds:list];
//            
//        }
////        else if(tab.tabID == RankTypePlayer){
////            NSInteger startIndex = (indexPath.row * NORMAL_CELL_VIEW_NUMBER);
////            NSMutableArray *list = [NSMutableArray array];
////            for (NSInteger i = startIndex; i < startIndex+NORMAL_CELL_VIEW_NUMBER; ++ i) {
////                NSObject *object = [self saveGetObjectForIndex:i];
////                if (object) {
////                    [list addObject:object];
////                }
////            }
////            [self setTopPlayerCell:cell WithPlayers:list isFirstRow:(indexPath.row == 0)];
////        }
//        else if(tab.tabID == RankTypeRecommend){
////            NSInteger startIndex = (indexPath.row * NORMAL_CELL_VIEW_NUMBER);
////            NSMutableArray *list = [NSMutableArray array];
////            for (NSInteger i = startIndex; i < startIndex+NORMAL_CELL_VIEW_NUMBER; ++ i) {
////                NSObject *object = [self saveGetObjectForIndex:i];
////                if (object) {
////                    [list addObject:object];
////                }
////            }
//            
//            NSInteger startIndex = indexPath.row * NORMAL_CELL_VIEW_NUMBER;
//            NSArray *list = [[self tabDataList] subarrayWithRangeSafe:NSMakeRange(startIndex, NORMAL_CELL_VIEW_NUMBER)];
//            [self setNormalRankCell:cell WithFeeds:list];
//        }
//    }
//    
//    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = [super tableView:tableView numberOfRowsInSection:section];
    
    switch ([[self currentTab] tabID]) {
        case RankTypeHot:
        case RankTypeHistory:
            return [CellManager getHotStyleCellCountWithDataCount:count
                                                       roundingUp:NO];
            break;
            
        case RankTypeNew:
        case RankTypeRecommend:
        default:
            return [CellManager getLastStyleCellCountWithDataCount:count
                                                        roundingUp:NO];
            break;            
    }
}


#pragma mark common tab controller

- (NSInteger)tabCount
{
    return 5;
}
- (NSInteger)fetchDataLimitForTabIndex:(NSInteger)index
{
    return [PPConfigManager getHotOpusCountOnce];
}
- (NSInteger)tabIDforIndex:(NSInteger)index
{
    NSInteger tabId[] = {RankTypeHistory, RankTypeHot, RankTypeRecommend, RankTypeNew, RankTypeVIP};
    return tabId[index];
}

- (NSString *)tabNoDataTipsforIndex:(NSInteger)index
{
    NSString *tabDesc[] = {NSLS(@"kNoRankHistory"),NSLS(@"kNoRankHot"), NSLS(@"kNoRecommend"),NSLS(@"kNoRankNew"),NSLS(@"kNoRankVip")};
    
    return tabDesc[index];
}

- (NSString *)tabTitleforIndex:(NSInteger)index
{
    NSString *tabTitle[] = {NSLS(@"kRankHistory"),NSLS(@"kRankHot"), NSLS(@"kLittleGeeRecommend"),NSLS(@"kRankNew"),NSLS(@"kRankVip")};
    
    return tabTitle[index];

}

- (void)serviceLoadDataForTabID:(NSInteger)tabID
{
    
    [self showActivityWithText:NSLS(@"kLoading")];
    TableTab *tab = [_tabManager tabForID:tabID];
    if (tab) {
        if (tabID == RankTypeNew) {
            [[FeedService defaultService] getFeedList:FeedListTypeLatest offset:tab.offset limit:tab.limit delegate:self];        
        }
        else {
            [[FeedService defaultService] getFeedList:tabID offset:tab.offset limit:tab.limit delegate:self];        
        }
    }
}


#pragma mark - feed service delegate

- (void)didGetFeedList:(NSArray *)feedList 
          feedListType:(FeedListType)type 
            resultCode:(NSInteger)resultCode
{
    PPDebug(@"<didGetFeedList> list count = %d ", [feedList count]);
    [self hideActivity];
    if (resultCode == 0) {
        [self finishLoadDataForTabID:type resultList:feedList];
    }else{
        [self failLoadDataForTabID:type];
    }
}

#pragma mark Rank View delegate

- (void)showFeed:(DrawFeed *)feed
{
    ShowFeedController *sc = [[ShowFeedController alloc] initWithFeed:feed scene:[UseItemScene createSceneByType:UseSceneTypeShowFeedDetail feed:feed]];
    [sc showOpusImageBrower];
    sc.feedList = [[self currentTab] dataList];
    [self.navigationController pushViewController:sc animated:YES];
    [sc release];
}

- (void)showFeed:(DrawFeed *)feed animatedWithTransition:(UIViewAnimationTransition)transition
{
    ShowFeedController *sc = [[ShowFeedController alloc] initWithFeed:feed scene:[UseItemScene createSceneByType:UseSceneTypeShowFeedDetail feed:feed]];
    sc.feedList = [[self currentTab] dataList];
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

@end
