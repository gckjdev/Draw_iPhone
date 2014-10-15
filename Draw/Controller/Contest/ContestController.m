//
//  ContestController.m
//  Draw
//
//  Created by  on 12-9-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ContestController.h"
#import "Contest.h"
#import "PPConfigManager.h"
#import "StatementController.h"
#import "CommonMessageCenter.h"
#import "ContestOpusController.h"
#import "CommonMessageCenter.h"
#import "ShareImageManager.h"
#import "UICustomPageControl.h"
#import "OfflineDrawViewController.h"
#import "ContestManager.h"
#import "StatisticManager.h"
#import "CustomInfoView.h"
#import "PPConfigManager.h"
#import "FeedService.h"
#import "CellManager.h"
#import "CreateContestController.h"
#import "GroupManager.h"
#import "GroupPermission.h"
#import "ContestCell.h"
#import "GroupTopicController.h"
#import "UIViewController+BGImage.h"


typedef enum{
    TabTypeOfficial = 1,
    TabTypeGroup = 2,

    TabTypeGroupFollow = 3,
    TabTypeGroupPop = 4,
    TabTypeGroupAward = 5,
    TabTypeGroupNew = 6,
}TabType;


@interface ContestController()<FeedServiceDelegate, ContestCellDelegate>{
    UIButton *currentTabButton;
    UIButton *currentGroupSubButton;
    int _defaultTabId;
}

@property (assign, nonatomic) BOOL groupContestOnly;
@property (copy, nonatomic) NSString *groupId;

@property (retain, nonatomic) IBOutlet UIButton *officialButton;
@property (retain, nonatomic) IBOutlet UIButton *groupButton;

@property (retain, nonatomic) IBOutlet UIView *subTabsHolder;

@property (retain, nonatomic) IBOutlet UIView *tabsHolderView;

@end


@implementation ContestController
@synthesize noContestTipLabel = _noContestTipLabel;
@synthesize scrollView = _scrollView;
@synthesize pageControl = _pageControl;

#define CONTEST_COUNT_LIMIT 20

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _contestViewList = [[NSMutableArray alloc] init];
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

