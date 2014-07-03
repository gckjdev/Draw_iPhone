//
//  UserTutorialService.h
//  Draw
//
//  Created by qqn_pipi on 14-6-26.
//
//

#import "CommonService.h"
#import "Tutorial.pb.h"

typedef void(^UserTutorialServiceResultBlock)(int resultCode);

@interface UserTutorialService : CommonService

+ (UserTutorialService*)defaultService;

// 用户添加/开始学习某个教程
- (void)addTutorial:(PBTutorial*)tutorial resultBlock:(UserTutorialServiceResultBlock)resultBlock;
- (void)deleteUserTutorial:(PBUserTutorial*)ut resultBlock:(UserTutorialServiceResultBlock)resultBlock;

// 用户下载教程所有关卡数据
- (void)downloadTutorial:(PBTutorial*)tutorial resultBlock:(UserTutorialServiceResultBlock)resultBlock;

// 获取用户当前正在学习的所有教程列表
- (void)getAllUserTutorials:(UserTutorialServiceResultBlock)resultBlock;

@end
