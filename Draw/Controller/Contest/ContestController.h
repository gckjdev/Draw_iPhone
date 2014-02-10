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
    NSMutableArray *_contestViewList;
}

@property (retain, nonatomic) IBOutlet UILabel *noContestTipLabel;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UICustomPageControl *pageControl;
@property (retain, nonatomic) IBOutlet UIView *scrollerViewHolder;

- (IBAction)clickBackButton:(id)sender;
- (void)enterDrawControllerWithContest:(Contest *)contest
                              animated:(BOOL)animated;

// 官方比赛+家族比赛，默认选中家族比赛
- (id)initWithGroupDefault;

// 仅有家族比赛，没有官方比赛，家族比赛为所有家族的比赛。
- (id)initWithGroupContestOnly;

// 仅有家族比赛，没有官方比赛，家族比赛为指定的某个家族的比赛。
- (id)initWithGroupId:(NSString *)groupId;

@end
