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
#import "AppTaskManager.h"
#import "AppTask.h"
#import "GameAdWallService.h"
#import "PurchaseVipController.h"

#define USER_TASK_LIST_KEY @"USER_TASK_LIST_KEY_5"

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
    
//    GameTask* task1 = [[GameTask alloc] initWithId:PBTaskIdTypeTaskCheckIn
//                                             name:NSLS(@"kTaskCheckIn")
//                                             desc:NSLS(@"kTaskCheckInDesc")
//                                           status:PBTaskStatusTaskStatusAlwaysOpen
//                                            badge:0
//                                             award:0
//                                          selector:@selector(checkIn:)];

    GameTask* vipTask = [[[GameTask alloc] initWithId:PBTaskIdTypeTaskVip
                                               name:NSLS(@"kTaskVip")
                                               desc:NSLS(@"kTaskVipDesc")
                                             status:PBTaskStatusTaskStatusAlwaysOpen
                                              badge:1
                                              award:0
                                           selector:@selector(showVip:)] autorelease];

    
    GameTask* task2 = [[[GameTask alloc] initWithId:PBTaskIdTypeTaskBindSina
                                             name:NSLS(@"kTaskBindSinaWeibo")
                                              desc:[NSString stringWithFormat:NSLS(@"kTaskBindSinaWeiboDesc"), [PPConfigManager getFollowWeiboReward]]
                                           status:PBTaskStatusTaskStatusCanTake
                                            badge:1
                                             award:[PPConfigManager getFollowWeiboReward]
                                          selector:@selector(bindSinaWeibo:)] autorelease];
    
    GameTask* task3 = [[[GameTask alloc] initWithId:PBTaskIdTypeTaskBindQq
                                              name:NSLS(@"kTaskBindQQWeibo")
                                              desc:[NSString stringWithFormat:NSLS(@"kTaskBindQQWeiboDesc"), [PPConfigManager getFollowWeiboReward]]
                                            status:PBTaskStatusTaskStatusCanTake
                                             badge:1
                                             award:[PPConfigManager getFollowWeiboReward]
                                          selector:@selector(bindQQWeibo:)] autorelease];

    GameTask* task4 = [[[GameTask alloc] initWithId:PBTaskIdTypeTaskShareSina
                                              name:NSLS(@"kTaskShareSinaWeibo")
                                              desc:[NSString stringWithFormat:NSLS(@"kTaskShareSinaWeiboDesc"), [PPConfigManager getShareAppWeiboReward]]
                                            status:PBTaskStatusTaskStatusCanTake
                                             badge:1
                                             award:[PPConfigManager getShareAppWeiboReward]
                                          selector:@selector(shareSinaWeibo:)] autorelease];
    
    GameTask* task5 = [[[GameTask alloc] initWithId:PBTaskIdTypeTaskShareWeixinTimeline
                                              name:NSLS(@"kTaskShareWeixinTimeline")
                                              desc:[NSString stringWithFormat:NSLS(@"kTaskShareWeixinTimelineDesc"), [PPConfigManager getShareAppWeiboReward]]
                                            status:PBTaskStatusTaskStatusCanTake
                                             badge:1
                                             award:[PPConfigManager getShareAppWeiboReward]                       
                                          selector:@selector(shareWeixinTimeline:)] autorelease];
    
    /*
    GameTask* shareQQSpace = [[[GameTask alloc] initWithId:PBTaskIdTypeTaskShareQqSpace
                                              name:NSLS(@"kTaskShareQQSpace")
                                              desc:[NSString stringWithFormat:NSLS(@"kTaskShareQQSpaceDesc"), [PPConfigManager getShareAppWeiboReward]]
                                            status:PBTaskStatusTaskStatusCanTake
                                             badge:1
                                             award:[PPConfigManager getShareAppWeiboReward]                       
                                          selector:@selector(shareQQSpace:)] autorelease];
    */
    
    GameTask* task61 = [[[GameTask alloc] initWithId:PBTaskIdTypeTaskShareQqWeibo
                                              name:NSLS(@"kTaskShareQQWeibo")
                                              desc:[NSString stringWithFormat:NSLS(@"kTaskShareQQWeiboDesc"), [PPConfigManager getShareAppWeiboReward]]
                                            status:PBTaskStatusTaskStatusCanTake
                                             badge:1
                                              award:[PPConfigManager getShareAppWeiboReward]                        
                                           selector:@selector(shareQQWeibo:)] autorelease];

    
    GameTask* createOpusTask = [[[GameTask alloc] initWithId:PBTaskIdTypeTaskCreateOpus
                                              name:NSLS(@"kTaskCreateOpus")
                                              desc:[NSString stringWithFormat:NSLS(@"kTaskCreateOpusDesc"), [PPConfigManager getFirstCreateOpusWeiboReward]]
                                            status:PBTaskStatusTaskStatusCanTake
                                             badge:1
                                             award:[PPConfigManager getFirstCreateOpusWeiboReward]                       
                                          selector:@selector(createOpus:)] autorelease];

    GameTask* guessOpusTask = [[[GameTask alloc] initWithId:PBTaskIdTypeTaskGuessOpus
                                              name:NSLS(@"kTaskGuessOpus")
                                              desc:[NSString stringWithFormat:NSLS(@"kTaskGuessOpusDesc"), [PPConfigManager getFirstGuessOpusReward]]
                                            status:PBTaskStatusTaskStatusCanTake
                                             badge:1
                                             award:[PPConfigManager getFirstGuessOpusReward]                       
                                          selector:@selector(guessOpus:)] autorelease];

    GameTask* task9 = [[[GameTask alloc] initWithId:PBTaskIdTypeTaskShareOpus
                                              name:NSLS(@"kTaskShareOpus")
                                              desc:[NSString stringWithFormat:NSLS(@"kTaskShareOpusDesc"), [PPConfigManager getShareWeiboReward]]
                                            status:PBTaskStatusTaskStatusAlwaysOpen
                                             badge:1
                                             award:[PPConfigManager getShareWeiboReward]                       
                                          selector:@selector(shareOpus:)] autorelease];

    GameTask* reviewTask = [[[GameTask alloc] initWithId:PBTaskIdTypeTaskAppReview
                                              name:NSLS(@"kTaskAppReview")
                                              desc:NSLS(@"kTaskAppReviewDesc")
                                            status:PBTaskStatusTaskStatusAlwaysOpen
                                             badge:1
                                              award:0
                                           selector:@selector(gotoAppReview:)] autorelease];
    
    
    
    GameTask* task11 = [[[GameTask alloc] initWithId:PBTaskIdTypeTaskAppUpgrade
                                               name:NSLS(@"kTaskAppUpgrade")
                                               desc:[NSString stringWithFormat:NSLS(@"kTaskAppUpgradeDesc"),
                                                     [PPConfigManager getLastAppVersion]]
                                             status:PBTaskStatusTaskStatusAlwaysOpen
                                              badge:1
                                              award:0
                                           selector:@selector(upgradeApp:)] autorelease];

    
