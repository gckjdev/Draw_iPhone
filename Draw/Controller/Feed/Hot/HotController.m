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
//#import "DrawUserInfoView.h"
#import "UserDetailViewController.h"
#import "ViewUserDetail.h"
#import "UseItemScene.h"
#import "MyFriend.h"
#import "ConfigManager.h"
#import "UserManager.h"
#import "CommonMessageCenter.h"
#import "MKBlockActionSheet.h"
#import "BBSPermissionManager.h"
#import "AddLearnDrawView.h"

typedef enum{

    RankTypePlayer = FeedListTypeTopPlayer,
    RankTypeHistory = FeedListTypeHistoryRank,
    RankTypeHot = FeedListTypeHot,
    RankTypeNew = FeedListTypeLatest,
    RankTypeRecommend = FeedListTypeRecommend,
    
}RankType;

#define  HISTORY_RANK_NUMBER [ConfigManager historyRankNumber]

@interface HotController (){
    RankView* _selectedRankView;
    DrawFeed* _selectedFeed;
}

@end

@implementation HotController
//@synthesize titleLabel = _tipsLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _defaultTabIndex = 2;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    [super dealloc];
}

- (void)showCachedFeedList:(int)tabID
{
    PPDebug(@"<showCachedFeedList> tab id = %d", tabID);
    FeedListType type = [self feedListTypeForTabID:tabID];
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

- (FeedListType)feedListTypeForTabID:(int)tabID
{
    if(tabID == RankTypePlayer){
        return FeedListTypeUnknow;
    }else {
        return tabID;
    }
}

- (void)clickTabButton:(id)sender
{
    int tabID = [(UIButton *)sender tag];
    TableTab *tab = [_tabManager tabForID:tabID];
    if ([tab.dataList count] == 0) {
        [self showCachedFeedList:tabID];
    }
    [super clickTabButton:sender];
    
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];    
    [self initTabButtons];
    [self.titleLabel setText:NSLS(@"kRank")];
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
    NSInteger type = self.currentTab.tabID;
    
    if (type == RankTypeHot || type == RankTypeHistory) {
        if (indexPath.row == 0) {
            return [RankView heightForRankViewType:RankViewTypeFirst]+1;
        }else if(indexPath.row == 1){
            return [RankView heightForRankViewType:RankViewTypeSecond]+1;
        }        
    }
    if (type == RankTypePlayer) {
        return [TopPlayerView getHeight] + 1;
    }
    return [RankView heightForRankViewType:RankViewTypeNormal]+1;
}

- (void)clearCellSubViews:(UITableViewCell *)cell{
    for (UIView *view in cell.contentView.subviews) {
        if ([view isKindOfClass:[RankView class]] || [view isKindOfClass:[TopPlayerView class]]) {
            [view removeFromSuperview];
        }
    }    
}

- (void)setFirstRankCell:(UITableViewCell *)cell WithFeed:(DrawFeed *)feed
{
    RankView *view = [RankView createRankView:self type:RankViewTypeFirst];
    [view setViewInfo:feed];
    [cell.contentView addSubview:view];
}

#define NORMAL_CELL_VIEW_NUMBER 3
#define WIDTH_SPACE 1

- (void)setSencodRankCell:(UITableViewCell *)cell 
                WithFeed1:(DrawFeed *)feed1 
                    feed2:(DrawFeed *)feed2
{
    RankView *view1 = [RankView createRankView:self type:RankViewTypeSecond];
    [view1 setViewInfo:feed1];
    RankView *view2 = [RankView createRankView:self type:RankViewTypeSecond];
    [view2 setViewInfo:feed2];
    [cell.contentView addSubview:view1];
    [cell.contentView addSubview:view2];
    
    CGFloat x2 = WIDTH_SPACE + [RankView widthForRankViewType:RankViewTypeSecond];
    view2.frame = CGRectMake(x2, 0, view2.frame.size.width, view2.frame.size.height);
}


- (void)setNormalRankCell:(UITableViewCell *)cell 
                WithFeeds:(NSArray *)feeds
{
    CGFloat width = [RankView widthForRankViewType:RankViewTypeNormal];
    CGFloat height = [RankView heightForRankViewType:RankViewTypeNormal];
    CGFloat space = WIDTH_SPACE;
    CGFloat x = 0;
    CGFloat y = 0;
    for (DrawFeed *feed in feeds) {
        RankView *rankView = [RankView createRankView:self type:RankViewTypeNormal];
        [rankView setViewInfo:feed];
        [cell.contentView addSubview:rankView];
        rankView.frame = CGRectMake(x, y, width, height);
        x += width + space;
    }
}

