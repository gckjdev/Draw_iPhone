//
//  CommonTabController.m
//  Draw
//
//  Created by  on 12-9-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommonTabController.h"
#import "CommonMessageCenter.h"
#import "ShareImageManager.h"

@implementation CommonTabController
@synthesize titleLabel = _titleLabel;
@synthesize noDataTipLabl = _noDataTipLabl;


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return (gestureRecognizer.view == self.view);
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return (gestureRecognizer.view == self.view);    
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)swp
{
    PPDebug(@"<handleSwipe> STATA = %d, DIRECTION = %d", swp.state, swp.direction);
    
    if (swp.state == UIGestureRecognizerStateRecognized) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)setSwipeToBack:(BOOL)swipeToBack
{
    if (swipeToBack) {
        if (swipe == nil) {
            swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
            swipe.delegate = self;
            [self.view addGestureRecognizer:swipe];
            swipe.direction = UISwipeGestureRecognizerDirectionLeft;//|UISwipeGestureRecognizerDirectionRight|UISwipeGestureRecognizerDirectionUp|UISwipeGestureRecognizerDirectionDown;
            [swipe release];
        }
    }else{
        if (swipe){
            [self.view removeGestureRecognizer:swipe];
            swipe = nil;
        }
    }
}

- (void)setDefaultTabIndex:(int)tabIndex
{
    _defaultTabIndex = tabIndex;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        PPDebug(@"initWithNibName = %@", nibNameOrNil);
        self.pullRefreshType = PullRefreshTypeBoth;
        _tabManager = [[TableTabManager alloc] init];
        self.unReloadDataWhenViewDidAppear = YES;
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

+ (void)enterControllerWithIndex:(NSInteger)index
                  fromController:(UIViewController *)controller 
                        animated:(BOOL)animated

{
    
}

- (id)initWithDefaultTabIndex:(NSInteger)index
{
    self = [super init];
    if (self) {
        _defaultTabIndex = index;
    }
    return self;
}

#pragma mark init tabs
- (void)initTabs
{
    PPDebug(@"init tabs");
    NSInteger count = [self tabCount];
    NSInteger currentTabIndex = [self currentTabIndex];
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

#define BUTTON_DEFAULT_COLOR [UIColor colorWithRed:62/255. green:42/255. blue:23/255. alpha:1]
#define BUTTON_SELETED_COLOR [UIColor whiteColor]
#define BUTTON_FONT (ISIPAD ? [UIFont boldSystemFontOfSize:28] : [UIFont boldSystemFontOfSize:14])


- (void)initTabButtons
{
    NSArray* tabList = [_tabManager tabList];
    NSInteger index = 0;
    NSInteger start = 0;
    NSInteger end = [tabList count] - 1;
    for(TableTab *tab in tabList){
        UIButton *button = (UIButton *)[self.view viewWithTag:tab.tabID];
        ShareImageManager *imageManager = [ShareImageManager defaultManager];
        
        //title
        [button setTitle:tab.title forState:UIControlStateNormal];
        
        //font
        [button.titleLabel setFont:BUTTON_FONT];
        
        //text color
        UIColor *nomalTextColor = [self tabButtonTitleColorForNormal:index];
        UIColor *selectedTextColor = [self tabButtonTitleColorForSelected:index];
        if (nomalTextColor == nil) {
            [button setTitleColor:BUTTON_DEFAULT_COLOR forState:UIControlStateNormal];
        }else{
            [button setTitleColor:nomalTextColor forState:UIControlStateNormal];
        }
        
        if (selectedTextColor == nil) {
            [button setTitleColor:BUTTON_SELETED_COLOR forState:UIControlStateSelected];
        }else{
            [button setTitleColor:selectedTextColor forState:UIControlStateSelected];
        }
        
        
        
        //bg image
        if (index == start) {
            [button setBackgroundImage:[imageManager myFoucsImage] forState:UIControlStateNormal];
            [button setBackgroundImage:[imageManager myFoucsSelectedImage] forState:UIControlStateSelected];
        }else if(index == end){
            [button setBackgroundImage:[imageManager focusMeImage] forState:UIControlStateNormal];
            [button setBackgroundImage:[imageManager focusMeSelectedImage] forState:UIControlStateSelected];
        }else{
            [button setBackgroundImage:[imageManager middleTabImage] forState:UIControlStateNormal];
            [button setBackgroundImage:[imageManager middleTabSelectedImage] forState:UIControlStateSelected];
        }
        
        index++;
    }
    [self clickTabButton:self.currentTabButton];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    if ((self.pullRefreshType & PullRefreshTypeFooter) != 0) {
        [self setSupportRefreshFooter:YES];
    }
    if ((self.pullRefreshType & PullRefreshTypeHeader) != 0) {
        [self setSupportRefreshHeader:YES];
    }
    [super viewDidLoad];
    [self initTabs];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self setSwipeToBack:NO];
}


- (void)viewDidAppear:(BOOL)animated
{
    if ([_tabManager needResetFrontData]) {
        [_tabManager resetFrontData];
        [self.dataTableView reloadData];        
    }

    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    [self setTitleLabel:nil];
    [self setNoDataTipLabl:nil];
    [_tabManager cleanData];
    [super viewDidUnload];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (IBAction)clickBackButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickTab:(NSInteger)tabID
{
    TableTab *tab = [_tabManager tabForID:tabID];
    [_tabManager setCurrentTab:tab];
    [self.dataTableView reloadData];
    if (tab.status == TableTabStatusUnload) {
        [self startToLoadDataForTabID:tab.tabID];
        [self serviceLoadDataForTabID:tab.tabID];
    }
    _defaultTabIndex = tab.index;

}
- (IBAction)clickTabButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    UIButton *currentButton = self.currentTabButton;
    [currentButton setSelected:NO];
    [button setSelected:YES];
    [self clickTab:button.tag];
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
    PPDebug(@"current tabID = %d",tab.tabID);
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
    [self hideActivity];
    [self dataSourceDidFinishLoadingNewData];   
    [self dataSourceDidFinishLoadingMoreData];

    TableTab * tab = [_tabManager tabForID:tabID];
    if (tab.offset == 0) {
        [tab.dataList removeAllObjects];
    }

    if ([list count] == 0) {
        tab.hasMoreData = NO;
    }else{
        tab.hasMoreData = YES;        
        [tab.dataList addObjectsFromArray:list];
        tab.offset += tab.limit;
    }
    tab.status = TableTabStatusLoaded;
    if (tab.isCurrentTab) {
        [self.dataTableView reloadData];
    }
}
- (void)failLoadDataForTabID:(NSInteger)tabID
{
    [self hideActivity];
    [self dataSourceDidFinishLoadingNewData];   
    [self dataSourceDidFinishLoadingMoreData];

    TableTab * tab = [_tabManager tabForID:tabID];
    if ([tab.dataList count] == 0) {
        tab.status = TableTabStatusUnload;
    }else{
        tab.status = TableTabStatusLoaded;
    }
    [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kLoadFail") 
                                                   delayTime:1.5 
                                                     isHappy:NO];

}

- (void)finishDeleteData:(NSObject *)data ForTabID:(NSInteger)tabID
{
    NSMutableArray *list = [_tabManager dataListForTabID:tabID];
    [list removeObject:data];
    [self.dataTableView reloadData];
}

#pragma mark table view delegate

//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    NSInteger count = [[self tabDataList] count];
//    self.noMoreData = !self.currentTab.hasMoreData;
//    return count;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = [[self tabDataList] count];
    
    TableTab *tab = self.currentTab;
    
    if (tab.status == TableTabStatusLoading) {
        [self showActivityWithText:NSLS(@"kLoading")];
    }else{
        [self hideActivity];        
    }
    
    if (count == 0 && tab.status == TableTabStatusLoaded) {
        self.noDataTipLabl.hidden = NO;
        [self.noDataTipLabl setText:tab.noDataDesc];
        [self.view bringSubviewToFront:self.noDataTipLabl];
    }else{
        self.noDataTipLabl.hidden = YES;
    }
    
    self.noMoreData = !tab.hasMoreData;
    return count;
}
#pragma mark tab controller delegate