- (void)initCustomPageControl
{
    self.pageControl.hidesForSinglePage = YES;
    
    [self.pageControl setPageIndicatorImageForCurrentPage:[[ShareImageManager defaultManager] pointForCurrentSelectedPage] forNotCurrentPage:[[ShareImageManager defaultManager] pointForUnSelectedPage]];
    
    if ([DeviceDetection isIPAD]) {
        self.pageControl.transform = CGAffineTransformMakeScale(2.0, 2.0);
        self.pageControl.center = CGPointMake(self.view.center.x, self.pageControl.center.y);
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    for (ContestView *contestView in _contestViewList) {
        [contestView refreshCount];
    }
}

- (void)showTips:(NSString *)tips
{
    [[self noContestTipLabel] setTextColor:COLOR_BROWN];
    [[self noContestTipLabel] setHidden:NO];
    [[self noContestTipLabel] setText:tips];
}

- (void)hideTips
{
    [[self noContestTipLabel] setHidden:YES];
}

- (id)init{
    
    if (self = [super init]) {
        _defaultTabId = TabTypeOfficial;

        if ([[ContestService defaultService] newContestCount] == 0){
            _defaultTabId = TabTypeGroup;
        }
        
    }
    return self;
}

- (id)initWithGroupDefault{
    
    if (self = [super init]) {
        _defaultTabId = TabTypeGroup;
    }
    return self;
}

- (id)initWithGroupContestOnly{
    
    if (self = [super init]) {
        self.groupContestOnly = YES;
        _defaultTabId = TabTypeGroupPop;
    }
    
    return self;
}

// 仅有家族比赛，没有官方比赛，家族比赛为指定的某个家族的比赛。
- (id)initWithGroupId:(NSString *)groupId{
    
    if (self = [super init]) {
        self.groupContestOnly = YES;
        self.groupId = groupId;
        _defaultTabId = TabTypeGroupNew;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initTabButtons];

    
    SET_VIEW_BG(self.view);
    [self initCustomPageControl];
    
    CommonTitleView *titleView = [CommonTitleView createTitleView:self.view];
    [titleView setTarget:self];
    [titleView setTitle:NSLS(@"kContest")];
    [titleView setBackButtonSelector:@selector(clickBackButton:)];
    [self hideTips];
    
    if (_groupContestOnly) {
        
        if (self.groupId == nil){
            [titleView setTitle:NSLS(@"kAllGroupContest")];
            
            CGFloat originY = CGRectGetMinY(self.subTabsHolder.frame) - CGRectGetHeight(self.tabsHolderView.frame);
            [self.subTabsHolder updateOriginY:originY];
        }
        else{
            [titleView setTitle:NSLS(@"kMyGroupContest")];
            self.subTabsHolder.hidden = YES;
            
            CGFloat originY = CGRectGetMaxY(titleView.frame)- CGRectGetHeight(self.tabsHolderView.frame);
            [self.subTabsHolder updateOriginY:originY];
        }

        self.tabsHolderView.hidden = YES;
        
        GroupPermissionManager *permission =[GroupPermissionManager myManagerWithGroupId:self.groupId];
        if ([permission canHoldContest]) {
            [titleView setRightButtonTitle:NSLS(@"kCreate")];
            [titleView setRightButtonSelector:@selector(clickCreateButton:)];
        } ;
        [self clickTab:TabTypeGroupNew];
        [self setDefaultBGImage];
    }
    
    if (_groupContestOnly) {
        self.view.backgroundColor = COLOR_WHITE;

    }else{
        self.view.backgroundColor = COLOR_GRAY;
        
        CGFloat y = CGRectGetMaxY(self.groupButton.frame);
        [self.dataTableView updateOriginY:y];
        [self.dataTableView updateHeight:(CGRectGetHeight(self.view.bounds) - y)];
    }
    
    [[ContestService defaultService] syncOngoingContestList];
    
    
    [self clickTabButton:[self defaultTabButton]];
}

- (UIButton *)defaultTabButton
{
    id button = [self.tabsHolderView viewWithTag:_defaultTabId];
    if (button == nil) {
        button = [self.subTabsHolder viewWithTag:_defaultTabId];
    }
    
    return button;
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setPageControl:nil];
    [self setNoContestTipLabel:nil];
    [self setScrollerViewHolder:nil];
    [self setOfficialButton:nil];
    [self setGroupButton:nil];
    [self setSubTabsHolder:nil];
    [self setTabsHolderView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)clearScrollView
{
    PPDebug(@"clearScrollView");
    for (UIView *view in self.scrollView.subviews) {
        if ([view isKindOfClass:[ContestView class]]) {
            [view removeFromSuperview];
        }
    }
    [_contestViewList removeAllObjects];
}

- (void)updateScorollViewWithContestList:(NSArray *)contestList
{
    PPDebug(@"<updateScorollViewWithContestList>, list count = %d", 
            [contestList count]);
    [self clearScrollView];
    int i = 0;

    CGFloat width = self.scrollView.frame.size.width;
    CGFloat height = self.scrollView.frame.size.height;
    
    NSInteger count = [contestList count];
    [self.scrollView setContentSize:CGSizeMake(width * count, height)];
    for (Contest *contest in contestList) {
        
        ContestView *contestView = [ContestView createContestView:self];
        contestView.frame = CGRectMake(width * i ++, 0, width, height);
        [self.scrollView addSubview:contestView];
        [_contestViewList addObject:contestView];
        [contestView setViewInfo:contest];
    }
    [self.pageControl setNumberOfPages:count];

    int showIndex = 0;  // force the first one as current contest, add by Benson 2013-09-10
    [self.pageControl setCurrentPage:showIndex];
    [self.scrollView setContentOffset:CGPointMake(showIndex * width, 0) animated:YES];
}

- (void)updatePage
{
    NSInteger page = _scrollView.contentOffset.x / [ContestView getViewWidth];
    if (page >=0 && page < [self.pageControl numberOfPages]) {
        [self.pageControl setCurrentPage:page];
    }
}

#pragma mark - Scroll view delegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    [self updatePage];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self updatePage];    
}


