//
//  FriendCell.h
//  Draw
//
//  Created by haodong qiu on 12年5月14日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "PPTableViewCell.h"

typedef enum{
    FromFriendList = 1,
    FromInviteList = 2
}FromType;

@protocol FollowDelegate <NSObject>
@optional
- (void)didClickFollowButtonAtIndexPath:(NSIndexPath *)indexPath 
                               user:(NSDictionary *)user;
//- (void)didInviteFriendAtIndexPath:(NSIndexPath *)indexPath;

@end

@class HJManagedImageV;
@class Friend;
@class Room;
@interface FriendCell : PPTableViewCell
@property (retain, nonatomic) IBOutlet HJManagedImageV *avatarView;
@property (retain, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *genderLabel;
@property (retain, nonatomic) IBOutlet UILabel *areaLabel;
@property (retain, nonatomic) IBOutlet UIImageView *authImageView;
@property (retain, nonatomic) IBOutlet UILabel *statusLabel;
@property (retain, nonatomic) IBOutlet UIButton *followButton;

@property (retain, nonatomic) NSDictionary *user;
@property (assign, nonatomic) id<FollowDelegate> followDelegate;
//@property (assign, nonatomic) id<FollowDelegate> inviteDelegate;


- (void)setCellByDictionary:(NSDictionary *)aUser indexPath:(NSIndexPath *)aIndexPath;
- (void)setCellByFriend:(Friend *)aFriend indexPath:(NSIndexPath *)aIndexPath;
- (void)setCellWithFriend:(Friend *)aFriend indexPath:(NSIndexPath *)aIndexPath fromType:(FromType)type;

- (IBAction)clickFollowButton:(id)sender;



@end
