//
//  InputDialog.m
//  Draw
//
//  Created by  on 12-4-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "InputDialog.h"
#import "AnimationManager.h"
#import "ShareImageManager.h"
#import "LocaleUtils.h"


@implementation InputDialog
@synthesize cancelButton;
@synthesize okButton;
@synthesize bgView;
@synthesize titleLabel;
@synthesize targetTextField;
@synthesize delegate;


- (void)updateTextFields
{
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    [self.targetTextField setBackground:[imageManager inputImage]];
    [self.targetTextField setPlaceholder:NSLS(@"kNicknameHolder")];
}


- (IBAction)clickCancelButton:(id)sender {
    [self disappear];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickCancel:)]) {
        [self.delegate didClickCancel:self];
    }
}

- (IBAction)clickOkButton:(id)sender {
    [self disappear];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickOk:targetText:)]) {
        [self.delegate didClickOk:self targetText:self.targetTextField.text];
    }
}

+ (InputDialog *)dialogWith:(NSString *)title delegate:(id<InputDialogDelegate>)delegate
{

    InputDialog* view =  (InputDialog*)[self createInfoViewByXibName:INPUT_DIALOG_THEME_DRAW];
    
    //init the button
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    [view updateTextFields];
    [view setDialogTitle:title];
    [view.cancelButton setBackgroundImage:[imageManager greenImage] forState:UIControlStateNormal];
    [view.cancelButton setTitle:NSLS(@"kCancel") forState:UIControlStateNormal];
    [view.okButton setTitle:NSLS(@"kOK") forState:UIControlStateNormal];
    [view.okButton setBackgroundImage:[imageManager redImage] forState:UIControlStateNormal];
    view.delegate = delegate;
    view.tag = 0;
    return view;

}

+ (InputDialog *)createDialogWithTheme:(CommonInputDialogTheme)theme
{
    InputDialog* view;
    switch (theme) {
        case CommonInputDialogThemeDice: {
            view = (InputDialog*)[self createInfoViewByXibName:INPUT_DIALOG_THEME_DICE]; 
        } break;
        case CommonInputDialogThemeDraw: {
            view = (InputDialog*)[self createInfoViewByXibName:INPUT_DIALOG_THEME_DRAW];
        } break;
        default:
            PPDebug(@"<CommonDialog> theme %d do not exist",theme);
            view = nil;
    }   
    return view;
}

+ (InputDialog *)dialogWith:(NSString *)title 
                   delegate:(id<InputDialogDelegate>)delegate 
                      theme:(CommonInputDialogTheme)theme
{
    InputDialog* view = [self createDialogWithTheme:theme];
    if (view) {
        ShareImageManager *imageManager = [ShareImageManager defaultManager];
        [view updateTextFields];
        [view setDialogTitle:title];
        [view.cancelButton setBackgroundImage:[imageManager greenImage] forState:UIControlStateNormal];
        [view.cancelButton setTitle:NSLS(@"kCancel") forState:UIControlStateNormal];
        [view.okButton setTitle:NSLS(@"kOK") forState:UIControlStateNormal];
        [view.okButton setBackgroundImage:[imageManager redImage] forState:UIControlStateNormal];
        view.delegate = delegate;
        view.tag = 0;
    }
    return view;

}

- (void)setDialogTitle:(NSString *)title
{
    [self.titleLabel setTitle:title forState:UIControlStateNormal];
}

- (void)setTargetText:(NSString *)text
{
    [self.targetTextField setText:text];
}

//- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
//{
//    [self.targetTextField becomeFirstResponder];
//}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self clickOkButton:okButton];
    return YES;
}

- (void)dealloc {
    [cancelButton release];
    [okButton release];
    [bgView release];
    [titleLabel release];
    [targetTextField release];
    [super dealloc];
}
@end
