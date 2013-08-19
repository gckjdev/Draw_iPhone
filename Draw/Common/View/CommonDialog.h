//
//  CommonDialog.h
//  Draw
//
//  Created by  on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "commonInfoView.h"

@class CommonDialog;



typedef enum {
    CommonDialogStyleSingleButton = 0,
    CommonDialogStyleDoubleButton,
    CommonDialogStyleDoubleButtonWithCross,
    CommonDialogStyleCross,
}CommonDialogStyle;

typedef enum {
    CommonDialogTypeLabel,
    CommonDialogTypeInputField,
    CommonDialogTypeInputTextView,
    CommonDialogTypeCustomView,
}CommonDialogType;

typedef void (^DialogSelectionBlock)(id infoView);

@protocol CommonDialogDelegate <NSObject>
 @optional
- (void)didClickOk:(CommonDialog *)dialog infoView:(id)infoView;
- (void)didClickCancel:(CommonDialog *)dialog;

@end

@interface CommonDialog : CommonInfoView

@property (assign, nonatomic) CommonDialogStyle style;
@property (assign, nonatomic) CommonDialogType type;

// 最大输入长度，为0时表示不限制
@property (assign, nonatomic) int maxInputLen;
@property (assign, nonatomic) BOOL allowInputEmpty;

@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UILabel *messageLabel;
@property (retain, nonatomic) IBOutlet UITextField *inputTextField;
@property (retain, nonatomic) IBOutlet UITextView *inputTextView;
@property (retain, nonatomic) UIView *customView;

@property (retain, nonatomic) IBOutlet UIButton *oKButton;
@property (retain, nonatomic) IBOutlet UIButton *cancelButton;
@property (retain, nonatomic) IBOutlet UIButton *closeButton;

@property (assign, nonatomic) id<CommonDialogDelegate> delegate;

@property (copy, nonatomic) DialogSelectionBlock clickOkBlock;
@property (copy, nonatomic) DialogSelectionBlock clickCancelBlock;

- (void)setTitle:(NSString *)title;

+ (CommonDialog *)createDialogWithTitle:(NSString *)title
                                message:(NSString *)message
                                  style:(CommonDialogStyle)aStyle;

+ (CommonDialog *)createDialogWithTitle:(NSString *)title 
                                message:(NSString *)message 
                                  style:(CommonDialogStyle)aStyle 
                               delegate:(id<CommonDialogDelegate>)aDelegate;


+ (CommonDialog *)createInputFieldDialogWith:(NSString *)title;
+ (CommonDialog *)createInputFieldDialogWith:(NSString *)title
                                    delegate:(id<CommonDialogDelegate>)delegate;

+ (CommonDialog *)createInputViewDialogWith:(NSString *)title;

+ (CommonDialog *)createDialogWithTitle:(NSString *)title
                             customView:(UIView *)customView
                                  style:(CommonDialogStyle)style;


@end



