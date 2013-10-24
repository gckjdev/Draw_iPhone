//
//  ContestController.m
//  Draw
//
//  Created by  on 12-9-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ContestController.h"
#import "Contest.h"
#import "ConfigManager.h"
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
    [[ContestService defaultService] syncOngoingContestList];
    [self hideTips];
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setPageControl:nil];
    [self setTitleLabel:nil];
    [self setNoContestTipLabel:nil];
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


#pragma mark contest view delegate

- (void)didClickContestView:(ContestView *)contestView
             onReportButton:(Contest *)contest
{
    ContestOpusController *coc = [[ContestOpusController alloc] initWithContest:contest];
    [coc setDefaultTabIndex:0];
    [self.navigationController pushViewController:coc animated:YES];
    [coc release];
}

- (void)didClickContestView:(ContestView *)contestView 
               onOpusButton:(Contest *)contest
{
    ContestOpusController *coc = [[ContestOpusController alloc] initWithContest:contest];
    [self.navigationController pushViewController:coc animated:YES];
    [coc release];
}

- (void)didClickContestView:(ContestView *)contestView
               onJoinButton:(Contest *)contest
{
//    Test Code below
//    StatementController *sc = [[StatementController alloc] initWithContest:contest];
//    [self.navigationController pushViewController:sc animated:YES];
//    sc.superController = self;
//    [sc release];
//    return;
    
    //not running
//#if !DEBUG
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
}

#define StatementViewSize (ISIPAD ? CGSizeMake(690,874) : CGSizeMake(300,380))

- (void)didClickContestView:(ContestView *)contestView
             onDetailButton:(Contest *)contest
{
    UIWebView *webView = [[[UIWebView alloc] initWithFrame:CGRectFromCGSize(StatementViewSize)] autorelease];
    webView.scalesPageToFit = YES;
    CustomInfoView *infoView = [CustomInfoView createWithTitle:NSLS(@"kContestRule") infoView:webView hasEdgeSpace:NO];
    
    [infoView showInView:self.view];
    NSURLRequest *request = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:contest.statementUrl]];
    
    [webView loadRequest:request];
    [self setCanDragBack:NO];
    __block ContestController * cp = self;
    [infoView setCloseHandler:^{
        PPDebug(@"close rule info view");
        [cp setCanDragBack:YES];
    }];
}

- (void)dealloc {
    PPRelease(_scrollView);
    PPRelease(_pageControl);
    PPRelease(_contestViewList);
    PPRelease(_titleLabel);
    PPRelease(_noContestTipLabel);
    [[ContestManager defaultManager] setAllContestList:nil];
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
@end
