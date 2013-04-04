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
#import "DiceImageManager.h"
#import "ZJHImageManager.h"


@interface InputDialog ()

- (void)initWithTheme:(CommonInputDialogTheme)theme title:(NSString*)title;
- (void)initWithTitle:(NSString*)title;

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

- (void)initByDiceTheme:(NSString*)title
{
    DiceImageManager* diceImgManager = [DiceImageManager defaultManager];
    float fontSize = [DeviceDetection isIPAD] ? 40 : 20;
    
    [self.targetTextField setBackground:[diceImgManager inputBackgroundImage]];
    [self.titleLabel.titleLabel setText:title];
    
//    [self.okButton setRoyButtonWithColor:[UIColor colorWithRed:244.0/255.0 green:93.0/255.0 blue:93.0/255.0 alpha:0.95]];
//    [self.cancelButton setRoyButtonWithColor:[UIColor colorWithRed:236.0/255.0 green:247.0/255.0 blue:63.0/255.0 alpha:0.95]];
    
    [self.cancelButton.titleLabel setText:NSLS(@"kCancel")];
    [self.okButton.titleLabel setText:NSLS(@"kOK")];
    self.titleLabel.titleLabel.font = [UIFont boldSystemFontOfSize:fontSize];
    self.titleLabel.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
}

- (void)initByZJHTheme:(NSString*)title
{
    DiceImageManager* diceImgManager = [DiceImageManager defaultManager];
    float fontSize = [DeviceDetection isIPAD] ? 40 : 20;
    
    
    [self.targetTextField setBackground:[diceImgManager inputBackgroundImage]];
    [self.titleLabel setTitle:title forState:UIControlStateNormal];
    
//    [self.okButton setRoyButtonWithColor:[UIColor colorWithRed:244.0/255.0 green:93.0/255.0 blue:93.0/255.0 alpha:0.95]];
//    [self.cancelButton setRoyButtonWithColor:[UIColor colorWithRed:236.0/255.0 green:247.0/255.0 blue:63.0/255.0 alpha:0.95]];
    
    [self.cancelButton setTitle:NSLS(@"kCancel") forState:UIControlStateNormal];
    [self.cancelButton.titleLabel setFont:[UIFont boldSystemFontOfSize:fontSize]];
    [self.okButton setTitle:NSLS(@"kOK") forState:UIControlStateNormal];
    [self.okButton.titleLabel setFont:[UIFont boldSystemFontOfSize:fontSize]];
    
    self.titleLabel.titleLabel.font = [UIFont boldSystemFontOfSize:fontSize];
    self.titleLabel.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
    [self.bgView setImage:[ZJHImageManager defaultManager].ZJHUserInfoBackgroundImage];
}

- (void)initByDrawTheme:(NSString*)title
{
    DiceImageManager* diceImgManager = [DiceImageManager defaultManager];
    float fontSize = [DeviceDetection isIPAD] ? 40 : 20;
    
    
    [self.targetTextField setBackground:[diceImgManager inputBackgroundImage]];
    [self.titleLabel setTitle:title forState:UIControlStateNormal];
    
//    [self.okButton setRoyButtonWithColor:[UIColor colorWithRed:244.0/255.0 green:93.0/255.0 blue:93.0/255.0 alpha:0.95]];
//    [self.cancelButton setRoyButtonWithColor:[UIColor colorWithRed:236.0/255.0 green:247.0/255.0 blue:63.0/255.0 alpha:0.95]];
    
    [self.cancelButton setTitle:NSLS(@"kCancel") forState:UIControlStateNormal];
    [self.cancelButton.titleLabel setFont:[UIFont boldSystemFontOfSize:fontSize]];
    [self.okButton setTitle:NSLS(@"kOK") forState:UIControlStateNormal];
    [self.okButton.titleLabel setFont:[UIFont boldSystemFontOfSize:fontSize]];
    
    self.titleLabel.titleLabel.font = [UIFont boldSystemFontOfSize:fontSize];
    self.titleLabel.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
    [self.bgView setImage:[ZJHImageManager defaultManager].ZJHUserInfoBackgroundImage];
}

