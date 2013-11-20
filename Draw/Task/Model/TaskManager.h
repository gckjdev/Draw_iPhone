//
//  TaskManager.h
//  Draw
//
//  Created by qqn_pipi on 13-11-14.
//
//

#import <Foundation/Foundation.h>

@class GameTask;
@class PPViewController;

@interface TaskManager : NSObject

+ (TaskManager*)defaultManager;

@property (nonatomic, retain) NSMutableArray *taskList;

- (void)execute:(GameTask*)task viewController:(PPViewController*)viewController;

@end
