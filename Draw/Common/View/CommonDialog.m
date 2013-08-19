//
//  CommonDialog.m
//  Draw
//
//  Created by  on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommonDialog.h"
#import "LocaleUtils.h"
#import "ShareImageManager.h"
#import "UILabel+Extend.h"

#define CONTENT_VIEW_INSERT (ISIPAD ? 10 : 5)

#define TITLE_LABEL_HEIGHT (ISIPAD ? 74 : 34)
#define MESSAGE_LABEL_MAX_HEIGHT (ISIPAD ? 654 : 300)

#define GAP_Y_BETWEEN_TITLE_LABEL_AND_INFO_VIEW (ISIPAD ? 30 : 10)
#define GAP_Y_BETWEEN_INFO_VIEW_AND_BUTTON (ISIPAD ? 30 : 10)
#define GAP_Y_BETWEEN_BUTTON_AND_BOTTOM (ISIPAD ? 22 : 10)


#define FONT_TITLE_LABEL [UIFont boldSystemFontOfSize:(ISIPAD ? 36 : 18)]
#define FONT_MESSAGE_LABEL [UIFont boldSystemFontOfSize:(ISIPAD ? 30 : 15)]
#define FONT_INPUT_TEXT_FIELD [UIFont boldSystemFontOfSize:(ISIPAD ? 28 : 14)]
#define FONT_INPUT_TEXT_VIEW [UIFont boldSystemFontOfSize:(ISIPAD ? 28 : 14)]

#define FONT_BUTTON [UIFont boldSystemFontOfSize:(ISIPAD ? 30 : 15)]

#define DIALOG_CORNER_RADIUS    (ISIPAD ? 30 : 15)

@interface CommonDialog()<UITextFieldDelegate, UITextViewDelegate>

@end

@implementation CommonDialog


- (void)dealloc
{

    self.clickCancelBlock = nil;
    self.clickOkBlock = nil;
    self.delegate = nil;
    
    [_titleLabel release];
    [_messageLabel release];
    
    [_oKButton release];
    [_cancelButton release];
    [_closeButton release];
    [_inputTextField release];
    [_inputTextView release];
    [_customView release];
    [super dealloc];
}


+ (CommonDialog *)createDialogWithTitle:(NSString *)title
                                message:(NSString *)message
                                  style:(CommonDialogStyle)style{
    
    return [self createDialogWithTitle:title message:message style:style delegate:nil];
}

+ (CommonDialog *)createDialogWithTitle:(NSString *)title
                                message:(NSString *)message
                                  style:(CommonDialogStyle)aStyle
                               delegate:(id<CommonDialogDelegate>)aDelegate
{
    CommonDialog* view = [CommonDialog createDialogWithStyle:aStyle];
    view.delegate = aDelegate;
    [view setTitle:title];
    [view setMessage:message];
    view.type = CommonDialogTypeLabel;
    [view layout];
    return view;
}

+ (CommonDialog *)createInputFieldDialogWith:(NSString *)title{
    
    CommonDialog *view = [self createInputFieldDialogWith:title delegate:nil];
    return view;
}

+ (CommonDialog *)createInputFieldDialogWith:(NSString *)title
                                    delegate:(id<CommonDialogDelegate>)delegate{
    
    CommonDialog* view = [CommonDialog createDialogWithStyle:CommonDialogStyleDoubleButton];
    [view setTitle:title];
    view.delegate = delegate;
    view.type = CommonDialogTypeInputField;
    [view.inputTextField becomeFirstResponder];
    view.inputTextField.delegate = view;
    view.allowInputEmpty = YES;
    [view layout];
    return view;
}

+ (CommonDialog *)createInputViewDialogWith:(NSString *)title{
    
    CommonDialog* view = [CommonDialog createDialogWithStyle:CommonDialogStyleDoubleButton];
    [view setTitle:title];
    view.type = CommonDialogTypeInputTextView;
    view.inputTextView.delegate = view;
    [view.inputTextView becomeFirstResponder];
    view.allowInputEmpty = YES;
    [view layout];
    return view;
}

+ (CommonDialog *)createDialogWithTitle:(NSString *)title
                             customView:(UIView *)customView
                                  style:(CommonDialogStyle)style{
    
    CommonDialog *view = [CommonDialog createDialogWithStyle:style];
    [view setTitle:title];
    view.type = CommonDialogTypeCustomView;
    view.customView = customView;
    [view.contentView addSubview:view.customView];
    [view layout];
    return view;
}

