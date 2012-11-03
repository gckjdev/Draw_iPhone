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
#import "DealerView.h"
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

@interface ZJHGameController : PPViewController <PokerViewProtocol, ZJHAvatarViewDelegate, DealerViewDelegate, ChipsSelectViewProtocol>

@property (retain, nonatomic) IBOutlet BetTable *betTable;
@property (retain, nonatomic) IBOutlet DealerView *dealerView;
@property (retain, nonatomic) IBOutlet UIButton *betButton;
@property (retain, nonatomic) IBOutlet UIButton *raiseBetButton;
@property (retain, nonatomic) IBOutlet UIButton *autoBetButton;
@property (retain, nonatomic) IBOutlet UIButton *compareCardButton;
@property (retain, nonatomic) IBOutlet UIButton *checkCardButton;
@property (retain, nonatomic) IBOutlet UIButton *foldCardButton;
@property (retain, nonatomic) IBOutlet UIButton *cardTypeButton;
@property (retain, nonatomic) IBOutlet UILabel *totalBetLabel;
@property (retain, nonatomic) IBOutlet UILabel *singleBetLabel;


@end
