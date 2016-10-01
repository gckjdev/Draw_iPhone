//
//  UserTutorialManager.m
//  Draw
//
//  Created by qqn_pipi on 14-6-26.
//
//

#import "UserTutorialManager.h"
#import "LevelDBManager.h"
#import "PBTutorial+Extend.h"
#import "TutorialCoreManager.h"

@interface UserTutorialManager()

@property (nonatomic, retain) APLevelDB* db;
@property (nonatomic, retain) NSString* currentDbName;

@end

@implementation UserTutorialManager

static UserTutorialManager* _defaultManager;

+ (UserTutorialManager*)defaultManager;
{
    if (_defaultManager == nil)
        _defaultManager = [[UserTutorialManager alloc] init];
    
    return _defaultManager;
}

- (NSString*)dbName
{
    NSString* userId = [[UserManager defaultManager] userId];
    return [NSString stringWithFormat:@"user_tutorial_%@", userId];
}

- (APLevelDB*)getDb
{
    NSString* dbName = [self dbName];
    self.currentDbName = dbName;
    self.db = [[LevelDBManager defaultManager] db:_currentDbName];
    return self.db;
}

- (NSString*)createLocalId
{
    return [NSString stringWithFormat:@"%010ld-%010d", time(0), rand()];
}

- (void)save:(PBUserTutorial*)ut
{
    if (ut == nil){
        return;
    }
    
    if ([ut.localId length] == 0){
        PPDebug(@"save user tutorial but localId is empty");
        return;
    }
    
    [[self getDb] setObject:[ut data] forKey:ut.localId];
    PPDebug(@"save user tutorial, localId=%@, turotialId=%@", ut.localId, ut.tutorial.tutorialId);
    return;
}

- (PBUserTutorial*)findUserTutorialByTutorialId:(NSString*)tutorialId
{
    if ([tutorialId length] == 0){
        return nil;
    }
    
    NSArray* all = [[self getDb] allObjects];
    for (NSData* data in all){
        @try
        {
            PBUserTutorial* ut = [PBUserTutorial parseFromData:data];
            if ([ut.tutorial.tutorialId isEqualToString:tutorialId]){
                return ut;
            }
        }
        @catch (NSException *exception) {
            PPDebug(@"<findUserTutorialByTutorialId> id=%@, but catch exception=%@", tutorialId, [exception description]);
        }
        @finally {
        }
    }
    
    return nil;
}

- (PBUserTutorial*)findUserTutorialByLocalId:(NSString*)localId
{
    if ([localId length] == 0){
        return nil;
    }
    
    @try
    {
        NSData* data = [[self getDb] objectForKey:localId];
        PBUserTutorial* ut = [PBUserTutorial parseFromData:data];
        return ut;
    }
    @catch (NSException *exception) {
        PPDebug(@"<findUserTutorialByLocalId> id=%@, but catch exception=%@", localId, [exception description]);
        return nil;
    }
}

- (void)dealloc
{
    PPRelease(_db);
    PPRelease(_currentDbName);
    [super dealloc];
}



#pragma mark - for external operation

//用户删除教程
- (BOOL)deleteUserTutorial:(PBUserTutorial *)userTutorial{
    
    if(userTutorial == nil){
        return nil;
    }
    
    PPDebug(@"<deleteUserTutorial> tutorialId=%@, localId=%@", userTutorial.tutorial.tutorialId, userTutorial.localId);
    return [[self getDb] removeKey:userTutorial.localId];
}

// 用户添加/开始学习某个教程
- (PBUserTutorial*)addTutorial:(PBTutorial*)tutorial
{
    if (tutorial == nil)
        return nil;
    
    NSString* userId = [[UserManager defaultManager] userId];
    if (userId == nil){
        return nil;
    }
    
    if ([self findUserTutorialByTutorialId:tutorial.tutorialId] != nil){
        // already added, don't add again
        PPDebug(@"<addTutorial> but tutorial(%@) already added", tutorial.tutorialId);
        return nil;
    }
    
    PBUserTutorialBuilder* builder = [PBUserTutorial builder];
    [builder setUserId:userId];
    [builder setTutorial:tutorial];
    
    // set status
    [builder setStatus:PBUserTutorialStatusUtStatusNotStart];
    
    // set init stage info
    if ([tutorial.stages count] > 0){
        PBStage* stage = [tutorial.stages objectAtIndex:0];
        [builder setCurrentStageIndex:0];
        [builder setCurrentStageId:stage.stageId];
    }
    
    // update time stamp
    [builder setCreateDate:time(0)];
    [builder setModifyDate:time(0)];
    
    // set key
    [builder setLocalId:[self createLocalId]];
    
    @try {
        PBUserTutorial* ut = [builder build];
        [self save:ut];
        return ut;
    }
    @catch (NSException *exception) {
        PPDebug(@"<addTutorial> tutorial(%@) catch exception", tutorial.tutorialId, [exception description]);
    }
    @finally {
    }
    
    return nil;
}

