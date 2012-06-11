//
//  ChatCell.h
//  Draw
//
//  Created by haodong qiu on 12年6月7日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "PPTableViewCell.h"
#import "HJManagedImageV.h"

@interface ChatCell : PPTableViewCell

@property (retain, nonatomic) IBOutlet HJManagedImageV *avatarImage;
@property (retain, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (retain, nonatomic) IBOutlet UIImageView *graffiti;
@property (retain, nonatomic) IBOutlet UILabel *messageNumberLabel;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel;

@end
