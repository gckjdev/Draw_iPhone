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
@class AvatarView;

@interface RoomCell : PPTableViewCell

@property (retain, nonatomic) AvatarView *avatarImage;
@property (retain, nonatomic) IBOutlet UILabel *roomNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *roomStatusLabel;
@property (retain, nonatomic) IBOutlet UILabel *creatorLabel;
@property (retain, nonatomic) IBOutlet UILabel *userListLabel;
@property (retain, nonatomic) IBOutlet UIButton *inviteInfoButton;
@property (retain, nonatomic) IBOutlet UIButton *inviteButton;
- (IBAction)clickInviteButton:(id)sender;

- (void)setInfo:(Room *)room;
@end
