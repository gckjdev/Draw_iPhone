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
#import "PBTutorial+Extend.h"
#import "Reachability.h"
#import "StorageManager.h"

#define TUTORIAL_IMAGE_DIR  @"TutorialImage"

@interface UserTutorialService ()
{
    
}

@property (nonatomic, assign) BOOL isTestMode;
@property (nonatomic, retain) NSMutableDictionary* smartDataDict;
@property (nonatomic, retain) StorageManager *imageManager;

@end

@implementation UserTutorialService

static UserTutorialService* _defaultService;

+ (UserTutorialService*)defaultService
{
    if (_defaultService == nil){
        _defaultService = [[UserTutorialService alloc] init];
        _defaultService.smartDataDict = [NSMutableDictionary dictionary];
        _defaultService.imageManager = [[[StorageManager alloc] initWithStoreType:StorageTypePersistent
                                                                   directoryName:TUTORIAL_IMAGE_DIR] autorelease];
    }
    
    return _defaultService;
}

- (void)dealloc
{
    PPRelease(_imageManager);
    PPRelease(_smartDataDict);
    [super dealloc];
}

// 同步用户学习某个教程的信息到服务器
- (void)syncUserTutorial:(PBUserTutorial*)ut
{
    NSDictionary* para = nil;
//    NSData* postData = [ut data];
    
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
                                NSArray* retUserTutorialList = response.userTutorials;
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


+ (NSString*)getTutorialDataDir:(NSString*)tutorialId
{
    NSString* dir = [NSString stringWithFormat:@"%@", tutorialId];
    //    PPDebug(@"tutorial data dir is %@");
    return dir;
}

+ (NSString*)getStageDataFileName:(NSString*)tutorialId stageId:(NSString*)stageId
{
    NSString* name = [NSString stringWithFormat:@"%@__%@.zip", tutorialId, stageId];
    //    PPDebug(@"stage file name is %@");
    return name;
}

+ (NSString*)getLocalStageDataPath:(NSString*)tutorialId stageId:(NSString*)stageId
{
    NSString* subDir = [self getTutorialDataDir:tutorialId];
    NSString* name = [self getStageDataFileName:tutorialId stageId:stageId];
    NSString* path = [PPSmartUpdateDataUtils pathBySubDir:subDir name:name type:SMART_UPDATE_DATA_TYPE_ZIP];
    PPDebug(@"local data file path for stage is %@");
    return path;
}

- (NSArray*)getChapterTipsImagePath:(NSString*)tutorialId stage:(PBStage*)stage chapterIndex:(int)chapterIndex
{
    NSArray* tipsImageList = [stage tipsImageList:chapterIndex];
    if ([tipsImageList count] == 0){
        PPDebug(@"<getChapterTipsImagePath> chapterIndex=%d, but no tips image", chapterIndex);
        return nil;
    }
    
    NSMutableArray* retList = [NSMutableArray array];
    PPSmartUpdateData* smartData = [self getSmartData:tutorialId stageId:stage.stageId];
    for (NSString* tipsName in tipsImageList){
        if ([tipsName length] > 0){
            NSString* imagePath = [[smartData currentDataPath] stringByAppendingPathComponent:tipsName];
            [retList addObject:imagePath];
            PPDebug(@"<getChapterTipsImagePath> chapterIndex=%d, add tips path(%@) ", chapterIndex, imagePath);
        }
        else{
            PPDebug(@"<getChapterTipsImagePath> chapterIndex=%d, tipsName empty", chapterIndex);
        }
    }
    
    return retList;
}

- (NSString*)getChapterImagePath:(NSString*)tutorialId stage:(PBStage*)stage chapterIndex:(int)currentChapterIndex
{
    PPSmartUpdateData* smartData = [self getSmartData:tutorialId stageId:stage.stageId];
    NSString* imageName = nil;
    if (currentChapterIndex >= [stage.chapter count]){
        // TODO use stage image name by default?
        return nil;
    }
    else{
        PBChapter* chapter = [stage.chapter objectAtIndex:currentChapterIndex];
        imageName = chapter.imageName;
    }
    
    NSString* imagePath = [[smartData currentDataPath] stringByAppendingPathComponent:imageName];
    PPDebug(@"<getChapterImagePath> path=%@", imagePath);
    return imagePath;
}

- (NSString*)getBgImagePath:(NSString*)tutorialId stage:(PBStage*)stage
{
    PPSmartUpdateData* smartData = [self getSmartData:tutorialId stageId:stage.stageId];
    NSString* imageName = stage.bgImageName;
    NSString* imagePath = [[smartData currentDataPath] stringByAppendingPathComponent:imageName];
    PPDebug(@"<getBgImagePath> path=%@", imagePath);
    return imagePath;
    
}

- (NSString*)getOpusDataPath:(NSString*)tutorialId stage:(PBStage*)stage
{
    PPSmartUpdateData* smartData = [self getSmartData:tutorialId stageId:stage.stageId];
    NSString* opusDataName = stage.opusName;
    NSString* opusDataPath = [[smartData currentDataPath] stringByAppendingPathComponent:opusDataName];
    PPDebug(@"<getOpusDataPath> path=%@", opusDataPath);
    return opusDataPath;
}

- (NSString*)tutorialStageImageKey:(NSString*)tutorialId stageId:(NSString*)stageId type:(TargetType)type
{
    NSString* typeString = (type == TypeConquerDraw) ? @"conquer" : @"practice";
    NSString* stageImageKey = [NSString stringWithFormat:@"%@__%@__%@.jpg", typeString, tutorialId, stageId];
    return stageImageKey;
}

- (void)saveTutorialImage:(PBUserStage*)userStage image:(UIImage*)image type:(TargetType)type
{
    if (userStage == nil || image == nil){
        return;
    }
    
    NSString* stageImageKey = [self tutorialStageImageKey:userStage.tutorialId stageId:userStage.stageId type:type];
    PPDebug(@"<saveTutorialImage> %@", stageImageKey);
    [_imageManager saveImage:image forKey:stageImageKey];
}

- (UIImage*)stageDrawImage:(PBUserStage*)userStage type:(TargetType)type
{
    if (userStage == nil){
        return nil;
    }
    
    NSString* stageImageKey = [self tutorialStageImageKey:userStage.tutorialId stageId:userStage.stageId type:type];
    return [_imageManager imageForKey:stageImageKey];
}

- (UIImage*)getBgImage:(PBUserStage*)userStage stage:(PBStage*)stage type:(TargetType)type
{
    if (stage.useBgFromPrev){
        // 用上一关的作品作为背景底图
        PPDebug(@"<getBgImage> use previous stage result as bg image");
        return [self stageDrawImage:userStage type:type];
    }
    else{
        // 用默认的指定背景底图
        NSString* bgImagePath = [[UserTutorialService defaultService] getBgImagePath:userStage.tutorialId stage:stage];
        UIImage* bgImage = [[[UIImage alloc] initWithContentsOfFile:bgImagePath] autorelease];
        return bgImage;
    }
}


// 用户下载教程所有关卡数据
- (void)downloadTutorial:(PBTutorial*)tutorial resultBlock:(UserTutorialServiceResultBlock)resultBlock
{
    
}

- (PPSmartUpdateData*)getSmartData:(NSString*)tutorialId stageId:(NSString*)stageId
{
    NSString* dir = [UserTutorialService getTutorialDataDir:tutorialId];
    NSString* name = [UserTutorialService getStageDataFileName:tutorialId stageId:stageId];

    PPSmartUpdateData* smartData = [self.smartDataDict objectForKey:name];
    if (smartData == nil){
        // init smart data here and set config data here
        smartData = [[PPSmartUpdateData alloc] initWithName:name
                                                       type:SMART_UPDATE_DATA_TYPE_ZIP
                                             originDataPath:nil
                                            initDataVersion:nil
                                                  serverURL:TUTORIAL_FILE_SERVER_URL
                                                localSubDir:dir];
        
        [self.smartDataDict setObject:smartData forKey:name];
        [smartData release];
    }
    
    return smartData;
}

- (PPSmartUpdateData*)getSmartData:(PBUserTutorial*)userTutorial
{
    NSString* tutorialId = userTutorial.tutorial.tutorialId;
    NSString* stageId = userTutorial.currentStageId;
    PPSmartUpdateData* smartData = [self getSmartData:tutorialId stageId:stageId];
    return smartData;
}

// 用户下载某个关卡数据
- (void)downloadStage:(PBUserTutorial*)userTutorial resultBlock:(UserTutorialServiceResultBlock)resultBlock
{
    PPSmartUpdateData* smartData = [self getSmartData:userTutorial];
    [smartData checkUpdateAndDownload:^(BOOL isAlreadyExisted, NSString *dataFilePath) {
        
        // download success
        POSTMSG(NSLS(@"kDownloadTutorialSuccess"));
         
    } failureBlock:^(NSError *error) {

        // download failure
        POSTMSG(NSLS(@"kDownloadTutorialFailure"));

    }];
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

#define KEY_THE_FIRST_LEARNING ([NSString stringWithFormat:@"%@_KEY_THE_FIRST_LEARNING", [[UserManager defaultManager] userId]])

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
    @synchronized (self) {
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
                    else{
                        // success
                        if(retList!=nil){
                            [[UserTutorialManager defaultManager] addUserTutorials:retList];
                        }
                    }

                    // sync from server success, set the SYNC flag
                    [self setSyncFromServer];
                }
                
                NSArray* newList = [[UserTutorialManager defaultManager] allUserTutorials];
                EXECUTE_BLOCK(resultBlock, 0, newList);
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

    PBUserTutorialBuilder* builder = [PBUserTutorial builderWithPrototype:userTutorial];
    int newStageIndex = userTutorial.currentStageIndex + 1;
    if (newStageIndex >= [tutorial.stages count]){
        // reach final stage, set status to COMPLETE
        [builder setStatus:PBUserTutorialStatusUtStatusComplete];
    }
    else{
        // increase stage index, and set stageId
        PBStage* stage = [tutorial.stages objectAtIndex:newStageIndex];
        [builder setCurrentStageId:stage.stageId];
        [builder setCurrentStageIndex:newStageIndex];
    }
    
    PBUserTutorial* newUT = [builder build];
    [[UserTutorialManager defaultManager] save:newUT];

    // report to server
    [self reportUserTutorialStatus:newUT action:ACTION_UPDATE_USER_TUTORIAL];
    
    return newUT;
}

//- (PBUserTutorial*)enterConquerDraw:(PPViewController*)fromController
//                       userTutorial:(PBUserTutorial*)userTutorial
//                            stageId:(NSString*)stageId
//                         stageIndex:(int)stageIndex
//{
//
//    [fromController showProgressViewWithMessage:NSLS(@"kLoadingStage")];
//    PPSmartUpdateData* smartData = [self getSmartData:userTutorial.tutorial.tutorialId stageId:stageId];
//    [self registerNotification:smartData viewController:fromController];
//    
//    [smartData checkUpdateAndDownload:^(BOOL isAlreadyExisted, NSString *dataFilePath) {
//        
//        [fromController hideProgressView];
//        [self unregisterNotification:smartData viewController:fromController];
//        
//        // download success
//        PBUserTutorial* newUT = [[UserTutorialService defaultService] startConquerTutorialStage:userTutorial.localId
//                                                                                        stageId:stageId
//                                                                                     stageIndex:stageIndex];
//        
//        if (newUT && stageIndex < [newUT.userStagesList count]){
//            PBUserStage* userStage = [newUT.userStagesList objectAtIndex:stageIndex];
//            
//            // enter offline draw view controller
//            [OfflineDrawViewController conquer:fromController userStage:userStage userTutorial:newUT];
//            return;
//        }
//        else{
//            return;
//        }
//        
//    } failureBlock:^(NSError *error) {
//        
//        // download failure
//        [fromController hideProgressView];
//        [self unregisterNotification:smartData viewController:fromController];
//
//        POSTMSG(NSLS(@"kDownloadTutorialFailure"));
//        
//    }];
//    
//    return userTutorial;
//}

- (void)registerNotification:(PPSmartUpdateData*)smartData viewController:(PPViewController*)viewController
{
    [viewController registerNotificationWithName:[smartData progressNotificationName]
                                      usingBlock:^(NSNotification *note) {
                                          
                                          NSDictionary* userInfo = note.userInfo;
                                          float newProgress = [[userInfo objectForKey:SMART_DATA_PROGRESS] floatValue];
                                          NSString* message = [NSString stringWithFormat:NSLS(@"kLoadingStageWithProgress"), (int)(newProgress*100.0f)];
                                          [viewController showProgressViewWithMessage:message progress:newProgress];
                                          
                                      }];

}

- (void)unregisterNotification:(PPSmartUpdateData*)smartData viewController:(PPViewController*)viewController
{
    [viewController unregisterNotificationWithName:[smartData progressNotificationName]];
}


// 显示
- (void)showPracticeDraw:(PPViewController*)fromController
                        userTutorial:(PBUserTutorial*)userTutorial
                             stageId:(NSString*)stageId
                          stageIndex:(int)stageIndex
{
    
    // download success
    // Practice
    PBUserTutorial* newUT = [[UserTutorialService defaultService] startPracticeTutorialStage:userTutorial.localId
                                                                                     stageId:stageId
                                                                                  stageIndex:stageIndex];
    
    if (newUT && stageIndex < [newUT.userStages count]){
        
        PBUserStage* userStage = [newUT.userStages objectAtIndex:stageIndex];
        
        // enter offline draw view controller
        [OfflineDrawViewController practice:fromController userStage:userStage userTutorial:newUT];
        return;
    }
    else{
        return;
    }

}

- (void)showConquerDraw:(PPViewController*)fromController
            userTutorial:(PBUserTutorial*)userTutorial
                 stageId:(NSString*)stageId
              stageIndex:(int)stageIndex
{
    // download success
    PBUserTutorial* newUT = [[UserTutorialService defaultService] startConquerTutorialStage:userTutorial.localId
                                                                                    stageId:stageId
                                                                                 stageIndex:stageIndex];
    
    if (newUT && stageIndex < [newUT.userStages count]){
        PBUserStage* userStage = [newUT.userStages objectAtIndex:stageIndex];
        
        // enter offline draw view controller
        [OfflineDrawViewController conquer:fromController
                                 userStage:userStage
                              userTutorial:newUT];
        return;
    }
    else{
        return;
    }

}

- (void)showLearnDraw:(PPViewController*)fromController
            userTutorial:(PBUserTutorial*)userTutorial
                 stageId:(NSString*)stageId
              stageIndex:(int)stageIndex
                    type:(int)type
{
    if (type == PBOpusTypeDrawPractice){
        [self showPracticeDraw:fromController userTutorial:userTutorial stageId:stageId stageIndex:stageIndex];
    }
    else{
        [self showConquerDraw:fromController userTutorial:userTutorial stageId:stageId stageIndex:stageIndex];
    }

}



- (PBUserTutorial*)enterLearnDraw:(PPViewController*)fromController
                        userTutorial:(PBUserTutorial*)userTutorial
                             stageId:(NSString*)stageId
                          stageIndex:(int)stageIndex
                             type:(int)type
{
    PPSmartUpdateData* smartData = [self getSmartData:userTutorial.tutorial.tutorialId stageId:stageId];

//#ifdef DEBUG
//    
//    if ([smartData isDataExist]){
//        [self showLearnDraw:fromController userTutorial:userTutorial stageId:stageId stageIndex:stageIndex type:type];
//
//        return userTutorial;
//    }
//    
//#endif
    
//    if ([Reachability isNetworkOK] == NO){
        // network not available, try local data
    
    if ([smartData isDataExist]){
        [self showLearnDraw:fromController userTutorial:userTutorial stageId:stageId stageIndex:stageIndex type:type];
        [smartData checkUpdateAndDownload:nil failureBlock:nil];
        return userTutorial;
    }
    
//        else{
//            POSTMSG(NSLS(@"kDownloadTutorialFailure"));
//        }
    
//    }
    
    [fromController showProgressViewWithMessage:NSLS(@"kLoadingStage")];
    [self registerNotification:smartData viewController:fromController];
    
    [smartData checkUpdateAndDownload:^(BOOL isAlreadyExisted, NSString *dataFilePath) {
        
        [fromController hideProgressView];
        [self unregisterNotification:smartData viewController:fromController];

        [self showLearnDraw:fromController userTutorial:userTutorial stageId:stageId stageIndex:stageIndex type:type];
        
        
    } failureBlock:^(NSError *error) {
        
        [fromController hideProgressView];
        [self unregisterNotification:smartData viewController:fromController];
        
        if ([smartData isDataExist]){
            // access latest failure, just use local data
            [self showLearnDraw:fromController userTutorial:userTutorial stageId:stageId stageIndex:stageIndex type:type];
        }
        else{
            POSTMSG(NSLS(@"kDownloadTutorialFailure"));
        }
        
    }];
    
    return userTutorial;
}

- (PBUserTutorial*)enterPracticeDraw:(PPViewController*)fromController
                        userTutorial:(PBUserTutorial*)userTutorial
                             stageId:(NSString*)stageId
                          stageIndex:(int)stageIndex
{
    return [self enterLearnDraw:fromController
                   userTutorial:userTutorial
                        stageId:stageId
                     stageIndex:stageIndex
                           type:PBOpusTypeDrawPractice];
}

- (PBUserTutorial*)enterConquerDraw:(PPViewController*)fromController
                       userTutorial:(PBUserTutorial*)userTutorial
                            stageId:(NSString*)stageId
                         stageIndex:(int)stageIndex
{
    return [self enterLearnDraw:fromController
                   userTutorial:userTutorial
                        stageId:stageId
                     stageIndex:stageIndex
                           type:PBOpusTypeDrawConquer];
}

// 进入修炼界面
//- (PBUserTutorial*)enterPracticeDraw:(PPViewController*)fromController
//                        userTutorial:(PBUserTutorial*)userTutorial
//                             stageId:(NSString*)stageId
//                          stageIndex:(int)stageIndex
//{
//    
//    [fromController showProgressViewWithMessage:NSLS(@"kLoadingStage")];
//    PPSmartUpdateData* smartData = [self getSmartData:userTutorial.tutorial.tutorialId stageId:stageId];
//    [self registerNotification:smartData viewController:fromController];
//    
//    [smartData checkUpdateAndDownload:^(BOOL isAlreadyExisted, NSString *dataFilePath) {
//        
//        [fromController hideProgressView];
//        [self unregisterNotification:smartData viewController:fromController];
//        
//        [self showPracticeDraw:fromController userTutorial:userTutorial stageId:stageId stageIndex:stageIndex];
//        
//    } failureBlock:^(NSError *error) {
//        
//        [fromController hideProgressView];
//        [self unregisterNotification:smartData viewController:fromController];
//
//        if ([smartData isDataExist]){
//            [self showPracticeDraw:fromController userTutorial:userTutorial stageId:stageId stageIndex:stageIndex];
//        }
//        else{
//            POSTMSG(NSLS(@"kDownloadTutorialFailure"));
//        }
//        
//    }];
//
//    return userTutorial;
//}

@end
