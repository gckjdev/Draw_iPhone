//
//  TwoInputFieldView.m
//  Draw
//
//  Created by 王 小涛 on 13-9-6.
//
//

#import "TwoInputFieldView.h"
#import "AutoCreateViewByXib.h"

@implementation TwoInputFieldView

AUTO_CREATE_VIEW_BY_XIB(TwoInputFieldView);

- (void)dealloc {
    [_textField1 release];
    [_textField2 release];
    [super dealloc];
}

+ (id)create{
    
    TwoInputFieldView *v = [self createView];
    SET_INPUT_VIEW_STYLE(v.textField1);
    SET_INPUT_VIEW_STYLE(v.textField2);
    
    v.textField1.returnKeyType = UIReturnKeyNext;
    v.textField2.returnKeyType = UIReturnKeyDone;
    
    v.textField1.delegate = v;
    v.textField2.delegate = v;
    
    [v.textField1 becomeFirstResponder];
    
    return v;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField;              // called when 'return' key pressed. return NO to ignore.
{
    if (textField == _textField1) {
        [_textField2 becomeFirstResponder];
    }else{
        [_textField2 resignFirstResponder];
    }
    
    return YES;
}


+ (CommonDialog *)loginViewWithNumber:(NSString *)number passWord:(NSString *)passWord
{
    TwoInputFieldView *rpDialog = [TwoInputFieldView create];
    
    rpDialog.textField1.placeholder = NSLS(@"kLoginXiaojiPlaceHolder");
    rpDialog.textField2.placeholder = NSLS(@"kLoginPasswordPlaceHolder");
    rpDialog.textField1.text = number;
    rpDialog.textField2.text = passWord;
    
    rpDialog.textField2.secureTextEntry = YES;
    
    rpDialog.textField1.keyboardType = UIKeyboardTypeNumberPad;
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kLoginXiaoji") customView:rpDialog style:CommonDialogStyleDoubleButtonWithCross];
    
    return dialog;

}
@end
