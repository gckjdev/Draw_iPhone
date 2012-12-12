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
#import "FontButton.h"
#import "DiceImageManager.h"
#import "ZJHImageManager.h"

@implementation PassWordDialog
@synthesize anotherPasswordTextField;
@synthesize oldPasswordTextField;

- (void)initWithTheme:(CommonInputDialogTheme)theme title:(NSString*)title
{
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    DiceImageManager* diceImgManager = [DiceImageManager defaultManager];
    float fontSize = [DeviceDetection isIPAD] ? 40 : 20;
    switch (theme) {
        case CommonInputDialogThemeDice:{ 
            [self.targetTextField setBackground:[diceImgManager inputBackgroundImage]];
            [self.titleLabel.fontLable setText:title];
            
            [self.cancelButton setBackgroundImage:[diceImgManager fastGameBtnBgImage] 
                                         forState:UIControlStateNormal];
            [self.okButton setBackgroundImage:[diceImgManager diceQuitBtnImage] 
                                     forState:UIControlStateNormal];
            
            [self.cancelButton.fontLable setText:NSLS(@"kCancel")];
            [self.okButton.fontLable setText:NSLS(@"kOK")];
            self.titleLabel.fontLable.font = [UIFont boldSystemFontOfSize:fontSize];
            self.titleLabel.fontLable.adjustsFontSizeToFitWidth = YES;
            self.titleLabel.fontLable.lineBreakMode = UILineBreakModeTailTruncation;
            
            [self.targetTextField setBackground:[diceImgManager inputBackgroundImage]];
            [self.anotherPasswordTextField setBackground:[diceImgManager inputBackgroundImage]];
            [self.oldPasswordTextField setBackground:[diceImgManager inputBackgroundImage]];
            
        } break;
        case CommonInputDialogThemeZJH: {
            [self.targetTextField setBackground:[diceImgManager inputBackgroundImage]];
            [self.titleLabel.titleLabel setText:title];
            
            [self.cancelButton setBackgroundImage:[diceImgManager fastGameBtnBgImage]
                                         forState:UIControlStateNormal];
            [self.okButton setBackgroundImage:[diceImgManager diceQuitBtnImage]
                                     forState:UIControlStateNormal];
            
            [self.cancelButton.fontLable setText:NSLS(@"kCancel")];
            [self.okButton.fontLable setText:NSLS(@"kOK")];
            self.titleLabel.titleLabel.font = [UIFont boldSystemFontOfSize:fontSize];
            self.titleLabel.titleLabel.adjustsFontSizeToFitWidth = YES;
            self.titleLabel.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
            
            [self.targetTextField setBackground:[diceImgManager inputBackgroundImage]];
            [self.anotherPasswordTextField setBackground:[diceImgManager inputBackgroundImage]];
            [self.oldPasswordTextField setBackground:[diceImgManager inputBackgroundImage]];
            [self.bgView setImage:[ZJHImageManager defaultManager].ZJHUserInfoBackgroundImage];
            
        }break;
            
        case CommonInputDialogThemeDraw: 
        default: {
            [self.targetTextField setBackground:[imageManager inputImage]];
            [self setDialogTitle:title];
            [self.cancelButton setBackgroundImage:[imageManager greenImage] forState:UIControlStateNormal];
            [self.cancelButton setTitle:NSLS(@"kCancel") forState:UIControlStateNormal];
            [self.okButton setTitle:NSLS(@"kOK") forState:UIControlStateNormal];
            [self.okButton setBackgroundImage:[imageManager redImage] forState:UIControlStateNormal];
            self.titleLabel.titleLabel.font = [UIFont boldSystemFontOfSize:fontSize];
            self.titleLabel.titleLabel.adjustsFontSizeToFitWidth = YES;
            self.titleLabel.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
            
            [self.targetTextField setBackground:[imageManager inputImage]];
            [self.anotherPasswordTextField setBackground:[imageManager inputImage]];
            [self.oldPasswordTextField setBackground:[imageManager inputImage]];
        }break;
            
            
    }
    [self.targetTextField setPlaceholder:NSLS(@"kNicknameHolder")];
    [self.oldPasswordTextField setPlaceholder:NSLS(@"kOldPasswordHolder")];
    [self.anotherPasswordTextField setPlaceholder:NSLS(@"kNewPasswordHolder")];
    [self.targetTextField setPlaceholder:NSLS(@"kConfirmPasswordHolder")];
    
}

