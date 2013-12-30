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
#import "ContestCell.h"

typedef enum{
    TabTypeOfficial = 1,
    TabTypeGroup = 2,
    TabTypeOpus = 3,
}TabType;


@implementation ContestController
@synthesize noContestTipLabel = _noContestTipLabel;
@synthesize scrollView = _scrollView;
@synthesize pageControl = _pageControl;
@synthesize titleLabel = _titleLabel;


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

- (void)getContestList
{
    [self showActivityWithText:NSLS(@"kLoading")];
    _contestService = [ContestService  defaultService];
    [_contestService getContestListWithType:ContestListTypeAll offset:0 limit:CONTEST_COUNT_LIMIT delegate:self];    
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initTabButtons];
    
    [self.titleLabel setText:NSLS(@"kContest")];
    SET_VIEW_BG(self.view);
    [self initCustomPageControl];
    [self getContestList];
    [self.noContestTipLabel setHidden:YES];
    
    CommonTitleView *titleView = [CommonTitleView createTitleView:self.view];
    [titleView setTarget:self];
    [titleView setTitle:NSLS(@"kContest")];
    [titleView setRightButtonAsRefresh];
    [titleView setRightButtonSelector:@selector(clickRefreshButton:)];
    [titleView setBackButtonSelector:@selector(clickBackButton:)];
    [self hideTips];
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setPageControl:nil];
    [self setTitleLabel:nil];
    [self setNoContestTipLabel:nil];
    [self setScrollerViewHolder:nil];
    [self setTableViewHolder:nil];
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
//    CGFloat width = [ContestView getViewWidth];
//    CGFloat height = [ContestView getViewHeight];
    CGFloat width = self.scrollView.frame.size.width;
    CGFloat height = self.scrollView.frame.size.height;
    
    NSInteger count = [contestList count];
    [self.scrollView setContentSize:CGSizeMake(width * count, height)];
    for (Contest *contest in contestList) {
//        if ([contest isRunning] && showIndex == 0) {
//            showIndex = i;
//        }
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
    
//    [self.view bringSubviewToFront:self.pageControl];
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
    [self updatePage];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self updatePage];    
}



#pragma mark contest service delegate

- (void)didGetContestList:(NSArray *)contestList 
                     type:(ContestListType)type 
               resultCode:(NSInteger)code
{

    PPDebug(@"didGetContestList, type = %d, code = %d, contestList = %@", type,code,contestList);
    if (code == 0) {
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
    [self hideActivity];
}

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
//#endif
    
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
    PPRelease(_titleLabel);
    PPRelease(_noContestTipLabel);
    [[ContestManager defaultManager] setAllContestList:nil];
    [_scrollerViewHolder release];
    [_tableViewHolder release];
    [super dealloc];
}
- (IBAction)clickRefreshButton:(id)sender {
    [self getContestList];
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
    
    return 3;
};

- (NSInteger)currentTabIndex{
    
    return 0;
}

- (NSInteger)fetchDataLimitForTabIndex:(NSInteger)index{
    
    return 20;
}

- (NSInteger)tabIDforIndex:(NSInteger)index{
    
    int indexs[] = {TabTypeOfficial,TabTypeGroup,TabTypeOpus};
    return indexs[index];
}

- (NSString *)tabTitleforIndex:(NSInteger)index{
    NSString *titles[] = {NSLS(@"kOfficialContest"),NSLS(@"kGroupContest"),NSLS(@"kGoodOpus")};
    return titles[index];
}

- (void)serviceLoadDataForTabID:(NSInteger)tabID{
    
    
    switch (tabID) {
        case TabTypeOfficial:
            [[ContestService defaultService] syncOngoingContestList];
            break;
            
        case TabTypeGroup:
            
            break;
            
        case TabTypeOpus:
            
            break;
            
        default:
            break;
    }
}

- (void)clickTab:(NSInteger)tabID{
    
    [super clickTab:tabID];
    
    switch (tabID) {
        case TabTypeOfficial:
            self.scrollerViewHolder.hidden = NO;
            self.tableViewHolder.hidden = YES;

            break;
            
        case TabTypeGroup:
            self.scrollerViewHolder.hidden = YES;
            self.tableViewHolder.hidden = NO;

            break;
            
        case TabTypeOpus:
            self.scrollerViewHolder.hidden = YES;
            self.tableViewHolder.hidden = NO;
            break;
            
        default:
            break;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ContestCell *cell = [tableView dequeueReusableCellWithIdentifier:[ContestCell getCellIdentifier]];
    if (cell == nil) {
        cell = [ContestCell createCell:self];
    }
    
    PBContest *pbContest = [[[ContestManager defaultManager] allContestList] objectAtIndex:indexPath.row];
    Contest *contest = [[[Contest alloc] initWithPBContest:pbContest] autorelease];
    [cell setCellInfo:contest];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    int count = [[[ContestManager defaultManager] allContestList] count];
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return [ContestCell getCellHeight];
}



@end
