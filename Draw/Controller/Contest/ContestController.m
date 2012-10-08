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
#import "StatementView.h"
#import "StatementController.h"
#import "CommonMessageCenter.h"
#import "ContestOpusController.h"
#import "CommonMessageCenter.h"

@implementation ContestController
@synthesize scrollView = _scrollView;
@synthesize pageControl = _pageControl;
@synthesize titleLabel = _titleLabel;

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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.titleLabel setText:NSLS(@"kContest")];
    _contestViewList = [[NSMutableArray alloc] init];
    _contestService = [ContestService  defaultService];
    [_contestService getContestListWithType:ContestListTypeAll offset:0 limit:12 delegate:self];
    [self showActivityWithText:NSLS(@"kLoading")];
    
//    UIColor *bgColor = [UIColor colorWithRed:245.0/255.0 green:240.0/255.0 blue:220./255. alpha:1.0];
    [self.view setBackgroundColor:[UIColor darkGrayColor]];
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setPageControl:nil];
    [self setTitleLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    CGFloat width = [ContestView getViewWidth];
    CGFloat height = [ContestView getViewHeight];
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
    [self.pageControl setCurrentPage:0];
    
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
    PPDebug(@"<scrollViewDidEndDragging>");
    [self updatePage];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    PPDebug(@"<scrollViewDidEndDecelerating>");
    [self updatePage];    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    PPDebug(@"<scrollViewDidScroll>:offset = %@",NSStringFromCGPoint(scrollView.contentOffset));
}

#pragma mark contest service delegate

- (void)didGetContestList:(NSArray *)contestList 
                     type:(ContestListType)type 
               resultCode:(NSInteger)code
{

    PPDebug(@"didGetContestList, type = %d, code = %d, contestList = %@", type,code,contestList);
    if (code == 0) {
        [self updateScorollViewWithContestList:contestList];
    }else{
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kFailLoad") delayTime:1.5 isHappy:NO];
    }
    [self hideActivity];
}

- (IBAction)clickBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark contest view delegate

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
    //not running
    if (![contest isRunning]) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kContestNotRunning") delayTime:1.5 isHappy:NO];
        return;
    }else if([contest commintCountEnough]){
        NSString *title = [NSString stringWithFormat:NSLS(@"kContesSummitCountEnough"),contest.canSubmitCount];
        [[CommonMessageCenter defaultCenter] postMessageWithText:title 
                                                       delayTime:1.5 
                                                         isHappy:NO];        
        return;
    }
    //user limit
    
    //
    StatementController *sc = [[StatementController alloc] initWithContest:contest];
    [self.navigationController pushViewController:sc animated:YES];
    [sc release];
}

- (void)didClickContestView:(ContestView *)contestView
             onDetailButton:(Contest *)contest
{
    StatementView *state = [StatementView createStatementView:self];
    [state setViewInfo:contest];
    [state showInView:self.view];
}

- (void)dealloc {
    PPRelease(_scrollView);
    PPRelease(_pageControl);
    PPRelease(_contestViewList);
    PPRelease(_titleLabel);
    [super dealloc];
}
@end
