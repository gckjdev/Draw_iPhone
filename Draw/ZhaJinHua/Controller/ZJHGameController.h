//
//  ZJHGameController.h
//  Draw
//
//  Created by 王 小涛 on 12-10-24.
//
//

#import "PPViewController.h"
#import "ZJHPokerView.h"
#import "ZJHAvatarView.h"
#import "DealerView.h"
#import "ChipsSelectView.h"
#import "ZJHImageManager.h"
#import "MoneyTree.h"


@class ZJHGameService;
@class UserManager;
@class LevelService;
@class AudioManager;
@class ZJHImageManager;
@class AccountService;
@class BetTable;
@class MoneyTree;


@interface ZJHGameController : PPViewController <ZJHPokerViewProtocol, ZJHAvatarViewDelegate, DealerViewDelegate, ChipsSelectViewProtocol, MoneyTreeDelegate> {
    BOOL _isComparing;
}

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
@property (retain, nonatomic) IBOutlet MoneyTree *moneyTree;
@property (retain, nonatomic) IBOutlet UIImageView *vsImageView;


@end
