//
//  FriendController.h
//  Draw
//
//  Created by haodong qiu on 12年5月8日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

//Replace with the MyFriendsController
#import "CommonTabController.h"
#import "FriendService.h"
#import "FriendCell.h"
#import "RoomService.h"
#import "SearchUserController.h"

//call back by the caller of invite friends

@class FriendController;
@protocol FriendControllerDelegate <NSObject>

@optional
//set of MyFriend objects
- (void)friendController:(FriendController *)controller 
      didInviteFriendSet:(NSSet *)friendSet;
- (void)friendController:(FriendController *)controller 
      didSelectFriend:(MyFriend *)aFriend;
@end

typedef enum{
    FriendTabIndexFollow = 0,
    FriendTabIndexFan = 1
} FriendTabIndexType;



//@class Room;
@class MyFriend;
@interface FriendController : CommonTabController <FriendServiceDelegate,FollowDelegate,RoomServiceDelegate, UIActionSheetDelegate, SearchUserControllerDelegate>
{

}

@property (retain, nonatomic) IBOutlet UIButton *editButton;
@property (retain, nonatomic) IBOutlet UIButton *searchUserButton;
@property (retain, nonatomic) IBOutlet UIButton *inviteButton;
@property (retain, nonatomic) IBOutlet UIButton *newFanNumber;

- (void)setDefaultTabIndex:(FriendTabIndexType)tabIndex;

//invite a set of friends;
- (id)initWithInviteText:(NSString *)inviteText //a invite text send to friends via sms        
      invitedFriendIdSet:(NSSet *)fSet 
                capacity:(NSInteger)capacity
                delegate:(id<FriendControllerDelegate>)delegate;

//select a friend
- (id)initWithDelegate:(id<FriendControllerDelegate>)delegate;

- (IBAction)clickEdit:(id)sender;
- (IBAction)clickSearchUser:(id)sender;
- (IBAction)clickInviteButton:(id)sender;
@end
