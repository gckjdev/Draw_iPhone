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

typedef enum
{
    RoomCellTypeMyRoom = 1,
    RoomCellTypeSearchRoom = 2
    
}RoomCellType ;


@protocol RoomCellDelegate <NSObject>

@optional
- (void)didClickInvite:(NSIndexPath *)indexPath;
- (void)didClickAvatar:(NSIndexPath *)indexPath;

@end

//@class HJManagedImageV;
@class AvatarView;

@interface RoomCell : PPTableViewCell
{
    RoomCellType _roomCellType;
}
@property (retain, nonatomic) IBOutlet UIImageView *avatarView;
@property (retain, nonatomic) IBOutlet UILabel *roomNameLabel;

@property (retain, nonatomic) IBOutlet UILabel *creatorLabel;
@property (retain, nonatomic) IBOutlet UILabel *userListLabel;
@property (retain, nonatomic) IBOutlet UIButton *inviteInfoButton;
@property (retain, nonatomic) IBOutlet UIButton *inviteButton;
@property (assign, nonatomic) RoomCellType roomCellType;
@property (assign, nonatomic) id<RoomCellDelegate> roomCellDelegate;

- (IBAction)clickInviteButton:(id)sender;
- (IBAction)clickAvatar:(id)sender;

- (void)setInfo:(Room *)room;
@end
