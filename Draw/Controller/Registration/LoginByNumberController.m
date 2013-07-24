//
//  LoginByNumberController.m
//  Draw
//
//  Created by qqn_pipi on 13-7-24.
//
//

#import "LoginByNumberController.h"
#import "UserNumberService.h"
#import "GameNetworkConstants.h"

@interface LoginByNumberController ()

@end

@implementation LoginByNumberController

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
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_inputNumberLabel release];
    [_inputPasswordLabel release];
    [_inputNumberTextField release];
    [_inputPasswordTextField release];
    [_forgotPasswordButton release];
    [_loginButton release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setInputNumberLabel:nil];
    [self setInputPasswordLabel:nil];
    [self setInputNumberTextField:nil];
    [self setInputPasswordTextField:nil];
    [self setForgotPasswordButton:nil];
    [self setLoginButton:nil];
    [super viewDidUnload];
}

- (IBAction)clickForgot:(id)sender
{
    
}

- (IBAction)clickLogin:(id)sender
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
