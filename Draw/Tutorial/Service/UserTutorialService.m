//
//  UserTutorialService.m
//  Draw
//
//  Created by qqn_pipi on 14-6-26.
//
//

#import "UserTutorialService.h"
#import "UserTutorialManager.h"
#import "PPGameNetworkRequest.h"
#import "TutorialService.h"
#import "TutorialCoreManager.h"
#import "OfflineDrawViewController.h"

@interface UserTutorialService ()

@property (nonatomic, assign) BOOL isTestMode;

@end

@implementation UserTutorialService

static UserTutorialService* _defaultService;

+ (UserTutorialService*)defaultService
{
    if (_defaultService == nil)
        _defaultService = [[UserTutorialService alloc] init];
    
    return _defaultService;
}

// 同步用户学习某个教程的信息到服务器
- (void)syncUserTutorial:(PBUserTutorial*)ut
{
    NSDictionary* para = nil;
    NSData* postData = [ut data];
    
    [PPGameNetworkRequest loadPBData:workingQueue
                             hostURL:TUTORIAL_HOST
                             method:METHOD_SYNC_USER_TUTORIAL
                         parameters:para
                           callback:^(DataQueryResponse *response, NSError *error) {
                
                                if (error == nil){
                                    // success
                                    // update user tutorial SYNC status
                                    [[UserTutorialManager defaultManager] syncUserTutorial:ut.localId syncStatus:YES];
                                }
                            }
                        isPostError:NO];
}

//add server
- (void)addUserTutorialToServer:(PBUserTutorial*)ut
{
    [self actionOnUserTutorial:ut action:ACTION_ADD_USER_TUTORIAL];
}
//delete  server
- (void)deleteUserTutorialToServer:(PBUserTutorial*)ut
{
    [self actionOnUserTutorial:ut action:ACTION_DELETE_USER_TUTORIAL];
}

//取得服务器用户教程列表
-(void)getAllUserTutorialFromServer:(UserTutorialActionType)action resultBlock:(UserTutorialServiceGetListResultBlock)resultBlock{
    NSMutableDictionary* para = [[[NSMutableDictionary alloc] init] autorelease];
    [para setObject:@(action) forKey:PARA_ACTION_TYPE];

    [para setObject:@(0) forKey:PARA_OFFSET];
    [para setObject:@(10) forKey:PARA_LIMIT];
    
    [PPGameNetworkRequest loadPBData:workingQueue
                             hostURL:TUTORIAL_HOST
                              method:METHOD_USER_TUTORIAL_ACTION
                          parameters:para
                            callback:^(DataQueryResponse *response, NSError *error) {
                                
                                NSArray* retUserTutorialList = response.userTutorialsList;
                                if (error == nil){
                                    // success
                                    if(retUserTutorialList!=nil){
                                        for(PBUserTutorial *retUserTutorial in retUserTutorialList){
                                            [[UserTutorialManager defaultManager] addNewUserTutorialFromServer:retUserTutorial WithRemoteId:retUserTutorial.remoteId];
                                        }
                                        
                                    }
                                }
                                
                                EXECUTE_BLOCK(resultBlock, 0, retUserTutorialList);
                            }
                         isPostError:NO];
    
}


//set device info
- (void)setDeviceInfo:(NSMutableDictionary*)para{
    NSString * deviceOs = [DeviceDetection deviceOS];
    NSString * deviceModel = [UIDevice currentDevice].model;
    NSInteger deviceType = DEVICE_TYPE_IOS;
    
    if (deviceOs){
        [para setObject:deviceOs forKey:PARA_DEVICEOS];
    }
    
    if (deviceModel){
        [para setObject:deviceModel forKey:PARA_DEVICEMODEL];
    }
    
    [para setObject:@(deviceType) forKey:PARA_DEVICETYPE];
    PPDebug(@"<setDeviceInfo> para=%@", [para description]);
}

