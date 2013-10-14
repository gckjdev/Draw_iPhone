//
//  NameAndDescEditView.m
//  Draw
//
//  Created by 王 小涛 on 13-10-12.
//
//

#import "NameAndDescEditView.h"
#import "AutoCreateViewByXib.h"

@implementation NameAndDescEditView

AUTO_CREATE_VIEW_BY_XIB(NameAndDescEditView);

+ (id)createViewWithName:(NSString *)name
                    desc:(NSString *)desc{
    
    NameAndDescEditView *v = [self createView];
    v.nameLabel.text = NSLS(@"kSubject");
    v.nameTextField.text = name;
    v.nameTextField.placeholder = NSLS(@"kSubjectPlaceholder");
    v.nameLabel.textColor = COLOR_BROWN;
    SET_INPUT_VIEW_STYLE(v.nameTextField);
    
    v.descLabel.text = NSLS(@"kDesc");
    v.descTextView.text = desc;
    v.descTextView.placeholder = NSLS(@"kDescPlaceholder");
    v.descLabel.textColor = COLOR_BROWN;
    SET_INPUT_VIEW_STYLE(v.descTextView);
    
    [v.nameTextField becomeFirstResponder];
    v.nameTextField.returnKeyType = UIReturnKeyNext;
    v.nameTextField.delegate = v;
    
    return v;
}

// called when 'return' key pressed. return NO to ignore.
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [self.nameTextField resignFirstResponder];
    [self.descTextView becomeFirstResponder];
    return YES;
}

- (void)dealloc {
    [_nameLabel release];
    [_nameTextField release];
    [_descLabel release];
    [_descTextView release];
    [super dealloc];
}

@end
