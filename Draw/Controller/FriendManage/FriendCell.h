//
//  FriendCell.h
//  Draw
//
//  Created by haodong qiu on 12年5月14日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "PPTableViewCell.h"



@protocol FollowDelegate <NSObject>
@optional
- (void)didClickFollowButtonAtIndexPath:(NSIndexPath *)indexPath 
                               user:(NSDictionary *)user;
@end

@class HJManagedImageV;
@class Friend;

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


- (void)setCellByDictionary:(NSDictionary *)aUser indexPath:(NSIndexPath *)aIndexPath;
- (void)setCellByFriend:(Friend *)aFriend indexPath:(NSIndexPath *)aIndexPath;

- (IBAction)clickFollowButton:(id)sender;

@end