//用户学习某个教程的信息到服务器动作
- (void)actionOnUserTutorial:(PBUserTutorial*)ut action:(UserTutorialActionType)action
{
    if (ut == nil || ut.tutorial.tutorialId == nil || ut.localId == nil){
        PPDebug(@"<actionOnUserTutorial> but key parameters is nil");
        return;
    }
    NSMutableDictionary* para = [[[NSMutableDictionary alloc] init] autorelease];
    [para setObject:ut.tutorial.tutorialId forKey:PARA_TUTORIAL_ID];
    [para setObject:ut.localId forKey:PARA_LOCAL_USER_TUTORIAL_ID];
    [para setObject:@(action) forKey:PARA_ACTION_TYPE];
    
    if (ut.currentStageId){
        [para setObject:ut.currentStageId forKey:PARA_STAGE_ID];
        [para setObject:@(ut.currentStageIndex) forKey:PARA_STAGE_INDEX];
    }
    
    //set device
    [self setDeviceInfo:para];
    
    // set remotedId when update/delete action when needed
    if (ut.remoteId != nil){
        [para setObject:ut.remoteId forKey:PARA_REMOTE_USER_TUTORIAL_ID];
    }
    
    [PPGameNetworkRequest loadPBData:workingQueue
                             hostURL:TUTORIAL_HOST
                              method:METHOD_USER_TUTORIAL_ACTION
                          parameters:para
                            callback:^(DataQueryResponse *response, NSError *error) {
                                
                                if (error == nil){
                                    
                                    // success
                                    PBUserTutorial* retUserTutorial = response.userTutorial;
                                    if (action == ACTION_ADD_USER_TUTORIAL){
                                        [[UserTutorialManager defaultManager] saveUserTutorial:ut.localId
                                                                                      remoteId:retUserTutorial.remoteId];
                                    }
                                    //2014-07-17
                                    if(action == ACTION_GET_ALL_USER_TUTORIAL){
                                        [[UserTutorialManager defaultManager] saveUserTutorial:ut.localId
                                                                                      remoteId:retUserTutorial.remoteId];
                                    }
                                    
                                    // update user tutorial SYNC status
//                                    [[UserTutorialManager defaultManager] syncUserTutorial:ut.localId syncStatus:YES];
                                }
                            }
                         isPostError:NO];
}

- (void)reportUserTutorialStatus:(PBUserTutorial*)ut action:(UserTutorialActionType)action
{
    if (ut == nil || ut.tutorial.tutorialId == nil || ut.localId == nil || ut.remoteId == nil){
        PPDebug(@"<reportUserTutorialStatus> but key parameters is nil");
        return;
    }
    
    NSMutableDictionary* para = [[[NSMutableDictionary alloc] init] autorelease];
    [para setObject:ut.tutorial.tutorialId forKey:PARA_TUTORIAL_ID];
    [para setObject:ut.localId forKey:PARA_LOCAL_USER_TUTORIAL_ID];
    [para setObject:@(action) forKey:PARA_ACTION_TYPE];
    [para setObject:ut.remoteId forKey:PARA_REMOTE_USER_TUTORIAL_ID];
    
    if (ut.currentStageId){
        [para setObject:ut.currentStageId forKey:PARA_STAGE_ID];
        [para setObject:@(ut.currentStageIndex) forKey:PARA_STAGE_INDEX];
    }
    
    //set device
    [self setDeviceInfo:para];
    
    PPDebug(@"<reportUserTutorialStatus> report user status, para=%@", [para description]);
    [PPGameNetworkRequest loadPBData:workingQueue
                             hostURL:TUTORIAL_HOST
                              method:METHOD_USER_TUTORIAL_ACTION
                          parameters:para
                            callback:^(DataQueryResponse *response, NSError *error) {
                                PPDebug(@"<reportUserTutorialStatus> report user status, error=%@", [error description]);
                            }
                         isPostError:NO];
}




