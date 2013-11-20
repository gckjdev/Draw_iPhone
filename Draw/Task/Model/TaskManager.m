//
//  TaskManager.m
//  Draw
//
//  Created by qqn_pipi on 13-11-14.
//
//

#import "TaskManager.h"
#import "GameTask.h"
#import "GameSNSService.h"

#define USER_TASK_LIST_KEY @"USER_TASK_LIST_KEY_1"

static TaskManager* _defaultTaskManager;

@implementation TaskManager

+ (TaskManager*)defaultManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultTaskManager = [[TaskManager alloc] init];
        [_defaultTaskManager loadTask];
    });
    
    return _defaultTaskManager;
}

- (NSArray*)createInitTaskList
{
    NSMutableArray* retList = [NSMutableArray array];
    
    GameTask* task1 = [[GameTask alloc] initWithId:PBTaskIdTypeTaskCheckIn
                                             name:NSLS(@"kTaskCheckIn")
                                             desc:NSLS(@"kTaskCheckInDesc")
                                           status:PBTaskStatusTaskStatusCanTake
                                            badge:1
                                          selector:@selector(checkIn)];
    
    GameTask* task2 = [[GameTask alloc] initWithId:PBTaskIdTypeTaskBindSina
                                             name:NSLS(@"kTaskBindSinaWeibo")
                                             desc:NSLS(@"kTaskBindSinaWeiboDesc")
                                           status:PBTaskStatusTaskStatusCanTake
                                            badge:1
                                          selector:@selector(bindSinaWeibo)];
    
    GameTask* task3 = [[GameTask alloc] initWithId:PBTaskIdTypeTaskBindQq
                                              name:NSLS(@"kTaskBindQQWeibo")
                                              desc:NSLS(@"kTaskBindQQWeiboDesc")
                                            status:PBTaskStatusTaskStatusCanTake
                                             badge:1
                                          selector:@selector(checkIn)];

    GameTask* task4 = [[GameTask alloc] initWithId:PBTaskIdTypeTaskShareSina
                                              name:NSLS(@"kTaskShareSinaWeibo")
                                              desc:NSLS(@"kTaskShareSinaWeiboDesc")
                                            status:PBTaskStatusTaskStatusCanTake
                                             badge:1
                                          selector:@selector(checkIn)];
    
    GameTask* task5 = [[GameTask alloc] initWithId:PBTaskIdTypeTaskShareWeixinTimeline
                                              name:NSLS(@"kTaskShareWeixinTimeline")
                                              desc:NSLS(@"kTaskShareWeixinTimelineDesc")
                                            status:PBTaskStatusTaskStatusCanTake
                                             badge:1
                                          selector:@selector(checkIn)];

    GameTask* task6 = [[GameTask alloc] initWithId:PBTaskIdTypeTaskShareQqSpace
                                              name:NSLS(@"kTaskShareQQSpace")
                                              desc:NSLS(@"kTaskShareQQSpaceDesc")
                                            status:PBTaskStatusTaskStatusCanTake
                                             badge:1
                                          selector:@selector(checkIn)];
    
    GameTask* task7 = [[GameTask alloc] initWithId:PBTaskIdTypeTaskCreateOpus
                                              name:NSLS(@"kTaskCreateOpus")
                                              desc:NSLS(@"kTaskCreateOpusDesc")
                                            status:PBTaskStatusTaskStatusCanTake
                                             badge:1
                                          selector:@selector(checkIn)];

    GameTask* task8 = [[GameTask alloc] initWithId:PBTaskIdTypeTaskGuessOpus
                                              name:NSLS(@"kTaskGuessOpus")
                                              desc:NSLS(@"kTaskGuessOpusDesc")
                                            status:PBTaskStatusTaskStatusCanTake
                                             badge:1
                                          selector:@selector(checkIn)];

    GameTask* task9 = [[GameTask alloc] initWithId:PBTaskIdTypeTaskShareOpus
                                              name:NSLS(@"kTaskShareOpus")
                                              desc:NSLS(@"kTaskShareOpusDesc")
                                            status:PBTaskStatusTaskStatusCanTake
                                             badge:1
                                          selector:@selector(checkIn)];

    GameTask* task10 = [[GameTask alloc] initWithId:PBTaskIdTypeTaskAppReview
                                              name:NSLS(@"kTaskAppReview")
                                              desc:NSLS(@"kTaskAppReviewDesc")
                                            status:PBTaskStatusTaskStatusCanTake
                                             badge:1
                                           selector:@selector(checkIn)];

    
    [retList addObject:task1];
    [retList addObject:task2];
    [retList addObject:task3];
    [retList addObject:task4];
    [retList addObject:task5];
    [retList addObject:task6];
    [retList addObject:task7];
    [retList addObject:task8];
    [retList addObject:task9];
    [retList addObject:task10];
    
    return retList;
}

- (void)loadTask
{
    // init task list
    NSArray* list = [self createInitTaskList];
    self.taskList = [NSMutableArray arrayWithArray:list];    
    
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    NSArray* pbList = [ud objectForKey:USER_TASK_LIST_KEY];
    if (pbList){
        // data list to task list
        for (NSData* data in pbList){
            GameTask* task = [GameTask taskFromData:data];
            if (task != nil){
                for (GameTask* t in self.taskList){
                    if (t.taskId == task.taskId){
                        // TODO set other user status here
                        [t setStatus:task.status];
                        break;
                    }
                }
            }
        }

    }
    
    // save
    [self save];
    
}

- (void)save
{
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    if (self.taskList){
        
        // task list to data list
        NSMutableArray* pbList = [NSMutableArray array];
        for (GameTask* task in self.taskList){
            NSData* data = [task data];
            if (data){
                [pbList addObject:data];
            }
        }
        
        [ud setObject:pbList forKey:USER_TASK_LIST_KEY];
    }
}

- (void)execute:(GameTask*)task viewController:(PPViewController*)viewController
{
    if (task.selector && [self respondsToSelector:task.selector]){
        [self performSelector:task.selector];
    }
}

- (void)bindSinaWeibo
{
    [[GameSNSService defaultService] autheticate:TYPE_SINA];
}

@end
