//
//  RoomCell.h
//  Draw
//
//  Created by  on 12-5-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPTableViewCell.h"
#import "Room.h"

@class HJManagedImageV;
@interface RoomCell : PPTableViewCell

@property (retain, nonatomic) IBOutlet HJManagedImageV *avatarImage;
@property (retain, nonatomic) IBOutlet UILabel *roomNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *roomStatusLabel;

- (void)setInfo:(Room *)room;
@end
