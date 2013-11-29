//
//  TaskManager.h
//  Draw
//
//  Created by qqn_pipi on 13-11-14.
//
//

#import <Foundation/Foundation.h>
#import "PPSNSConstants.h"
#import <ShareSDK/ShareSDK.h>

#define TASK_DATA_RELOAD_NOTIFICATION       @"TASK_DATA_RELOAD_NOTIFICATION"

@class GameTask;
@class PPViewController;

@interface TaskManager : NSObject

+ (TaskManager*)defaultManager;

@property (nonatomic, retain) NSMutableArray *taskList;
@property (nonatomic, retain) PPViewController *viewController;

- (void)execute:(GameTask*)task viewController:(PPViewController*)viewController;
- (void)awardTask:(GameTask*)task viewController:(PPViewController*)viewController;
- (void)awardTaskSuccess:(int)taskId amount:(int)amount;

- (void)completeTask:(PBTaskIdType)taskId isAward:(BOOL)isAward clearBadge:(BOOL)clearBadge;
- (void)completeBindWeiboTask:(ShareType)shareType isAward:(BOOL)isAward clearBadge:(BOOL)clearBadge;
- (int)totalBadge;
- (void)loadTask;

@end
