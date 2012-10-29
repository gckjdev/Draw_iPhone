//
//  ZJHGameController.h
//  Draw
//
//  Created by 王 小涛 on 12-10-24.
//
//

#import "PPViewController.h"

@class ZJHGameService;
@class UserManager;
@class LevelService;
@class AudioManager;
@class ZJHImageManager;
@class AccountService;

typedef enum {
    UserPositionRightTop = 1,
    UserPositionRight,
    UserPositionCenter,
    UserPositionLeft,
    UserPositionLeftTop,
}UserPosition;

@interface ZJHGameController : PPViewController {
    ZJHGameService  *_gameService;
    LevelService    *_levelService;
    UserManager     *_userManager;
    AudioManager    *_audioManager;
    AccountService  *_accountService;
    ZJHImageManager *_imageManager;
}

@end
