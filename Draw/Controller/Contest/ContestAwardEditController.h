//
//  ContestAwardEditController.h
//  Draw
//
//  Created by 王 小涛 on 14-1-3.
//
//

#import "PPTableViewController.h"
#import "Contest.h"

#define NotificationContestAwardEditDone @"NotificationContestAwardEditDone"
@interface ContestAwardEditController : PPTableViewController

- (id)initWithContest:(Contest *)contest;

@end
