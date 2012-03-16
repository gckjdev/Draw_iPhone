//
//  RegisterUserController.h
//  Draw
//
//  Created by  on 12-3-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterUserController : UIViewController

+ (void)showAt:(UIViewController*)superViewController;


- (IBAction)clickSubmit:(id)sender;

@property (retain, nonatomic) IBOutlet UITextField *userIdTextField;

@end
