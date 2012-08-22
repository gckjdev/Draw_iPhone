//
//  PassWordDialog.h
//  Draw
//
//  Created by  on 12-4-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "InputDialog.h"
//@class PassWordDialog;

//@protocol PassWordDialog : InputDialog
//
//
//@end
#define PASSWORD_DIALOG @"PassWordDialog"
#define DICE_PASSWORD_DIALOG    @"DicePassWordDialog"

@interface PassWordDialog : InputDialog
{
    
}
@property (retain, nonatomic) IBOutlet UITextField *oldPasswordTextField;
@property (retain, nonatomic) IBOutlet UITextField *anotherPasswordTextField;
+ (PassWordDialog *)dialogWith:(NSString *)title 
                      delegate:(id<InputDialogDelegate>)delegate;
+ (PassWordDialog *)dialogWith:(NSString *)title 
                      delegate:(id<InputDialogDelegate>)delegate 
                         theme:(CommonInputDialogTheme)theme;
- (void)hideOldPasswordTextField;
@end
