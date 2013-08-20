//
//  InputAlertView.h
//  Draw
//
//  Created by gamy on 13-1-14.
//
//

#import <UIKit/UIKit.h>

typedef enum {
    ComposeInputDialogTypeContent,
    ComposeInputDialogTypeTitleAndContent,
    ComposeInputDialogTypeTitleAndContentWithSNS,
    ComposeInputDialogTypeContentWithSNS,
    
} ComposeInputDialogType;

@interface InputAlertView : UIView

@property (retain, nonatomic) IBOutlet UITextView *contentInputView;
@property (retain, nonatomic) IBOutlet UITextField *titleInputField;

+ (id)createWithType:(ComposeInputDialogType)type;
- (NSSet *)shareSet;

- (void)setMaxTitleLength:(int)maxTitleLeng;
- (void)setMaxContentLength:(int)maxContentLen;

@end
