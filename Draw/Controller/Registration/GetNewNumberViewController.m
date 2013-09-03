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

#define SUBVIEW_FRAME CGRectMake(0, 205, 320, 480-205)



#define SET_BUTTON_ROUND_STYLE_LOGIN_BUTTON(view)                              \
{                                                           \
[[ShareImageManager defaultManager] setButtonStyle:view normalTitleColor:COLOR_BROWN selectedTitleColor:COLOR_WHITE highlightedTitleColor:COLOR_WHITE font:LOGIN_FONT_BUTTON normalColor:COLOR_YELLOW2 selectedColor:COLOR_YELLOW highlightedColor:COLOR_YELLOW round:YES];         \
[view.layer setCornerRadius:(ISIPAD ? 40 : 21)];  \
[view.layer setMasksToBounds:YES];    \
}

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
    SET_BUTTON_ROUND_STYLE_LOGIN_BUTTON(self.takeNumberButton);
    SET_BUTTON_ROUND_STYLE_LOGIN_BUTTON(self.loginButton);
    self.getNumberTipsLabel.textColor = COLOR_GREEN3;
    
    [self.view addSubview:self.getNumberMainView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.bottomView.backgroundColor = COLOR_GREEN2;
    self.bottomView.frame = SUBVIEW_FRAME;
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
    [_bottomView release];
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
    [self setBottomView:nil];
    [super viewDidUnload];
}

- (void)showLoginView
{
    self.getNumberMainView.hidden = YES;

    self.loginView.frame = SUBVIEW_FRAME;
    [self.view addSubview:self.loginView];
}

- (NSString*)textFromNumber:(NSString*)number
{
    int minLen = 3;
    if ([number length] < minLen){
        return number;
    }
    
    NSString* first3 = [number substringToIndex:minLen];
    NSString* left = [number substringFromIndex:minLen];
    
    return [NSString stringWithFormat:@"%@ %@", first3, left];
}

- (void)showTakeNumberView
{
    self.getNumberMainView.hidden = YES;
    
    self.showNumberTipsLabel.textColor = COLOR_GREEN3;
    self.numberLabel.textColor = COLOR_BROWN;
    SET_BUTTON_ROUND_STYLE_LOGIN_BUTTON(self.okButton);
    
    
    NSString* text = [self textFromNumber:[[UserManager defaultManager] xiaojiNumber]];
    
    self.numberLabel.text = text;
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
