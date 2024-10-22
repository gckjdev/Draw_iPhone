//
//  UserTutorialService.h
//  Draw
//
//  Created by qqn_pipi on 14-6-26.
//
//

#import "CommonService.h"
#import "Tutorial.pb.h"
#import "DrawConstants.h"

typedef enum{
    
    ACTION_ADD_USER_TUTORIAL = 1,         // 开始学习/添加教程
    ACTION_DELETE_USER_TUTORIAL = 2,      // 删除
    ACTION_PRACTICE_USER_TUTORIAL = 3,    // 修炼
    ACTION_CONQUER_USER_TUTORIAL = 4,     // 闯关
    ACTION_DOWNLOAD_USER_TUTORIAL = 5,    // 下载教程所有关卡，或者单个关卡
    ACTION_GET_ALL_USER_TUTORIAL = 6,     // 取得所有用户教程
    ACTION_UPDATE_USER_TUTORIAL = 7,      // 更新数据

} UserTutorialActionType;

typedef void(^UserTutorialServiceResultBlock)(int resultCode);
typedef void(^UserTutorialServiceGetListResultBlock)(int resultCode, NSArray* retList);

@class PPViewController;

@interface UserTutorialService : CommonService

+ (UserTutorialService*)defaultService;

// 下载数据的目录、文件名和存储方法
+ (NSString*)getTutorialDataDir:(NSString*)tutorialId;
+ (NSString*)getStageDataFileName:(NSString*)tutorialId stageId:(NSString*)stageId;
+ (NSString*)getLocalStageDataPath:(NSString*)tutorialId stageId:(NSString*)stageId;

// 用户添加/开始学习某个教程
- (void)addTutorial:(PBTutorial*)tutorial resultBlock:(UserTutorialServiceResultBlock)resultBlock;
//用户删除指定关卡
- (void)deleteUserTutorial:(PBUserTutorial*)ut resultBlock:(UserTutorialServiceResultBlock)resultBlock;

// 用户下载教程所有关卡数据
- (void)downloadTutorial:(PBTutorial*)tutorial resultBlock:(UserTutorialServiceResultBlock)resultBlock;

// 用户下载某个关卡数据
- (void)downloadStage:(PBUserTutorial*)userTutorial resultBlock:(UserTutorialServiceResultBlock)resultBlock;


// 获取用户当前正在学习的所有教程列表
- (void)getAllUserTutorials:(UserTutorialServiceGetListResultBlock)resultBlock;

// 用户尝试修炼
- (PBUserTutorial*)startPracticeTutorialStage:(NSString*)userTutorialLocalId
                                      stageId:(NSString*)stageId
                                   stageIndex:(int)stageIndex;

// 用户尝试闯关
- (PBUserTutorial*)startConquerTutorialStage:(NSString*)userTutorialLocalId
                                      stageId:(NSString*)stageId
                                   stageIndex:(int)stageIndex;

// 用户成功通过当前关
- (PBUserTutorial*)passCurrentStage:(PBUserTutorial*)userTutorial;

//从服务器取得用户教程列表

// 进入闯关界面
- (PBUserTutorial*)enterConquerDraw:(PPViewController*)fromController
                       userTutorial:(PBUserTutorial*)userTutorial
                            stageId:(NSString*)stageId
                         stageIndex:(int)stageIndex;

// 进入修炼界面
- (PBUserTutorial*)enterPracticeDraw:(PPViewController*)fromController
                       userTutorial:(PBUserTutorial*)userTutorial
                            stageId:(NSString*)stageId
                         stageIndex:(int)stageIndex;

// 获得某个小节显示图片的路径（该图片用于界面显示）
- (NSString*)getChapterImagePath:(NSString*)tutorialId stage:(PBStage*)stage chapterIndex:(int)currentChapterIndex;

// 获得某个小节显示图片的路径（该图片用于界面显示）
- (NSArray*)getChapterTipsImagePath:(NSString*)tutorialId stage:(PBStage*)stage chapterIndex:(int)chapterIndex;

// 获得当前背景图片的路径（该图片用于界面显示）
- (NSString*)getBgImagePath:(NSString*)tutorialId stage:(PBStage*)stage;

// 获得作品数据文件的路径（该图片用于界面显示）
- (NSString*)getOpusDataPath:(NSString*)tutorialId stage:(PBStage*)stage;

// 保存最近一次闯关作品图片
- (void)saveTutorialImage:(PBUserStage*)userStage image:(UIImage*)image type:(TargetType)type;;

// 获得最近一次闯关作品图片
- (UIImage*)stageDrawImage:(PBUserStage*)userStage type:(TargetType)type;;

// 获得画画时候的背景图
- (UIImage*)getBgImage:(PBUserStage*)userStage stage:(PBStage*)stage type:(TargetType)type;


@end
