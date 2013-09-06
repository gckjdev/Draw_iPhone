//
//  GetNewNumberViewController.m
//  Draw
//
//  Created by qqn_pipi on 13-7-24.
//
//

#import "GetNewNumberViewController.h"
#import "UserNumberService.h"
#import "UserNumberService.h"
#import "GameNetworkConstants.h"
#import "UserManager.h"
#import "UserService.h"
#import "StringUtil.h"

#define SUBVIEW_FRAME CGRectMake(0, 205, 320, 480-205)



#define SET_BUTTON_ROUND_STYLE_LOGIN_BUTTON(view)                              \
{                                                           \
    [ShareImageManager setButtonStyle:view normalTitleColor:COLOR_BROWN selectedTitleColor:COLOR_WHITE highlightedTitleColor:COLOR_WHITE font:LOGIN_FONT_BUTTON normalColor:COLOR_YELLOW selectedColor:COLOR_YELLOW highlightedColor:COLOR_YELLOW round:YES];         \
    [view.layer setCornerRadius:(ISIPAD ? 40 : 21)];  \
[view.layer setMasksToBounds:YES];    \
}

#define SET_BUTTON_ROUND_STYLE_SMALL_LOGIN_BUTTON(view)                              \
{                                                           \
    [ShareImageManager setButtonStyle:view normalTitleColor:COLOR_BROWN selectedTitleColor:COLOR_WHITE highlightedTitleColor:COLOR_WHITE font:FONT_BUTTON normalColor:COLOR_YELLOW selectedColor:COLOR_YELLOW highlightedColor:COLOR_YELLOW round:YES];         \
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
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.bottomView.backgroundColor = OPAQUE_COLOR(139, 234, 204);
//    self.bottomView.frame = SUBVIEW_FRAME;

        
//    self.getNumberMainView.frame = SUBVIEW_FRAME;
    self.getNumberMainView.center = self.bottomView.center;
    SET_BUTTON_ROUND_STYLE_LOGIN_BUTTON(self.takeNumberButton);
    SET_BUTTON_ROUND_STYLE_LOGIN_BUTTON(self.loginButton);
    self.getNumberTipsLabel.textColor = OPAQUE_COLOR(52, 136, 112);
    
    self.getNumberTipsLabel.text = NSLS(@"kGetNumberTipsLabelText");
    [self.takeNumberButton setTitle:NSLS(@"kTakeNumberButtonTitle") forState:UIControlStateNormal];
    [self.loginButton setTitle:NSLS(@"kLoginButtonTitle") forState:UIControlStateNormal];
    
    [self.view addSubview:self.getNumberMainView];
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
    PPRelease(_xiaojiNumber);
    PPRelease(_password);
    
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
    
    [self showLoginDialog];
    
//    self.getNumberMainView.hidden = YES;
//
//    SET_INPUT_VIEW_STYLE(self.inputNumberTextField);
//    SET_INPUT_VIEW_STYLE(self.inputPasswordTextField);
//    
//    self.inputNumberTextField.backgroundColor = [UIColor whiteColor];
//    self.inputPasswordTextField.backgroundColor = [UIColor whiteColor];
//    
//    SET_BUTTON_ROUND_STYLE_SMALL_LOGIN_BUTTON(self.submitLoginButton);
//    SET_BUTTON_ROUND_STYLE_SMALL_LOGIN_BUTTON(self.forgotPasswordButton);
//
//    self.loginView.frame = self.view.frame;
//    self.loginView.backgroundColor = OPAQUE_COLOR(139, 234, 204);
//    [self.view addSubview:self.loginView];
//    
//    [self.inputNumberTextField becomeFirstResponder];
    
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
    
    self.showNumberTipsLabel.text = NSLS(@"kShowNumberTipsLabelText");
    [self.okButton setTitle:NSLS(@"kOkButtonTitle") forState:UIControlStateNormal];
    
    self.showNumberTipsLabel.textColor = OPAQUE_COLOR(52, 136, 112);    
    self.numberLabel.textColor = COLOR_BROWN;

    SET_BUTTON_ROUND_STYLE_LOGIN_BUTTON(self.okButton);
    
    
    
    
    NSString* text = [self textFromNumber:[[UserManager defaultManager] xiaojiNumber]];
    
    self.numberLabel.text = text;
//    self.takeNumberView.frame = SUBVIEW_FRAME;
    self.takeNumberView.center = self.bottomView.center;
    [self.view addSubview:self.takeNumberView];
    
    self.takeNumberView.alpha = 0.0f;
    [UIView animateWithDuration:1.5 animations:^{
        self.takeNumberView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        self.takeNumberView.alpha = 1.0f;
    }];
}


