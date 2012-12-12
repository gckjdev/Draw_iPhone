//
//  InputDialog.h
//  Draw
//
//  Created by  on 12-4-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonInfoView.h"
@class FontButton;

#define INPUT_DIALOG_THEME_DRAW @"InputDialog"
#define INPUT_DIALOG_THEME_DICE @"DiceInputDialog"
#define INPUT_DIALOG_THEME_ZJH @"ZJHInputDialog"

typedef enum {
    CommonInputDialogThemeDraw = 0,
    CommonInputDialogThemeDice,
    CommonInputDialogThemeZJH,
}CommonInputDialogTheme;

@class InputDialog;
@protocol InputDialogDelegate <NSObject>

@optional
- (void)didClickOk:(InputDialog *)dialog targetText:(NSString *)targetText;
- (void)didClickCancel:(InputDialog *)dialog;

//used for password dialog
- (void)passwordIsWrong:(NSString *)password;
- (void)passwordIsIllegal:(NSString *)password;
- (void)roomNameIsIllegal:(NSString *)password;
- (void)twoInputDifferent;
@end

@interface InputDialog : CommonInfoView<UITextFieldDelegate>
{
    
}

- (void)setDialogTitle:(NSString *)title;
- (void)setTargetText:(NSString *)text;
@property (retain, nonatomic) IBOutlet FontButton *cancelButton;
@property (retain, nonatomic) IBOutlet FontButton *okButton;
@property (retain, nonatomic) IBOutlet UIImageView *bgView;
@property (retain, nonatomic) IBOutlet FontButton *titleLabel;
@property (retain, nonatomic) IBOutlet UITextField *targetTextField;
@property (assign, nonatomic) id<InputDialogDelegate> delegate;

- (IBAction)clickCancelButton:(id)sender;
- (IBAction)clickOkButton:(id)sender;

+ (InputDialog *)dialogWith:(NSString *)title 
                   delegate:(id<InputDialogDelegate>)delegate;
+ (InputDialog *)dialogWith:(NSString *)title 
                   delegate:(id<InputDialogDelegate>)delegate 
                      theme:(CommonInputDialogTheme)theme;

- (void)initView:(NSString*)title;
@end
