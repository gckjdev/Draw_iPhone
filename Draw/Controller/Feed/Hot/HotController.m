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

typedef enum{

    RankTypePlayer = 100,
    RankTypeHistory = 101,
    RankTypeHot = 3,
    RankTypeNew = 6,
    
}RankType;

@implementation HotController
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



- (void)initTabButtons
{
    NSArray* tabList = [_tabManager tabList];
    for(TableTab *tab in tabList){
        UIButton *button = (UIButton *)[self.view viewWithTag:tab.tabID];
        ShareImageManager *imageManager = [ShareImageManager defaultManager];
        [button setTitle:tab.title forState:UIControlStateNormal];
        if (tab.tabID == RankTypePlayer) {
            [button setBackgroundImage:[imageManager myFoucsImage] forState:UIButtonTypeCustom];
            [button setBackgroundImage:[imageManager myFoucsSelectedImage] forState:UIControlStateSelected];
        }else if(tab.tabID == RankTypeNew){
            [button setBackgroundImage:[imageManager foucsMeImage] forState:UIButtonTypeCustom];
            [button setBackgroundImage:[imageManager foucsMeSelectedImage] forState:UIControlStateSelected];            
        }else{
            [button setBackgroundImage:[imageManager middleTabImage] forState:UIControlStateNormal];
            [button setBackgroundImage:[imageManager middleTabSelectedImage] forState:UIControlStateSelected];
        }
    }
//    UIButton *tabButton = [self tabButtonWithTabID:RankTypeHot];
    [self clickTabButton:self.currentTabButton];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.currentTab.tabID == RankTypeHot) {
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
        if ([view isKindOfClass:[RankView class]]) {
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
    
    CGFloat x2 = (CGRectGetWidth(cell.frame) -  [RankView widthForRankViewType:RankViewTypeSecond]);
    view2.frame = CGRectMake(x2, 0, view2.frame.size.width, view2.frame.size.height);
}


#define NORMAL_CELL_VIEW_NUMBER 3

- (void)setNormalRankCell:(UITableViewCell *)cell 
                WithFeeds:(NSArray *)feeds
{
    CGFloat width = [RankView widthForRankViewType:RankViewTypeNormal];
    CGFloat height = [RankView heightForRankViewType:RankViewTypeNormal];
    CGFloat space = (cell.frame.size.width - NORMAL_CELL_VIEW_NUMBER * width)/ (NORMAL_CELL_VIEW_NUMBER - 1);
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
    if (tab.tabID == RankTypeHot) {
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
            PPDebug(@"startIndex = %d,list count = %d",startIndex,[list count]);
            [self setNormalRankCell:cell WithFeeds:list];
        }        
    }else if(tab.tabID == RankTypeNew){
        NSInteger startIndex = (indexPath.row * NORMAL_CELL_VIEW_NUMBER);
        NSMutableArray *list = [NSMutableArray array];
        PPDebug(@"startIndex = %d",startIndex);
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
    NSInteger count = [[self tabDataList] count];
    
    
    TableTab *tab = self.currentTab;
    
    if (count == 0 && tab.status == TableTabStatusLoaded) {
        self.tipsLabel.hidden = YES;
    }else{
        self.tipsLabel.hidden = NO;
        [self.tipsLabel setText:tab.noDataDesc];
    }

    
    self.noMoreData = !tab.hasMoreData;
    switch (tab.tabID) {
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
    return 4;
}
- (NSInteger)currentTabIndex
{
    return 2;
}
- (NSInteger)fetchDataLimitForTabIndex:(NSInteger)index
{
    return 24;
}
- (NSInteger)tabIDforIndex:(NSInteger)index
{
    NSInteger tabId[] = {RankTypePlayer,RankTypeHistory,RankTypeHot,RankTypeNew};
    return tabId[index];
}

- (NSString *)tabNoDataTipsforIndex:(NSInteger)index
{
    NSString *tabDesc[] = {NSLS(@"kNoRankPlayer"),NSLS(@"kNoRankHistory"),NSLS(@"kNoRankHot"),NSLS(@"kNoRankNew")};
    
    return tabDesc[index];
}

- (NSString *)tabTitleforIndex:(NSInteger)index
{
    NSString *tabTitle[] = {NSLS(@"kRankPlayer"),NSLS(@"kRankHistory"),NSLS(@"kRankHot"),NSLS(@"kRankNew")};
    
    return tabTitle[index];

}

- (void)serviceLoadDataForTabID:(NSInteger)tabID
{
    
    [self showActivityWithText:NSLS(@"kLoading")];
    TableTab *tab = [_tabManager tabForID:tabID];
    if (tab) {
        
        if (tabID == RankTypeNew) {
            [[FeedService defaultService] getFeedList:FeedListTypeLatest offset:tab.offset limit:tab.limit delegate:self];        
        }else{
            [[FeedService defaultService] getFeedList:FeedListTypeHot offset:tab.offset limit:tab.limit delegate:self];        
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
- (void)didClickRankView:(RankView *)rankView
{
    ShowFeedController *sc = [[ShowFeedController alloc] initWithFeed:rankView.feed];
    [self.navigationController pushViewController:sc animated:YES];
    [sc release];
}

@end
