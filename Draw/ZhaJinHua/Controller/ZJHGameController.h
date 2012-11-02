//
//  ZJHGameController.h
//  Draw
//
//  Created by 王 小涛 on 12-10-24.
//
//

#import "PPViewController.h"
#import "PokerView.h"
#import "ZJHAvatarView.h"
#import "ChipsSelectView.h"

@class ZJHGameService;
@class UserManager;
@class LevelService;
@class AudioManager;
@class ZJHImageManager;
@class AccountService;
@class BetTable;

typedef enum {
    UserPositionRightTop = 1,
    UserPositionRight,
    UserPositionCenter,
    UserPositionLeft,
    UserPositionLeftTop,
}UserPosition;

@interface ZJHGameController : PPViewController <PokerViewProtocol, ZJHAvatarViewDelegate, ChipsSelectViewProtocol>
@property (retain, nonatomic) IBOutlet BetTable *betTable;

@end
