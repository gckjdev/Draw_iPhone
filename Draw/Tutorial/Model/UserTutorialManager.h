//
//  UserTutorialManager.h
//  Draw
//
//  Created by qqn_pipi on 14-6-26.
//
//

#import <Foundation/Foundation.h>
#import "Tutorial.pb.h"

@interface UserTutorialManager : NSObject

+ (UserTutorialManager*)defaultManager;


-(BOOL)deleteUserTutorial:(PBUserTutorial *)userTutorial;

// 用户添加/开始学习某个教程
- (PBUserTutorial*)addTutorial:(PBTutorial*)tutorial;
- (BOOL)isTutorialLearned:(NSString*)tutorialId;
-(PBUserTutorial *)getUserTutorialByTutorialId:(NSString*)tutorialId;

- (void)syncUserTutorial:(NSString*)utLocalId syncStatus:(BOOL)syncStatus;
- (void)saveUserTutorial:(NSString*)utLocalId remoteId:(NSString*)remoteId;

// return all user tutorial in local
- (NSArray*)allUserTutorials;

- (PBUserTutorial*)practiceTutorialStage:(NSString*)userTutorialLocalId
                                 stageId:(NSString*)stageId
                              stageIndex:(int)stageIndex;

- (PBUserTutorial*)conquerTutorialStage:(NSString*)userTutorialLocalId
                                stageId:(NSString*)stageId
                             stageIndex:(int)stageIndex;

- (PBUserTutorial*)updateUserStage:(PBUserStage*)userStage utLocalId:(NSString*)utLocalId;
- (BOOL)isLastStage:(PBUserStage*)userStage;

- (void)addNewUserTutorialFromServer:(PBUserTutorial *)userTutorial WithRemoteId:(NSString *)remoteId;
- (BOOL)isPass:(int)score;
- (void)save:(PBUserTutorial*)ut;

- (PBUserTutorial*)updateLatestTutorial:(PBUserTutorial*)ut;
- (PBUserTutorial*)findUserTutorialByLocalId:(NSString*)localId;

@end
