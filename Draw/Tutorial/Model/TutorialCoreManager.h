//
//  TutorialCoreManager.h
//  Draw
//
//  Created by qqn_pipi on 14-6-26.
//
//

#import <Foundation/Foundation.h>
#import "Tutorial.pb.h"
// 管理所有教程的核心类，包括自动从服务器更新所有教程数据和保存到本地
@interface TutorialCoreManager : NSObject

+ (TutorialCoreManager*)defaultManager;
- (void)autoUpdate;

// 返回教程列表
- (NSArray*)allTutorials;

// 内存清理
- (void)cleanData;

// 创建测试数据
- (void)createTestData;

-(PBTutorial*)findTutorialByUserTutorialId:(PBUserTutorial*)userTutorial;
-(PBTutorial*)findTutorialByTutorialId:(NSString*)tutorialId;

-(PBTutorial*)defaultFirstTutorial;


@end
