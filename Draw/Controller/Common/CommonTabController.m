//
//  CommonTabController.m
//  Draw
//
//  Created by  on 12-9-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommonTabController.h"
#import "TableTabManager.h"

@implementation CommonTabController
@synthesize titleLabel = _titleLabel;
@synthesize noDataTipLabl = _noDataTipLabl;

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

- (void)dealloc
{
    PPRelease(_tabManager);
    PPRelease(_titleLabel);
    PPRelease(_noDataTipLabl);
    [super dealloc];
}

#pragma mark init tabs
- (void)initTabs
{
    NSInteger count = [self tabCount];
    NSInteger currentTabIndex = [self currentTabIndex];
    _tabManager = [[TableTabManager alloc] init];
    for (int i = 0; i < count; ++i) {
        NSInteger tabID = [self tabIDforIndex:i];
        NSInteger limit = [self fetchDataLimitForTabIndex:i];
        NSString *noDataDesc = [self tabNoDataTipsforIndex:i];
        NSString *title = [self tabTitleforIndex:i];
        TableTab *tab = [TableTab tabWithID:tabID 
                                      index:i 
                                      title:title 
                                     offset:0 
                                      limit:limit
                                 noDataDesc:noDataDesc 
                                hasMoreData:YES 
                               isCurrentTab:NO];
        
        [_tabManager addTab:tab];
    }
    [[_tabManager tabAtIndex:currentTabIndex] setCurrentTab:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [self setSupportRefreshHeader:YES];
    [self setSupportRefreshFooter:YES];
    [super viewDidLoad];
    [self initTabs];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self setTitleLabel:nil];
    [self setNoDataTipLabl:nil];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)clickBackButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickTabButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    [self.currentTabButton setSelected:NO];
    [button setSelected:YES];
    TableTab *tab = [_tabManager tabForID:button.tag];
    [_tabManager setCurrentTab:tab];
    [self.dataTableView reloadData];
    if (tab.status == TableTabStatusUnload) {
        [self startToLoadDataForTabID:tab.tabID];
        [self serviceLoadDataForTabID:tab.tabID];
    }
}

- (IBAction)clickRefreshButton:(id)sender
{
    [self reloadTableViewDataSource];
}

#pragma mark - methods used by sub classes

- (NSMutableArray *)tabDataList
{
    return [[self currentTab] dataList];
}
- (TableTab *)currentTab
{
    return [_tabManager currentTab];
}

- (UIButton *)tabButtonWithTabID:(NSInteger)tabID
{
    return (UIButton *)[self.view viewWithTag:tabID];        
}


- (UIButton *)currentTabButton
{
    TableTab *tab = [self currentTab];
    if (tab) {
        return [self tabButtonWithTabID:tab.tabID];
    }
    return nil;
}

- (void)startToLoadDataForTabID:(NSInteger)tabID
{
    TableTab * tab = [_tabManager tabForID:tabID];
    tab.status = TableTabStatusLoading;
}

- (void)finishLoadDataForTabID:(NSInteger)tabID resultList:(NSArray *)list
{
    [self dataSourceDidFinishLoadingNewData];   
    [self dataSourceDidFinishLoadingMoreData];

    TableTab * tab = [_tabManager tabForID:tabID];
    if ([list count] == 0) {
        tab.hasMoreData = NO;
    }else{
        tab.hasMoreData = YES;        
        if (tab.offset == 0) {
            [tab.dataList removeAllObjects];
        }
        [tab.dataList addObjectsFromArray:list];
        tab.offset = [tab.dataList count];
    }
    tab.status = TableTabStatusLoaded;
    if (tab.isCurrentTab) {
        [self.dataTableView reloadData];
    }
}
- (void)failLoadDataForTabID:(NSInteger)tabID
{
    [self dataSourceDidFinishLoadingNewData];   
    [self dataSourceDidFinishLoadingMoreData];

    TableTab * tab = [_tabManager tabForID:tabID];
    if ([tab.dataList count] == 0) {
        tab.status = TableTabStatusUnload;
    }else{
        tab.status = TableTabStatusLoaded;
    }
}


#pragma mark table view delegate


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = [[self tabDataList] count];
    self.noMoreData = !self.currentTab.hasMoreData;
    return count;
}

#pragma mark tab controller delegate

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
    return 18;
}
- (NSInteger)tabIDforIndex:(NSInteger)index
{
    return index;
}

- (NSString *)tabNoDataTipsforIndex:(NSInteger)index
{
    return nil;
}
- (NSString *)tabTitleforIndex:(NSInteger)index
{
    return nil;
}


- (void)serviceLoadDataForTabID:(NSInteger)tabID
{
    
}

#pragma mark - refresh header & footer delegate
- (void)reloadTableViewDataSource
{
    TableTab *tab = self.currentTab;
    tab.status = TableTabStatusUnload;
    tab.offset = 0;
    [self startToLoadDataForTabID:tab.tabID];
    [self serviceLoadDataForTabID:tab.tabID];
    CGRect beginRect = CGRectMake(0, 0, 1, 1);
    [self.dataTableView scrollRectToVisible:beginRect animated:YES];
}

- (void)loadMoreTableViewDataSource
{
    TableTab *tab = self.currentTab;
    [self startToLoadDataForTabID:tab.tabID];
    [self serviceLoadDataForTabID:tab.tabID];
}
@end
