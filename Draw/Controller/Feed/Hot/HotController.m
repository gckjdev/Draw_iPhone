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
//    return [RankFirstCell getCellHeight];
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSString *CellIdentifier = [RankFirstCell getCellIdentifier];
//    RankFirstCell *cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [RankFirstCell createCell:self];
//    }
//    cell.indexPath = indexPath;
//    cell.accessoryType = UITableViewCellAccessoryNone;
//    DrawFeed *feed = [self.tabDataList objectAtIndex:indexPath.row];
//    [cell setCellInfo:feed];
//    return cell;

    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = [[self tabDataList] count];
    TableTab *tab = self.currentTab;
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
    return 3;
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
    [self hideActivity];
    if (resultCode == 0) {
        [self finishLoadDataForTabID:type resultList:feedList];
    }else{
        [self failLoadDataForTabID:type];
    }
}


@end
