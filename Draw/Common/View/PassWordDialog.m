//
//  PassWordDialog.m
//  Draw
//
//  Created by  on 12-4-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PassWordDialog.h"
#import "LocaleUtils.h"
#import "ShareImageManager.h"
#import "AnimationManager.h"
#import "UserManager.h"
#import "StringUtil.h"
#import "DiceImageManager.h"
#import "ZJHImageManager.h"
#import "CustomUITextField.h"
#import "AutoCreateViewByXib.h"

#define GAP (ISIPAD ? 26 : 12)

@implementation PassWordDialog

AUTO_CREATE_VIEW_BY_XIB(PassWordDialog);

- (void)dealloc {
    
    [_oldPasswordTextField release];
    [_passwordTextField release];
    [_anotherPasswordTextField release];
    [super dealloc];
}


//- (void)initWithTitle:(NSString*)title
//{
//    ShareImageManager *imageManager = [ShareImageManager defaultManager];
//    DiceImageManager* diceImgManager = [DiceImageManager defaultManager];
//    float fontSize = [DeviceDetection isIPAD] ? 40 : 20;
//    switch (theme) {
//        case CommonInputDialogThemeDice:{ 
//            [self.targetTextField setBackground:[diceImgManager inputBackgroundImage]];
//            [self.titleLabel.titleLabel setText:title];
//            
//            [self.cancelButton setBackgroundImage:[diceImgManager fastGameBtnBgImage] 
//                                         forState:UIControlStateNormal];
//            [self.okButton setBackgroundImage:[diceImgManager diceQuitBtnImage] 
//                                     forState:UIControlStateNormal];
//            
//            [self.cancelButton.titleLabel setText:NSLS(@"kCancel")];
//            [self.okButton.titleLabel setText:NSLS(@"kOK")];
//            self.titleLabel.titleLabel.font = [UIFont boldSystemFontOfSize:fontSize];
//            self.titleLabel.titleLabel.adjustsFontSizeToFitWidth = YES;
//            self.titleLabel.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
//            
//            [self.targetTextField setBackground:[diceImgManager inputBackgroundImage]];
//            [self.anotherPasswordTextField setBackground:[diceImgManager inputBackgroundImage]];
//            [self.oldPasswordTextField setBackground:[diceImgManager inputBackgroundImage]];
//            
//        } break;
//        case CommonInputDialogThemeZJH: {
//            [self.targetTextField setBackground:[diceImgManager inputBackgroundImage]];
//            [self.titleLabel.titleLabel setText:title];
//            
//            [self.cancelButton setBackgroundImage:[diceImgManager fastGameBtnBgImage]
//                                         forState:UIControlStateNormal];
//            [self.okButton setBackgroundImage:[diceImgManager diceQuitBtnImage]
//                                     forState:UIControlStateNormal];
//            
//            [self.cancelButton.titleLabel setText:NSLS(@"kCancel")];
//            [self.okButton.titleLabel setText:NSLS(@"kOK")];
//            self.titleLabel.titleLabel.font = [UIFont boldSystemFontOfSize:fontSize];
//            self.titleLabel.titleLabel.adjustsFontSizeToFitWidth = YES;
//            self.titleLabel.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
//            
//            [self.targetTextField setBackground:[diceImgManager inputBackgroundImage]];
//            [self.anotherPasswordTextField setBackground:[diceImgManager inputBackgroundImage]];
//            [self.oldPasswordTextField setBackground:[diceImgManager inputBackgroundImage]];
//            [self.bgView setImage:[ZJHImageManager defaultManager].ZJHUserInfoBackgroundImage];
//            
//        }break;
//            
//        case CommonInputDialogThemeDraw: 
//        default: {
//            [self.targetTextField setBackground:[imageManager inputImage]];
//            [self setDialogTitle:title];
//            [self.cancelButton setBackgroundImage:[imageManager greenImage] forState:UIControlStateNormal];
//            [self.cancelButton setTitle:NSLS(@"kCancel") forState:UIControlStateNormal];
//            [self.okButton setTitle:NSLS(@"kOK") forState:UIControlStateNormal];
//            [self.okButton setBackgroundImage:[imageManager redImage] forState:UIControlStateNormal];
//            self.titleLabel.titleLabel.font = [UIFont boldSystemFontOfSize:fontSize];
//            self.titleLabel.titleLabel.adjustsFontSizeToFitWidth = YES;
//            self.titleLabel.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
//            
//            [self.targetTextField setBackground:[imageManager inputImage]];
//            [self.anotherPasswordTextField setBackground:[imageManager inputImage]];
//            [self.oldPasswordTextField setBackground:[imageManager inputImage]];
//        }break;
//            
//            
//    }
//    [self.targetTextField setPlaceholder:NSLS(@"kNicknameHolder")];
//    
//    [self.oldPasswordTextField setPlaceholder:NSLS(@"kOldPasswordHolder")];
//    [self.anotherPasswordTextField setPlaceholder:NSLS(@"kNewPasswordHolder")];
//    [self.passwordTextField setPlaceholder:NSLS(@"kConfirmPasswordHolder")];
//
//    
//}

