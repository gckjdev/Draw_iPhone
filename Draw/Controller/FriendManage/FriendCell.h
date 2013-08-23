//
//  FriendCell.h
//  Draw
//
//  Created by haodong qiu on 12年5月14日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "PPTableViewCell.h"
#import "StableView.h"
typedef enum{
    FromFriendList = 1,
    FromInviteList = 2,
    FromSearchUserList = 3
}FromType;


@class Friend;
@class MyFriend;
@class Room;

@protocol FollowDelegate <NSObject>
@optional
- (void)didClickFollowButtonAtIndexPath:(NSIndexPath *)indexPath 
                               user:(NSDictionary *)user;
//for new friend controller.
- (void)didClickFollowButtonWithFriend:(MyFriend *)myFriend;

@end

@interface FriendCell : PPTableViewCell
{
    MyFriend *_myFriend;
}

@property (retain, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *genderLabel;
@property (retain, nonatomic) IBOutlet UILabel *areaLabel;
@property (retain, nonatomic) IBOutlet UILabel *statusLabel;
@property (retain, nonatomic) IBOutlet UILabel* levelLabel;
@property (retain, nonatomic) IBOutlet AvatarView *avatarView;

@property (assign, nonatomic) id<FollowDelegate> followDelegate;
@property (retain, nonatomic) MyFriend *myFriend;


- (void)setCellWithMyFriend:(MyFriend *)aFriend
                  indexPath:(NSIndexPath *)aIndexPath 
                 statusText:(NSString *)statusText;


@end
