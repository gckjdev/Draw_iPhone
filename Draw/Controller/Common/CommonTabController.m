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
#import "UIButton+Sound.h"

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
        self.autoResizeTabButton = YES;
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
    NSArray* subviews = [self.view subviews];
    for (UIView* view in subviews){
        if ([view isKindOfClass:[UIButton class]] &&
            [view respondsToSelector:@selector(unregisterSound)]){
            [view performSelector:@selector(unregisterSound)];
        }
    }
    
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

//#define BUTTON_FONT (ISIPAD ? [UIFont boldSystemFontOfSize:28] : [UIFont boldSystemFontOfSize:14])
#define BUTTON_FONT (ISIPAD ? [UIFont systemFontOfSize:28] : [UIFont systemFontOfSize:14])
#define BADGE_FONT (ISIPAD ? [UIFont systemFontOfSize:18] : [UIFont systemFontOfSize:10])
#define SPLIT_WIDTH (ISIPAD ? 2 : 1)

#define BUTTON_Y (ISIPAD ? 108 : 42)
#define BUTTON_HEIGHT (ISIPAD ? 65 : 30)

- (void)initTabButtons
{
    NSArray* tabList = [_tabManager tabList];
    NSInteger index = 0;
    
    NSUInteger count = [tabList count];
    CGFloat width = CGRectGetWidth([[UIScreen mainScreen] bounds]);

    CGFloat split = SPLIT_WIDTH;
    CGFloat btnWidth = (width - ((count-1) * split)) / count;
    CGFloat step = btnWidth + split;
    
    NSInteger i = 0;
    for(TableTab *tab in tabList){
        UIButton *button = (UIButton *)[self.view viewWithTag:tab.tabID];

        [button registerSound:SOUND_EFFECT_BUTTON_DOWN];
        
        CGRect rect = button.frame;
        CGFloat x = i * step;
        rect.origin.x = x;
        rect.size.width = btnWidth;

        if ([self isAutoResizeTabButton]) {
            rect.origin.y = BUTTON_Y;
            rect.size.height = BUTTON_HEIGHT;
        }
        
        button.frame = rect;
        i ++;
                
        [button addTarget:self action:@selector(clickTabDown:) forControlEvents:UIControlEventTouchDown];
        [button addTarget:self action:@selector(clickTabUp:) forControlEvents:UIControlEventAllEvents^UIControlEventTouchDown];        
        
        
        //font
        [button.titleLabel setFont:BUTTON_FONT];
        
        NSArray *states = @[@(UIControlStateNormal),@(UIControlStateSelected),@(UIControlStateHighlighted)];
        
        for (NSNumber *state in states) {
            [button setTitleColor:COLOR_WHITE forState:[state integerValue]];
            [button setImage:nil forState:[state integerValue]];
            [button setBackgroundImage:nil forState:[state integerValue]];
            //title
            [button setTitle:tab.title forState:[state integerValue]];
            
        }
       
        //shadow offset
        [button setShadowOffset:CGSizeMake(0,0) blur:0 shadowColor:nil];        
        [button setBackgroundColor:COLOR_ORANGE];
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

    [currentButton setBackgroundColor:COLOR_ORANGE];
    [button setBackgroundColor:COLOR_ORANGE1];

    [button setSelected:YES];
    [self clickTab:button.tag];
}

//highlight
- (IBAction)clickTabDown:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if (self.currentTabButton != button) {
        [button setBackgroundColor:COLOR_ORANGE2];
    }
}

//selected
- (IBAction)clickTabUp:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if (self.currentTabButton == button) {
        [button setBackgroundColor:COLOR_ORANGE1];
    }else{
        [button setBackgroundColor:COLOR_ORANGE];
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

#define BadgeTagOffset 20130813
#define BadgeSize (ISIPAD ?  40: 25)
#define PositionOffset 0.8

- (UIButton *)badgeButtonForTab:(NSInteger) tabID
{
    NSInteger tag = tabID + BadgeTagOffset;
    UIButton *button = [self tabButtonWithTabID:tabID];
    if (button == nil) {
        return nil;
    }
    UIButton *badge = (id)[self.view viewWithTag:tag];
    if(badge == nil){
        badge = [UIButton buttonWithType:UIButtonTypeCustom];
        badge.tag = tag;
        badge.userInteractionEnabled = NO;
        badge.frame = CGRectMake(CGRectGetWidth(button.bounds) - BadgeSize*PositionOffset,
                                 - BadgeSize*(1-PositionOffset), BadgeSize, BadgeSize);
        
        badge.frame = [self.view convertRect:badge.frame fromView:button];

        [badge.titleLabel setFont:BADGE_FONT];
        [badge setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [badge setBackgroundImage:[[ShareImageManager defaultManager] badgeImage]
                         forState:UIControlStateNormal];
        [self.view addSubview:badge];        
    }
    [self.view bringSubviewToFront:badge];
    return badge;

}

- (void)setBadge:(NSInteger)badge onTab:(NSInteger)tabID
{
    UIButton *badgeButton = [self badgeButtonForTab:tabID];
    if (badgeButton) {
        badgeButton.hidden = NO;
        if (badge <= 0) {
            badgeButton.hidden = YES;
        }else if(badge < 99){
            [badgeButton setTitle:[@(badge) stringValue] forState:UIControlStateNormal];
        }else{
            [badgeButton setTitle:@"N" forState:UIControlStateNormal];
        }
    }
}

- (void)setTab:(NSInteger)tabID titleNumber:(NSInteger)number
{
    NSInteger index = [_tabManager indexOfTabID:tabID];
    if (index != NSNotFound) {
        NSString *title = [self tabTitleforIndex:index];
        title = [NSString stringWithFormat:@"%@(%d)", title, number];
        UIButton *button = [self tabButtonWithTabID:tabID];
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitle:title forState:UIControlStateHighlighted];
        [button setTitle:title forState:UIControlStateSelected];
    }
}
@end
