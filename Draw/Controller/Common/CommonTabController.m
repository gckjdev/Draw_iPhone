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
        TableTab *tab = [TableTab tabWithID:tabID index:0 offset:0 limit:limit noDataDesc:noDataDesc hasMoreData:YES isCurrentTab:NO];
        [_tabManager addTab:tab];
    }
    [[_tabManager tabAtIndex:currentTabIndex] setCurrentTab:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initTabs];
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

#pragma mark - methods used by sub classes

- (NSMutableArray *)tabDataList
{
    return [[self currentTab] dataList];
}
- (TableTab *)currentTab
{
    return [_tabManager currentTab];
}


- (void)startToLoadNewDataForTabID:(NSInteger)tabID
{
    TableTab * tab = [_tabManager tabForID:tabID];
    tab.status = TableTabStatusLoading;
    tab.offset = 0;
}

- (void)finishLoadDataForTabID:(NSInteger)tabID resultList:(NSArray *)list
{
    TableTab * tab = [_tabManager tabForID:tabID];
    if ([list count] == 0) {
        tab.hasMoreData = NO;
    }else{
        tab.hasMoreData = YES;        
        [tab.dataList addObjectsFromArray:list];
        tab.offset += [tab.dataList count];
    }
    tab.status = TableTabStatusLoaded;
}
- (void)failLoadDataForTabID:(NSInteger)tabID
{
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
    return 20;
}
- (NSInteger)tabIDforIndex:(NSInteger)index
{
    return index;
}

- (NSString *)tabNoDataTipsforIndex:(NSInteger)index
{
    return NSLS(@"kNoData");
}

@end
