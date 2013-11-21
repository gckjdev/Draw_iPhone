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
#import "PPConfigManager.h"
#import "DrawAppDelegate.h"
#import "SuperHomeController.h"
#import "SingController.h"
#import "OfflineDrawViewController.h"
#import "HotController.h"
#import "AccountService.h"

#define USER_TASK_LIST_KEY @"USER_TASK_LIST_KEY_4"

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
                                           status:PBTaskStatusTaskStatusAlwaysOpen
                                            badge:0
                                             award:0
                                          selector:@selector(checkIn:)];
    
    GameTask* task2 = [[GameTask alloc] initWithId:PBTaskIdTypeTaskBindSina
                                             name:NSLS(@"kTaskBindSinaWeibo")
                                              desc:[NSString stringWithFormat:NSLS(@"kTaskBindSinaWeiboDesc"), [PPConfigManager getFollowWeiboReward]]
                                           status:PBTaskStatusTaskStatusCanTake
                                            badge:1
                                             award:[PPConfigManager getFollowWeiboReward]
                                          selector:@selector(bindSinaWeibo:)];
    
    GameTask* task3 = [[GameTask alloc] initWithId:PBTaskIdTypeTaskBindQq
                                              name:NSLS(@"kTaskBindQQWeibo")
                                              desc:[NSString stringWithFormat:NSLS(@"kTaskBindQQWeiboDesc"), [PPConfigManager getFollowWeiboReward]]
                                            status:PBTaskStatusTaskStatusCanTake
                                             badge:1
                                             award:[PPConfigManager getFollowWeiboReward]
                                          selector:@selector(bindQQWeibo:)];

    GameTask* task4 = [[GameTask alloc] initWithId:PBTaskIdTypeTaskShareSina
                                              name:NSLS(@"kTaskShareSinaWeibo")
                                              desc:[NSString stringWithFormat:NSLS(@"kTaskShareSinaWeiboDesc"), [PPConfigManager getShareAppWeiboReward]]
                                            status:PBTaskStatusTaskStatusCanTake
                                             badge:1
                                             award:[PPConfigManager getShareAppWeiboReward]
                                          selector:@selector(shareSinaWeibo:)];
    
    GameTask* task5 = [[GameTask alloc] initWithId:PBTaskIdTypeTaskShareWeixinTimeline
                                              name:NSLS(@"kTaskShareWeixinTimeline")
                                              desc:[NSString stringWithFormat:NSLS(@"kTaskShareWeixinTimelineDesc"), [PPConfigManager getShareAppWeiboReward]]
                                            status:PBTaskStatusTaskStatusCanTake
                                             badge:1
                                             award:[PPConfigManager getShareAppWeiboReward]                       
                                          selector:@selector(shareWeixinTimeline:)];
    
    GameTask* task6 = [[GameTask alloc] initWithId:PBTaskIdTypeTaskShareQqSpace
                                              name:NSLS(@"kTaskShareQQSpace")
                                              desc:[NSString stringWithFormat:NSLS(@"kTaskShareQQSpaceDesc"), [PPConfigManager getShareAppWeiboReward]]
                                            status:PBTaskStatusTaskStatusCanTake
                                             badge:1
                                             award:[PPConfigManager getShareAppWeiboReward]                       
                                          selector:@selector(shareQQSpace:)];
    
    GameTask* task61 = [[GameTask alloc] initWithId:PBTaskIdTypeTaskShareQqWeibo
                                              name:NSLS(@"kTaskShareQQWeibo")
                                              desc:[NSString stringWithFormat:NSLS(@"kTaskShareQQWeiboDesc"), [PPConfigManager getShareAppWeiboReward]]
                                            status:PBTaskStatusTaskStatusCanTake
                                             badge:1
                                              award:[PPConfigManager getShareAppWeiboReward]                        
                                           selector:@selector(shareQQWeibo:)];

    
    GameTask* task7 = [[GameTask alloc] initWithId:PBTaskIdTypeTaskCreateOpus
                                              name:NSLS(@"kTaskCreateOpus")
                                              desc:[NSString stringWithFormat:NSLS(@"kTaskCreateOpusDesc"), [PPConfigManager getFirstCreateOpusWeiboReward]]
                                            status:PBTaskStatusTaskStatusCanTake
                                             badge:1
                                             award:[PPConfigManager getFirstCreateOpusWeiboReward]                       
                                          selector:@selector(createOpus:)];

    GameTask* task8 = [[GameTask alloc] initWithId:PBTaskIdTypeTaskGuessOpus
                                              name:NSLS(@"kTaskGuessOpus")
                                              desc:[NSString stringWithFormat:NSLS(@"kTaskGuessOpusDesc"), [PPConfigManager getFirstGuessOpusReward]]
                                            status:PBTaskStatusTaskStatusCanTake
                                             badge:1
                                             award:[PPConfigManager getFirstGuessOpusReward]                       
                                          selector:@selector(guessOpus:)];

    GameTask* task9 = [[GameTask alloc] initWithId:PBTaskIdTypeTaskShareOpus
                                              name:NSLS(@"kTaskShareOpus")
                                              desc:[NSString stringWithFormat:NSLS(@"kTaskShareOpusDesc"), [PPConfigManager getShareWeiboReward]]
                                            status:PBTaskStatusTaskStatusAlwaysOpen
                                             badge:1
                                             award:[PPConfigManager getShareWeiboReward]                       
                                          selector:@selector(shareOpus:)];

    GameTask* task10 = [[GameTask alloc] initWithId:PBTaskIdTypeTaskAppReview
                                              name:NSLS(@"kTaskAppReview")
                                              desc:NSLS(@"kTaskAppReviewDesc")
                                            status:PBTaskStatusTaskStatusAlwaysOpen
                                             badge:1
                                              award:0
                                           selector:@selector(gotoAppReview:)];
    
    
    
    GameTask* task11 = [[GameTask alloc] initWithId:PBTaskIdTypeTaskAppUpgrade
                                               name:NSLS(@"kTaskAppUpgrade")
                                               desc:[NSString stringWithFormat:NSLS(@"kTaskAppUpgradeDesc"),
                                                     [PPConfigManager getLastAppVersion]]
                                             status:PBTaskStatusTaskStatusAlwaysOpen
                                              badge:1
                                              award:0
                                           selector:@selector(upgradeApp:)];

    
