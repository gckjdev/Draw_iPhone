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
#import "FXLabel.h"
#import "MoneyTreeView.h"
#import "CommonDialog.h"
#import "AccountService.h"
#import "FallingCoinView.h"

@class ZJHGameService;
@class UserManager;
@class LevelService;
@class AudioManager;
@class ZJHImageManager;
@class BetTable;

@interface ZJHGameController : PPViewController <ZJHPokerViewProtocol, ZJHAvatarViewDelegate, DealerViewDelegate, ChipsSelectViewProtocol, MoneyTreeViewDelegate, CommonDialogDelegate, AccountServiceDelegate, FallingCoinViewDelegate> {
    BOOL _isComparing;
    BOOL _isShowingComparing;
    FallingCoinView* _coinView;
}

@property (retain, nonatomic) IBOutlet UIView *rightTopAvatar;
@property (retain, nonatomic) IBOutlet UIView *rightAvatar;
@property (retain, nonatomic) IBOutlet UIView *centerAvatar;
@property (retain, nonatomic) IBOutlet UIView *leftAvatar;
@property (retain, nonatomic) IBOutlet UIView *leftTopAvatar;
@property (retain, nonatomic) IBOutlet ZJHPokerView *leftTopPokers;
@property (retain, nonatomic) IBOutlet ZJHPokerView *rightTopPokers;
@property (retain, nonatomic) IBOutlet ZJHPokerView *leftPokers;
@property (retain, nonatomic) IBOutlet ZJHPokerView *rightPokers;
@property (retain, nonatomic) IBOutlet ZJHPokerView *centerPokers;
@property (retain, nonatomic) IBOutlet UIImageView *centerTotalBetBg;
@property (retain, nonatomic) IBOutlet UIImageView *rightTotalBetBg;
@property (retain, nonatomic) IBOutlet UIImageView *leftTotalBetBg;
@property (retain, nonatomic) IBOutlet UIImageView *rightTopTotalBetBg;
@property (retain, nonatomic) IBOutlet UIImageView *leftTopTotalBetBg;
@property (retain, nonatomic) IBOutlet UILabel *centerTotalBet;
@property (retain, nonatomic) IBOutlet UILabel *leftTotalBet;
@property (retain, nonatomic) IBOutlet UILabel *rightTotalBet;
@property (retain, nonatomic) IBOutlet UILabel *rightTopTotalBet;
@property (retain, nonatomic) IBOutlet UILabel *leftTopTotalBet;

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
@property (retain, nonatomic) IBOutlet UIButton *cardTypeButton;
@property (retain, nonatomic) IBOutlet UIImageView *cardTypeBgImageView;
@property (retain, nonatomic) IBOutlet FXLabel *roomNameLabel;

@property (retain, nonatomic) IBOutlet FXLabel *waitGameNoteLabel;


@end
