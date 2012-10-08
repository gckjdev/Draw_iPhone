//
//  ContestController.h
//  Draw
//
//  Created by  on 12-9-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PPViewController.h"
#import "ContestService.h"
#import "ContestView.h"

@interface ContestController : PPViewController<ContestServiceDelegate, UIScrollViewDelegate>
{
    ContestService *_contestService;
    NSMutableArray *_contestViewList;
}

- (IBAction)clickBackButton:(id)sender;
- (IBAction)clickRefreshButton:(id)sender;

@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIPageControl *pageControl;


@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@end