//- (PBTutorial*)createTestTutorial
//{
//    PBTutorialBuilder* builder = [PBTutorial builder];
//    [builder setTutorialId:@"testId2"];
//    [builder setCnName:@"测试教程2"];
//    
//    //默认的小图片
//    NSString *imageUrl = @"http://image226-c.poco.cn/mypoco/myphoto/20140312/20/5274901820140312205602029_640.jpg";
//    [builder setThumbImage:imageUrl];
//    
//    
//    return [builder build];
//}


-(void)addNewUserTutorialFromServer:(PBUserTutorial *)userTutorial WithRemoteId:(NSString *)remoteId{
    
    if (userTutorial == nil || userTutorial.tutorial == nil){
        return;
    }
    
    NSString* localId = [self createLocalId];
    
    PBUserTutorialBuilder* builder = [PBUserTutorial builderWithPrototype:userTutorial];
    
    PBTutorial* tutorial = [[TutorialCoreManager defaultManager] findTutorialByTutorialId:userTutorial.tutorial.tutorialId];
    if(tutorial == nil){
        PPDebug(@"<syncUserTutorial> but tutorial not found");
        return;
    }

    [builder setTutorial:tutorial];
    [builder setLocalId:localId];
    [builder setRemoteId:remoteId];
    
    [builder setCurrentStageIndex:userTutorial.currentStageIndex];
    
    NSUInteger stageIndex = userTutorial.currentStageIndex; // set to from server
    if (userTutorial.currentStageIndex < 0){
        stageIndex = 0; // set to first
    }
    else if (userTutorial.currentStageIndex >= [tutorial.stages count]){
        stageIndex = [tutorial.stages count]-1; // set to last
    }
    
    PBStage* stage = [tutorial.stages objectAtIndex:stageIndex];
    NSString* stageId = stage.stageId;
    
    [builder setCurrentStageIndex:stageIndex];
    [builder setCurrentStageId:stageId];
    
    for (int i=0; i<stageIndex+1; i++){
        // need to add user stage and add into user tutorial
        PBStage* stage = [tutorial.stages objectAtIndex:i];

        int addStageIndex = i;
        NSString* addStageId = stage.stageId;
        
        PBUserStageBuilder* userStageBuilder = nil;
        userStageBuilder = [PBUserStage builder];
        [userStageBuilder setStageId:addStageId];
        [userStageBuilder setStageIndex:addStageIndex];
        [userStageBuilder setTutorialId:tutorial.tutorialId];
        [userStageBuilder setUserId:[[UserManager defaultManager] userId]];
        
        PBUserStage* userStage = [userStageBuilder build];
        [builder addUserStages:userStage];
        
        PPDebug(@"<addNewUserTutorialFromServer> add new user stage(%d, %@)", addStageIndex, addStageId);
    }
    
    if(userTutorial == nil){
        PPDebug(@"<syncUserTutorial> but userTutorial not found");
        return;
    }
    if(remoteId == nil){
        PPDebug(@"<syncUserTutorial> but remoteId(%@) not found",remoteId);
        return;
    }

    PBUserTutorial* utToSave = [builder build];
    if (utToSave == nil){
        return;
    }
    
    [[self getDb] setObject:[utToSave data] forKey:localId];
    
    // TODO report new localId to server?
}

- (void)syncUserTutorial:(NSString*)utLocalId syncStatus:(BOOL)syncStatus
{
    if (utLocalId == nil){
        return;
    }
    
    PBUserTutorial* ut = [self findUserTutorialByLocalId:utLocalId];
    if (ut == nil){
        PPDebug(@"<syncUserTutorial> but localId(%@) not found", utLocalId);
        return;
    }
    
    if (syncStatus == ut.syncServer){
        // status the same, no need to update
        PPDebug(@"<syncUserTutorial> localId(%@) but status the same, skip", utLocalId);
        return;
    }
    
    PBUserTutorialBuilder* builder = [PBUserTutorial builderWithPrototype:ut];
    [builder setSyncServer:syncStatus];
    PBUserTutorial* newUt = [builder build];
    [self save:newUt];
}

- (void)saveUserTutorial:(NSString*)utLocalId remoteId:(NSString*)remoteId
{
    if (utLocalId == nil || remoteId == nil){
        return;
    }
    
    PBUserTutorial* ut = [self findUserTutorialByLocalId:utLocalId];
    if (ut == nil){
        PPDebug(@"<saveUserTutorial> but localId(%@) not found", utLocalId);
        return;
    }
    
    PBUserTutorialBuilder* builder = [PBUserTutorial builderWithPrototype:ut];
    [builder setRemoteId:remoteId];
    PBUserTutorial* newUt = [builder build];
    [self save:newUt];
}

