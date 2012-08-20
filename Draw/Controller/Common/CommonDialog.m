//
//  CommonDialog.m
//  Draw
//
//  Created by  on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommonDialog.h"
#import "ShareImageManager.h"
#import "LocaleUtils.h"

#define COMMON_DIALOG_THEME_DRAW    @"CommonDialog"
#define COMMON_DIALOG_THEME_DICE    @"CommonDiceDialog"

@implementation CommonDialog
@synthesize oKButton = _OKButton;
@synthesize backButton = _backButton;
@synthesize messageLabel = _messageLabel;
@synthesize titleLabel = _titleLabel;
@synthesize delegate = _delegate;
@synthesize style = _style;
- (void)dealloc
{
    _delegate = nil;
    [_OKButton release];
    [_backButton release];
    [_messageLabel release];
    [_titleLabel release];
    [super dealloc];
}

- (void)initTitles
{

}

- (void)initButtonsWithStyle:(CommonDialogStyle)aStyle
{
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    self.style = aStyle;
    switch (aStyle) {
        case CommonDialogStyleSingleButton: {
            [self.oKButton setFrame:CGRectMake(self.oKButton.frame.origin.x, self.oKButton.frame.origin.y, self.oKButton.frame.size.width*2, self.oKButton.frame.size.height)];
            [self.oKButton setCenter:CGPointMake(self.contentView.frame.size.width/2, self.oKButton.frame.origin.y)];
            [self.oKButton setBackgroundImage:[imageManager greenImage] forState:UIControlStateNormal];
            [self.backButton setHidden:YES];
        }
            break;
        case CommonDialogStyleDoubleButton: {
            [self.oKButton setBackgroundImage:[imageManager redImage] forState:UIControlStateNormal];
        }
            break;
        default:
            break;
    }
}

+ (CommonDialog *)createDialogWithStyle:(CommonDialogStyle)aStyle
{
    CommonDialog* view =  (CommonDialog*)[self createInfoViewByXibName:COMMON_DIALOG_THEME_DRAW];
    [view initButtonsWithStyle:aStyle];
    [view initTitles];
    [view appear];
    
    //init the button
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    [view.backButton setBackgroundImage:[imageManager greenImage] forState:UIControlStateNormal];
    [view.backButton setTitle:NSLS(@"kCancel") forState:UIControlStateNormal];
    [view.oKButton setTitle:NSLS(@"kOK") forState:UIControlStateNormal];
    view.tag = 0;
    return view;
    
}

+ (CommonDialog *)createDialogWithStyle:(CommonDialogStyle)aStyle 
                                  theme:(CommonDialogTheme)theme
{

    CommonDialog* view;
    switch (theme) {
        case CommonDialogThemeDice: {
            view = (CommonDialog*)[self createInfoViewByXibName:COMMON_DIALOG_THEME_DICE]; 
        } break;
        case CommonDialogThemeDraw: {
            view = (CommonDialog*)[self createInfoViewByXibName:COMMON_DIALOG_THEME_DRAW];
        } break;
        default:
            break;
    }
    [view initButtonsWithStyle:aStyle];
    [view initTitles];
    [view appear];
    
    //init the button
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    [view.backButton setBackgroundImage:[imageManager greenImage] forState:UIControlStateNormal];
    [view.backButton setTitle:NSLS(@"kCancel") forState:UIControlStateNormal];
    [view.oKButton setTitle:NSLS(@"kOK") forState:UIControlStateNormal];
    view.tag = 0;
    return view;
    
}


+ (CommonDialog *)createDialogWithTitle:(NSString *)title message:(NSString *)message style:(CommonDialogStyle)aStyle delegate:(id<CommonDialogDelegate>)aDelegate
{
    CommonDialog* view = [CommonDialog createDialogWithStyle:aStyle];
    view.delegate = aDelegate;
    [view setTitle:title];
    [view setMessage:message];
    return view;
    
}

+ (CommonDialog *)createDialogWithTitle:(NSString *)title 
                                message:(NSString *)message 
                                  style:(CommonDialogStyle)aStyle 
                               delegate:(id<CommonDialogDelegate>)aDelegate 
                                  theme:(CommonDialogTheme)theme
{
    CommonDialog* view = [CommonDialog createDialogWithStyle:aStyle theme:theme];
    view.delegate = aDelegate;
    [view setTitle:title];
    [view setMessage:message];
    return view;
}

- (void)setTitle:(NSString *)title
{
    [self.titleLabel setText:title];
}
- (void)setMessage:(NSString *)message
{
    CGSize size = [message sizeWithFont:_messageLabel.font];
    if (size.width > _messageLabel.frame.size.width) {
        [self.messageLabel setTextAlignment:UITextAlignmentLeft];
    }else{
        [self.messageLabel setTextAlignment:UITextAlignmentCenter];
    }
    [self.messageLabel setText:message];
}

- (IBAction)clickOk:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(clickOk:)]) {
        [_delegate clickOk:self];
    }
    [self disappear];
}

- (IBAction)clickBack:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(clickBack:)]) {
        [_delegate clickBack:self];
    }
    [self disappear];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */


@end
