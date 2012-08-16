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
@class PBGameSession;

@interface DiceRoomListCell : PPTableViewCell <DiceAvatarViewDelegate>

@property (retain, nonatomic) IBOutlet UILabel *roomNameLabel;
- (void)setCellInfo:(PBGameSession *)session;
@property (retain, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end
