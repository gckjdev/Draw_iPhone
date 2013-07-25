//
//  GetNewNumberViewController.m
//  Draw
//
//  Created by qqn_pipi on 13-7-24.
//
//

#import "GetNewNumberViewController.h"
#import "UserNumberService.h"
#import "LoginByNumberController.h"
#import "ShowNumberController.h"
#import "UserNumberService.h"
#import "GameNetworkConstants.h"
#import "UserManager.h"

#define SUBVIEW_FRAME CGRectMake(0, 307, 320, 480-307)

@interface GetNewNumberViewController ()

@end

@implementation GetNewNumberViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
        
    self.getNumberMainView.frame = SUBVIEW_FRAME;
    [self.view addSubview:self.getNumberMainView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_takeNumberButton release];
    [_loginButton release];
    [_loginController release];
    [_showNumberController release];
    
    [_showNumberTipsLabel release];
    [_numberLabel release];
    [_okButton release];
    [_completeUserInfoButton release];    
    
    [_inputNumberLabel release];
    [_inputPasswordLabel release];
    [_inputNumberTextField release];
    [_inputPasswordTextField release];
    [_forgotPasswordButton release];
    [_submitLoginButton release];
    
    [_getNumberMainView release];
    [_loginView release];
    [_takeNumberView release];
    [_getNumberTipsLabel release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setTakeNumberButton:nil];
    [self setLoginButton:nil];
    [self setLoginController:nil];
    [self setShowNumberController:nil];
    [self setInputNumberLabel:nil];
    [self setInputPasswordLabel:nil];
    [self setInputNumberTextField:nil];
    [self setInputPasswordTextField:nil];
    [self setForgotPasswordButton:nil];
    [self setSubmitLoginButton:nil];
    [self setShowNumberTipsLabel:nil];
    [self setNumberLabel:nil];
    [self setOkButton:nil];
    [self setCompleteUserInfoButton:nil];
    
    [self setGetNumberMainView:nil];
    [self setLoginView:nil];
    [self setTakeNumberView:nil];
    [self setGetNumberTipsLabel:nil];
    [super viewDidUnload];
}

- (void)showLoginView
{
    self.getNumberMainView.hidden = YES;

    self.loginView.frame = SUBVIEW_FRAME;
    [self.view addSubview:self.loginView];
}

- (void)showTakeNumberView
{
    self.getNumberMainView.hidden = YES;
    
    self.numberLabel.text = [[UserManager defaultManager] xiaojiNumber];
    self.takeNumberView.frame = SUBVIEW_FRAME;
    [self.view addSubview:self.takeNumberView];    
}


- (IBAction)clickLogin:(id)sender
{
    [self showLoginView];
}

- (IBAction)clickTakeNumber:(id)sender
{
    [self showActivityWithText:NSLS(@"kLoading")];
    [[UserNumberService defaultService] getAndRegisterNumber:^(int resultCode, NSString *number) {
        [self hideActivity];
        if (resultCode == 0){
            [self showTakeNumberView];
        }
        else{
            // TODO show error information
        }
    }];      
}

- (IBAction)clickForgot:(id)sender
{
    
}

- (IBAction)clickSubmitLogin:(id)sender
{
    if ([self.inputNumberTextField.text length] == 0){
        return;
    }
    
    if ([self.inputPasswordTextField.text length] == 0){
        return;
    }
    
    
    NSString* number = self.inputNumberTextField.text;
    NSString* password = self.inputPasswordTextField.text;
    
    [self showActivityWithText:NSLS(@"kLoading")];
    [[UserNumberService defaultService] loginUser:number password:password block:^(int resultCode, NSString *number) {
        [self hideActivity];
        if (resultCode == ERROR_SUCCESS){
            
        }
        else if (resultCode == ERROR_USERID_NOT_FOUND){
            
        }
        else if (resultCode == ERROR_PASSWORD_NOT_MATCH){
            
        }
        else{
        }
    }];
    
}


@end
