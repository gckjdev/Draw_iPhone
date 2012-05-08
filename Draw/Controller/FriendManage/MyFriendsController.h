//
//  MyFriendsController.h
//  Draw
//
//  Created by haodong qiu on 12年5月8日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "PPTableViewController.h"

@interface MyFriendsController : PPTableViewController

@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIButton *editButton;
@property (retain, nonatomic) IBOutlet UIButton *myFollowButton;
@property (retain, nonatomic) IBOutlet UIButton *myFanButton;

- (IBAction)clickBackButton:(id)sender;

@end
