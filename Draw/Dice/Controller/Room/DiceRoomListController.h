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
@class FontButton;
@class PBGameSession;

@interface DiceRoomListController : PPTableViewController<CommonGameServiceDelegate, InputDialogDelegate> {
    BOOL _isJoiningDice;
    DiceGameService* _diceGameService;
    PBGameSession* _currentSession;
    NSTimer* _refreshRoomTimer;
    BOOL firstLoad;
}
@property (retain, nonatomic) IBOutlet FontButton *titleFontButton;

@property (retain, nonatomic) IBOutlet UIButton *createRoomButton;
@property (retain, nonatomic) IBOutlet UIButton *fastEntryButton;
@property (retain, nonatomic) IBOutlet FontButton *allRoomButton;
@property (retain, nonatomic) IBOutlet FontButton *friendRoomButton;
@property (retain, nonatomic) IBOutlet FontButton *nearByRoomButton;

@property (retain, nonatomic) PBGameSession* currentSession;
@end
