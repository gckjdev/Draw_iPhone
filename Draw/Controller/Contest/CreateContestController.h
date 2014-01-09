//
//  CreateContestController.h
//  Draw
//
//  Created by 王 小涛 on 13-12-30.
//
//

#import "PPTableViewController.h"

#define NOTIFICATION_CREATE_CONTEST_SUCCESS @"NOTIFICATION_CREATE_CONTEST_SUCCESS"
#define NOTIFICATION_UPDATE_CONTEST_SUCCESS @"NOTIFICATION_UPDATE_CONTEST_SUCCESS"

@class Contest;
@interface CreateContestController : PPTableViewController

// 创建比赛
+ (void)enterFromController:(PPViewController *)controller;

// 修改比赛
+ (void)enterFromController:(PPViewController *)controller withContest:(Contest *)contest;

@end
