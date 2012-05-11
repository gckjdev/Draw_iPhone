//
//  MyFriendsController.h
//  Draw
//
//  Created by haodong qiu on 12年5月8日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "PPTableViewController.h"
#import "FriendService.h"

@interface MyFriendsController : PPTableViewController <FriendServiceDelegate>

@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIButton *editButton;
@property (retain, nonatomic) IBOutlet UIButton *myFollowButton;
@property (retain, nonatomic) IBOutlet UIButton *myFanButton;
@property (retain, nonatomic) IBOutlet UIButton *searchUserButton;
@property (retain, nonatomic) IBOutlet UILabel *tipsLabel;

@property (retain, nonatomic) NSArray *myFollowList;
@property (retain, nonatomic) NSArray *myFanList;

- (IBAction)clickBack:(id)sender;
- (IBAction)clickMyFollow:(id)sender;
- (IBAction)clickMyFan:(id)sender;
- (IBAction)clickEdit:(id)sender;
- (IBAction)clickSearchUser:(id)sender;

@end