- (NSInteger)tabCount
{
    return 1;
}
- (NSInteger)currentTabIndex
{
    return _defaultTabIndex;
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

- (UIColor *)tabButtonTitleColorForNormal:(NSInteger)index
{
    return nil;
}

- (UIColor *)tabButtonTitleColorForSelected:(NSInteger)index
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

- (BOOL)isCurrentTabLoading
{
    return ([[_tabManager currentTab] status] == TableTabStatusLoading);
}

#pragma mark - refresh header & footer delegate
- (void)reloadTableViewDataSource
{
    TableTab *tab = self.currentTab;
    if (tab.status == TableTabStatusLoading) {
        return;
    }
    
    tab.status = TableTabStatusUnload;
    tab.offset = 0;
    [self startToLoadDataForTabID:tab.tabID];
    [self serviceLoadDataForTabID:tab.tabID];
//    CGRect beginRect = CGRectMake(0, 0, 1, 1);
//    [self.dataTableView scrollRectToVisible:beginRect animated:YES];
}

- (void)loadMoreTableViewDataSource
{
    TableTab *tab = self.currentTab;
    [self startToLoadDataForTabID:tab.tabID];
    [self serviceLoadDataForTabID:tab.tabID];
}

- (void)cleanFrontData
{
//    if (self.cleanFrontDataWhenViewDisappear) {
        [_tabManager cleanFrontData];
        [self.dataTableView reloadData];
//    }
}

@end
