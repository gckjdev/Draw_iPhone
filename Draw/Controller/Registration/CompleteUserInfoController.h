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
#import "UserService.h"

@interface CompleteUserInfoController : PPViewController<ChangeAvatarDelegate, UserServiceDelegate>
{
    BOOL _isFemale;
}

@property (retain, nonatomic) IBOutlet UILabel *avatarLabel;
@property (retain, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (retain, nonatomic) IBOutlet UIButton *maleAvatarButton;
@property (retain, nonatomic) IBOutlet UITextField *nickNameTextField;
@property (retain, nonatomic) IBOutlet UIButton *submitButton;
@property (retain, nonatomic) IBOutlet UIButton *skipButton;

@property (retain, nonatomic) ChangeAvatar *changeAvatarMenu;
@property (retain, nonatomic) UIImage *avatarImage;
@property (retain, nonatomic) IBOutlet UIButton *femaleAvatarButton;

- (IBAction)clickSkip:(id)sender;
- (IBAction)clickSubmit:(id)sender;
- (IBAction)clickMaleAvatar:(id)sender;
- (IBAction)clickFemaleAvatar:(id)sender;
@property (retain, nonatomic) IBOutlet UIImageView *maleSelectImageView;
@property (retain, nonatomic) IBOutlet UIImageView *femaleSelectImageView;

@end
