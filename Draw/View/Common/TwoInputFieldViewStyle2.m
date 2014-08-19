//
//  TwoInputFieldViewStyle2.m
//  Draw
//
//  Created by ChaoSo on 14-8-15.
//
//

#import "TwoInputFieldViewStyle2.h"
#import "AutoCreateViewByXib.h"
@interface TwoInputFieldViewStyle2()

@end

@implementation TwoInputFieldViewStyle2

AUTO_CREATE_VIEW_BY_XIB(TwoInputFieldViewStyle2);
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (id)create{
    
    TwoInputFieldViewStyle2 *v = [self createView];
    SET_INPUT_VIEW_STYLE(v.textField1);
    SET_INPUT_VIEW_STYLE(v.textField2);
    SET_MESSAGE_LABEL_STYLE(v.textFieldTitle1);
    SET_MESSAGE_LABEL_STYLE(v.textFieldTitle2);
    v.textField1.returnKeyType = UIReturnKeyNext;
    v.textField2.returnKeyType = UIReturnKeyDone;
    
    v.textField1.delegate = v;
    v.textField2.delegate = v;
    [v.textField2 resignFirstResponder];


    
    return v;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField;
// called when 'return' key pressed. return NO to ignore.
{
    if (textField == _textField1) {
        [_textField2 becomeFirstResponder];
    }else{
        [_textField2 resignFirstResponder];
    }
    
    return YES;
}







-(void)dealloc{
    [_textField1 release];
    [_textField2 release];
    [_textFieldTitle1 release];
    [_textFieldTitle2 release];

    [super dealloc];
}

@end