#pragma mark contest service delegate

- (IBAction)clickBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)alertCopyrightStatement:(void (^)(void))block{
    if (![PPConfigManager isInReviewVersion]) {
        EXECUTE_BLOCK(block);
        return;
    }
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kHint") message:NSLS(@"kContestCopyright") style:CommonDialogStyleSingleButton];
    [dialog setClickOkBlock:^(id infoView){
        EXECUTE_BLOCK(block);
    }];
    [dialog showInView:self.view];
}

#pragma mark contest view delegate

- (void)didClickContestView:(ContestView *)contestView
             onReportButton:(Contest *)contest
{
    [self alertCopyrightStatement:^{
        ContestOpusController *coc = [[ContestOpusController alloc] initWithContest:contest];
        [coc setDefaultTabIndex:0];
        [self.navigationController pushViewController:coc animated:YES];
        [coc release];        
    }];
}

- (void)didClickContestView:(ContestView *)contestView 
               onOpusButton:(Contest *)contest
{
    [self alertCopyrightStatement:^{
        ContestOpusController *coc = [[ContestOpusController alloc] initWithContest:contest];
        [self.navigationController pushViewController:coc animated:YES];
        [coc release];
    }];
}

- (void)didClickContestView:(ContestView *)contestView
               onJoinButton:(Contest *)contest
{
    CHECK_AND_LOGIN(self.view);
    if (![contest isRunning]) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kContestNotRunning") delayTime:1.5 isHappy:NO];
        return;
    }
    
    if (![contest canSubmit]) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kContestSubmitEnd") delayTime:1.5 isHappy:NO];
        return;
    }

    if (![contest canUserJoined:[[UserManager defaultManager] userId]]) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kContestNotForUser") delayTime:1.5 isHappy:NO];
        return;
    }    
    
    if([contest commitCountEnough]){
        NSString *title = [NSString stringWithFormat:NSLS(@"kContestCommitCountEnough"),contest.canSubmitCount];
        [[CommonMessageCenter defaultCenter] postMessageWithText:title 
                                                       delayTime:1.5 
                                                         isHappy:NO];        
        return;
    }
    
    [self alertCopyrightStatement:^{
        if ([contest joined]) {
            [OfflineDrawViewController startDrawWithContest:contest
                                             fromController:self
                                            startController:self
                                                   animated:YES];
        }else{
            StatementController *sc = [[StatementController alloc] initWithContest:contest];
            sc.superController = self;
            [self.navigationController pushViewController:sc animated:YES];
            [sc release];        
        }
    }];    
}

#define StatementViewSize (ISIPAD ? CGSizeMake(690,874) : CGSizeMake(300,380))

- (void)didClickContestView:(ContestView *)contestView
             onDetailButton:(Contest *)contest
{
    __block ContestController * cp = self;
    [self alertCopyrightStatement:^{
        UIWebView *webView = [[[UIWebView alloc] initWithFrame:CGRectFromCGSize(StatementViewSize)] autorelease];
        webView.scalesPageToFit = YES;
        CustomInfoView *infoView = [CustomInfoView createWithTitle:NSLS(@"kContestRule") infoView:webView hasEdgeSpace:NO];
        
        [infoView showInView:cp.view];
        NSURLRequest *request = [NSURLRequest requestWithURL:
                                 [NSURL URLWithString:contest.statementUrl]];
        
        [webView loadRequest:request];
        [cp setCanDragBack:NO];
        [infoView setCloseHandler:^{
            PPDebug(@"close rule info view");
            [cp setCanDragBack:YES];
        }];
    }];
}

- (void)dealloc {
    PPRelease(_scrollView);
    PPRelease(_pageControl);
    PPRelease(_contestViewList);
    PPRelease(_noContestTipLabel);
    [[ContestManager defaultManager] setAllContestList:nil];
    [_scrollerViewHolder release];
    [_officialButton release];
    [_groupButton release];
    [_groupId release];
    [_subTabsHolder release];
    [_tabsHolderView release];
    [super dealloc];
}

