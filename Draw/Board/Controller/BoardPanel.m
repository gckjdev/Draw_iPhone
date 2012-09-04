//
//  BoardPanel.m
//  Draw
//
//  Created by  on 12-8-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BoardPanel.h"
#import "JumpHandler.h"
#import "AnimationManager.h"
//#import <QuartzCore/QuartzCore.h>
@interface BoardPanel()
{
    NSTimer *_timer;
}
- (void)gotoPage:(NSInteger)page animated:(BOOL)animated;
- (void)restartTimer;
- (void)handleTimer:(NSTimer *)theTimer;
- (void)stopTimer;
@end

@implementation BoardPanel
@synthesize scrollView;
@synthesize controller = _controller;
@synthesize pageControl;

+ (BoardPanel *)boardPanelWithController:(UIViewController *)controller;
{
    static NSString *identifier = @"BoardPanel";
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    BoardPanel *panel = [topLevelObjects objectAtIndex:0];
    panel.controller = controller;
    panel.scrollView.delegate = panel;
    return  panel;
}

#define PAGE_WIDTH  self.frame.size.width
#define PAGE_HEIGHT self.frame.size.height

- (CGRect)frameForIndex:(NSInteger)index boardView:(BoardView *)boardView
{
    CGFloat x = index * PAGE_WIDTH + (PAGE_WIDTH - boardView.frame.size.width) / 2.0;
    CGFloat y = (PAGE_HEIGHT - boardView.frame.size.height) / 2.0;
    
    return CGRectMake(x, y, boardView.frame.size.width, boardView.frame.size.height);
}

- (CGPoint)centerForFrame:(CGRect)frame
{
    CGFloat x = (frame.size.width - frame.origin.x) / 2.0;
    CGFloat y = (frame.size.height - frame.origin.y) / 2.0;
    return CGPointMake(x, y);
}
#define BOARD_VIEW_BASE_TAG 100
- (void)setBoardList:(NSArray *)boardList
{
    [scrollView setContentSize:CGSizeMake([boardList count] * PAGE_WIDTH, PAGE_HEIGHT)];
    if (_boardViews == nil) {
        _boardViews = [[NSMutableArray alloc] init];
    }
    [_boardViews removeAllObjects];
    
    int i = 0;
    for (Board *board in boardList) {
        BoardView *boardView = [BoardView createBoardView:board];
        if (boardView) {
            boardView.viewController = self.controller;
            boardView.delegate = self;
            boardView.frame = [self frameForIndex:i ++ boardView:boardView];
            [boardView loadView];
            boardView.tag = BOARD_VIEW_BASE_TAG + i;
            [self.scrollView addSubview:boardView];
            [_boardViews addObject:boardView];
        }
    }
    [self.pageControl setNumberOfPages:i];
    if (i > 1) {
        [self restartTimer];
    }
}

- (BoardView *)boardViewInPage:(NSInteger)page
{
    if (page >= 0 && page < [_boardViews count]) {
        return [_boardViews objectAtIndex:page];
    }
    return nil;
}

#pragma mark - Timer
#define TIMER_INTERVAL 15
#define TRASITION_DURATION 1

- (void)restartTimer
{
    [self stopTimer];
    _timer = [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];        
}

- (void)stopTimer
{
    if (_timer && [_timer isValid]) {
        [_timer invalidate];
    }
    _timer = nil;
}


- (void)handleTimer:(NSTimer *)theTimer
{
    NSInteger page = self.pageControl.currentPage;
    if (page >= self.pageControl.numberOfPages - 1) {
        page = 0;
    }else{
        page++;
    }
    [self gotoPage:page animated:NO];
    
    CAAnimation *transition = [AnimationManager trastionWithType:@"fade" duration:TRASITION_DURATION delegate:nil];
    [scrollView.layer addAnimation:transition forKey:@"transition"];        
}

#pragma mark - BoardView Delegate
- (void)boardView:(BoardView *)boardView HandleJumpURL:(NSURL *)URL
{
    if (![URL.host isEqualToString:BOARD_HOST]) {
        return;
    }
    NSDictionary *dict = [URL queryComponents];
    NSString *typeString = [dict objectForKey:BOARD_PARA_TYPE];
    JumpType type = [typeString integerValue];
    JumpHandler *jumpHandler = [JumpHandler createJumpHandlerWithType:type];
    [jumpHandler handleJump:boardView controller:self.controller URL:URL];    
    
}

- (BOOL)boardView:(BoardView *)boardView WillHandleJumpURL:(NSURL *)URL
{
    PPDebug(@"scheme = %@", URL.scheme);
    return [URL.scheme isEqualToString:BOARD_SCHEME_BOARD];
}

- (void)refreshBoardViewInPage:(NSInteger)page
{
    BoardView *boardView = [self boardViewInPage:page];
    [boardView viewWillAppear];
}

#pragma mark - scrollView delegate

- (CGPoint)offsetForPage
{
    CGFloat offset = [self.pageControl currentPage] * PAGE_WIDTH;
    return CGPointMake(offset, 0);
}

- (NSInteger)pageForOffset
{
    CGFloat offset = self.scrollView.contentOffset.x;
    return offset / PAGE_WIDTH;    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self stopTimer];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.pageControl.currentPage = [self pageForOffset];    
    PPDebug(@"scrollViewDidEndDecelerating, page = %d", self.pageControl.currentPage);    
    [self restartTimer];
    [self refreshBoardViewInPage:self.pageControl.currentPage];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    PPDebug(@"<BoardPanel>scrollViewDidEndScrollingAnimation");
    self.pageControl.currentPage = [self pageForOffset];     
}

- (void)gotoPage:(NSInteger)page animated:(BOOL)animated
{
    self.pageControl.currentPage = page;
    CGPoint offset = [self offsetForPage];
    [self.scrollView setContentOffset:offset animated:animated];
    [self refreshBoardViewInPage:page];
}
- (IBAction)changePage:(id)sender {
    [self.scrollView setContentOffset:[self offsetForPage] animated:YES];
    [self refreshBoardViewInPage:self.pageControl.currentPage];
}
- (void)dealloc {
    PPRelease(scrollView);
    PPRelease(_controller);
    PPRelease(pageControl);
    [super dealloc];
}
@end
