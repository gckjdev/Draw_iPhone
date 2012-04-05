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
#import "SNSServiceDelegate.h"
#import "SNSConstants.h"

@interface RegisterUserController : PPViewController<UserServiceDelegate, SNSServiceDelegate, UITextFieldDelegate>
{
    int _currentLoginType;
}

+ (void)showAt:(UIViewController*)superViewController;


- (IBAction)clickSubmit:(id)sender;
- (IBAction)clickSinaLogin:(id)sender;
- (IBAction)clickQQLogin:(id)sender;
- (IBAction)textFieldDone:(id)sender;

@property (retain, nonatomic) IBOutlet UITextField *userIdTextField;
@property (retain, nonatomic) IBOutlet UIButton *submitButton;
@property (retain, nonatomic) IBOutlet UILabel *promptLabel;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;

@end