//    [retList addObject:task1];

    [retList addObject:vipTask];
    

    
    
    
    if ([UIUtils checkAppHasUpdateVersion]){
        [retList addObject:task11];
    }
    else{
        // clean local app upgrade task status        
    }
    
    if ([PPConfigManager isInReviewVersion] == NO){
        [retList addObject:reviewTask];
        
        // add app task
        
        NSArray* appTaskList = [[AppTaskManager defaultManager] taskList];
        for (AppTask* appTask in appTaskList){
            if ([appTask show]){
                
                int taskStartId = ([appTask type] == AppTaskTypeWall) ? PBTaskIdTypeTaskAppWall : PBTaskIdTypeTaskAppDownload;
                SEL selector = ([appTask type] == AppTaskTypeWall) ? @selector(gotoAppWall:) : @selector(downloadApp:);
                int status = ([appTask type] == AppTaskTypeWall) ? PBTaskStatusTaskStatusAlwaysOpen : PBTaskStatusTaskStatusCanTake;
                
                GameTask* t = [[[GameTask alloc] initWithId:taskStartId+[appTask index]
                                                       name:[appTask name]
                                                       desc:[appTask desc]
                                                     status:status
                                                      badge:1
                                                      award:[appTask award]
                                                   selector:selector
                                                    appTask:appTask] autorelease];
                
                if (appTask.type == AppTaskTypeWall && [PPConfigManager wallEnabled] == NO){
                    continue;
                }
                else if (appTask.type == AppTaskTypeDownload && [appTask isAppAward] == YES){
                    continue;
                }
                
                [retList addObject:t];
                
            }
        }
        
    }

    [retList addObject:createOpusTask];
    [retList addObject:guessOpusTask];
    
    [retList addObject:task2];
    [retList addObject:task3];
    [retList addObject:task4];
    [retList addObject:task5];
    [retList addObject:task61];
