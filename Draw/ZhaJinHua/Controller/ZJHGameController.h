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
#import "FXLabel.h"

@class ZJHGameService;
@class UserManager;
@class LevelService;
@class AudioManager;
@class ZJHImageManager;
@class AccountService;
@class BetTable;
@class MoneyTreeView;

@interface ZJHGameController : PPViewController <ZJHPokerViewProtocol, ZJHAvatarViewDelegate, DealerViewDelegate, ChipsSelectViewProtocol, MoneyTreeDelegate> {
    BOOL _isComparing;
    BOOL _isShowingComparing;
}

@property (retain, nonatomic) IBOutlet UIImageView *gameBgImageView;
@property (retain, nonatomic) IBOutlet UIImageView *totalBetBgImageView;
@property (retain, nonatomic) IBOutlet UIImageView *buttonsHolderBgImageView;
@property (retain, nonatomic) IBOutlet UIButton *runawayButton;
@property (retain, nonatomic) IBOutlet UIButton *settingButton;
@property (retain, nonatomic) IBOutlet UIButton *chatButton;
@property (retain, nonatomic) IBOutlet UIView *moneyTreeHolder;
@property (retain, nonatomic) IBOutlet UIImageView *vsImageView;

@property (retain, nonatomic) IBOutlet BetTable *betTable;
@property (retain, nonatomic) IBOutlet DealerView *dealerView;
@property (retain, nonatomic) IBOutlet UIButton *betButton;
@property (retain, nonatomic) IBOutlet UIButton *raiseBetButton;
@property (retain, nonatomic) IBOutlet UIButton *autoBetButton;
@property (retain, nonatomic) IBOutlet UIButton *compareCardButton;
@property (retain, nonatomic) IBOutlet UIButton *checkCardButton;
@property (retain, nonatomic) IBOutlet UIButton *foldCardButton;
@property (retain, nonatomic) IBOutlet FXLabel *singleBetLabel;
@property (retain, nonatomic) IBOutlet FXLabel *singleBetNoteLabel;
@property (retain, nonatomic) IBOutlet FXLabel *totalBetLabel;
@property (retain, nonatomic) IBOutlet FXLabel *totalBetNoteLabel;

@property (retain, nonatomic) MoneyTreeView *moneyTreeView;

@property (retain, nonatomic) IBOutlet FXLabel *cardTypeLabel;
@property (retain, nonatomic) IBOutlet FXLabel *roomNameLabel;



@end
