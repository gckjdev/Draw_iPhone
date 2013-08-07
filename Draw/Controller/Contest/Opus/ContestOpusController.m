//
//  HotController.m
//  Draw
//
//  Created by  on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ContestOpusController.h"
#import "TableTabManager.h"
#import "ShareImageManager.h"
#import "ShowFeedController.h"
//#import "DrawUserInfoView.h"
#import "UserDetailViewController.h"
#import "ViewUserDetail.h"
#import "Contest.h"
#import "UseItemScene.h"
#import "MyFriend.h"

typedef enum{
    OpusTypeMy = 1,
    OpusTypeRank = 2,
    OpusTypeNew = 3,
}OpusType;

#define  HISTORY_RANK_NUMBER 120

@implementation ContestOpusController
@synthesize contest = _contest;

- (id)initWithContest:(Contest *)contest
{
    self = [super init];
    if(self){
        self.contest = contest;
        _defaultTabIndex = 1;
    }
    return self;
}

//@synthesize titleLabel = _tipsLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];    
    [self initTabButtons];
    [self.titleLabel setText:NSLS(@"kContestRank")];
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
    
    if (type == OpusTypeRank) {
        if (indexPath.row == 0) {
            return [RankView heightForRankViewType:RankViewTypeFirst]+1;
        }else if(indexPath.row == 1){
            return [RankView heightForRankViewType:RankViewTypeSecond]+1;
        }        
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
    [view.cupFlag setImage:[ShareImageManager defaultManager].goldenCupImage];
    view.cupFlag.hidden = NO;
    [cell.contentView addSubview:view];
    [view updateViewInfoForContestOpus];
    [view.title setHidden:YES];
}

#define NORMAL_CELL_VIEW_NUMBER 3
#define WIDTH_SPACE 1

- (void)setSencodRankCell:(UITableViewCell *)cell 
                WithFeed1:(DrawFeed *)feed1 
                    feed2:(DrawFeed *)feed2
{
    RankView *view1 = [RankView createRankView:self type:RankViewTypeSecond];
    [view1 setViewInfo:feed1];
    [view1.cupFlag setImage:[ShareImageManager defaultManager].silverCupImage];
    view1.cupFlag.hidden = NO;
    RankView *view2 = [RankView createRankView:self type:RankViewTypeSecond];
    [view2 setViewInfo:feed2];
    [view2.cupFlag setImage:[ShareImageManager defaultManager].copperCupImage];
    view2.cupFlag.hidden = NO;
    [view1 updateViewInfoForContestOpus];
    [view2 updateViewInfoForContestOpus];
    [cell.contentView addSubview:view1];
    [cell.contentView addSubview:view2];
    
    CGFloat x2 = WIDTH_SPACE + [RankView widthForRankViewType:RankViewTypeSecond];
    view2.frame = CGRectMake(x2, 0, view2.frame.size.width, view2.frame.size.height);
    [view1.title setHidden:YES];
    [view2.title setHidden:YES];
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
        [rankView updateViewInfoForContestOpus];
        [rankView.title setHidden:YES];
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
//    NSInteger i = 0;
    for (TopPlayer *player in players) {
        TopPlayerView *playerView = [TopPlayerView createTopPlayerView:self];
        [playerView setViewInfo:player];
//        if (isFirstRow) {
//            [playerView setRankFlag:i++];
//        }
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
    if (tab.tabID == OpusTypeRank) {
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
    }else {
        NSInteger startIndex = (indexPath.row * NORMAL_CELL_VIEW_NUMBER);
        NSMutableArray *list = [NSMutableArray array];
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
    if (type == OpusTypeRank) {
        if (HISTORY_RANK_NUMBER <= count) {
            self.noMoreData = YES;            
        }
    }
    switch (type) {
        case OpusTypeRank:
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
    return 3;
}
- (NSInteger)fetchDataLimitForTabIndex:(NSInteger)index
{
    return 24;
}
- (NSInteger)tabIDforIndex:(NSInteger)index
{
    NSInteger tabId[] = {OpusTypeMy,OpusTypeRank,OpusTypeNew};
    return tabId[index];
}

- (NSString *)tabNoDataTipsforIndex:(NSInteger)index
{
    return NSLS(@"kNoData");
}

- (NSString *)tabTitleforIndex:(NSInteger)index
{
    NSString *tabTitle[] = {NSLS(@"kOpusMy"),NSLS(@"kOpusRank"),NSLS(@"kOpusNew")};
    return tabTitle[index];

}

- (void)serviceLoadDataForTabID:(NSInteger)tabID
{
    
    [self showActivityWithText:NSLS(@"kLoading")];
    TableTab *tab = [_tabManager tabForID:tabID];
    if (tab) {
        [[FeedService defaultService] getContestOpusList:tabID 
                                               contestId:self.contest.contestId
                                                  offset:tab.offset
                                                   limit:tab.limit
                                                delegate:self];
    }
}

#pragma mark - feed service delegate

- (void)didGetContestOpusList:(NSArray *)feedList 
                         type:(int)type 
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
- (void)didClickRankView:(RankView *)rankView
{
    UseItemScene* scene ;
    if ([self.contest isRunning]) {
        scene = [UseItemScene createSceneByType:UseSceneTypeDrawMatch feed:rankView.feed];
    } else {
        scene = [UseItemScene createSceneByType:UseSceneTypeMatchRank feed:rankView.feed];
    }
    ShowFeedController *sc = [[ShowFeedController alloc] initWithFeed:rankView.feed scene:scene];
    sc.feedList = [[self currentTab] dataList];
    [self.navigationController pushViewController:sc animated:YES];
    [sc release];
}


- (void)didClickTopPlayerView:(TopPlayerView *)topPlayerView
{
    TopPlayer *player = topPlayerView.topPlayer;
//    NSString* genderString = player.gender?@"m":@"f";
//    MyFriend *friend = [MyFriend friendWithFid:player.userId
//                                      nickName:player.nickName
//                                        avatar:player.avatar
//                                        gender:genderString
//                                         level:1];
//    UserDetailViewController* uc = [[[UserDetailViewController alloc] initWithUserDetail:[ViewUserDetail viewUserDetailWithUserId:player.userId avatar:player.avatar nickName:player.nickName]] autorelease];
//    [self.navigationController pushViewController:uc animated:YES];
    [UserDetailViewController presentUserDetail:[ViewUserDetail viewUserDetailWithUserId:player.userId avatar:player.avatar nickName:player.nickName] inViewController:self];
}

@end
