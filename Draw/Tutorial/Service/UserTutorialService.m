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


- (void)addUserTutorial:(PBUserTutorial*)ut
{
    [self actionOnUserTutorial:ut action:ACTION_ADD_USER_TUTORIAL];
}

- (void)deleteUserTutorial:(PBUserTutorial*)ut
{
    [self actionOnUserTutorial:ut action:ACTION_DELETE_USER_TUTORIAL];
}

//用户学习某个教程的信息到服务器
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
                                    
                                    // update user tutorial SYNC status
                                    [[UserTutorialManager defaultManager] syncUserTutorial:ut.localId syncStatus:YES];
                                }
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
    [self addUserTutorial:ut];
}
//删除教程
- (void)deleteUserTutorial:(PBUserTutorial*)ut resultBlock:(UserTutorialServiceResultBlock)resultBlock
{
    NSString * userId = ut.userId;
    
    
    [[UserTutorialManager defaultManager] deleteUserTutorial:ut];
    EXECUTE_BLOCK(resultBlock, 0);
    
    // TODO check how to sync later
//    [self syncUserTutorial:ut];
}



// 用户下载教程所有关卡数据
- (void)downloadTutorial:(PBTutorial*)tutorial resultBlock:(UserTutorialServiceResultBlock)resultBlock
{
    
}

// 获取用户当前正在学习的所有教程列表
- (void)getAllUserTutorials:(UserTutorialServiceResultBlock)resultBlock
{
    NSArray* list = [[UserTutorialManager defaultManager] allUserTutorials];
    if (list == nil){
        // TODO, try to sync from server
        
    }

    EXECUTE_BLOCK(resultBlock, 0);
}


@end