- (IBAction)clickLogin:(id)sender
{
    [self showLoginView];
}

- (IBAction)clickTakeNumber:(id)sender
{
    if ([[UserManager defaultManager] incAndCheckIsExceedMaxTakeNumber] == YES){
        POSTMSG(@"kExceedMaxTakeNumber");
        return;
    }
    
    [self showActivityWithText:NSLS(@"kLoading")];
    [[UserNumberService defaultService] getAndRegisterNumber:^(int resultCode, NSString *number) {
        [self hideActivity];
        if (resultCode == 0){
            [self showTakeNumberView];
        }
        else{
            [CommonDialog showSimpleDialog:NSLS(@"kTakeNumberFail")  inView:self.view];
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
    
    [self processLogin:number password:password];
    
}

- (void)processLogin:(NSString*)number password:(NSString*)password
{
    self.xiaojiNumber = number;
    self.password = password;
    
    if ([number length] == 0){
        POSTMSG(NSLS(@"kXiaojiNumberCannotEmpty"));
        return;
    }
    
    if ([password length] == 0){
        POSTMSG(NSLS(@"kXiaojiPasswordCannotEmpty"));
        return;
    }
    
    [self showActivityWithText:NSLS(@"kLoading")];
    [[UserNumberService defaultService] loginUser:number password:password block:^(int resultCode, NSString *number) {
        [self hideActivity];
        if (resultCode == ERROR_SUCCESS){
            [self dismiss:nil];
        }
        else if (resultCode == ERROR_USERID_NOT_FOUND){
            POSTMSG(NSLS(@"kXiaojiNumberNotFound"));
        }
        else if (resultCode == ERROR_PASSWORD_NOT_MATCH){
            POSTMSG(NSLS(@"kXiaojiPasswordIncorrect"));
        }
        else{
            POSTMSG(NSLS(@"kSystemFailure"));
        }
    }];
}

#define LOGIN_DIALOG_TAG    2013090401

- (void)showLoginDialog
{
    RoomPasswordDialog *rpDialog = [RoomPasswordDialog create];
    rpDialog.delegate = self;
    
    rpDialog.roomNameField.placeholder = NSLS(@"kLoginXiaojiPlaceHolder");
    rpDialog.passwordField.placeholder = NSLS(@"kLoginPasswordPlaceHolder");
    
    rpDialog.roomNameField.text = self.xiaojiNumber;
    rpDialog.passwordField.text = self.password;
    
    rpDialog.passwordField.secureTextEntry = YES;
//    rpDialog.roomNameLabel.text = NSLS(@"kLoginXiaojiLabel");
//    rpDialog.passwordLabel.text = NSLS(@"kLoginPasswordLabel");
    rpDialog.roomNameField.keyboardType = UIKeyboardTypeNumberPad;
    [rpDialog.roomNameField becomeFirstResponder];
    
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kLoginXiaoji") customView:rpDialog style:CommonDialogStyleDoubleButtonWithCross];
    dialog.delegate = self;
    dialog.tag = LOGIN_DIALOG_TAG;
    [dialog showInView:self.view];
}

- (void)didClickOk:(CommonDialog *)dialog
          infoView:(id)infoView
{
    if (dialog.tag == LOGIN_DIALOG_TAG) {        
        RoomPasswordDialog *v = (RoomPasswordDialog *)infoView;
        [self processLogin:v.roomNameField.text password:v.passwordField.text];
    }
    }

- (void)didClickCancel:(CommonDialog *)dialog
{
    
}

- (void)roomNameIsIllegal
{
    
}

- (IBAction)dismiss:(id)sender
{
    [CommonDialog showSimpleDialog:NSLS(@"kTakeNumberSuccess")  inView:self.view.superview];
    [[UserService defaultService] dismissGetNumberView];
}

@end
