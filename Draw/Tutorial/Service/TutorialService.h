//
//  TutorialService.h
//  Draw
//
//  Created by qqn_pipi on 14-6-26.
//
//

#import "CommonService.h"
#import "PPConfigManager.h"
#import "DrawError.h"

#define TUTORIAL_HOST                      [PPConfigManager getTutorialServerURL]
#define TUTORIAL_FILE_SERVER_URL           ([MobClickUtils getStringValueByKey:@"TUTORIAL_FILE_SERVER_URL" defaultValue:@"http://58.215.160.100:8080/app_res/tutorial/"])



typedef void(^TutorialServiceResultBlock)(int resultCode);

@interface TutorialService : CommonService

@end
