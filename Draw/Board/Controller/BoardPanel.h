//
//  BoardPanel.h
//  Draw
//
//  Created by  on 12-8-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BoardView.h"
@interface BoardPanel : UIView<BoardViewDelegate>
{
    UIViewController *_controller;
}
+ (BoardPanel *)boardPanelWithController:(UIViewController *)controller;
- (void)setBoardList:(NSArray *)boardList;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) UIViewController *controller;
@property (retain, nonatomic) IBOutlet UIPageControl *pageControl;
@end
