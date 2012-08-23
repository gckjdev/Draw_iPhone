//
//  ChatViewCell.h
//  Draw
//
//  Created by 小涛 王 on 12-8-21.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPTableViewCell.h"
#import "FontButton.h"
#import "DiceChatMessage.h"

@protocol ChatViewCellDelegate <NSObject>

@optional
- (void)didClickMessage:(DiceChatMessage *)message;

@end

@interface ChatViewCell : PPTableViewCell

@property (assign, nonatomic) id<ChatViewCellDelegate> delegate;
@property (retain, nonatomic) IBOutlet FontButton *messageButton;

- (void)setCellData:(DiceChatMessage *)message;

@end
