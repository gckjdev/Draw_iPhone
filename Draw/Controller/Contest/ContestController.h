//
//  ContestController.h
//  Draw
//
//  Created by  on 12-9-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommonTabController.h"
#import "ContestService.h"
#import "ContestView.h"

@class UICustomPageControl;
@interface ContestController : CommonTabController<ContestServiceDelegate, UIScrollViewDelegate>
{
    ContestService *_contestService;
    NSMutableArray *_contestViewList;
    UILabel *_noContestTipLabel;
}

- (IBAction)clickBackButton:(id)sender;
- (IBAction)clickRefreshButton:(id)sender;

- (void)enterDrawControllerWithContest:(Contest *)contest
                              animated:(BOOL)animated;
@property (retain, nonatomic) IBOutlet UILabel *noContestTipLabel;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UICustomPageControl *pageControl;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIView *scrollerViewHolder;
@property (retain, nonatomic) IBOutlet UIView *tableViewHolder;
@end
