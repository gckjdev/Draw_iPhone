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
}CommonDialogStyle;

typedef enum {
    CommonDialogThemeDraw = 0,
    CommonDialogThemeDice = 1,
    CommonDialogThemeZJH,
    CommonDialogThemeStarry,
}CommonDialogTheme;

typedef void (^DialogSelectionBlock)(void);

@protocol CommonDialogDelegate <NSObject>
 @optional
- (void)clickOk:(CommonDialog *)dialog;
- (void)clickBack:(CommonDialog *)dialog;
- (void)clickMask:(CommonDialog *)dialog;
@end

@interface CommonDialog : CommonInfoView {
    DialogSelectionBlock _clickOkBlock;
    DialogSelectionBlock _clickBackBlock;
    BOOL    _shouldResize;
}
@property (retain, nonatomic) IBOutlet UIButton *closeButton;

@property (retain, nonatomic) IBOutlet UIButton *oKButton;
@property (retain, nonatomic) IBOutlet UIButton *backButton;
@property (retain, nonatomic) IBOutlet UILabel *messageLabel;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (assign, nonatomic) CommonDialogStyle style;
@property (retain, nonatomic) IBOutlet UIImageView *frontBackgroundImageView;
@property (assign, nonatomic) id<CommonDialogDelegate> delegate;
@property (retain, nonatomic) IBOutlet UIImageView *contentBackground;

- (IBAction)clickMask:(id)sender;

+ (CommonDialog *)createDialogWithTitle:(NSString *)title 
                                message:(NSString *)message 
                                  style:(CommonDialogStyle)aStyle 
                               delegate:(id<CommonDialogDelegate>)aDelegate;

+ (CommonDialog *)createDialogWithTitle:(NSString *)title 
                                message:(NSString *)message 
                                  style:(CommonDialogStyle)aStyle 
                               delegate:(id<CommonDialogDelegate>)aDelegate 
                                  theme:(CommonDialogTheme)theme;

+ (CommonDialog *)createDialogWithTitle:(NSString *)title
                                message:(NSString *)message
                                  style:(CommonDialogStyle)aStyle
                               delegate:(id<CommonDialogDelegate>)aDelegate
                           clickOkBlock:(DialogSelectionBlock)block1
                       clickCancelBlock:(DialogSelectionBlock)block2;

+ (CommonDialog *)createDialogWithTitle:(NSString *)title
                                message:(NSString *)message
                                  style:(CommonDialogStyle)aStyle
                               delegate:(id<CommonDialogDelegate>)aDelegate
                                  theme:(CommonDialogTheme)theme
                           clickOkBlock:(DialogSelectionBlock)block1
                       clickCancelBlock:(DialogSelectionBlock)block2;


- (void)setTitle:(NSString *)title;
- (void)setMessage:(NSString *)message;
- (void)initButtonsWithTheme:(CommonDialogTheme)theme;
+ (CommonDialogTheme)globalGetTheme;

- (void)setClickOkBlock:(DialogSelectionBlock)block;
- (void)setClickBackBlock:(DialogSelectionBlock)block;

@end
