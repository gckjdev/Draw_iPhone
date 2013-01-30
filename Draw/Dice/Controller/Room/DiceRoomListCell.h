//
//  RoomListCell.h
//  Draw
//
//  Created by 小涛 王 on 12-7-27.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPTableViewCell.h"
#import "DiceAvatarView.h"
#import "GameConstants.pb.h"
#import "CommonRoomListCell.h"

@class PBGameSession;

@interface DiceRoomListCell : CommonRoomListCell <DiceAvatarViewDelegate> {
    
}

@property (retain, nonatomic) IBOutlet UILabel *roomNameLabel;
- (void)setCellInfo:(PBGameSession *)session ruleType:(DiceGameRuleType)ruleType;


@end