//- (void)initView:(NSString*)title
//{
//    [super initView:title];
//    float fontSize = [DeviceDetection isIPAD] ? 40 : 20;
//    [self.targetTextField setBackground:[[GameApp getImageManager] inputDialogInputBgImage]];
//    [self.titleLabel setTitle:title forState:UIControlStateNormal];
//    
//    [self.cancelButton setBackgroundImage:[[GameApp getImageManager] inputDialogLeftBtnImage]
//                                 forState:UIControlStateNormal];
//    [self.okButton setBackgroundImage:[[GameApp getImageManager] inputDialogRightBtnImage]
//                             forState:UIControlStateNormal];
//    
//    [self.cancelButton setTitle:NSLS(@"kCancel") forState:UIControlStateNormal];
//    [self.okButton setTitle:NSLS(@"kOK") forState:UIControlStateNormal];
//    self.titleLabel.titleLabel.font = [UIFont boldSystemFontOfSize:fontSize];
//    self.titleLabel.titleLabel.adjustsFontSizeToFitWidth = YES;
//    self.titleLabel.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
//    
//    [self.targetTextField setBackground:[[GameApp getImageManager] inputDialogInputBgImage]];
//    [self.anotherPasswordTextField setBackground:[[GameApp getImageManager] inputDialogInputBgImage]];
//    [self.oldPasswordTextField setBackground:[[GameApp getImageManager] inputDialogInputBgImage]];
    
//    [self.targetTextField setPlaceholder:NSLS(@"kNicknameHolder")];
//    
//    [self.oldPasswordTextField setPlaceholder:NSLS(@"kOldPasswordHolder")];
//    [self.anotherPasswordTextField setPlaceholder:NSLS(@"kNewPasswordHolder")];
//    [self.passwordTextField setPlaceholder:NSLS(@"kConfirmPasswordHolder")];
//
//}

//- (void)updateTextFields
//{
//    ShareImageManager *imageManager = [ShareImageManager defaultManager];
//    [self.targetTextField setBackground:[imageManager inputImage]];
//    [self.anotherPasswordTextField setBackground:[imageManager inputImage]];
//    [self.oldPasswordTextField setBackground:[imageManager inputImage]];
//    
//    [self.oldPasswordTextField setPlaceholder:NSLS(@"kOldPasswordHolder")];
//    [self.anotherPasswordTextField setPlaceholder:NSLS(@"kNewPasswordHolder")];
//    [self.passwordTextField setPlaceholder:NSLS(@"kConfirmPasswordHolder")];
//}


+ (PassWordDialog *)create
{
    PassWordDialog *view = (PassWordDialog *)[self createView];
    
    [view.oldPasswordTextField setPlaceholder:NSLS(@"kOldPasswordHolder")];
    [view.passwordTextField setPlaceholder:NSLS(@"kNewPasswordHolder")];
    [view.anotherPasswordTextField setPlaceholder:NSLS(@"kConfirmPasswordHolder")];
    
    SET_VIEW_ROUND_CORNER(view.oldPasswordTextField);
    view.oldPasswordTextField.layer.borderWidth = TEXT_VIEW_BORDER_WIDTH;
    view.oldPasswordTextField.layer.borderColor = [COLOR_YELLOW CGColor];
    
    SET_VIEW_ROUND_CORNER(view.passwordTextField);
    view.passwordTextField.layer.borderWidth = TEXT_VIEW_BORDER_WIDTH;
    view.passwordTextField.layer.borderColor = [COLOR_YELLOW CGColor];
    
    SET_VIEW_ROUND_CORNER(view.anotherPasswordTextField);
    view.anotherPasswordTextField.layer.borderWidth = TEXT_VIEW_BORDER_WIDTH;
    view.anotherPasswordTextField.layer.borderColor = [COLOR_YELLOW CGColor];

    UserManager *userManager = [UserManager defaultManager];
    if ([userManager isPasswordEmpty]) {
        [view hideOldPasswordTextField];
    }else{
        [view.oldPasswordTextField becomeFirstResponder];
    }
    
    return view;
}

