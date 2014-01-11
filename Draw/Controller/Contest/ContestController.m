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

typedef enum{
    TabTypeOfficial = 1,
    TabTypeGroup = 2,
//    TabTypeOpus = 3,
}TabType;

@interface ContestController()<FeedServiceDelegate, ContestCellDelegate>

@property (assign, nonatomic) BOOL groupContestOnly;
@property (copy, nonatomic) NSString *groupId;


@property (retain, nonatomic) IBOutlet UIButton *officialButton;
@property (retain, nonatomic) IBOutlet UIButton *groupButton;
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

- (id)initWithGroupContestOnly{
    
    if (self = [super init]) {
        self.groupContestOnly = YES;
    }
    
    return self;
}

// 仅有家族比赛，没有官方比赛，家族比赛为指定的某个家族的比赛。
- (id)initWithGroupId:(NSString *)groupId{
    
    if (self = [super init]) {
        self.groupContestOnly = YES;
        self.groupId = groupId;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    SET_VIEW_BG(self.view);
    [self initCustomPageControl];
    
    CommonTitleView *titleView = [CommonTitleView createTitleView:self.view];
    [titleView setTarget:self];
    [titleView setTitle:NSLS(@"kContest")];
    [titleView setBackButtonSelector:@selector(clickBackButton:)];
    [self hideTips];
    
    if (_groupContestOnly) {
//        self.officialButton.hidden = YES;
//        self.groupButton.hidden = YES;
        [self.officialButton removeFromSuperview];
        [self.groupButton removeFromSuperview];
        
        GroupPermissionManager *permission =[GroupPermissionManager myManagerWithGroupId:self.groupId];
        if ([permission canHoldContest]) {
            [titleView setRightButtonTitle:NSLS(@"kCreate")];
            [titleView setRightButtonSelector:@selector(clickCreateButton:)];
        } ;
        [self clickTab:TabTypeGroup];
    }else{
        [self initTabButtons];
//        self.officialButton.hidden = NO;
//        self.groupButton.hidden = NO;
    }
    
    if (_groupContestOnly) {
        self.view.backgroundColor = COLOR_WHITE;

    }else{
        self.view.backgroundColor = COLOR_GRAY;
        
//        int delta = (ISIPAD ? 30 *2 : 30);
        CGFloat y = CGRectGetMaxY(self.groupButton.frame);
        [self.dataTableView updateOriginY:y];
        [self.dataTableView updateHeight:(CGRectGetHeight(self.view.bounds) - y)];
    }
    
    [[ContestService defaultService] syncOngoingContestList];
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setPageControl:nil];
    [self setNoContestTipLabel:nil];
    [self setScrollerViewHolder:nil];
    [self setOfficialButton:nil];
    [self setGroupButton:nil];
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
    
    if (_groupContestOnly) {
        return 1;
    }else{
        return 2;
    }
};

- (NSInteger)currentTabIndex{
    
    return 0;
}

- (NSInteger)fetchDataLimitForTabIndex:(NSInteger)index{
    
    return 20;
}

- (NSInteger)tabIDforIndex:(NSInteger)index{
    
    if (_groupContestOnly) {
        return TabTypeGroup;
    }else{
        int indexs[] = {TabTypeOfficial,TabTypeGroup};
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
            
        default:
            return nil;
    }
}

- (void)serviceLoadDataForTabID:(NSInteger)tabID{
    
    
    switch (tabID) {
        case TabTypeOfficial:
            [self loadOfficialContestList];
            break;
            
        case TabTypeGroup:
            [self loadGroupContestList];
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

- (void)loadGroupContestList{
    
    [self showActivityWithText:NSLS(@"kLoading")];

    if ([self.groupId length] == 0) {
        [[ContestService defaultService] getGroupContestListWithType:ContestListTypeAllGroup offset:self.currentTab.offset limit:self.currentTab.limit completed:^(int resultCode, ContestListType type, NSArray *contestList) {
            
            [self hideActivity];
            if (resultCode == 0) {
                [self finishLoadDataForTabID:TabTypeGroup resultList:contestList];
            }else{
                [self failLoadDataForTabID:TabTypeGroup];
            }
        }];
    }else{
        
        [[ContestService defaultService] getContestListWithGroupId:self.groupId offset:self.currentTab.offset limit:self.currentTab.limit completed:^(int resultCode, ContestListType type, NSArray *contestList) {
            
            [self hideActivity];
            if (resultCode == 0) {
                [self finishLoadDataForTabID:TabTypeGroup resultList:contestList];
            }else{
                [self failLoadDataForTabID:TabTypeGroup];
            }
        }];
    }
   
}

//- (void)loadWonderfulOpusList{
//    
//    [self showActivityWithText:NSLS(@"kLoading")];
//
//    [[FeedService defaultService] getWonderfulContestOpusListWithOffset:self.currentTab.offset limit:self.currentTab.limit completed:^(int resultCode, NSArray *feedList) {
//        
//        [self hideActivity];
//        if (resultCode == 0) {
//            [self finishLoadDataForTabID:TabTypeOpus resultList:feedList];
//        }else{
//            [self failLoadDataForTabID:TabTypeOpus];
//        }
//    }];
//}

- (NSString *)tabNoDataTipsforIndex:(NSInteger)index{
    
    
    
    TabType tabId = [self tabIDforIndex:index];
    switch (tabId) {
        case TabTypeOfficial:
            return NSLS(@"");
            
        case TabTypeGroup:
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
            return [CellManager getContestStyleCell:tableView
                                          indexPath:indexPath
                                           delegate:self
                                           dataList:self.currentTab.dataList];
            
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

@end
