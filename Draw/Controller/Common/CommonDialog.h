//
//  CommonDialog.h
//  Draw
//
//  Created by  on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "commonInfoView.h"
@class FontButton;
@class CommonDialog;
@class FontLabel;
typedef enum {
    CommonDialogStyleSingleButton = 0,
    CommonDialogStyleDoubleButton
}CommonDialogStyle;

typedef enum {
    CommonDialogThemeDraw = 0,
    CommonDialogThemeDice = 1
}CommonDialogTheme;

@protocol CommonDialogDelegate <NSObject>
 @optional
- (void)clickOk:(CommonDialog *)dialog;
- (void)clickBack:(CommonDialog *)dialog;
@end

@interface CommonDialog : CommonInfoView {
    
}

@property (retain, nonatomic) IBOutlet FontButton *oKButton;
@property (retain, nonatomic) IBOutlet FontButton *backButton;
@property (retain, nonatomic) IBOutlet FontLabel *messageLabel;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (assign, nonatomic) CommonDialogStyle style;
@property (assign, nonatomic) id<CommonDialogDelegate> delegate;
@property (retain, nonatomic) IBOutlet UIImageView *contentBackground;
+ (CommonDialog *)createDialogWithTitle:(NSString *)title 
                                message:(NSString *)message 
                                  style:(CommonDialogStyle)aStyle 
                               delegate:(id<CommonDialogDelegate>)aDelegate;
+ (CommonDialog *)createDialogWithTitle:(NSString *)title 
                                message:(NSString *)message 
                                  style:(CommonDialogStyle)aStyle 
                               delegate:(id<CommonDialogDelegate>)aDelegate 
                                  theme:(CommonDialogTheme)theme;
- (void)setTitle:(NSString *)title;
- (void)setMessage:(NSString *)message;
- (void)initButtonsWithTheme:(CommonDialogTheme)theme;
+ (CommonDialogTheme)globalGetTheme;
@end
