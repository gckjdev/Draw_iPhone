//
//  ChatCell.h
//  Draw
//
//  Created by haodong qiu on 12年6月7日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "PPTableViewCell.h"
#import "HJManagedImageV.h"

@class MessageTotal;
@interface ChatCell : PPTableViewCell

@property (retain, nonatomic) IBOutlet HJManagedImageV *avatarImage;
@property (retain, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (retain, nonatomic) IBOutlet UIImageView *graffiti;
@property (retain, nonatomic) IBOutlet UILabel *textLabel;

@property (retain, nonatomic) IBOutlet UILabel *messageNumberLabel;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel;

+ (id)createCell:(id)delegate;
+ (NSString*)getCellIdentifier;
+ (CGFloat)getCellHeight;
- (void)setCellByMessageTotal:(MessageTotal *)messageTotal indexPath:(NSIndexPath *)aIndexPath;

@end