//    [retList addObject:task6];
    [retList addObject:task9];
        
    
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
                GameTask* foundTask = nil;
                for (GameTask* t in self.taskList){
                    if (t.taskId == task.taskId){
                        
                        // check download app real time status since it's not detect anyelse where
                        if (t.appTask != nil
                            && t.appTask.type == AppTaskTypeDownload
                            && task.status == PBTaskStatusTaskStatusCanTake
                            && [UIUtils canOpenURL:t.appTask.schema]
                            && [t.appTask isAppAward] == NO){
                            
                            task.status = PBTaskStatusTaskStatusDone;
                        }
                        
                        // TODO set other user status here
                        [t setStatus:task.status];
                        [t setBadge:task.badge];
                        
                        foundTask = t;                        
                        break;
                    }
                }
                
                if (foundTask && task.status == PBTaskStatusTaskStatusAward){
                    // task is completed, move it to the end of list
                    [self.taskList removeObject:foundTask];
                    [self.taskList addObject:foundTask];
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

- (void)postReloadTaskNotification
{
    PPDebug(@"<postReloadTaskNotification>");
    [[NSNotificationCenter defaultCenter] postNotificationName:TASK_DATA_RELOAD_NOTIFICATION object:nil];
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
    
    [self postReloadTaskNotification];
}

- (void)awardTask:(GameTask*)task viewController:(PPViewController*)viewController
{
    [self clearTaskBadge:task];
    
    if (task.status != PBTaskStatusTaskStatusDone){
        return;
    }

    [[AccountService defaultService] chargeCoin:task.award source:TaskAward+task.taskId];
}

- (void)showVip:(GameTask*)task
{
    [PurchaseVipController enter:self.viewController];
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
    int award = (task.status == PBTaskStatusTaskStatusAward) ? 0 : [PPConfigManager getShareAppWeiboReward];
    
    [[GameSNSService defaultService] publishWeibo:TYPE_SINA
                                             text:[self getShareAppWeiboText]
                                    imageFilePath:nil
                                           inView:nil
                                       awardCoins:award
                                   successMessage:NSLS(@"kShareWeiboSucc")
                                   failureMessage:NSLS(@"kShareWeiboFailure")
                                           taskId:task.taskId];
}

- (void)shareWeixinTimeline:(GameTask*)task
{
    int award = (task.status == PBTaskStatusTaskStatusAward) ? 0 : [PPConfigManager getShareAppWeiboReward];
    
    [[GameSNSService defaultService] publishWeibo:TYPE_WEIXIN_TIMELINE
                                             text:[self getShareAppWeiboText]
                                    imageFilePath:nil
                                           inView:nil
                                       awardCoins:award
                                   successMessage:NSLS(@"kShareWeiboSucc")
                                   failureMessage:NSLS(@"kShareWeiboFailure")
                                           taskId:task.taskId];
}

- (void)shareQQSpace:(GameTask*)task
{
    int award = (task.status == PBTaskStatusTaskStatusAward) ? 0 : [PPConfigManager getShareAppWeiboReward];
    
    [[GameSNSService defaultService] publishWeibo:TYPE_QQSPACE
                                             text:[self getShareAppWeiboText]
                                    imageFilePath:nil     
                                           inView:nil
                                       awardCoins:award
                                   successMessage:NSLS(@"kShareWeiboSucc")
                                   failureMessage:NSLS(@"kShareWeiboFailure")
                                           taskId:task.taskId];
}

- (void)shareQQWeibo:(GameTask*)task
{
    int award = (task.status == PBTaskStatusTaskStatusAward) ? 0 : [PPConfigManager getShareAppWeiboReward];
    
    [[GameSNSService defaultService] publishWeibo:TYPE_QQ
                                             text:[self getShareAppWeiboText]
                                    imageFilePath:nil
                                           inView:nil
                                       awardCoins:award
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
//    if (isSingApp()){
//        [self.viewController.navigationController popToRootViewControllerAnimated:NO];
//        DrawAppDelegate* app = (DrawAppDelegate*)[UIApplication sharedApplication].delegate;
//        if ([app.homeController respondsToSelector:@selector(enterGuessSing)]){
//            [app.homeController performSelector:@selector(enterGuessSing)];
//        }
//    }
//    else{
        HotController *hc = [[HotController alloc] init];
        [self.viewController.navigationController pushViewController:hc animated:YES];
        [hc release];
//    }
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

- (void)downloadApp:(GameTask*)task
{
    AppTask* appTask = task.appTask;
    
    if ([UIUtils canOpenURL:appTask.schema]){
        // already complete
        if (task.status == PBTaskStatusTaskStatusCanTake){
            task.status = PBTaskStatusTaskStatusDone;
        }
    }
    else{
        // goto download app
        [UIUtils openURL:[appTask url]];
    }
}

- (void)gotoAppWall:(GameTask*)task
{
    AppTask* appTask = task.appTask;
    [[GameAdWallService defaultService] showWall:self.viewController wallType:appTask.wallType forceShowWall:YES];
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
    
    [self postReloadTaskNotification];
    
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
    
    if (task.appTask && task.appTask.type == AppTaskTypeDownload){
        // app award only can be taken once
        [task.appTask setAppAward];
    }
    
    NSString* msg = [NSString stringWithFormat:NSLS(@"kAwardTaskSucc"), amount];
    POSTMSG2(msg, 2);
    
    [self postReloadTaskNotification];
    
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