- (void)layout
{    
    CGFloat centerX = self.contentView.frame.size.width/2;
    
    CGFloat originY = CONTENT_VIEW_INSERT;

    [_titleLabel updateCenterX:centerX];
    [_titleLabel updateOriginY:originY];
    [_titleLabel updateHeight:TITLE_LABEL_HEIGHT];
    
    originY += _titleLabel.frame.size.height + GAP_Y_BETWEEN_TITLE_LABEL_AND_INFO_VIEW;
    UIView *infoView = [self infoView];
    [infoView updateCenterX:centerX];
    [infoView updateOriginY:(originY)];
    
    originY += infoView.frame.size.height + GAP_Y_BETWEEN_INFO_VIEW_AND_BUTTON;

    [self.oKButton updateOriginY:originY];
    [self.cancelButton updateOriginY:(originY)];
    
    if (_style == CommonDialogStyleSingleButton) {
        [self.oKButton updateCenterX:centerX];
    }
    
    // update content view height
    CGFloat height = originY + _oKButton.frame.size.height +  GAP_Y_BETWEEN_BUTTON_AND_BOTTOM + CONTENT_VIEW_INSERT;
    [self.contentView updateHeight:height];
}

- (UIView *)infoView{
    
    switch (_type) {
        case CommonDialogTypeLabel:
            return _messageLabel;
            
        case CommonDialogTypeInputField:
            return _inputTextField;
            
        case CommonDialogTypeInputTextView:
            return _inputTextView;
            
        case CommonDialogTypeCustomView:
            return _customView;
            
        default:
            return nil;
    }
}

- (void)setType:(CommonDialogType)type{
    
    _type = type;
    
    switch (type) {
        case CommonDialogTypeLabel:
            self.messageLabel.hidden = NO;
            
            [self.inputTextField removeFromSuperview];
            self.inputTextField = nil;
            [self.inputTextView removeFromSuperview];
            self.inputTextView = nil;
            
            break;
            
        case CommonDialogTypeInputField:
            
            self.inputTextField.hidden = NO;
            
            [self.messageLabel removeFromSuperview];
            self.messageLabel = nil;
            [self.inputTextView removeFromSuperview];
            self.inputTextView = nil;
            
            break;
            
        case CommonDialogTypeInputTextView:
            
            self.inputTextView.hidden = NO;
            
            [self.messageLabel removeFromSuperview];
            self.messageLabel = nil;
            [self.inputTextField removeFromSuperview];
            self.inputTextField = nil;            
            
            break;
            
        case CommonDialogTypeCustomView:
            
            [self.inputTextView removeFromSuperview];
            self.inputTextView = nil;
            [self.messageLabel removeFromSuperview];
            self.messageLabel = nil;
            [self.inputTextField removeFromSuperview];
            self.inputTextField = nil;
            
            break;

        default:
            break;
    }
}

- (void)setStyle:(CommonDialogStyle)style{
    
    _style = style;
        
    switch (style) {
        case CommonDialogStyleSingleButton:
            [self.oKButton updateCenterX:self.contentView.frame.size.width/2];
            
            [_cancelButton removeFromSuperview];
            self.cancelButton = nil;
            [_closeButton removeFromSuperview];
            self.closeButton = nil;
            break;
            
        case CommonDialogStyleDoubleButton:
            [_closeButton removeFromSuperview];
            self.closeButton = nil;
            break;
                        
        case CommonDialogStyleCross:
            [_oKButton removeFromSuperview];
            self.oKButton = nil;
            [_cancelButton removeFromSuperview];
            self.cancelButton = nil;
            break;
            
        default:
            break;
    }
}



