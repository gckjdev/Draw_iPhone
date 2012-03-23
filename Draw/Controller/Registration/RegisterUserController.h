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

@interface RegisterUserController : PPViewController<UserServiceDelegate>

+ (void)showAt:(UIViewController*)superViewController;


- (IBAction)clickSubmit:(id)sender;

@property (retain, nonatomic) IBOutlet UITextField *userIdTextField;

@end