- (void)addUserTutorials:(NSArray*)list
{
    @synchronized (self) {
        for(PBUserTutorial *retUserTutorial in list){
            [[UserTutorialManager defaultManager] addNewUserTutorialFromServer:retUserTutorial WithRemoteId:retUserTutorial.remoteId];
        }
    }
}

- (NSArray*)allUserTutorials
{
    @synchronized (self) {
        NSArray* list = [[self getDb] allObjects];
        if ([list count] == 0){
            PPDebug(@"<allUserTutorials> no item");
            return nil;
        }
        
        NSMutableArray* retList = [[[NSMutableArray alloc] initWithCapacity:[list count]] autorelease];
        for (NSData* data in list){
            @try {
                PBUserTutorial* ut = [PBUserTutorial parseFromData:data];
                [retList insertObject:ut atIndex:0]; // insert from first
            }
            @catch (NSException *exception) {
            }
            @finally {
            }
        }
        
        [retList sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            PBUserTutorial* ut1 = obj1;
            PBUserTutorial* ut2 = obj2;
            return (ut2.modifyDate - ut1.modifyDate);
        }];
        
        PPDebug(@"<allUserTutorials> return %d items", [retList count]);
        return retList;
    }
}

- (BOOL)isTutorialLearned:(NSString*)tutorialId
{
    NSArray* list = [self allUserTutorials];
    for (PBUserTutorial* ut in list){
        if ([ut.tutorial.tutorialId isEqualToString:tutorialId]){
            return YES;
        }
    }
    
    return NO;
}

-(PBUserTutorial *)getUserTutorialByTutorialId:(NSString*)tutorialId{
    NSArray* list = [self allUserTutorials];
    for(PBUserTutorial* ut in list){
        if([ut.tutorial.tutorialId isEqualToString:tutorialId]){
            return ut;
        }
        
    }
    return nil;
}

// 实现一样，待合并
- (PBUserTutorial*)conquerTutorialStage:(NSString*)userTutorialLocalId
                                 stageId:(NSString*)stageId
                              stageIndex:(int)stageIndex
{
    PPDebug(@"<conquerTutorialStage> localId=%@, stageId=%@, stageIndex=%d", userTutorialLocalId, stageId, stageIndex);
    
    if (stageId == nil){
        return nil;
    }
    
    PBUserTutorial* ut = [self findUserTutorialByLocalId:userTutorialLocalId];
    if (ut == nil){
        return nil;
    }
    
    if (ut.tutorial.tutorialId == nil){
        return nil;
    }
    
    if ([ut isStageLock:stageIndex]){
        PPDebug(@"stage %d is lock for user tutorial", stageIndex);
        return nil;
    }
    
    PBUserTutorialBuilder* builder = [PBUserTutorial builderWithPrototype:ut];
    
    if (stageIndex >= [ut.userStages count]){
        for (NSUInteger i=ut.userStages.count; i<=stageIndex; i++){
            // need to create new user stage and add into user tutorial
            NSString* addStageId = [[ut.tutorial.stages objectAtIndex:i] stageId];
            PBUserStageBuilder* userStageBuilder = nil;
            userStageBuilder = [PBUserStage builder];
            [userStageBuilder setStageId:addStageId];
            [userStageBuilder setTutorialId:ut.tutorial.tutorialId];
            [userStageBuilder setUserId:ut.userId];
            [userStageBuilder setStageIndex:i];
            
            PBUserStage* userStage = [userStageBuilder build];
            [builder addUserStages:userStage];
            
            PPDebug(@"<conquerTutorialStage> add new user stage at (%d, %@)",
                    i, addStageId);
        }
    }
    else if (stageIndex < [ut.userStages count]){
        // already has current user stage data
        PBUserStage* us = [ut userStagesAtIndex:stageIndex];
        if (us != nil){
        }
        
        PPDebug(@"<conquerTutorialStage> use existing user stage");
    }
    else{
        // need to create new user stage and add into user tutorial
        PBUserStageBuilder* userStageBuilder = nil;
        userStageBuilder = [PBUserStage builder];
        [userStageBuilder setStageId:stageId];
        [userStageBuilder setTutorialId:ut.tutorial.tutorialId];
        [userStageBuilder setUserId:ut.userId];
        [userStageBuilder setStageIndex:stageIndex];
        
        PBUserStage* userStage = [userStageBuilder build];
        [builder addUserStages:userStage];
        
        PPDebug(@"<conquerTutorialStage> add new user stage");
    }
    
    [builder setModifyDate:time(0)];
    
    PBUserTutorial* newUT = [builder build];
    [self save:newUT];
    return newUT;
}