// 用户添加/开始学习某个教程
- (void)addTutorial:(PBTutorial*)tutorial resultBlock:(UserTutorialServiceResultBlock)resultBlock
{
    // 先保存到本地
    PBUserTutorial* ut = [[UserTutorialManager defaultManager] addTutorial:tutorial];
    EXECUTE_BLOCK(resultBlock, 0);
    
    // 再同步到服务器
    [self addUserTutorialToServer:ut];
}

//删除教程
- (void)deleteUserTutorial:(PBUserTutorial*)ut resultBlock:(UserTutorialServiceResultBlock)resultBlock
{
    PBUserTutorial* utForDelete = [[UserTutorialManager defaultManager] getUserTutorialByTutorialId:ut.tutorial.tutorialId];
    [utForDelete retain];
    
    // delete locally
    [[UserTutorialManager defaultManager] deleteUserTutorial:ut];
    EXECUTE_BLOCK(resultBlock, 0);

    // delete in server
    [self deleteUserTutorialToServer:utForDelete];
    [utForDelete release];
}




// 用户下载教程所有关卡数据
- (void)downloadTutorial:(PBTutorial*)tutorial resultBlock:(UserTutorialServiceResultBlock)resultBlock
{
    
}

#define KEY_SYNC_USER_TUTORIAL_FROM_SERVER @"KEY_SYNC_USER_TUTORIAL_FROM_SERVER"

// 是否已经从服务器同步过教程列表
- (BOOL)hasSyncFromServer
{
//#ifdef DEBUG
//    return NO;
//#endif
    return [UD_GET(KEY_SYNC_USER_TUTORIAL_FROM_SERVER) boolValue];
}

- (void)setSyncFromServer
{
    UD_SET(KEY_SYNC_USER_TUTORIAL_FROM_SERVER, @(YES));
}

#define KEY_THE_FIRST_LEARNING @"KEY_THE_FIRST_LEARNING"

- (BOOL)hasTheFirstLearningKey
{
//#ifdef DEBUG
//    return NO;
//#endif
    return [UD_GET(KEY_THE_FIRST_LEARNING) boolValue];
}

- (void)setTheFirstLearningKey
{
    UD_SET(KEY_THE_FIRST_LEARNING, @(YES));
}


- (void)addDefaultTutorial
{
    if ([self hasTheFirstLearningKey]){
        return;
    }
    
    PBTutorial *pb = [[TutorialCoreManager defaultManager] defaultFirstTutorial];
    if (pb == nil){
        return;
    }
    
    PPDebug(@"add default tutorial, tutorialId=%@", pb.tutorialId);
    [self addTutorial:pb resultBlock:nil];
    
    // update flag
    [self setTheFirstLearningKey];
}



// 获取用户当前正在学习的所有教程列表
- (void)getAllUserTutorials:(UserTutorialServiceGetListResultBlock)resultBlock
{
    NSArray* list = [[UserTutorialManager defaultManager] allUserTutorials];
    if ([list count] == 0){
        // list is empty try to sync from server
        if([self hasSyncFromServer] == NO){
            [self getAllUserTutorialFromServer:ACTION_GET_ALL_USER_TUTORIAL resultBlock:^(int resultCode, NSArray *retList) {
                if (resultCode == 0){
                    if([retList count] == 0){
                        PPDebug(@"<getAllUserTutorials> no data, try add default tutorial");
                        [self addDefaultTutorial];
                    }

                    // sync from server success, set the SYNC flag
                    [self setSyncFromServer];
                }
                
                NSArray* list = [[UserTutorialManager defaultManager] allUserTutorials];
                EXECUTE_BLOCK(resultBlock, 0, list);
            }];
            return;
        }
        else{
            //没有用户教程列表时候，添加默认教程
            [self addDefaultTutorial];
            list = [[UserTutorialManager defaultManager] allUserTutorials];

            EXECUTE_BLOCK(resultBlock, 0, list);
        }
    }
    else{
        EXECUTE_BLOCK(resultBlock, 0, list);
    }

    
}

