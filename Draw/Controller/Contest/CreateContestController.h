//
//  CreateContestController.h
//  Draw
//
//  Created by 王 小涛 on 13-12-30.
//
//

#import "PPTableViewController.h"

#define NOTIFICATION_CREATE_CONTEST_SUCCESS @"NOTIFICATION_CREATE_CONTEST_SUCCESS"

@interface CreateContestController : PPTableViewController

+ (void)enterFromController:(PPViewController *)controller;

@end
