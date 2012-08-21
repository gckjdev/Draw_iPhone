//
//  ChatViewCell.h
//  Draw
//
//  Created by 小涛 王 on 12-8-21.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPTableViewCell.h"

@protocol ChatViewCellDelegate <NSObject>

@optional
- (void)didClickMessage:(NSString *)message;

@end

@interface ChatViewCell : PPTableViewCell

@property (assign, nonatomic) id<ChatViewCellDelegate> delegate;
@property (retain, nonatomic) IBOutlet UIButton *messageButton;

- (void)setCellData:(NSString *)message;

@end
