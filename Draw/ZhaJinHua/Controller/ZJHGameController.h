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
    UserPositionLeftTop = 0,
    UserPositionLeft,
    UserPositionCenter,
    UserPositionRight,
    UserPositionRightTop,
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