//    [retList addObject:task1];
    [retList addObject:task2];
    [retList addObject:task3];
    [retList addObject:task4];
    [retList addObject:task5];
    [retList addObject:task61];
    [retList addObject:task6];
    [retList addObject:task7];
    [retList addObject:task8];
    [retList addObject:task9];
    
    if ([PPConfigManager isInReviewVersion] == NO){
        [retList addObject:task10];
    }
    
    if ([UIUtils checkAppHasUpdateVersion]){
        [retList addObject:task11];
    }
    else{
        // clean local app upgrade task status
        
    }
    
    return retList;
}

- (NSString*)getKey
{
    return [NSString stringWithFormat:@"%@_%@", USER_TASK_LIST_KEY, [[UserManager defaultManager] userId]];
}

- (void)loadTask
{
    // init task list
    NSArray* list = [self createInitTaskList];
    self.taskList = [NSMutableArray arrayWithArray:list];    
    
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    NSArray* pbList = [ud objectForKey:[self getKey]];
    if (pbList){
        // data list to task list
        for (NSData* data in pbList){
            GameTask* task = [GameTask taskFromData:data];
            if (task != nil){
                for (GameTask* t in self.taskList){
                    if (t.taskId == task.taskId){
                        // TODO set other user status here
                        [t setStatus:task.status];
                        [t setBadge:task.badge];
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
        
        PPDebug(@"save task list");
        
        // task list to data list
        NSMutableArray* pbList = [NSMutableArray array];
        for (GameTask* task in self.taskList){
            
            if (task.taskId == PBTaskIdTypeTaskAppUpgrade &&
                [UIUtils checkAppHasUpdateVersion] == NO){                
                // if app is upgraded
                // don't save app upgrade info in data for next upgrade
                continue;
            }
            
            NSData* data = [task data];
            if (data){
                [pbList addObject:data];
            }
        }
        
        [ud setObject:pbList forKey:[self getKey]];
        [ud synchronize];
    }
}

- (void)execute:(GameTask*)task viewController:(PPViewController*)viewController
{
    [self clearTaskBadge:task];
    
    self.viewController = viewController;
    
    if (task.selector && [self respondsToSelector:task.selector]){
        PPDebug(@"<executeTask> task(%d)", task.taskId);
        [self performSelector:task.selector withObject:task];
    }
    
    self.viewController = nil;
}

- (void)awardTask:(GameTask*)task viewController:(PPViewController*)viewController
{
    [self clearTaskBadge:task];
    
    if (task.status != PBTaskStatusTaskStatusDone){
        return;
    }

    self.viewController = viewController;
    [[AccountService defaultService] chargeCoin:task.award source:TaskAward+task.taskId];
}

- (void)bindSinaWeibo:(GameTask*)task
{
    [[GameSNSService defaultService] autheticate:TYPE_SINA];
}

- (void)bindQQWeibo:(GameTask*)task
{
    [[GameSNSService defaultService] autheticate:TYPE_QQ];
}

- (NSString*)getShareAppWeiboText
{
    NSString *shareBody = [NSString stringWithFormat:NSLS(@"kShareAppWeiboDefault"),
                           NSLocalizedStringFromTable(@"CFBundleDisplayName", @"InfoPlist", @""),
                           [UIUtils getAppLink:[PPConfigManager appId]]];

    return shareBody;
}

- (void)shareSinaWeibo:(GameTask*)task
{
    [[GameSNSService defaultService] publishWeibo:TYPE_SINA
                                             text:[self getShareAppWeiboText]
                                    imageFilePath:nil
                                           inView:nil
                                       awardCoins:[PPConfigManager getShareAppWeiboReward]
                                   successMessage:NSLS(@"kShareWeiboSucc")
                                   failureMessage:NSLS(@"kShareWeiboFailure")
                                           taskId:task.taskId];
}

- (void)shareWeixinTimeline:(GameTask*)task
{
    [[GameSNSService defaultService] publishWeibo:TYPE_WEIXIN_TIMELINE
                                             text:[self getShareAppWeiboText]
                                    imageFilePath:nil
                                           inView:nil
                                       awardCoins:[PPConfigManager getShareAppWeiboReward]
                                   successMessage:NSLS(@"kShareWeiboSucc")
                                   failureMessage:NSLS(@"kShareWeiboFailure")
                                           taskId:task.taskId];
}

- (void)shareQQSpace:(GameTask*)task
{
    [[GameSNSService defaultService] publishWeibo:TYPE_QQSPACE
                                             text:[self getShareAppWeiboText]
                                    imageFilePath:nil     
                                           inView:nil
                                       awardCoins:[PPConfigManager getShareAppWeiboReward]
                                   successMessage:NSLS(@"kShareWeiboSucc")
                                   failureMessage:NSLS(@"kShareWeiboFailure")
                                           taskId:task.taskId];
}

- (void)shareQQWeibo:(GameTask*)task
{
    [[GameSNSService defaultService] publishWeibo:TYPE_QQ
                                             text:[self getShareAppWeiboText]
                                    imageFilePath:nil
                                           inView:nil
                                       awardCoins:[PPConfigManager getShareAppWeiboReward]
                                   successMessage:NSLS(@"kShareWeiboSucc")
                                   failureMessage:NSLS(@"kShareWeiboFailure")
                                           taskId:task.taskId];
}

- (void)createOpus:(GameTask*)task
{
    // popup dialog, ask and enter
//    CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"")
//                                                       message:NSLS(@"")
//                                                         style:CommonDialogStyleDoubleButton];
//    
//    [dialog setClickOkBlock:^(id infoView){
//        
//    }];
//    
//    [dialog showInView:self.viewController.view];
    
    if (isDrawApp()){
        [OfflineDrawViewController startDraw:[Word cusWordWithText:@""]
                              fromController:self.viewController
                             startController:self.viewController
                                   targetUid:nil];
    }
    else if (isSingApp()){
        SingController *vc = [[[SingController alloc] init] autorelease];
        [self.viewController.navigationController pushViewController:vc animated:YES];
    }
    
}

- (void)guessOpus:(GameTask*)task
{
    // popup dialog, ask and enter
    HotController *hc = [[HotController alloc] init];
    [self.viewController.navigationController pushViewController:hc animated:YES];
    [hc release];
}

- (void)shareOpus:(GameTask*)task
{
    HotController *hc = [[HotController alloc] init];
    [self.viewController.navigationController pushViewController:hc animated:YES];
    [hc release];
}

- (void)gotoAppReview:(GameTask*)task
{
    [UIUtils gotoReview:[GameApp appId]];
}

- (void)upgradeApp:(GameTask*)task
{
    if ([UIUtils checkAppHasUpdateVersion]) {
        [UIUtils openApp:[GameApp appId]];
    }else{
        POSTMSG(NSLS(@"kAlreadLastVersion"));
    }
}

- (GameTask*)getTask:(PBTaskIdType)taskId
{
    for (GameTask* task in _taskList){
        if (task.taskId == taskId){
            return task;
        }
    }
    
    return nil;
    
}

- (void)completeTask:(PBTaskIdType)taskId isAward:(BOOL)isAward clearBadge:(BOOL)clearBadge
{
    GameTask* task = [self getTask:taskId];
    if (task == nil){
        return;
    }
    
    if ([task isComplete]){
        PPDebug(@"<completeTask> taskId(%d) but task already complete", taskId);
        return;
    }
    
    if (task.status != PBTaskStatusTaskStatusAlwaysOpen){
        if (isAward){
            task.status = PBTaskStatusTaskStatusAward;
        }
        else{
            task.status = PBTaskStatusTaskStatusDone;
        }
    }
    
    if (clearBadge){
        [task setBadge:0];
    }
    
    PPDebug(@"<completeTask> task(%d) status(%d) badge(%d)", taskId, task.status, task.badge);
    [self save];
}

- (void)awardTaskSuccess:(int)taskId amount:(int)amount
{
    GameTask* task = [self getTask:taskId];
    if (task == nil){
        return;
    }
    
    if (task.status == PBTaskStatusTaskStatusDone){
        task.status = PBTaskStatusTaskStatusAward;
        [self save];
    }
        
    NSString* msg = [NSString stringWithFormat:NSLS(@"kAwardTaskSucc"), amount];
    POSTMSG2(msg, 2);

    [self.viewController viewDidAppear:NO];
    self.viewController = nil;
}

- (void)clearTaskBadge:(GameTask*)task
{
    if (task == nil){
        return;
    }
    
    [task setBadge:0];
    PPDebug(@"<clearTaskBadge> task(%d)", task.taskId);
    [self save];
}

- (void)clearTaskBadgeById:(PBTaskIdType)taskId
{
    GameTask* task = [self getTask:taskId];
    [self clearTaskBadge:task];
}

- (void)completeBindWeiboTask:(ShareType)shareType isAward:(BOOL)isAward clearBadge:(BOOL)clearBadge
{
    int taskId = -1;
    if (shareType == ShareTypeSinaWeibo){
        taskId = PBTaskIdTypeTaskBindSina;
    }
    else if (shareType == ShareTypeTencentWeibo){
        taskId = PBTaskIdTypeTaskBindQq;
    }
    else{
        return;
    }
    
    [self completeTask:taskId isAward:isAward clearBadge:clearBadge];
}

- (int)totalBadge
{
    int count = 0;
    for (GameTask* task in _taskList){
        count += task.badge;
    }
    
    return count;
}

@end
