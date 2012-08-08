//
//  DiceGamePlayController.h
//  Draw
//
//  Created by 小涛 王 on 12-7-27.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPViewController.h"
#import "ToolSheetView.h"
#import "FontLabel.h"
#import "FontButton.h"
#import "DiceSelectedView.h"
#import "DiceAvatarView.h"
#import "UserManager.h"
#import "DicePopupViewManager.h"
#import "DiceImageManager.h"
#import "HKGirlFontLabel.h"

@class DiceGameService;


@interface DiceGamePlayController : PPViewController <ToolSheetViewDelegate, DiceSelectedViewDelegate, DiceAvatarViewDelegate> {
    DiceGameService*  _diceService;
    UserManager *_userManager;
    DicePopupViewManager *_popupViewManager;
    DiceImageManager *_imageManager;
}

@property (retain, nonatomic) IBOutlet FontLabel *myLevelLabel;
@property (retain, nonatomic) IBOutlet FontLabel *myCoinsLabel;
@property (retain, nonatomic) IBOutlet UIView *myDiceListHolderView;
@property (retain, nonatomic) IBOutlet FontButton *statusButton;
@property (retain, nonatomic) IBOutlet UIView *diceCountSelectedHolderView;
@property (retain, nonatomic) IBOutlet FontLabel *roomNameLabel;
@property (retain, nonatomic) IBOutlet FontButton *openDiceButton;
@property (retain, nonatomic) IBOutlet UIButton *userWildsButton;
@property (retain, nonatomic) IBOutlet UIButton *plusOneButton;
@property (retain, nonatomic) IBOutlet UIButton *itemsBoxButton;
@property (retain, nonatomic) IBOutlet HKGirlFontLabel *wildsLabel;
@property (retain, nonatomic) IBOutlet HKGirlFontLabel *plusOneLabel;
@property (retain, nonatomic) IBOutlet UIView *popResultView;
@property (retain, nonatomic) IBOutlet HKGirlFontLabel *rewardCoinLabel;

@end
