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
#import "OpusClassInfoManager.h"
#import "ShowOpusClassListController.h"

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

- (id)initWithOpusClass:(OpusClassInfo*)opusClassInfo
{
    self = [self init];
    if (self){
        _defaultTabIndex = 1;   // default is hot top
        self.opusClassInfo = opusClassInfo;
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
    PPRelease(_opusClassInfo);
    PPRelease(_hotRankSettingButton);
    [super dealloc];
}

- (void)showCachedFeedList:(int)tabID
{
    FeedListType type = tabID;
    if (type != FeedListTypeUnknow) {
        if (_opusClassInfo){
            type = [self getFeedTypeForOpusClass:type];
        }
        
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
    if (tab == nil){
        PPDebug(@"<clickTabButton> but tab not found");
        return;
    }
    
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
    
    NSString* defaultTitle = isDrawApp() ? NSLS(@"kRank") : NSLS(@"kSingTop");
    NSString* title = _opusClassInfo ? _opusClassInfo.name : defaultTitle;
    self.titleView = [CommonTitleView createTitleView:self.view];
    
    [self.titleView setTitle:title];
    [self.titleView setRightButtonAsRefresh];
    [self.titleView setTarget:self];
    [self.titleView setBackButtonSelector:@selector(clickBackButton:)];
    [self.titleView setRightButtonSelector:@selector(clickRefreshButton:)];
    
    
#ifdef DEBUG
    [self.titleView setRightButtonTitle:NSLS(@"kSetCategory")];
    [self.titleView setRightButtonSelector:@selector(clickSelectCategory:)];
#endif
    
    SET_COMMON_TAB_TABLE_VIEW_Y(self.dataTableView);
    CGFloat height = CGRectGetMaxY(self.view.bounds) - CGRectGetMinY(self.dataTableView.frame);
    [self.dataTableView updateHeight:height];

    CGRect rect = [self.titleView rectFromButtonBeforeRightButton];
    [_hotRankSettingButton setFrame:rect];
    [_hotRankSettingButton setBackgroundImage:[[ShareImageManager defaultManager] changeHotTopImage]
                                     forState:UIControlStateNormal];
    
    PPDebug(@"HotController viewDidLoad done!");
 
}

- (void)clickSelectCategory:(id)sender
{
    ShowOpusClassListController* vc = [[ShowOpusClassListController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
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
    [self.hotRankSettingButton setHidden:YES];
    [self.titleView setRightButtonAsRefresh];
    [self.titleView setRightButtonSelector:@selector(clickRefreshButton:)];
    
#ifdef DEBUG
    [self.titleView setRightButtonTitle:NSLS(@"kSetCategory")];
    [self.titleView setRightButtonSelector:@selector(clickSelectCategory:)];
#endif
}

- (void)viewDidUnload
{
    [super viewDidUnload];
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
}

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

static NSInteger tabIdForOpusClass[] = {RankTypeHistory, RankTypeHot, RankTypeNew};
static NSInteger tabIdForNormal[] = {RankTypeHistory, RankTypeHot, RankTypeRecommend, RankTypeNew, RankTypeVIP};



- (NSInteger)tabCount
{
    if (_opusClassInfo){
        return sizeof(tabIdForOpusClass)/sizeof(NSInteger);
    }
    else{
        return sizeof(tabIdForNormal)/sizeof(NSInteger);
    }
}
- (NSInteger)fetchDataLimitForTabIndex:(NSInteger)index
{
    return [PPConfigManager getHotOpusCountOnce];
}
- (NSInteger)tabIDforIndex:(NSInteger)index
{
    if (_opusClassInfo){
        return tabIdForOpusClass[index];
    }
    else{
//        NSInteger tabId[] = {RankTypeHistory, RankTypeHot, RankTypeRecommend, RankTypeNew, RankTypeVIP};
        return tabIdForNormal[index];
    }
}

- (NSString *)tabNoDataTipsforIndex:(NSInteger)index
{
    NSString *tabDescOpusClass[] = { NSLS(@"kNoRankHistory"),NSLS(@"kNoRankHot"), NSLS(@"kNoRankNew")};
    NSString *tabDescNormal[] = {NSLS(@"kNoRankHistory"),NSLS(@"kNoRankHot"), NSLS(@"kNoRecommend"),NSLS(@"kNoRankNew"),NSLS(@"kNoRankVip")};
    
    if (_opusClassInfo){
        return tabDescOpusClass[index];
    }
    else{
        return tabDescNormal[index];
    }
}

- (NSString *)tabTitleforIndex:(NSInteger)index
{
    NSString *tabTitleOpusClass[] = {NSLS(@"kRankHistory"),NSLS(@"kRankHot"), NSLS(@"kRankNew")};
    NSString *tabTitle[] = {NSLS(@"kRankHistory"),NSLS(@"kRankHot"), NSLS(@"kLittleGeeRecommend"),NSLS(@"kRankNew"),NSLS(@"kRankVip")};
    
    if (_opusClassInfo){
        return tabTitleOpusClass[index];
    }
    else{
        return tabTitle[index];
    }

}

- (int)getFeedTypeForOpusClass:(int)tabID
{
    switch (tabID){
        case RankTypeNew:
            return FeedListTypeClassLatest;
        case RankTypeRecommend:
            return FeedListTypeClassFeature;
        case RankTypeHistory:
            return FeedListTypeClassAlltimeTop;
        case RankTypeHot:
        default:
            return FeedListTypeClassHotTop;
    }
}

- (int)getTabIDByType:(int)type
{
    switch (type){
        case FeedListTypeClassLatest:
            return RankTypeNew;
        case FeedListTypeClassFeature:
            return RankTypeRecommend;
        case FeedListTypeClassAlltimeTop:
            return RankTypeHistory;
        case FeedListTypeClassHotTop:
        default:
            return RankTypeHot;
    }
}

- (void)serviceLoadDataForTabID:(NSInteger)tabID
{
    TableTab *tab = [_tabManager tabForID:tabID];
    if (tab) {
        [self showActivityWithText:NSLS(@"kLoading")];
        if (_opusClassInfo){
            int feedType = [self getFeedTypeForOpusClass:tabID];
            [[FeedService defaultService] getFeedList:feedType classId:_opusClassInfo.classId offset:tab.offset limit:tab.limit delegate:self];
        }
        else{
            if (tabID == RankTypeNew) {
                [[FeedService defaultService] getFeedList:FeedListTypeLatest classId:_opusClassInfo.classId offset:tab.offset limit:tab.limit delegate:self];
            }
            else {
                [[FeedService defaultService] getFeedList:tabID classId:_opusClassInfo.classId  offset:tab.offset limit:tab.limit delegate:self];
            }
        }
    }
    else{
        PPDebug(@"<serviceLoadDataForTabID> but tab not found");
        return;
    }
}


#pragma mark - feed service delegate

- (void)didGetFeedList:(NSArray *)feedList 
          feedListType:(FeedListType)type 
            resultCode:(NSInteger)resultCode
{
    PPDebug(@"<didGetFeedList> list count = %d ", [feedList count]);
    
    int tabID = type;
    if (_opusClassInfo){
        tabID = [self getTabIDByType:type];
    }
    
    [self hideActivity];
    if (resultCode == 0) {
        [self finishLoadDataForTabID:tabID resultList:feedList];
    }else{
        [self failLoadDataForTabID:tabID];
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
