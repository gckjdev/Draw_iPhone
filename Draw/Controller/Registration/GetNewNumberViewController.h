//
//  GetNewNumberViewController.h
//  Draw
//
//  Created by qqn_pipi on 13-7-24.
//
//

#import <UIKit/UIKit.h>
#import "PPViewController.h"

@class LoginByNumberController;
@class ShowNumberController;

@interface GetNewNumberViewController : PPViewController

@property (retain, nonatomic) IBOutlet UIView *getNumberMainView;
@property (retain, nonatomic) IBOutlet UILabel *getNumberTipsLabel;

@property (retain, nonatomic) IBOutlet UIButton *takeNumberButton;
@property (retain, nonatomic) IBOutlet UIButton *loginButton;

@property (retain, nonatomic) LoginByNumberController *loginController;
@property (retain, nonatomic) ShowNumberController *showNumberController;

@property (retain, nonatomic) IBOutlet UIView *loginView;

@property (retain, nonatomic) IBOutlet UILabel *inputNumberLabel;
@property (retain, nonatomic) IBOutlet UILabel *inputPasswordLabel;
@property (retain, nonatomic) IBOutlet UITextField *inputNumberTextField;
@property (retain, nonatomic) IBOutlet UITextField *inputPasswordTextField;
@property (retain, nonatomic) IBOutlet UIButton *forgotPasswordButton;
@property (retain, nonatomic) IBOutlet UIButton *submitLoginButton;

@property (retain, nonatomic) IBOutlet UIView *takeNumberView;
@property (retain, nonatomic) IBOutlet UILabel *showNumberTipsLabel;
@property (retain, nonatomic) IBOutlet UILabel *numberLabel;
@property (retain, nonatomic) IBOutlet UIButton *okButton;
@property (retain, nonatomic) IBOutlet UIButton *completeUserInfoButton;


- (IBAction)clickForgot:(id)sender;
- (IBAction)clickSubmitLogin:(id)sender;

- (IBAction)clickLogin:(id)sender;
- (IBAction)clickTakeNumber:(id)sender;

@end