//+ (PassWordDialog *)createDialogWithTheme:(CommonInputDialogTheme)theme
//{
//    PassWordDialog* view;
//    switch (theme) {
//        case CommonInputDialogThemeDice: {
//            view = (PassWordDialog*)[self createInfoViewByXibName:DICE_PASSWORD_DIALOG]; 
//        } break;
//        case CommonInputDialogThemeDraw: {
//            view = (PassWordDialog*)[self createInfoViewByXibName:PASSWORD_DIALOG];
//        } break;
//        case CommonInputDialogThemeZJH: {
//            view = (PassWordDialog*)[self createInfoViewByXibName:DICE_PASSWORD_DIALOG];
//        } break;
//        default:
//            PPDebug(@"<PassWordDialog> theme %d do not exist",theme);
//            view = nil;
//    }   
//    return view;
//}

//+ (PassWordDialog *)dialogWith:(NSString *)title 
//                      delegate:(id<InputDialogDelegate>)delegate 
//                         theme:(CommonInputDialogTheme)theme
//{
//    PassWordDialog* view = [self createDialogWithTheme:theme];
//    if (view) {
//        //init the button
//        [view initWithTheme:theme 
//                      title:title];
//        view.delegate = delegate;
//        
//        UserManager *userManager = [UserManager defaultManager];
//        if ([userManager isPasswordEmpty]) {
//            [view hideOldPasswordTextField];
//        }
//    }
//    return  view;
//}


//- (void)decreaseView:(UIView *)view height:(CGFloat)height
//{
//    CGFloat x = view.frame.origin.x;
//    CGFloat y = view.frame.origin.y; 
//    CGFloat width = view.frame.size.width;
//    CGFloat nHeight = view.frame.size.height - height;
//    view.frame = CGRectMake(x, y, width, nHeight);
//}


//- (void)upView:(UIView *)view height:(CGFloat)height
//{
//
//    CGFloat y = view.center.y - height;
//    view.center = CGPointMake(view.center.x, y);
//}

- (void)hideOldPasswordTextField
{
    [self.oldPasswordTextField removeFromSuperview];
    self.oldPasswordTextField = nil;
    
    [self.passwordTextField becomeFirstResponder];
    
    CGFloat originY = 0;
    [self.passwordTextField updateOriginY:0];
    
    originY += self.passwordTextField.frame.size.height + GAP;
    [self.anotherPasswordTextField updateOriginY:originY];
    
    CGFloat height = self.passwordTextField.frame.size.height + GAP + self.anotherPasswordTextField.frame.size.height;
    [self updateHeight:height];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    NSString* value = [anim valueForKey:@"AnimationKey"];
    if ([value isEqualToString:@"runOut"]) {
        [self setHidden:YES];
        [self removeFromSuperview];
    }else{
        UserManager *userManager = [UserManager defaultManager];
        if ([userManager isPasswordEmpty]) {
            [self.anotherPasswordTextField becomeFirstResponder];
        }else{
            [self.oldPasswordTextField becomeFirstResponder];
        }
    }

}

- (BOOL)isPasswordWrong
{
    if ([[UserManager defaultManager] isPasswordEmpty]) {
        return NO;
    }
    return ![[UserManager defaultManager] isPasswordCorrect:self.oldPasswordTextField.text];
}

- (BOOL)isTwoInputDifferent
{
    NSString *input1 = [self.anotherPasswordTextField text];
    NSString *input2 = [self.passwordTextField text];
    BOOL same = [input1 isEqualToString:input2];
    return !same;
}

- (BOOL)isPasswordIllegal
{
    return [self.passwordTextField.text length] < 6;
}

- (void)textFieldsResignFirstResponder
{
    [self.oldPasswordTextField resignFirstResponder];
    [self.anotherPasswordTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

- (void)handlePasswordWrong
{
    if( self.delegate && [self.delegate respondsToSelector:@selector(passwordIsWrong)])
    {
        [self.delegate passwordIsWrong];
    }
    [_oldPasswordTextField becomeFirstResponder];
}

- (void)handlePasswordIllegal
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(passwordIsIllegal)]) {
        [self.delegate passwordIsIllegal];
    }
    [_passwordTextField becomeFirstResponder];
}

- (void)handleTwoInputDifferent
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(twoInputDifferent)]) {
        [self.delegate twoInputDifferent];
    }
    [_anotherPasswordTextField becomeFirstResponder];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _oldPasswordTextField) {
        if ([self isPasswordWrong]) {
            [self handlePasswordWrong];
        }else{
            [_passwordTextField becomeFirstResponder];
        }
    }else if(textField == _passwordTextField)
    {
        if ([self isPasswordIllegal]) {
            [self handlePasswordIllegal];
        }else{
            [_anotherPasswordTextField becomeFirstResponder];
        }
    }else if(textField == _anotherPasswordTextField){
        if ([self isTwoInputDifferent]) {
            [self handleTwoInputDifferent];
        }else{
            [_anotherPasswordTextField resignFirstResponder];
        }
    }else {
        [_anotherPasswordTextField resignFirstResponder];
    }
    return YES;
}

@end
