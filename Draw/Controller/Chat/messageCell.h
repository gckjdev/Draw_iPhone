//
//  MessageCell.h
//  Draw
//
//  Created by 小涛 王 on 12-5-8.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "PPTableViewCell.h"

@protocol MessageCellDelegate <NSObject>
@required
- (void)didSelectMessage:(NSString*)message;
@end

@interface MessageCell : PPTableViewCell

@property (nonatomic, assign) id<MessageCellDelegate> messageCellDelegate;

- (void)setCellData:(NSArray*)messageArray;
- (IBAction)clickMessage:(id)sender;

@end
