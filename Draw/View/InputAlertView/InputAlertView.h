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


typedef void (^InputAlertBlock)(BOOL confirm, NSString *subject, NSString *content, NSSet *shareSet);

@interface InputAlert : NSObject

// by default, show SNS if has.
+ (void)showWithSubject:(NSString *)subject
                content:(NSString *)contest
                 inView:(UIView *)view
                  block:(InputAlertBlock)block;

// if you don't want to show SNS, use this method.
+ (void)showWithSubjectWithoutSNS:(NSString *)subject
                          content:(NSString *)contest
                           inView:(UIView *)view
                            block:(InputAlertBlock)block;
@end