// 用户尝试修炼
- (PBUserTutorial*)startPracticeTutorialStage:(NSString*)userTutorialLocalId
                                      stageId:(NSString*)stageId
                                   stageIndex:(int)stageIndex
{
    PBUserTutorial* ut = [[UserTutorialManager defaultManager] practiceTutorialStage:userTutorialLocalId
                                                                             stageId:stageId
                                                                          stageIndex:stageIndex];
    
    if (ut != nil){
        // report to server
        [self reportUserTutorialStatus:ut action:ACTION_PRACTICE_USER_TUTORIAL];
    }

    return ut;
}

// 用户尝试闯关
- (PBUserTutorial*)startConquerTutorialStage:(NSString*)userTutorialLocalId
                                     stageId:(NSString*)stageId
                                  stageIndex:(int)stageIndex
{
    PBUserTutorial* ut = [[UserTutorialManager defaultManager] conquerTutorialStage:userTutorialLocalId
                                                                             stageId:stageId
                                                                          stageIndex:stageIndex];
    
    if (ut != nil){
        // report to server
        [self reportUserTutorialStatus:ut action:ACTION_CONQUER_USER_TUTORIAL];
    }
    
    return ut;
}

- (PBUserTutorial*)passCurrentStage:(PBUserTutorial*)userTutorial
{
    if (userTutorial == nil){
        return nil;
    }
    
    PBTutorial* tutorial = [[TutorialCoreManager defaultManager] findTutorialByTutorialId:userTutorial.tutorial.tutorialId];
    if (tutorial == nil){
        return userTutorial;
    }

    PBUserTutorial_Builder* builder = [PBUserTutorial builderWithPrototype:userTutorial];
    int newStageIndex = userTutorial.currentStageIndex + 1;
    if (newStageIndex >= [tutorial.stagesList count]){
        // reach final stage, set status to COMPLETE
        [builder setStatus:PBUserTutorialStatusUtStatusComplete];
    }
    else{
        // increase stage index, and set stageId
        PBStage* stage = [tutorial.stagesList objectAtIndex:newStageIndex];
        [builder setCurrentStageId:stage.stageId];
        [builder setCurrentStageIndex:newStageIndex];
    }
    
    PBUserTutorial* newUT = [builder build];
    [[UserTutorialManager defaultManager] save:newUT];

    // report to server
    [self reportUserTutorialStatus:newUT action:ACTION_UPDATE_USER_TUTORIAL];
    
    return newUT;
}

- (PBUserTutorial*)enterConquerDraw:(UIViewController*)fromController
                       userTutorial:(PBUserTutorial*)userTutorial
                            stageId:(NSString*)stageId
                         stageIndex:(int)stageIndex
{
    PBUserTutorial* newUT = [[UserTutorialService defaultService] startConquerTutorialStage:userTutorial.localId
                                                                                    stageId:stageId
                                                                                 stageIndex:stageIndex];

    if (newUT && stageIndex < [newUT.userStagesList count]){
        PBUserStage* userStage = [newUT.userStagesList objectAtIndex:stageIndex];
        
        // enter offline draw view controller
        [OfflineDrawViewController conquer:fromController userStage:userStage userTutorial:newUT];
        return newUT;
    }
    else{
        return userTutorial;
    }
}

// 进入修炼界面
- (PBUserTutorial*)enterPracticeDraw:(UIViewController*)fromController
                        userTutorial:(PBUserTutorial*)userTutorial
                             stageId:(NSString*)stageId
                          stageIndex:(int)stageIndex
{
    // Practice
    PBUserTutorial* newUT = [[UserTutorialService defaultService] startPracticeTutorialStage:userTutorial.localId
                                                                                     stageId:stageId
                                                                                  stageIndex:stageIndex];
    
    if (newUT && stageIndex < [newUT.userStagesList count]){
        
        PBUserStage* userStage = [newUT.userStagesList objectAtIndex:stageIndex];
        
        // enter offline draw view controller
        [OfflineDrawViewController practice:fromController userStage:userStage userTutorial:newUT];
        return newUT;
    }
    else{
        return userTutorial;
    }
}

@end