+ (CommonDialog *)createDialogWithStyle:(CommonDialogStyle)aStyle
{
    CommonDialog* view =  (CommonDialog*)[self createInfoViewByXibName:@"CommonDialog"];

    [view setStyle:aStyle];
    
    [view.oKButton setTitle:NSLS(@"kOK") forState:UIControlStateNormal];
    view.oKButton.backgroundColor = COLOR_YELLOW;
    [view.oKButton setTitleColor:COLOR_WHITE forState:UIControlStateNormal];
    SET_VIEW_ROUND_CORNER_WIDTH(view.oKButton, BUTTON_CORNER_RADIUS);
    view.oKButton.titleLabel.font = FONT_BUTTON;
    
    [view.cancelButton setTitle:NSLS(@"kCancel") forState:UIControlStateNormal];    [view appear];
    view.cancelButton.backgroundColor = COLOR_YELLOW;
    [view.cancelButton setTitleColor:COLOR_WHITE forState:UIControlStateNormal];
    SET_VIEW_ROUND_CORNER_WIDTH(view.cancelButton, BUTTON_CORNER_RADIUS);
    view.cancelButton.titleLabel.font = FONT_BUTTON;
    
    view.titleLabel.textColor = COLOR_WHITE;
    view.titleLabel.font = FONT_TITLE_LABEL;
    
    view.messageLabel.textColor = COLOR_BROWN;
    view.messageLabel.font = FONT_MESSAGE_LABEL;
    
    view.inputTextField.font = FONT_INPUT_TEXT_FIELD;
    SET_VIEW_ROUND_CORNER_WIDTH(view.inputTextField, TEXT_VIEW_CORNER_RADIUS);
    view.inputTextField.layer.borderWidth = TEXT_VIEW_BORDER_WIDTH;
    view.inputTextField.layer.borderColor = [COLOR_YELLOW CGColor];
    
    view.inputTextView.font = FONT_INPUT_TEXT_VIEW;
    SET_VIEW_ROUND_CORNER_WIDTH(view.inputTextView, TEXT_VIEW_CORNER_RADIUS);
    view.inputTextView.layer.borderWidth = TEXT_VIEW_BORDER_WIDTH;
    view.inputTextView.layer.borderColor = [COLOR_YELLOW CGColor];

    return view;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (self.maxInputLen > 0 && range.location >= self.maxInputLen) {
        return NO;
    }
    
    if (_allowInputEmpty == NO) {
        int len = range.location - range.length + 1;
        BOOL enabled = (len <= 0) ? NO : YES;
        [self enableOkButton:enabled];
    }
    
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if (self.maxInputLen > 0 && range.location >= self.maxInputLen) {
        return NO;
    }
    
    if (_allowInputEmpty == NO) {
        int len = range.location - range.length + 1;
        BOOL enabled = (len <= 0) ? NO : YES;
        [self enableOkButton:enabled];
    }
    
    return YES;
}



- (void)enableOkButton:(BOOL)enabled{
    self.oKButton.enabled = enabled;
    if (enabled) {
        [self.oKButton setBackgroundColor:COLOR_YELLOW];
    }else{
        [self.oKButton setBackgroundColor:COLOR_LIGHT_YELLOW];
    }
}

- (void)setTitle:(NSString *)title
{
    [self.titleLabel setText:title];
}

- (void)setMessage:(NSString *)message{
    
    if ([LocaleUtils isChinese]) {
        [self.messageLabel setLineBreakMode:UILineBreakModeCharacterWrap];
    }else {
        [self.messageLabel setLineBreakMode:UILineBreakModeWordWrap];
    }
    
    _messageLabel.text = message;
    _messageLabel.numberOfLines = 0;
    CGSize cSize = CGSizeMake(_messageLabel.frame.size.width, MESSAGE_LABEL_MAX_HEIGHT);
    [_messageLabel wrapTextWithConstrainedSize:cSize];
    [_messageLabel updateCenterX:self.contentView.bounds.size.width/2];
}

- (IBAction)clickOkButton:(id)sender
{
    if (_clickOkBlock != nil) {
        _clickOkBlock([self infoView]);
        self.clickOkBlock = nil;
    } else if (_delegate && [_delegate respondsToSelector:@selector(didClickOk:infoView:)]) {
        [_delegate didClickOk:self infoView:[self infoView]];
    }
    [self disappear];
}

- (IBAction)clickCancelButton:(id)sender
{
    if (_clickCancelBlock != nil) {
        _clickCancelBlock([self infoView]);
        self.clickCancelBlock = nil;
    } else if (_delegate && [_delegate respondsToSelector:@selector(didClickCancel:)]) {
        [_delegate didClickCancel:self];
    }
    [self disappear];
}

- (IBAction)clickCloseButton:(id)sender {

    [self disappear];
}

@end

@interface DialogBGView : UIView

@end

@implementation DialogBGView


- (void)awakeFromNib
{
    [self.layer setCornerRadius:DIALOG_CORNER_RADIUS];
    [self.layer setMasksToBounds:YES];
    self.backgroundColor = [UIColor clearColor];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    [COLOR_WHITE setFill];
    CGContextFillRect(ctx, self.bounds);

    
    [COLOR_GREEN setFill];
    CGRect r = CGRectMake(0, 0, CGRectGetWidth(self.bounds), TITLE_LABEL_HEIGHT + CONTENT_VIEW_INSERT);
    CGContextFillRect(ctx, r);

    
    [COLOR_RED setStroke];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:DIALOG_CORNER_RADIUS];
    CGContextAddPath(ctx, path.CGPath);
    CGContextSetLineWidth(ctx, CONTENT_VIEW_INSERT * 2);
    CGContextStrokePath(ctx);
}

@end