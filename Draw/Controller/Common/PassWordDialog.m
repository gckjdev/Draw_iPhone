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

@implementation PassWordDialog
@synthesize anotherPasswordTextField;
@synthesize oldPasswordTextField;


- (void)updateTextFields
{
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    [self.targetTextField setBackground:[imageManager inputImage]];
    [self.anotherPasswordTextField setBackground:[imageManager inputImage]];
    [self.oldPasswordTextField setBackground:[imageManager inputImage]];
    
    [self.oldPasswordTextField setPlaceholder:NSLS(@"kOldPasswordHolder")];
    [self.anotherPasswordTextField setPlaceholder:NSLS(@"kNewPasswordHolder")];
    [self.targetTextField setPlaceholder:NSLS(@"kConfirmPasswordHolder")];
}

+ (PassWordDialog *)dialogWith:(NSString *)title delegate:(id<InputDialogDelegate>)delegate
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PassWordDialog" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create <PassWordDialog> but cannot find cell object from Nib");
        return nil;
    }
    PassWordDialog* view =  (PassWordDialog*)[topLevelObjects objectAtIndex:0];
    
    //init the button
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    
    [view updateTextFields];
    
    [view setDialogTitle:title];
    [view.cancelButton setBackgroundImage:[imageManager greenImage] forState:UIControlStateNormal];
    [view.cancelButton setTitle:NSLS(@"kCancel") forState:UIControlStateNormal];
    [view.okButton setTitle:NSLS(@"kOK") forState:UIControlStateNormal];
    [view.okButton setBackgroundImage:[imageManager redImage] forState:UIControlStateNormal];
    view.delegate = delegate;
    
    UserManager *userManager = [UserManager defaultManager];
    if ([userManager isPasswordEmpty]) {
        [view hideOldPasswordTextField];
    }
    
    return view;
}

- (void)decreaseView:(UIView *)view height:(CGFloat)height
{
    CGFloat x = view.frame.origin.x;
    CGFloat y = view.frame.origin.y; 
    CGFloat width = view.frame.size.width;
    CGFloat nHeight = view.frame.size.height - height;
    view.frame = CGRectMake(x, y, width, nHeight);
}


- (void)upView:(UIView *)view height:(CGFloat)height
{

    CGFloat y = view.center.y - height;
    view.center = CGPointMake(view.center.x, y);
}

- (void)hideOldPasswordTextField
{
    self.oldPasswordTextField.hidden = YES;
    
    const NSInteger UP_HEIGHT = 15;
    [self upView:self.anotherPasswordTextField height:UP_HEIGHT+10];
    [self upView:self.targetTextField height:UP_HEIGHT+5];
    [self upView:self.cancelButton height:UP_HEIGHT];
    [self upView:self.okButton height:UP_HEIGHT];
    
    [self decreaseView:self.contentView height:UP_HEIGHT];
    [self decreaseView:self.bgView height:UP_HEIGHT];
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
    NSString *input2 = [self.targetTextField text];
    BOOL same = [input1 isEqualToString:input2];
    return !same;
}

- (BOOL)isPasswordIllegal
{
    return [self.anotherPasswordTextField.text length] < 6;
}


- (void)textFieldsResignFirstResponder
{
    [self.oldPasswordTextField resignFirstResponder];
    [self.anotherPasswordTextField resignFirstResponder];
    [self.targetTextField resignFirstResponder];
}

- (void)handlePasswordWrong
{
    if( self.delegate && [self.delegate respondsToSelector:@selector(passwordIsWrong:)])
    {
        [self.delegate passwordIsWrong:oldPasswordTextField.text];
    }
    [oldPasswordTextField becomeFirstResponder];    
}

- (void)handlePasswordIllegal
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(passwordIsIllegal:)]) {
        [self.delegate passwordIsIllegal:anotherPasswordTextField.text];
    }
    [anotherPasswordTextField becomeFirstResponder];
}

- (void)handleTwoInputDifferent
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(twoInputDifferent)]) {
        [self.delegate twoInputDifferent];
    }
    [self.targetTextField becomeFirstResponder];

}

- (IBAction)clickOkButton:(id)sender {

    [self startRunOutAnimation];
    if ([self isPasswordWrong]) 
    {
        [self handlePasswordWrong];
    }else if([self isPasswordIllegal])
    {
        [self handlePasswordIllegal];
    }else if([self isTwoInputDifferent])
    {   
        [self handleTwoInputDifferent];
    }else{
        [self removeFromSuperview];
        [self textFieldsResignFirstResponder];
        if (self.delegate && [self.delegate respondsToSelector:@selector(didClickOk:targetText:)])
        {
            [self.delegate didClickOk:self targetText:self.targetTextField.text];
        }
    }
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == oldPasswordTextField) {
        if ([self isPasswordWrong]) {
            [self handlePasswordWrong];
        }else{
            [textField resignFirstResponder];
        }
    }else if(textField == anotherPasswordTextField)
    {
        if ([self isPasswordIllegal]) {
            [self handlePasswordIllegal];
        }else{
            [textField resignFirstResponder];
        }
    }else if(textField == self.targetTextField){
        if ([self isTwoInputDifferent]) {
            [self handleTwoInputDifferent];
        }else{
            [textField resignFirstResponder];
        }
    }else {
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)dealloc {
    [oldPasswordTextField release];
    [anotherPasswordTextField release];
    [super dealloc];
}
@end