- (void)clickCreateButton:(id)sender{
    
    [CreateContestController enterFromController:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createContestSuccess) name:NOTIFICATION_CREATE_CONTEST_SUCCESS object:nil];
}


- (void)createContestSuccess{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_CREATE_CONTEST_SUCCESS object:nil];
    [self clickTab:self.currentTab.tabID];
    [self clickRefreshButton:nil];
}

- (void)enterDrawControllerWithContest:(Contest *)contest
                              animated:(BOOL)animated
{
    [OfflineDrawViewController startDrawWithContest:contest
                                     fromController:self
                                    startController:self
                                           animated:animated];

}

- (NSInteger)tabCount{
    
    if (_groupContestOnly && [self.groupId length] > 0) {
        return 1;
    }else{
        return 6;
    }
};

- (NSInteger)currentTabIndex{
    
    return 0;
}

- (NSInteger)fetchDataLimitForTabIndex:(NSInteger)index{
    
    return 20;
}

- (NSInteger)tabIDforIndex:(NSInteger)index{
    
    if (_groupContestOnly && [self.groupId length] > 0) {
        return TabTypeGroupNew;
    }else{
        int indexs[] = {TabTypeOfficial,TabTypeGroup,TabTypeGroupFollow,TabTypeGroupPop, TabTypeGroupAward, TabTypeGroupNew};
        return indexs[index];
    }
}

- (NSString *)tabTitleforIndex:(NSInteger)index{
    
    TabType tabId = [self tabIDforIndex:index];
    switch (tabId) {
        case TabTypeOfficial:
            return NSLS(@"kOfficialContest");
            
        case TabTypeGroup:
            return NSLS(@"kGroupContest");
            
//        case TabTypeOpus:
//            return NSLS(@"kGoodOpus");
            
        case TabTypeGroupNew:
            return NSLS(@"kLatest");
            
        case TabTypeGroupFollow:
            return NSLS(@"kFollow");
            
        case TabTypeGroupPop:
            return NSLS(@"kPop");
            
        case TabTypeGroupAward:
            return NSLS(@"kAward");
            
        default:
            return nil;
    }
}

- (void)serviceLoadDataForTabID:(NSInteger)tabID{
    
    
    switch (tabID) {
        case TabTypeOfficial:
            [self loadOfficialContestList];
            break;
            
//        case TabTypeGroup:
//            [self loadGroupContestList];
//            break;
            
        case TabTypeGroupNew:
        case TabTypeGroupFollow:
        case TabTypeGroupPop:
        case TabTypeGroupAward:
            [self loadGroupContestList:tabID];
            break;
            
//        case TabTypeOpus:
//            [self loadWonderfulOpusList];
//            break;
            
        default:
            break;
    }
}

- (void)loadOfficialContestList{
    
    [self showActivityWithText:NSLS(@"kLoading")];

    [[ContestService  defaultService] getContestListWithType:ContestListTypeAll offset:0 limit:CONTEST_COUNT_LIMIT completed:^(int resultCode, ContestListType type, NSArray *contestList) {
        
        [self hideActivity];

        PPDebug(@"didGetContestList, type = %d, code = %d, contestList = %@", type,resultCode,contestList);
        if (resultCode == 0) {
            if ([contestList count] != 0) {
                [self updateScorollViewWithContestList:contestList];
                [self hideTips];
            }else{
                [self showTips:NSLS(@"kNoContestTips")];
                [self.pageControl setNumberOfPages:0];
            }
            [[ContestManager defaultManager] updateHasReadContestList:contestList];
        }else{
            [self showTips:NSLS(@"kFailLoad")];
        }
     
        // 为了避免第二次点击的时候显示loading
        [self finishLoadDataForTabID:TabTypeOfficial resultList:nil];
    }];
}

