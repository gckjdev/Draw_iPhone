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

@class PBGameSession;
@class CommonSearchView;

@interface DiceRoomListController : CommonRoomListController</*CommonGameServiceDelegate, */ HelpViewDelegate, CommonRoomListCellDelegate> {
    DiceGameService* _diceGameService;
}

- (id)initWithRuleType:(DiceGameRuleType)ruleType;


@end
