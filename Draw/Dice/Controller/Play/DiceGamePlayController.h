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
#import "FontLabel.h"
#import "FontButton.h"
#import "DiceSelectedView.h"
#import "DiceAvatarView.h"
#import "UserManager.h"
#import "DicePopupViewManager.h"
#import "DiceImageManager.h"
#import "HKGirlFontLabel.h"
#import "LevelService.h"
#import "AccountService.h"
#import "DicesResultView.h"
#import "AudioManager.h"
#import "CommonDialog.h"
#import "ItemService.h"
#import "ChatView.h"
#import "ExpressionManager.h"
#import "DiceSoundManager.h"
#import "DiceItemManager.h"

#define USER_THINK_TIME_INTERVAL 15

@class DiceGameService;


@interface DiceGamePlayController : PPViewController <DiceItemListViewDelegate, DiceSelectedViewDelegate, DiceAvatarViewDelegate, DicesResultViewAnimationDelegate, LevelServiceDelegate, CommonDialogDelegate, ChatViewDelegate, AccountServiceDelegate> {
    DiceGameService*  _diceService;
    UserManager *_userManager;
    DiceImageManager *_imageManager;
    LevelService *_levelService;
    AccountService *_accountService;
    AudioManager *_audioManager;
//    ItemService *_itemService;
    ExpressionManager *_expressionManager;
    DiceSoundManager *_soundManager;
    
    int hideAdCounter;
}

@property (retain, nonatomic) NSTimer *adHideTimer;

@property (retain, nonatomic) IBOutlet FontLabel *myLevelLabel;
@property (retain, nonatomic) IBOutlet FontLabel *myCoinsLabel;
@property (retain, nonatomic) IBOutlet UIView *myDiceListHolderView;
@property (retain, nonatomic) IBOutlet UIView *diceCountSelectedHolderView;
@property (retain, nonatomic) IBOutlet FontLabel *roomNameLabel;
@property (retain, nonatomic) IBOutlet FontButton *openDiceButton;
@property (retain, nonatomic) IBOutlet UIButton *wildsButton;
@property (retain, nonatomic) IBOutlet UIButton *plusOneButton;
@property (retain, nonatomic) IBOutlet UIButton *itemsBoxButton;
@property (retain, nonatomic) IBOutlet HKGirlFontLabel *wildsLabel;
@property (retain, nonatomic) IBOutlet HKGirlFontLabel *plusOneLabel;
@property (retain, nonatomic) IBOutlet UIView *popResultView;
@property (retain, nonatomic) IBOutlet HKGirlFontLabel *rewardCoinLabel;
@property (retain, nonatomic) IBOutlet FontButton *wildsFlagButton;
@property (retain, nonatomic) IBOutlet HKGirlFontLabel *resultDiceCountLabel;
@property (retain, nonatomic) IBOutlet UIImageView *resultDiceImageView;
@property (retain, nonatomic) IBOutlet UIView *resultHolderView;
@property (retain, nonatomic) IBOutlet HKGirlFontLabel *waittingForNextTurnNoteLabel;
@property (retain, nonatomic) IBOutlet HKGirlFontLabel *gameBeginNoteLabel;
@property (retain, nonatomic) UIView  *adView;
@property (retain, nonatomic) IBOutlet UIButton *chatButton;
@property (retain, nonatomic) IBOutlet UIView *popupLevel1View;
@property (retain, nonatomic) IBOutlet UIView *popupLevel2View;
@property (retain, nonatomic) IBOutlet UIView *popupLevel3View;

- (UIView *)bellViewOfUser:(NSString *)userId;
- (DiceAvatarView *)selfAvatarView;
- (DiceAvatarView*)avatarViewOfUser:(NSString*)userId;

@end
