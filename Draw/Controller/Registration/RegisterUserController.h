//
//  RegisterUserController.h
//  Draw
//
//  Created by  on 12-3-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserService.h"
#import "PPViewController.h"
#import "PassWordDialog.h"

@interface RegisterUserController : PPViewController<UserServiceDelegate, UITextFieldDelegate, InputDialogDelegate>
{
    int _currentLoginType;
}
@property (retain, nonatomic) IBOutlet UIImageView *backgroundImageView;

+ (void)showAt:(UIViewController*)superViewController;


- (IBAction)clickSubmit:(id)sender;
- (IBAction)clickSinaLogin:(id)sender;
- (IBAction)clickQQLogin:(id)sender;
- (IBAction)clickFacebookLogin:(id)sender;
- (IBAction)textFieldDone:(id)sender;

@property (retain, nonatomic) IBOutlet UITextField *userIdTextField;
@property (retain, nonatomic) IBOutlet UIButton *submitButton;
@property (retain, nonatomic) IBOutlet UILabel *promptLabel;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIButton *facebookButton;
@property (retain, nonatomic) IBOutlet UIButton *sinaButton;
@property (retain, nonatomic) IBOutlet UIButton *qqButton;
@property (retain, nonatomic) IBOutlet UILabel *inviteLabel;
@property (retain, nonatomic) IBOutlet UITextField *passwordTextField;
@property (retain, nonatomic) IBOutlet UITextField *passwordAgainTextField;

@property (retain, nonatomic) NSArray *remoteDrawArray;


- (IBAction)backgroundTap:(id)sender;

@end
