//
//  PassWordDialog.h
//  Draw
//
//  Created by  on 12-4-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#define PASSWORD_DIALOG @"PassWordDialog"
#define DICE_PASSWORD_DIALOG    @"DicePassWordDialog"

@protocol PassWordDialogDelegate <NSObject>

- (void)passwordIsWrong;
- (void)passwordIsIllegal;
- (void)twoInputDifferent;

@end

@interface PassWordDialog : UIView

@property (assign, nonatomic) id<PassWordDialogDelegate> delegate;
@property (retain, nonatomic) IBOutlet UITextField *oldPasswordTextField;
@property (retain, nonatomic) IBOutlet UITextField *passwordTextField;
@property (retain, nonatomic) IBOutlet UITextField *anotherPasswordTextField;

+ (PassWordDialog *)create;

- (BOOL)isPasswordWrong;
- (BOOL)isTwoInputDifferent;
- (BOOL)isPasswordIllegal;
- (void)textFieldsResignFirstResponder;

@end
