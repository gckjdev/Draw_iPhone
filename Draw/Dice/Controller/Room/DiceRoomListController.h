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

@interface DiceRoomListController : PPTableViewController<CommonGameServiceDelegate> {
    BOOL _isJoiningDice;
}

@property (retain, nonatomic) IBOutlet UIButton *createRoomButton;
@property (retain, nonatomic) IBOutlet UIButton *fastEntryButton;
@end
