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

@interface RegisterUserController : PPViewController<UserServiceDelegate, SNSServiceDelegate>

+ (void)showAt:(UIViewController*)superViewController;


- (IBAction)clickSubmit:(id)sender;
- (IBAction)clickSinaLogin:(id)sender;
- (IBAction)clickQQLogin:(id)sender;

@property (retain, nonatomic) IBOutlet UITextField *userIdTextField;

@end
