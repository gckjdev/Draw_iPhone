//
//  SelectChatFriendController.h
//  Draw
//
//  Created by haodong qiu on 12年6月13日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "PPTableViewController.h"

@class Friend;
@protocol SelectChatFriendDelagate <NSObject>

@optional
- (void)didCancel;
- (void)didSelectFriend:(Friend *)aFriend;

@end

@interface SelectChatFriendController : PPTableViewController

@property (assign, nonatomic) id<SelectChatFriendDelagate> delegate;
@property (retain, nonatomic) IBOutlet UIButton *cancelButton;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;

@end
