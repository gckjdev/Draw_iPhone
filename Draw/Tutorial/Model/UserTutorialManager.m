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
    
    PBUserTutorial_Builder* builder = [PBUserTutorial builder];
    [builder setUserId:userId];
    [builder setTutorial:tutorial];
    
    // set status
    [builder setStatus:PBUserTutorialStatusUtStatusNotStart];
    
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
//    PBTutorial_Builder* builder = [PBTutorial builder];
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
    
    PBUserTutorial_Builder* builder = [PBUserTutorial builderWithPrototype:ut];
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
    
    PBUserTutorial_Builder* builder = [PBUserTutorial builderWithPrototype:ut];
    [builder setRemoteId:remoteId];
    PBUserTutorial* newUt = [builder build];
    [self save:newUt];
}

- (NSArray*)allUserTutorials
{
    NSArray* list = [[self getDb] allObjects];

//#ifdef DEBUG
//    // for test
//    if ([list count] == 0){
//            PBTutorial* tutorial = [self createTestTutorial];
//            [self addTutorial:tutorial];
//        
//        list = [[self getDb] allObjects];
//    }
//#endif
    
    NSMutableArray* retList = [[[NSMutableArray alloc] init] autorelease];
    for (NSData* data in list){
        @try {
            PBUserTutorial* ut = [PBUserTutorial parseFromData:data];
            [retList addObject:ut];
        }
        @catch (NSException *exception) {
        }
        @finally {
        }
    }
    
    return retList;
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
    
    PBUserTutorial_Builder* builder = [PBUserTutorial builderWithPrototype:ut];

    if (stageIndex < [ut.userStagesList count]){
        // already has current user stage data
        PBUserStage* us = [ut userStagesAtIndex:stageIndex];
        if (us != nil){
//            userStageBuilder = [PBUserStage builderWithPrototype:us];
        }

        PPDebug(@"<practiceTutorialStage> use existing user stage");
    }
    else{
        // need to create new user stage and add into user tutorial
        PBUserStage_Builder* userStageBuilder = nil;
        userStageBuilder = [PBUserStage builder];
        [userStageBuilder setStageId:stageId];
        [userStageBuilder setTutorialId:ut.tutorial.tutorialId];
        [userStageBuilder setUserId:ut.userId];
        [userStageBuilder setStageIndex:stageIndex];

        PBUserStage* userStage = [userStageBuilder build];
        [builder addUserStages:userStage];
        
        PPDebug(@"<practiceTutorialStage> add new user stage");
    }

    PBUserTutorial* newUT = [builder build];
    [self save:newUT];
    return newUT;
}

@end
