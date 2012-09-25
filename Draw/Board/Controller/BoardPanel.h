//
//  BoardPanel.h
//  Draw
//
//  Created by  on 12-8-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BoardView.h"
#import "UICustomPageControl.h"

@interface BoardPanel : UIView<BoardViewDelegate, UIScrollViewDelegate>
{
    UIViewController *_controller;
    NSMutableArray *_boardViews;
}
+ (BoardPanel *)boardPanelWithController:(UIViewController *)controller;
- (void)setBoardList:(NSArray *)boardList;
- (IBAction)changePage:(id)sender;

@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) UIViewController *controller;
@property (retain, nonatomic) IBOutlet UICustomPageControl *pageControl;

// call this before release the panel or view disappear
- (void)stopTimer;

// call this when view didappear
- (void)restartTimer;

- (void)clearAds;

@end
