//
//  CompleteUserInfoController.h
//  Draw
//
//  Created by  on 12-3-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPViewController.h"
#import "ChangeAvatar.h"

@interface CompleteUserInfoController : PPViewController<ChangeAvatarDelegate>

@property (retain, nonatomic) IBOutlet UILabel *avatarLabel;
@property (retain, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (retain, nonatomic) IBOutlet UIButton *avatarButton;
@property (retain, nonatomic) IBOutlet UITextField *nickNameTextField;
@property (retain, nonatomic) IBOutlet UIButton *submitButton;
@property (retain, nonatomic) IBOutlet UIButton *skipButton;

@property (retain, nonatomic) ChangeAvatar *changeAvatarMenu;

- (IBAction)clickSkip:(id)sender;
- (IBAction)clickSubmit:(id)sender;
- (IBAction)clickAvatar:(id)sender;

@end