- (void)initView:(NSString*)title
{
    float fontSize = [DeviceDetection isIPAD] ? 40 : 20;
    [self.targetTextField setBackground:[[GameApp getImageManager] inputDialogInputBgImage]];
    [self.titleLabel.fontLable setText:title];
    
    [self.cancelButton setBackgroundImage:[[GameApp getImageManager] inputDialogLeftBtnImage]
                                 forState:UIControlStateNormal];
    [self.okButton setBackgroundImage:[[GameApp getImageManager] inputDialogRightBtnImage]
                             forState:UIControlStateNormal];
    
    [self.cancelButton setTitle:NSLS(@"kCancel") forState:UIControlStateNormal];
    [self.okButton setTitle:NSLS(@"kOK") forState:UIControlStateNormal];
    self.titleLabel.titleLabel.font = [UIFont boldSystemFontOfSize:fontSize];
    self.titleLabel.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
    
    [self.targetTextField setBackground:[[GameApp getImageManager] inputDialogInputBgImage]];
    [self.anotherPasswordTextField setBackground:[[GameApp getImageManager] inputDialogInputBgImage]];
    [self.oldPasswordTextField setBackground:[[GameApp getImageManager] inputDialogInputBgImage]];
    
    [self.targetTextField setPlaceholder:NSLS(@"kNicknameHolder")];
    [self.oldPasswordTextField setPlaceholder:NSLS(@"kOldPasswordHolder")];
    [self.anotherPasswordTextField setPlaceholder:NSLS(@"kNewPasswordHolder")];
    [self.targetTextField setPlaceholder:NSLS(@"kConfirmPasswordHolder")];
}

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

    PassWordDialog* view =  (PassWordDialog*)[self createInfoViewByXibName:[GameApp getPasswordDialogXibName]];
    [view initView:title];
    view.delegate = delegate;
    
    UserManager *userManager = [UserManager defaultManager];
    if ([userManager isPasswordEmpty]) {
        [view hideOldPasswordTextField];
    }
    
    return view;
}

+ (PassWordDialog *)createDialogWithTheme:(CommonInputDialogTheme)theme
{
    PassWordDialog* view;
    switch (theme) {
        case CommonInputDialogThemeDice: {
            view = (PassWordDialog*)[self createInfoViewByXibName:DICE_PASSWORD_DIALOG]; 
        } break;
        case CommonInputDialogThemeDraw: {
            view = (PassWordDialog*)[self createInfoViewByXibName:PASSWORD_DIALOG];
        } break;
        case CommonInputDialogThemeZJH: {
            view = (PassWordDialog*)[self createInfoViewByXibName:DICE_PASSWORD_DIALOG];
        } break;
        default:
            PPDebug(@"<PassWordDialog> theme %d do not exist",theme);
            view = nil;
    }   
    return view;
}

+ (PassWordDialog *)dialogWith:(NSString *)title 
                      delegate:(id<InputDialogDelegate>)delegate 
                         theme:(CommonInputDialogTheme)theme
{
    PassWordDialog* view = [self createDialogWithTheme:theme];
    if (view) {
        //init the button
        [view initWithTheme:theme 
                      title:title];
        view.delegate = delegate;
        
        UserManager *userManager = [UserManager defaultManager];
        if ([userManager isPasswordEmpty]) {
            [view hideOldPasswordTextField];
        }
    }
    return  view;
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

    [self disappear];
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
