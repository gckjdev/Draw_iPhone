//
//  RoomListController.h
//  Draw
//
//  Created by 小涛 王 on 12-7-27.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPTableViewController.h"
#import "DiceGameService.h"
#import "RoomPasswordDialog.h"
#import "HelpView.h"
#import "CommonDialog.h"
#import "DiceConfigManager.h"
#import "CommonSearchView.h"
#import "DiceRoomListCell.h"
#import "CommonRoomListController.h"

typedef enum {
    allRoom = 0,
    friendRoom = 1,
    nearByRoom = 2
}RoomFilter;

@class FontButton;
@class PBGameSession;
@class CommonSearchView;

@interface DiceRoomListController : PPTableViewController</*CommonGameServiceDelegate, */InputDialogDelegate, HelpViewDelegate, CommonDialogDelegate, CommonSearchViewDelegate, CommonInfoViewDelegate, DiceRoomListCellDelegate> {
    BOOL _isJoiningDice;
    DiceGameService* _diceGameService;
    PBGameSession* _currentSession;
    NSTimer* _refreshRoomTimer;
    BOOL firstLoad;
    int _currentRoomType;
    CommonSearchView* _searchView;
    BOOL _isRefreshing;
}

- (id)initWithRuleType:(DiceGameRuleType)ruleType;


@property (retain, nonatomic) IBOutlet FontButton *titleFontButton;
@property (retain, nonatomic) IBOutlet UIButton *helpButton;
@property (retain, nonatomic) IBOutlet FontButton *createRoomButton;
@property (retain, nonatomic) IBOutlet FontButton *fastEntryButton;
@property (retain, nonatomic) IBOutlet FontButton *allRoomButton;
@property (retain, nonatomic) IBOutlet FontButton *friendRoomButton;
@property (retain, nonatomic) IBOutlet FontButton *nearByRoomButton;
@property (retain, nonatomic) PBGameSession* currentSession;
@property (retain, nonatomic) IBOutlet HKGirlFontLabel *emptyListTips;


@end