- (ContestListType)getContestListTypeWithTabId:(int)tabId{
    
    switch (tabId) {
        case TabTypeGroupNew:
            return ContestListTypeAllGroupNew;
            break;
            
        case TabTypeGroupFollow:
            return ContestListTypeAllGroupFollow;
            break;
            
        case TabTypeGroupPop:
            return ContestListTypeAllGroupPop;
            break;
            
        case TabTypeGroupAward:
            return ContestListTypeAllGroupAward;
            break;
            
        default:
            return 0;
            break;
    }
}

- (void)loadGroupContestList:(int)tabId{
    
    [self showActivityWithText:NSLS(@"kLoading")];

    if ([self.groupId length] == 0) {
        
        ContestListType type = [self getContestListTypeWithTabId:tabId];
        [[ContestService defaultService] getGroupContestListWithType:type offset:self.currentTab.offset limit:self.currentTab.limit completed:^(int resultCode, ContestListType type, NSArray *contestList) {
            
            [self hideActivity];
            if (resultCode == 0) {
                [self finishLoadDataForTabID:tabId resultList:contestList];
            }else{
                [self failLoadDataForTabID:tabId];
            }
        }];
    }else{
        
        [[ContestService defaultService] getContestListWithGroupId:self.groupId offset:self.currentTab.offset limit:self.currentTab.limit completed:^(int resultCode, ContestListType type, NSArray *contestList) {
            
            [self hideActivity];
            if (resultCode == 0) {
                [self finishLoadDataForTabID:tabId resultList:contestList];
            }else{
                [self failLoadDataForTabID:tabId];
            }
        }];
    }
}

- (NSString *)tabNoDataTipsforIndex:(NSInteger)index{
    
    
    
    TabType tabId = [self tabIDforIndex:index];
    switch (tabId) {
        case TabTypeOfficial:
            return NSLS(@"");
            
        case TabTypeGroup:
        case TabTypeGroupNew:
        case TabTypeGroupFollow:
        case TabTypeGroupPop:
        case TabTypeGroupAward:
            return NSLS(@"kNoGroupContest");
            
            //        case TabTypeOpus:
            //            return NSLS(@"kNoOpus");
            
        default:
            return nil;
    }
}

