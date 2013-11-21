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

+ (PassWordDialog *)create
{
    PassWordDialog *view = (PassWordDialog *)[self createView];
    
    [view.oldPasswordTextField setPlaceholder:NSLS(@"kOldPasswordHolder")];
    [view.passwordTextField setPlaceholder:NSLS(@"kNewPasswordHolder")];
    [view.anotherPasswordTextField setPlaceholder:NSLS(@"kConfirmPasswordHolder")];
    
    SET_INPUT_VIEW_STYLE(view.oldPasswordTextField);
    
    SET_INPUT_VIEW_STYLE(view.passwordTextField);
    
    SET_INPUT_VIEW_STYLE(view.anotherPasswordTextField);

    UserManager *userManager = [UserManager defaultManager];
    if ([userManager isPasswordEmpty]) {
        [view hideOldPasswordTextField];
    }else{
        [view.oldPasswordTextField becomeFirstResponder];
    }
    
    return view;
}


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
