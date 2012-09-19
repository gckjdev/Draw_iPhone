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

@implementation ContestController
@synthesize scrollView = _scrollView;
@synthesize pageControl = _pageControl;

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
    _contestViewList = [[NSMutableArray alloc] init];
    _contestService = [ContestService  defaultService];
    [_contestService getContestListWithType:ContestListTypeAll offset:0 limit:12 delegate:self];
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setPageControl:nil];
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
//        [contestView refreshRequest];
    }
    [self.pageControl setNumberOfPages:count];
    [self.pageControl setCurrentPage:0];
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
    }
}

- (IBAction)clickBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark contest view delegate

- (void)didClickContestView:(ContestView *)contestView 
               onOpusButton:(Contest *)contest
{
    PPDebug(@"click opus button");
}

- (void)didClickContestView:(ContestView *)contestView
               onJoinButton:(Contest *)contest
{
    PPDebug(@"click join button");    
}

- (void)didClickContestView:(ContestView *)contestView
             onDetailButton:(Contest *)contest
{
    PPDebug(@"click detail button");
}

- (void)dealloc {
    PPRelease(_scrollView);
    PPRelease(_pageControl);
    PPRelease(_contestViewList);
    [super dealloc];
}
@end
