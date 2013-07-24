//
//  LoginByNumberController.h
//  Draw
//
//  Created by qqn_pipi on 13-7-24.
//
//

#import <UIKit/UIKit.h>
#import "PPViewController.h"

@interface LoginByNumberController : PPViewController
@property (retain, nonatomic) IBOutlet UILabel *inputNumberLabel;
@property (retain, nonatomic) IBOutlet UILabel *inputPasswordLabel;
@property (retain, nonatomic) IBOutlet UITextField *inputNumberTextField;
@property (retain, nonatomic) IBOutlet UITextField *inputPasswordTextField;
@property (retain, nonatomic) IBOutlet UIButton *forgotPasswordButton;
@property (retain, nonatomic) IBOutlet UIButton *loginButton;

- (IBAction)clickForgot:(id)sender;
- (IBAction)clickLogin:(id)sender;

@end