- (void)clickTab:(NSInteger)tabID{
    
    [super clickTab:tabID];
        
    switch (tabID) {
        case TabTypeOfficial:
            self.view.backgroundColor = COLOR_GRAY_BG;
            self.scrollerViewHolder.hidden = NO;
            self.dataTableView.hidden = YES;

            break;
            
        case TabTypeGroup:
        case TabTypeGroupNew:
        case TabTypeGroupFollow:
        case TabTypeGroupPop:
        case TabTypeGroupAward:
            self.view.backgroundColor = COLOR_WHITE;
            self.scrollerViewHolder.hidden = YES;
            self.dataTableView.hidden = NO;

            break;
            
//        case TabTypeOpus:
//            self.view.backgroundColor = COLOR_WHITE;
//            self.scrollerViewHolder.hidden = YES;
//            self.tableViewHolder.hidden = NO;
//            break;
            
        default:
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch ([[self currentTab] tabID]) {
            
        case TabTypeGroup:
        case TabTypeGroupNew:
        case TabTypeGroupFollow:
        case TabTypeGroupPop:
            return [CellManager getContestStyleCell:tableView
                                          indexPath:indexPath
                                           delegate:self
                                           dataList:self.currentTab.dataList];
            
        case TabTypeGroupAward:{
            
            ContestCell *cell = (id)[CellManager getContestStyleCell:tableView
                                   indexPath:indexPath
                                    delegate:self
                                                            dataList:self.currentTab.dataList];
            [cell showAward];
            return cell;
        }
            
        case TabTypeOfficial:
            return nil;
            
//        case TabTypeOpus:
//            return [CellManager getLastStyleCell:tableView
//                                       indexPath:indexPath
//                                        delegate:self
//                                        dataList:self.currentTab.dataList];
            
        default:
            return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSInteger count = [super tableView:tableView numberOfRowsInSection:section];
    
    switch ([[self currentTab] tabID]) {
            
        case TabTypeGroup:
        case TabTypeGroupNew:
        case TabTypeGroupFollow:
        case TabTypeGroupPop:
        case TabTypeGroupAward:
            return [CellManager getContestStyleCellCountWithDataCount:count];
            
        case TabTypeOfficial:
            return 0;
            
//        case TabTypeOpus:
//            return [CellManager getLastStyleCellCountWithDataCount:count roundingUp:NO];
            
        default:
            return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch ([[self currentTab] tabID]) {
            
        case TabTypeOfficial:
            return 0;
            
        case TabTypeGroup:            
        case TabTypeGroupNew:
        case TabTypeGroupFollow:
        case TabTypeGroupPop:
        case TabTypeGroupAward:

            return [CellManager getContestStyleCellHeight];
            
            
            
//        case TabTypeOpus:
//            return [CellManager getLastStyleCellHeightWithIndexPath:indexPath];
            
        default:
            return 0;
    }
}

- (void)didClickContest:(Contest *)contest{
    
    ContestOpusController *vc = [[[ContestOpusController alloc] initWithContest:contest] autorelease];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didClickGroup:(PBGroup *)pbGroup{
    
    [GroupTopicController enterWithGroup:pbGroup fromController:self];
}

- (void)initTabButtons
{
    NSInteger count = [self tabCount];
    for (int i = 0; i < count; ++ i) {
        GroupTab tab = [self tabIDforIndex:i];
        UIButton *button;

        if ([self isSubGroupTab:tab]) {
            button = (id)[self.subTabsHolder viewWithTag:tab];
            SET_BUTTON_SQUARE_STYLE_YELLOW(button);
            [button setTitleColor:COLOR_WHITE forState:UIControlStateNormal];
            [button setBackgroundImage:IMAGE_FROM_COLOR(COLOR_YELLOW) forState:
             UIControlStateSelected];
        }else{
            button = (id)[self.tabsHolderView viewWithTag:tab];
            SET_BUTTON_AS_COMMON_TAB_STYLE(button);
        }
        
        NSString *title = [self tabTitleforIndex:i];
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitle:title forState:UIControlStateSelected];
        [button setTitle:title forState:UIControlStateHighlighted];
    }
    
//    UIButton *newButton = (UIButton *)[self.subTabsHolder viewWithTag:TabTypeGroupNew];
//    SET_BUTTON_SQUARE_STYLE_YELLOW(newButton);
//    [newButton setTitleColor:COLOR_WHITE forState:UIControlStateNormal];
//    [newButton setBackgroundImage:IMAGE_FROM_COLOR(COLOR_YELLOW) forState:
//     UIControlStateSelected];
//    NSString *title = [self tabTitleforIndex:TabTypeGroupNew];
//    [newButton setTitle:title forState:UIControlStateNormal];
//    [newButton setTitle:title forState:UIControlStateSelected];
//    [newButton setTitle:title forState:UIControlStateHighlighted];
//    
//    UIButton *followButton = (UIButton *)[self.subTabsHolder viewWithTag:TabTypeGroupFollow];
//    SET_BUTTON_SQUARE_STYLE_YELLOW(followButton);
//    [followButton setTitleColor:COLOR_WHITE forState:UIControlStateNormal];
//    [followButton setBackgroundImage:IMAGE_FROM_COLOR(COLOR_YELLOW) forState:
//     UIControlStateSelected];
//    title = [self tabTitleforIndex:TabTypeGroupFollow];
//    [followButton setTitle:title forState:UIControlStateNormal];
//    [followButton setTitle:title forState:UIControlStateSelected];
//    [followButton setTitle:title forState:UIControlStateHighlighted];
//    
//    UIButton *topButton = (UIButton *)[self.subTabsHolder viewWithTag:TabTypeGroupPop];
//    SET_BUTTON_SQUARE_STYLE_YELLOW(topButton);
//    [topButton setTitleColor:COLOR_WHITE forState:UIControlStateNormal];
//    [topButton setBackgroundImage:IMAGE_FROM_COLOR(COLOR_YELLOW) forState:
//     UIControlStateSelected];
//    title = [self tabTitleforIndex:TabTypeGroupPop];
//    [topButton setTitle:title forState:UIControlStateNormal];
//    [topButton setTitle:title forState:UIControlStateSelected];
//    [topButton setTitle:title forState:UIControlStateHighlighted];
//    
//    UIButton *awardButton = (UIButton *)[self.subTabsHolder viewWithTag:TabTypeGroupAward];
//    SET_BUTTON_SQUARE_STYLE_YELLOW(awardButton);
//    [awardButton setTitleColor:COLOR_WHITE forState:UIControlStateNormal];
//    [awardButton setBackgroundImage:IMAGE_FROM_COLOR(COLOR_YELLOW) forState:
//     UIControlStateSelected];
//    title = [self tabTitleforIndex:TabTypeGroupAward];
//    [awardButton setTitle:title forState:UIControlStateNormal];
//    [awardButton setTitle:title forState:UIControlStateSelected];
//    [awardButton setTitle:title forState:UIControlStateHighlighted];
}

- (IBAction)clickTabButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if (button == currentTabButton || button == currentGroupSubButton) {
        return;
    }
    [button setSelected:YES];
    NSInteger tag = button.tag;
    if (![self isSubGroupTab:tag]) {
        [currentTabButton setSelected:NO];
        currentTabButton = button;
    }
    
    CGFloat originHeight = CGRectGetHeight(self.dataTableView.frame);
    CGFloat newHeight = originHeight;
    
    if ([self isGroupTab:tag]) {
        //don't load data. just show the sub tab buttons.
        
        if (_groupContestOnly && [self.groupId length] > 0) {
            self.subTabsHolder.hidden = YES;
        }else{
            self.subTabsHolder.hidden = NO;
        }
        
        [self.dataTableView updateOriginDataViewTableY:CGRectGetMaxY(self.subTabsHolder.frame)];
        float appHeight = CGRectGetHeight([[UIScreen mainScreen] applicationFrame]);
        float subTabsHolderMaxY = CGRectGetMaxY(self.subTabsHolder.frame);
        newHeight = appHeight - subTabsHolderMaxY;
        [self.dataTableView updateHeight:newHeight];

        if ([self isSubGroupTab:tag]) {
            [currentGroupSubButton setSelected:NO];
            currentGroupSubButton = sender;
            [self clickTab:tag];

        }else{
            if (!currentGroupSubButton) {
                [self clickTab:[self defaultGroupTab]];
                currentGroupSubButton = (id)[self.subTabsHolder viewWithTag:[self defaultGroupTab]];
            }else{
                [self clickTab:currentGroupSubButton.tag];
            }
        }
        currentGroupSubButton.selected = YES;
    }else{
        self.subTabsHolder.hidden = YES;
        [self.dataTableView updateOriginY:CGRectGetMaxY(self.tabsHolderView.frame)];
        newHeight = (CGRectGetHeight([[UIScreen mainScreen] applicationFrame]) - CGRectGetMaxY(self.tabsHolderView.frame));
        [self.dataTableView updateHeight:newHeight];
        [self clickTab:button.tag];
    }
}

- (BOOL)isSubGroupTab:(NSInteger)tab
{
    NSArray *tabs =@[
                     @(TabTypeGroupNew),
                     @(TabTypeGroupFollow),
                     @(TabTypeGroupPop),
                     @(TabTypeGroupAward)];
    
    return [tabs containsObject:@(tab)];
}

- (BOOL)isGroupTab:(NSInteger)tab
{
    if (tab == TabTypeOfficial) {
        return NO;
    }
    
    return YES;
}

- (GroupTab)defaultGroupTab
{
//    if([[[GroupManager defaultManager] followedGroupIds] count] > 0){
//        return TabTypeGroupFollow;
//    }
    return TabTypeGroupPop;
}

@end
