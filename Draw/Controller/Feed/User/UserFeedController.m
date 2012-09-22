//
//  HotController.m
//  Draw
//
//  Created by  on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UserFeedController.h"
#import "TableTabManager.h"
#import "ShareImageManager.h"
#import "ShowFeedController.h"
#import "FeedCell.h"
#import "CommonMessageCenter.h"
#import "CommonUserInfoView.h"
typedef enum{
    UserTypeFeed = FeedListTypeUserFeed,
    UserTypeOpus = FeedListTypeUserOpus,    
}UserFeedType;

@implementation UserFeedController
@synthesize nickName = _nickName;
@synthesize userId = _userId;


- (void)dealloc
{
    PPRelease(_userId);
    PPRelease(_nickName);
    [super dealloc];
}

- (id)initWithUserId:(NSString *)userId nickName:(NSString *)nickName
{
    self = [super init];
    if (self) {
        self.userId = userId;
        self.nickName = nickName;
    }
    return self;
}

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
        if (tab.tabID == UserTypeOpus) {
            [button setBackgroundImage:[imageManager myFoucsImage] forState:UIButtonTypeCustom];
            [button setBackgroundImage:[imageManager myFoucsSelectedImage] forState:UIControlStateSelected];
        }else if(tab.tabID == UserTypeFeed){
            [button setBackgroundImage:[imageManager foucsMeImage] forState:UIButtonTypeCustom];
            [button setBackgroundImage:[imageManager foucsMeSelectedImage] forState:UIControlStateSelected];            
        }
    }

    [self clickTabButton:self.currentTabButton];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];    
    [self initTabButtons];
    [self.titleLabel setText:[NSString stringWithFormat:@"[%@]",_nickName]];
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
    
    switch (self.currentTab.tabID) {
        case UserTypeOpus:
            return [RankView heightForRankViewType:RankViewTypeNormal]+1;
        case UserTypeFeed:
            return [FeedCell getCellHeight];
        default:
            return 0;
    }
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
    
    TableTab *tab = [self currentTab];
    
    if (tab.tabID == UserTypeFeed) {
        
        NSString *CellIdentifier = [FeedCell getCellIdentifier];
        FeedCell *cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [FeedCell createCell:self];
        }
        cell.indexPath = indexPath;
        cell.accessoryType = UITableViewCellAccessoryNone;
        Feed *feed = [self.tabDataList objectAtIndex:indexPath.row];
        [feed updateDesc];
        [cell setCellInfo:feed];
        return cell;
        
    }else if(tab.tabID == UserTypeOpus){
        
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
        PPDebug(@"startIndex = %d",startIndex);
        for (NSInteger i = startIndex; i < startIndex+NORMAL_CELL_VIEW_NUMBER; ++ i) {
            NSObject *object = [self saveGetObjectForIndex:i];
            if (object) {
                [list addObject:object];
            }
        }
        [self setNormalRankCell:cell WithFeeds:list];
        return cell;
    }else{
        return nil;
    }
}

- (void)updateSeparator:(NSInteger)dataCount
{
    if (self.currentTab.tabID == UserTypeOpus) {
        [self.dataTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    }else{
        if (dataCount == 0) {
            [self.dataTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];            
        }else{
            [self.dataTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];            
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = [super tableView:tableView numberOfRowsInSection:section];
    
    [self updateSeparator:count];
    switch (self.currentTab.tabID) {
        case UserTypeFeed:
            return count;
        case UserTypeOpus:
            if (count %3 == 0) {
                return count/3;
            }else{
                return count/3 + 1;
            }
        default:
            return 0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.currentTab.tabID != UserTypeFeed && indexPath.row > [self.tabDataList count])
        return;
    
    Feed *feed = [self.tabDataList objectAtIndex:indexPath.row];
    
    if (feed.opusStatus == OPusStatusDelete) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kOpusDelete") delayTime:1.5 isHappy:NO];
        return;
    }
    DrawFeed *drawFeed = nil;
    if (feed.isDrawType) {
        drawFeed = (DrawFeed *)feed;
    }else if(feed.isGuessType){
        drawFeed = [(GuessFeed *)feed drawFeed];
    }else{
        PPDebug(@"warnning:<FeedController> feedId = %@ is illegal feed, cannot set the detail", feed.feedId);
        return;
    }
    ShowFeedController *sfc = [[ShowFeedController alloc] initWithFeed:drawFeed];
    [self.navigationController pushViewController:sfc animated:YES];
    [sfc release];
    
    //enter the detail feed contrller
}


#pragma mark common tab controller

- (NSInteger)tabCount
{
    return 2;
}
- (NSInteger)currentTabIndex
{
    return 0;
}
- (NSInteger)fetchDataLimitForTabIndex:(NSInteger)index
{
    return 12;
}
- (NSInteger)tabIDforIndex:(NSInteger)index
{
    NSInteger tabId[] = {UserTypeOpus,UserTypeFeed};
    return tabId[index];
}

- (NSString *)tabNoDataTipsforIndex:(NSInteger)index
{
    
    NSString *tabDesc[] = {NSLS(@"kUserNoOpus"),NSLS(@"kUserNoFeed")};
    
    return tabDesc[index];
}

- (NSString *)tabTitleforIndex:(NSInteger)index
{
    NSString *tabTitle[] = {NSLS(@"kUserOpus"),NSLS(@"kUserFeed")};
    return tabTitle[index];
    
}

- (void)serviceLoadDataForTabID:(NSInteger)tabID
{
    
    [self showActivityWithText:NSLS(@"kLoading")];
    TableTab *tab = [_tabManager tabForID:tabID];
    FeedService *feedService = [FeedService defaultService];
    if (tab) {
        NSInteger offset = tab.offset;
        NSInteger limit = tab.limit;
        switch (tabID) {
            case UserTypeFeed:
                [feedService getUserFeedList:_userId offset:offset limit:limit delegate:self];
                break;
            case UserTypeOpus:
            {
                [feedService getUserOpusList:_userId offset:offset limit:limit type:FeedListTypeUserOpus delegate:self];
            }
            default:
                break;
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

- (void)didGetFeedList:(NSArray *)feedList 
            targetUser:(NSString *)userId 
                  type:(FeedListType)type
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
