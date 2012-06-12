//
//  ChatDetailController.h
//  Draw
//
//  Created by haodong qiu on 12年6月7日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "PPTableViewController.h"
#import "ChatService.h"

@interface ChatDetailController : PPTableViewController<ChatServiceDelegate, UITextFieldDelegate>
 
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIButton *graffitiButton;
@property (retain, nonatomic) IBOutlet UIView *inputView;
@property (retain, nonatomic) IBOutlet UITextField *inputTextField;

@property (retain, nonatomic) IBOutlet UIButton *sendButton;

- (id)initWithFriendUserId:(NSString *)frindUserId;

@end
