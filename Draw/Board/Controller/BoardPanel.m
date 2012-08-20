//
//  BoardPanel.m
//  Draw
//
//  Created by  on 12-8-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BoardPanel.h"
#import "JumpManager.h"


@implementation BoardPanel
@synthesize scrollView;
@synthesize controller = _controller;

+ (BoardPanel *)boardPanelWithController:(UIViewController *)controller;
{
    static NSString *identifier = @"BoardPanel";
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    BoardPanel *panel = [topLevelObjects objectAtIndex:0];
    panel.controller = controller;
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

- (void)setBoardList:(NSArray *)boardList
{
    [scrollView setContentSize:CGSizeMake([boardList count] * PAGE_WIDTH, PAGE_HEIGHT)];
        
    int i = 0;
    for (Board *board in boardList) {
        BoardView *boardView = [BoardView createBoardView:board];
        if (boardView) {
            boardView.delegate = self;
            boardView.frame = [self frameForIndex:i ++ boardView:boardView];
            [boardView loadView];
            [self.scrollView addSubview:boardView];
        }
    }
}

#pragma mark - BoardView Delegate
- (void)boardView:(BoardView *)boardView 
    HandleJumpURL:(NSURL *)URL
{
    JumpManager *jumpManager = [JumpManager defaultManager];
    [jumpManager jumpBoardView:boardView controller:self.controller request:URL];
}

- (BOOL)boardView:(BoardView *)boardView 
WillHandleJumpURL:(NSURL *)URL
{
    JumpManager *jumpManager = [JumpManager defaultManager];
    return ![jumpManager innerJump:URL];
}



- (void)dealloc {
    PPRelease(scrollView);
    PPRelease(_controller);
    [super dealloc];
}
@end