- (PBUserTutorial*)practiceTutorialStage:(NSString*)userTutorialLocalId
                                      stageId:(NSString*)stageId
                                   stageIndex:(int)stageIndex
{
    PPDebug(@"<practiceTutorialStage> localId=%@, stageId=%@, stageIndex=%d", userTutorialLocalId, stageId, stageIndex);
    
    if (stageId == nil){
        return nil;
    }
    
    PBUserTutorial* ut = [self findUserTutorialByLocalId:userTutorialLocalId];
    if (ut == nil){
        return nil;
    }
    
    if (ut.tutorial.tutorialId == nil){
        return nil;
    }
    
    if ([ut isStageLock:stageIndex]){
        PPDebug(@"stage %d is lock for user tutorial", stageIndex);
        return nil;
    }
    
    PBUserTutorialBuilder* builder = [PBUserTutorial builderWithPrototype:ut];

    if (stageIndex < [ut.userStages count]){
        // already has current user stage data
        PBUserStage* us = [ut userStagesAtIndex:stageIndex];
        if (us != nil){
//            userStageBuilder = [PBUserStage builderWithPrototype:us];
        }

        PPDebug(@"<practiceTutorialStage> use existing user stage");
    }
    else{
        // need to create new user stage and add into user tutorial
        PBUserStageBuilder* userStageBuilder = nil;
        userStageBuilder = [PBUserStage builder];
        [userStageBuilder setStageId:stageId];
        [userStageBuilder setTutorialId:ut.tutorial.tutorialId];
        [userStageBuilder setUserId:ut.userId];
        [userStageBuilder setStageIndex:stageIndex];

        PBUserStage* userStage = [userStageBuilder build];
        [builder addUserStages:userStage];
        
        PPDebug(@"<practiceTutorialStage> add new user stage");
    }

    [builder setModifyDate:time(0)];
    
    PBUserTutorial* newUT = [builder build];
    [self save:newUT];
    return newUT;
}

- (PBUserTutorial*)updateUserStage:(PBUserStage*)userStage utLocalId:(NSString*)utLocalId
{
    if (userStage == nil){
        PPDebug(@"<updateUserStage> but userStage is nil");
        return nil;
    }
    
    PBUserTutorial* ut = [self findUserTutorialByLocalId:utLocalId];
    if (ut == nil){
        PPDebug(@"<updateUserStage> but tutorialId=%@ not found for user", userStage.tutorialId);
        return nil;
    }
    
    if (userStage.stageIndex >= [ut.userStages count]){
        PPDebug(@"<updateUserStage> but stageIndex=%d out of bound for current user stage list count(%d)",
                userStage.stageIndex, [ut.userStages count]);
        return nil;
    }
    
    PBUserTutorialBuilder* builder = [PBUserTutorial builderWithPrototype:ut];
    
    [builder.userStages replaceObjectAtIndex:userStage.stageIndex withObject:userStage];
    
//    [builder replaceUserStagesAtIndex:userStage.stageIndex with:userStage];
    PBUserTutorial* finalUT = [builder build];
    [self save:finalUT];
    return finalUT;
}

- (BOOL)isLastStage:(PBUserStage*)userStage
{
    if (userStage == nil){
        PPDebug(@"<isLastStage> but userStage is nil");
        return NO;
    }
    
    PBTutorial* tutorial = [[TutorialCoreManager defaultManager] findTutorialByTutorialId:userStage.tutorialId];
    if (tutorial == nil){
        PPDebug(@"<isLastStage> but tutorialId=%@ not found for user", userStage.tutorialId);
        return NO;
    }
    
    PPDebug(@"<isLastStage> stageIndex=%d, tutorial stage list count(%d)",
            userStage.stageIndex, [tutorial.stages count]);

    if (userStage.stageIndex >= ([tutorial.stages count] - 1)){
        return YES;
    }
    else{
        return NO;
    }
    
}

- (BOOL)isPass:(int)score
{
    if (score == 0){
        return NO;
    }
    
#ifdef DEBUG
    return YES;
#endif
    
    return (score >= 60);
}

- (PBUserTutorial*)updateLatestTutorial:(PBUserTutorial*)ut
{
    if (ut == nil){
        return ut;
    }
    
    PBUserTutorialBuilder* builder = [PBUserTutorial builderWithPrototype:ut];
    PBTutorial* tutorial = [[TutorialCoreManager defaultManager] findTutorialByTutorialId:ut.tutorial.tutorialId];
    if (tutorial == nil){
        return ut;;
    }
    
    [builder setTutorial:tutorial];
    PBUserTutorial* newUT = [builder build];
    [[UserTutorialManager defaultManager] save:newUT];
    return newUT;
}

@end