- (void)initView:(NSString*)title
{
    float fontSize = [DeviceDetection isIPAD] ? 40 : 20;
    
    [self.bgView setImage:[[GameApp getImageManager] inputDialogBgImage]];
    [self.targetTextField setBackground:[[GameApp getImageManager] inputDialogInputBgImage]];
    [self setDialogTitle:title];
    [self.cancelButton setBackgroundImage:[[GameApp getImageManager] inputDialogLeftBtnImage] forState:UIControlStateNormal];
    [self.cancelButton setTitle:NSLS(@"kCancel") forState:UIControlStateNormal];
    [self.okButton setTitle:NSLS(@"kOK") forState:UIControlStateNormal];
    [self.okButton setBackgroundImage:[[GameApp getImageManager] inputDialogRightBtnImage] forState:UIControlStateNormal];
    self.titleLabel.titleLabel.font = [UIFont boldSystemFontOfSize:fontSize];
    self.titleLabel.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;

}

- (void)initWithTheme:(CommonInputDialogTheme)theme title:(NSString*)title
{
    
    switch (theme) {
        case CommonInputDialogThemeDice:{ 
            [self initByDiceTheme:title];
        } break;
        case CommonInputDialogThemeZJH: {
            [self initByZJHTheme:title];
        } break;
        case CommonInputDialogThemeDraw: 
        default: {
            [self initByDrawTheme:title];
        }break;
    }
    [self.targetTextField setPlaceholder:NSLS(@"kNicknameHolder")];
    
    
}

- (void)initWithTitle:(NSString *)title
{
    [self.okButton setTitle:NSLS(@"kOK") forState:UIControlStateNormal];
    [self.cancelButton setTitle:NSLS(@"kCancel") forState:UIControlStateNormal];
    [self.titleLabel setTitle:title forState:UIControlStateNormal];
    
    [self.bgView setImage:[[GameApp getImageManager] commonDialogBgImage]];
    [self.targetTextField setBackground:[[GameApp getImageManager] inputDialogInputBgImage]];
    
    [self.okButton setBackgroundImage:[[GameApp getImageManager] commonDialogRightBtnImage] forState:UIControlStateNormal];
    [self.cancelButton setBackgroundImage:[[GameApp getImageManager] commonDialogLeftBtnImage] forState:UIControlStateNormal];
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
    if (_clickCancelBlock != nil) {
        _clickCancelBlock(self.targetTextField.text);
    }
}

- (IBAction)clickOkButton:(id)sender {
    [self disappear];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickOk:targetText:)]) {
        [self.delegate didClickOk:self targetText:self.targetTextField.text];
    }
    if (_clickOkBlock != nil) {
        _clickOkBlock(self.targetTextField.text);
    }
}

+ (InputDialog *)dialogWith:(NSString *)title delegate:(id<InputDialogDelegate>)delegate
{

    InputDialog* view =  (InputDialog*)[self createInfoViewByXibName:[GameApp getInputDialogXibName]];
    
    //init the button
    [view initView:title];
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
        case CommonInputDialogThemeZJH: {
            view = (InputDialog*)[self createInfoViewByXibName:INPUT_DIALOG_THEME_ZJH];
            view.bgView.image = [[ZJHImageManager defaultManager] ZJHUserInfoBackgroundImage];
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

- (void)setClickOkBlock:(InputDialogSelectionBlock)block
{
    [_clickOkBlock release];
    _clickOkBlock = [block copy];
}
- (void)setClickCancelBlock:(InputDialogSelectionBlock)block
{
    [_clickCancelBlock release];
    _clickCancelBlock = [block copy];
}

+ (InputDialog *)dialogWith:(NSString *)title
                    clickOK:(InputDialogSelectionBlock)clickOk
                clickCancel:(InputDialogSelectionBlock)clickCancel
{
    InputDialog* view = [self createDialogWithTheme:CommonInputDialogThemeDraw];
    if (view) {
        [view initWithTitle:title];
        view.delegate = nil;
        [view setClickOkBlock:clickOk];
        [view setClickCancelBlock:clickCancel];
    }
    return view;
}

- (void)showInView:(UIView *)view
{
    self.frame = view.frame;
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (self.maxInputLen > 0 && range.location >= self.maxInputLen)
        return NO; // return NO to not change text
    return YES;
}

- (void)dealloc {
    PPRelease(cancelButton);
    PPRelease(okButton);
    PPRelease(bgView);
    PPRelease(titleLabel);
    PPRelease(targetTextField);
    PPRelease(_clickCancelBlock);
    PPRelease(_clickOkBlock);
    [super dealloc];
}
@end
