//
//  InputDialog.h
//  Draw
//
//  Created by  on 12-4-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonInfoView.h"
#import "CustomUITextField.h"

#define INPUT_DIALOG_THEME_DRAW @"InputDialog"
#define INPUT_DIALOG_THEME_DICE @"DiceInputDialog"
#define INPUT_DIALOG_THEME_ZJH @"ZJHInputDialog"

typedef enum {
    CommonInputDialogThemeDraw = 0,
    CommonInputDialogThemeDice,
    CommonInputDialogThemeZJH,
}CommonInputDialogTheme;

typedef void (^InputDialogSelectionBlock)(NSString* inputStr);

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
    InputDialogSelectionBlock _clickOkBlock;
    InputDialogSelectionBlock _clickCancelBlock;
}

- (void)setDialogTitle:(NSString *)title;
- (void)setTargetText:(NSString *)text;
@property (retain, nonatomic) IBOutlet UIButton *cancelButton;
@property (retain, nonatomic) IBOutlet UIButton *okButton;
@property (retain, nonatomic) IBOutlet UIImageView *bgView;
@property (retain, nonatomic) IBOutlet UIButton *titleLabel;
@property (retain, nonatomic) IBOutlet UITextField *targetTextField;
@property (assign, nonatomic) id<InputDialogDelegate> delegate;
@property (assign, nonatomic) NSInteger maxInputLen;
@property (assign, nonatomic) BOOL allowEmpty;

- (IBAction)clickCancelButton:(id)sender;
- (IBAction)clickOkButton:(id)sender;

+ (InputDialog *)dialogWith:(NSString *)title 
                   delegate:(id<InputDialogDelegate>)delegate;
//+ (InputDialog *)dialogWith:(NSString *)title 
//                   delegate:(id<InputDialogDelegate>)delegate 
//                      theme:(CommonInputDialogTheme)theme;
+ (InputDialog *)dialogWith:(NSString *)title
                    clickOK:(InputDialogSelectionBlock)clickOk
                clickCancel:(InputDialogSelectionBlock)clickCancel;

+ (InputDialog *)dialogWith:(NSString *)title
                defaultText:(NSString *)defaultText
            placeHolderText:(NSString *)placeHolderText
                    clickOK:(InputDialogSelectionBlock)clickOk
                clickCancel:(InputDialogSelectionBlock)clickCancel;
- (void)initView:(NSString*)title;
@end
