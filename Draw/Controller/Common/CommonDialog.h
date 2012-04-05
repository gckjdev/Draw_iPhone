//
//  CommonDialog.h
//  Draw
//
//  Created by  on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CommonDialog;
typedef enum {
    CommonDialogStyleSingleButton = 0,
    CommonDialogStyleDoubleButton
}CommonDialogStyle;

@protocol CommonDialogDelegate <NSObject>
 @optional
- (void)clickOk:(CommonDialog *)dialog;
- (void)clickBack:(CommonDialog *)dialog;
@end

@interface CommonDialog : UIView {
    
}
@property (retain, nonatomic) IBOutlet UIView *contentView;
@property (retain, nonatomic) IBOutlet UIButton *oKButton;
@property (retain, nonatomic) IBOutlet UIButton *backButton;
@property (retain, nonatomic) IBOutlet UILabel *messageLabel;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;

@property (assign, nonatomic) id<CommonDialogDelegate> delegate;
+ (CommonDialog *)createDialogWithTitle:(NSString *)title message:(NSString *)message style:(CommonDialogStyle)aStyle deelegate:(id<CommonDialogDelegate>)aDelegate;
- (void)setTitle:(NSString *)title;
- (void)setMessage:(NSString *)message;
- (void)showInView:(UIView*)view;

@end