#define WIDTH_SPACE 1
- (void)setTopPlayerCell:(UITableViewCell *)cell 
             WithPlayers:(NSArray *)players isFirstRow:(BOOL)isFirstRow
{
    CGFloat width = [TopPlayerView getHeight];
    CGFloat height = [TopPlayerView getHeight];//[RankView heightForRankViewType:RankViewTypeNormal];
    CGFloat space = WIDTH_SPACE;;
    CGFloat x = 0;
    CGFloat y = 0;
    NSInteger i = 0;
    for (TopPlayer *player in players) {
        TopPlayerView *playerView = [TopPlayerView createTopPlayerView:self];
        [playerView setViewInfo:player];
        if (isFirstRow) {
            [playerView setRankFlag:i++];
        }
        [cell.contentView addSubview:playerView];
        playerView.frame = CGRectMake(x, y, width, height);
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

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    NSString *CellIdentifier = @"RankCell";//[RankFirstCell getCellIdentifier];
    UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }else{
        [self clearCellSubViews:cell];
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    TableTab *tab = [self currentTab];
    if (tab.tabID == RankTypeHot || tab.tabID == RankTypeHistory) {
        if (indexPath.row == 0) {
            DrawFeed *feed = (DrawFeed *)[self saveGetObjectForIndex:0];  
            [self setFirstRankCell:cell WithFeed:feed];
        }else if(indexPath.row == 1){
            DrawFeed *feed1 = (DrawFeed *)[self saveGetObjectForIndex:1];  
            DrawFeed *feed2 = (DrawFeed *)[self saveGetObjectForIndex:2];            
            [self setSencodRankCell:cell WithFeed1:feed1 feed2:feed2];
        }else{
            NSInteger startIndex = ((indexPath.row - 1) * NORMAL_CELL_VIEW_NUMBER);
            NSMutableArray *list = [NSMutableArray array];
            for (NSInteger i = startIndex; i < startIndex+NORMAL_CELL_VIEW_NUMBER; ++ i) {
                NSObject *object = [self saveGetObjectForIndex:i];
                if (object) {
                    [list addObject:object];
                }
            }
//            PPDebug(@"startIndex = %d,list count = %d",startIndex,[list count]);
            [self setNormalRankCell:cell WithFeeds:list];
        }        
    }else if(tab.tabID == RankTypeNew){
        NSInteger startIndex = (indexPath.row * NORMAL_CELL_VIEW_NUMBER);
        NSMutableArray *list = [NSMutableArray array];
//        PPDebug(@"startIndex = %d",startIndex);
        for (NSInteger i = startIndex; i < startIndex+NORMAL_CELL_VIEW_NUMBER; ++ i) {
            NSObject *object = [self saveGetObjectForIndex:i];
            if (object) {
                [list addObject:object];
            }
        }
        [self setNormalRankCell:cell WithFeeds:list];
        
    }else if(tab.tabID == RankTypePlayer){
        NSInteger startIndex = (indexPath.row * NORMAL_CELL_VIEW_NUMBER);
        NSMutableArray *list = [NSMutableArray array];
//        PPDebug(@"startIndex = %d",startIndex);
        for (NSInteger i = startIndex; i < startIndex+NORMAL_CELL_VIEW_NUMBER; ++ i) {
            NSObject *object = [self saveGetObjectForIndex:i];
            if (object) {
                [list addObject:object];
            }
        }
        [self setTopPlayerCell:cell WithPlayers:list isFirstRow:(indexPath.row == 0)];
    }else if(tab.tabID == RankTypeRecommend){
        NSInteger startIndex = (indexPath.row * NORMAL_CELL_VIEW_NUMBER);
        NSMutableArray *list = [NSMutableArray array];
        //        PPDebug(@"startIndex = %d",startIndex);
        for (NSInteger i = startIndex; i < startIndex+NORMAL_CELL_VIEW_NUMBER; ++ i) {
            NSObject *object = [self saveGetObjectForIndex:i];
            if (object) {
                [list addObject:object];
            }
        }
        [self setNormalRankCell:cell WithFeeds:list];
        
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = [super tableView:tableView numberOfRowsInSection:section];
    
    NSInteger type = self.currentTab.tabID;
    if (type == RankTypeHistory || type == RankTypePlayer || type == RankTypeHot) {
        if (HISTORY_RANK_NUMBER <= count) {
            self.noMoreData = YES;            
        }
    }
    switch (type) {
        case RankTypeHot:
        case RankTypeHistory:
            if (count <= 1) {
                return count;
            }else if(count <= 3){
                return 2;
            }else{
                if (count %3 == 0) {
                    return count/3 + 1;
                }else{
                    return count / 3 + 2;
                }
            }
        default:
            if (count %3 == 0) {
                return count/3;
            }else{
                return count/3 + 1;
            }
    }
}


#pragma mark common tab controller

- (NSInteger)tabCount
{
    return 5;
}
- (NSInteger)fetchDataLimitForTabIndex:(NSInteger)index
{
    return [ConfigManager getHotOpusCountOnce];
}
- (NSInteger)tabIDforIndex:(NSInteger)index
{
    NSInteger tabId[] = {RankTypePlayer,RankTypeHistory,RankTypeHot,RankTypeNew, RankTypeRecommend};
    return tabId[index];
}

- (NSString *)tabNoDataTipsforIndex:(NSInteger)index
{
    NSString *tabDesc[] = {NSLS(@"kNoRankPlayer"),NSLS(@"kNoRankHistory"),NSLS(@"kNoRankHot"),NSLS(@"kNoRankNew"), NSLS(@"kNoRecommend")};
    
    return tabDesc[index];
}

- (NSString *)tabTitleforIndex:(NSInteger)index
{
    NSString *tabTitle[] = {NSLS(@"kPainter"),NSLS(@"kRankHistory"),NSLS(@"kRankHot"),NSLS(@"kRankNew"), NSLS(@"kLittleGeeRecommend")};
    
    return tabTitle[index];

}

- (void)serviceLoadDataForTabID:(NSInteger)tabID
{
    
    [self showActivityWithText:NSLS(@"kLoading")];
    TableTab *tab = [_tabManager tabForID:tabID];
    if (tab) {
        if (tabID == RankTypeNew) {
            [[FeedService defaultService] getFeedList:FeedListTypeLatest offset:tab.offset limit:tab.limit delegate:self];        
        }else if(tabID == RankTypePlayer){
            [[UserService defaultService] getTopPlayerByScore:tab.offset limit:tab.limit delegate:self];
        }else {
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
//        for (DrawFeed *feed in feedList) {
//            PPDebug(@"%d: feedId = %@, word = %@", i++, feed.feedId,feed.wordText);
//        }
        [self finishLoadDataForTabID:type resultList:feedList];
    }else{
        [self failLoadDataForTabID:type];
    }
}

- (void)didGetTopPlayerList:(NSArray *)playerList 
                 resultCode:(NSInteger)resultCode
{
    PPDebug(@"<didGetTopPlayerList> list count = %d ", [playerList count]);
    [self hideActivity];
    if (resultCode == 0) {
        [self finishLoadDataForTabID:RankTypePlayer resultList:playerList];
    }else{
        [self failLoadDataForTabID:RankTypePlayer];
    }
}

#pragma mark Rank View delegate

- (void)showFeed:(DrawFeed *)feed
{
    ShowFeedController *sc = [[ShowFeedController alloc] initWithFeed:feed scene:[UseItemScene createSceneByType:UseSceneTypeShowFeedDetail feed:feed]];
    [self.navigationController pushViewController:sc animated:YES];
    [sc release];

}

- (void)didClickRankView:(RankView *)rankView
{

    if (!isLearnDrawApp() || ![[BBSPermissionManager defaultManager] canPutDrawOnCell]) {
        [self showFeed:rankView.feed];
    }else{
        MKBlockActionSheet *sheet = [[MKBlockActionSheet alloc]
                                     initWithTitle:[NSString stringWithFormat:@"%@<警告！你正在使用超级管理权限>", NSLS(@"kOpusOperation")]
                                     delegate:nil
                                     cancelButtonTitle:NSLS(@"kCancel")
                                     destructiveButtonTitle:NSLS(@"kOpusDetail")
                                     otherButtonTitles:NSLS(@"kAddLearnDraw"), nil];
        
        __block HotController *cp = self;
        
        [sheet setActionBlock:^(NSInteger buttonIndex){
            PPDebug(@"click button index = %d", buttonIndex);
            if (buttonIndex == 0) {
                [cp showFeed:rankView.feed];
            }else if(buttonIndex == 1){
                AddLearnDrawView* alView = [AddLearnDrawView createViewWithOpusId:rankView.feed.feedId];
                [alView showInView:cp.view];
            }

        }];
        
        [sheet showInView:self.view];
        [sheet release];
        
    }
    
}


- (void)didClickTopPlayerView:(TopPlayerView *)topPlayerView
{
    TopPlayer *player = topPlayerView.topPlayer;
    
    [UserDetailViewController presentUserDetail:[ViewUserDetail viewUserDetailWithUserId:player.userId avatar:player.avatar nickName:player.nickName] inViewController:self];
}

@end
