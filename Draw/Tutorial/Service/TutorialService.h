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

#define TUTORIAL_HOST        [PPConfigManager getTutorialServerURL]

typedef void(^TutorialServiceResultBlock)(int resultCode);

@interface TutorialService : CommonService

@end
