//
//  DiceGamePlayController.h
//  Draw
//
//  Created by 小涛 王 on 12-7-27.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPViewController.h"
#import "DiceItemListView.h"
#import "DiceSelectedView.h"
#import "DiceAvatarView.h"
#import "UserManager.h"
#import "DicePopupViewManager.h"
#import "DiceImageManager.h"
#import "LevelService.h"
#import "AccountService.h"
#import "DicesResultView.h"
#import "AudioManager.h"
#import "CommonDialog.h"
#import "ChatView.h"
#import "ExpressionManager.h"
#import "DiceSoundManager.h"
#import "DiceRobotManager.h"
#import "DiceBetView.h"
#import "CommonInfoView.h"

#define USER_THINK_TIME_INTERVAL 15
#define ROBOT_CALL_TIPS_DIALOG_TAG  20120918

@class DiceGameService;
@class CustomDiceManager;
@class CommonDialog;


@interface DiceGamePlayController : PPViewController <DiceItemListViewDelegate, DiceSelectedViewDelegate, DiceAvatarViewDelegate, DicesResultViewAnimationDelegate, LevelServiceDelegate, CommonDialogDelegate, ChatViewDelegate, AccountServiceDelegate, DiceBetViewDelegate, CommonInfoViewDelegate> {
    DiceGameService*  _diceService;
    UserManager *_userManager;
    DiceImageManager *_imageManager;
    LevelService *_levelService;
    AccountService *_accountService;
    AudioManager *_audioManager;
    ExpressionManager *_expressionManager;
    DiceSoundManager *_soundManager;
    DiceRobotManager* _robotManager;
    CustomDiceManager* _customDicemanager;
    CommonDialog* _diceRobotDecision;
    NSMutableSet* _urgedUser;
}
@property (retain, nonatomic) IBOutlet UIImageView *tableImageView;

@property (retain, nonatomic) NSTimer *adHideTimer;
@property (retain, nonatomic) IBOutlet UILabel *myLevelLabel;
@property (retain, nonatomic) IBOutlet UILabel *myCoinsLabel;
@property (retain, nonatomic) IBOutlet UIView *myDiceListHolderView;
@property (retain, nonatomic) IBOutlet UIView *diceCountSelectedHolderView;
@property (retain, nonatomic) IBOutlet UILabel *roomNameLabel;
@property (retain, nonatomic) IBOutlet UIButton *openDiceButton;
@property (retain, nonatomic) IBOutlet UIButton *wildsButton;
@property (retain, nonatomic) IBOutlet UIButton *plusOneButton;
@property (retain, nonatomic) IBOutlet UIButton *itemsBoxButton;
@property (retain, nonatomic) IBOutlet UILabel *wildsLabel;
@property (retain, nonatomic) IBOutlet UILabel *plusOneLabel;
@property (retain, nonatomic) IBOutlet UIView *popResultView;
@property (retain, nonatomic) IBOutlet UILabel *rewardCoinLabel;
@property (retain, nonatomic) IBOutlet UIButton *wildsFlagButton;
@property (retain, nonatomic) IBOutlet UILabel *resultDiceCountLabel;
@property (retain, nonatomic) IBOutlet UIImageView *resultDiceImageView;
@property (retain, nonatomic) IBOutlet UIView *resultHolderView;
@property (retain, nonatomic) IBOutlet UILabel *waittingForNextTurnNoteLabel;
@property (retain, nonatomic) IBOutlet UILabel *gameBeginNoteLabel;
@property (retain, nonatomic) UIView  *adView;
@property (retain, nonatomic) IBOutlet UIButton *chatButton;
@property (retain, nonatomic) IBOutlet UIView *popupLevel1View;
@property (retain, nonatomic) IBOutlet UIView *popupLevel2View;
@property (retain, nonatomic) IBOutlet UIView *popupLevel3View;
@property (retain, nonatomic) IBOutlet UILabel *anteNoteLabel;
@property (retain, nonatomic) IBOutlet UILabel *anteLabel;
@property (retain, nonatomic) IBOutlet UIView *anteView;
@property (retain, nonatomic) IBOutlet UILabel *waitForPlayerBetLabel;

//- (id)initWIthRuleType:(DiceGameRuleType)ruleType;

- (UIView *)bellViewOfUser:(NSString *)userId;
- (DiceAvatarView *)selfAvatarView;
- (DiceAvatarView*)avatarViewOfUser:(NSString*)userId;
- (void)urgeUser:(NSString*)userId;
- (void)showRobotDecision;
- (void)hideRobotDecision;
- (void)clearAllUrgeUser;
@end
