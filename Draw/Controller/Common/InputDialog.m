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
#import "FontButton.h"
#import "DiceImageManager.h"

@interface InputDialog ()

- (void)initWithTheme:(CommonInputDialogTheme)theme title:(NSString*)title;

@end

@implementation InputDialog
@synthesize cancelButton;
@synthesize okButton;
@synthesize bgView;
@synthesize titleLabel;
@synthesize targetTextField;
@synthesize delegate;

- (void)setDialogTitle:(NSString *)title
{
    [self.titleLabel setTitle:title forState:UIControlStateNormal];
}

- (void)setTargetText:(NSString *)text
{
    [self.targetTextField setText:text];
}

- (void)initWithTheme:(CommonInputDialogTheme)theme title:(NSString*)title
{
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    DiceImageManager* diceImgManager = [DiceImageManager defaultManager];
    float fontSize = [DeviceDetection isIPAD] ? 40 : 20;
    switch (theme) {
        case CommonInputDialogThemeDice:{ 
            [self.targetTextField setBackground:[diceImgManager inputBackgroundImage]];
            [self.titleLabel.fontLable setText:title];
            
            [self.okButton setRoyButtonWithColor:[UIColor colorWithRed:244.0/255.0 green:93.0/255.0 blue:93.0/255.0 alpha:0.95]];
            [self.cancelButton setRoyButtonWithColor:[UIColor colorWithRed:236.0/255.0 green:247.0/255.0 blue:63.0/255.0 alpha:0.95]];
            
            [self.cancelButton.fontLable setText:NSLS(@"kCancel")];
            [self.okButton.fontLable setText:NSLS(@"kOK")];
            self.titleLabel.fontLable.font = [UIFont boldSystemFontOfSize:fontSize];
            self.titleLabel.fontLable.adjustsFontSizeToFitWidth = YES;
            self.titleLabel.fontLable.lineBreakMode = UILineBreakModeTailTruncation;
            
        } break;
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
        }break;
    }
    [self.targetTextField setPlaceholder:NSLS(@"kNicknameHolder")];
    
    
}

//- (void)updateTextFields
//{
//    ShareImageManager *imageManager = [ShareImageManager defaultManager];
//    [self.targetTextField setBackground:[imageManager inputImage]];
//    [self.targetTextField setPlaceholder:NSLS(@"kNicknameHolder")];
//}


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
    [view initWithTheme:CommonInputDialogThemeDraw title:title]; 
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
        [view initWithTheme:theme title:title];  
        view.delegate = delegate;
        view.tag = 0;
    }
    return view;

}

- (void)showInView:(UIView *)view
{
    [super showInView:view];
    [self.targetTextField becomeFirstResponder];
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
