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

#define FONT_TITLE_LABEL [UIFont boldSystemFontOfSize:(ISIPAD ? 36 : 18)]

#define CONTENT_VIEW_INSERT (ISIPAD ? 10 : 5)

#define TITLE_LABEL_HEIGHT (ISIPAD ? 74 : 34)
#define MESSAGE_LABEL_MAX_HEIGHT (ISIPAD ? 850 : 390)
#define MESSAGE_LABEL_MIN_HEIGHT (ISIPAD ? 110 : 55)

#define GAP_Y_BETWEEN_TITLE_LABEL_AND_INFO_VIEW (ISIPAD ? 30 : 10)
#define GAP_Y_BETWEEN_INFO_VIEW_AND_BUTTON (ISIPAD ? 30 : 10)
#define GAP_Y_BETWEEN_BUTTON_AND_BOTTOM (ISIPAD ? 22 : 10)


#define DIALOG_CORNER_RADIUS    (ISIPAD ? 30 : 15)

#define BUTTON_WIDTH (ISIPAD ? 185 : 85)
#define BUTTON_HEIGHT (ISIPAD ? 65 : 30)

@interface CommonDialog()<UITextFieldDelegate, UITextViewDelegate>

@end

@implementation CommonDialog

- (void)dealloc
{

    self.clickCancelBlock = nil;
    self.clickOkBlock = nil;
    self.textChangedCallback = nil;
    self.delegate = nil;
    
    [_titleLabel release];
    [_messageLabel release];
    
    [_oKButton release];
    [_cancelButton release];
    [_closeButton release];
    [_inputTextField release];
    [_inputTextView release];
    [_customView release];
    [_bgImageView release];
    [super dealloc];
}

+ (void)showSimpleDialog:(NSString*)msg inView:(UIView*)view
{
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kMessage") message:msg style:CommonDialogStyleSingleButton];
    [dialog showInView:view];
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
    
    ///
    
    [view.inputTextField addTarget:view action:@selector(didTextChange:) forControlEvents:UIControlEventEditingChanged];
    
    ///
    
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
    
    ///
    
    [view.inputTextField addTarget:view action:@selector(didTextChange:) forControlEvents:UIControlEventEditingChanged];
    
    ///
    
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
    if(style == CommonSquareDialogStyleCross){
        [view squareLayout];
    }
    else{
        [view layout];
    }
    
    return view;
}

+ (CommonDialog *)createDialogWithTitle:(NSString *)title
                             customView:(UIView *)customView
                                  style:(CommonDialogStyle)style
                               delegate:(id<CommonDialogDelegate>)delegate{
    
    CommonDialog *view = [CommonDialog createDialogWithStyle:style];
    [view setTitle:title];
    view.type = CommonDialogTypeCustomView;
    view.customView = customView;
    [view.contentView addSubview:view.customView];
    if(style == CommonSquareDialogStyleCross){
        [view squareLayout];
    }
    else{
        [view layout];
    }
    view.delegate = delegate;
    
    return view;
}


- (void)layout
{
    UIView *infoView = [self infoView];
    
    // update content view height
//    CGFloat height = CONTENT_VIEW_INSERT + TITLE_LABEL_HEIGHT
//    + GAP_Y_BETWEEN_TITLE_LABEL_AND_INFO_VIEW
//    + infoView.frame.size.height
//    + GAP_Y_BETWEEN_INFO_VIEW_AND_BUTTON
//    + self.oKButton.frame.size.height
//    + GAP_Y_BETWEEN_BUTTON_AND_BOTTOM + CONTENT_VIEW_INSERT;
    

    
    if (_type == CommonDialogTypeCustomView &&
        infoView.frame.size.width > (self.contentView.frame.size.width - 2 * (ISIPAD ? 8 : 4) - CONTENT_VIEW_INSERT)) {
        
        CGFloat width = infoView.frame.size.width + 2 * (ISIPAD ? 16 : 8) + CONTENT_VIEW_INSERT;
        [self.contentView updateWidth:width];
        [self.contentView updateCenterX:self.center.x];
        [self.contentView setNeedsDisplay];
    }
    
    CGFloat centerX = self.contentView.frame.size.width/2;
    
    CGFloat originY = CONTENT_VIEW_INSERT;

    [_titleLabel updateCenterX:centerX];
    [_titleLabel updateOriginY:originY];
    [_titleLabel updateHeight:TITLE_LABEL_HEIGHT];
    
    [_closeButton updateOriginY:originY];
    
//    originY += _titleLabel.frame.size.height + GAP_Y_BETWEEN_TITLE_LABEL_AND_INFO_VIEW;
    originY = CGRectGetMaxY(_titleLabel.frame) + GAP_Y_BETWEEN_TITLE_LABEL_AND_INFO_VIEW;

    [infoView updateCenterX:centerX];
    [infoView updateOriginY:(originY)];
    
//    originY += infoView.frame.size.height + GAP_Y_BETWEEN_INFO_VIEW_AND_BUTTON;
    originY = CGRectGetMaxY(infoView.frame) + GAP_Y_BETWEEN_INFO_VIEW_AND_BUTTON;


    [self.oKButton updateOriginY:originY];
    [self.cancelButton updateOriginY:(originY)];
    
    if (_style == CommonDialogStyleSingleButton) {
        [self.oKButton updateCenterX:centerX];
    }else if(_style == CommonDialogStyleSingleButtonWithCross){
        [self.oKButton updateCenterX:centerX];
    }
    else{
        CGFloat gapX = (self.contentView.frame.size.width - 2 * BUTTON_WIDTH) / 4;
        [self.cancelButton updateOriginX:gapX];
        [self.oKButton updateOriginX:(gapX * 3 + BUTTON_WIDTH)];
    }
    
    // update content view height
    CGFloat height = CGRectGetMaxY(infoView.frame)
    + GAP_Y_BETWEEN_INFO_VIEW_AND_BUTTON
    + self.oKButton.frame.size.height
    + GAP_Y_BETWEEN_BUTTON_AND_BOTTOM + CONTENT_VIEW_INSERT;
    
    [self.contentView updateHeight:height];
    [self.contentView setNeedsDisplay];
}


- (void)squareLayout
{
    UIView *infoView = [self infoView];
    
    // update content view height
    //    CGFloat height = CONTENT_VIEW_INSERT + TITLE_LABEL_HEIGHT
    //    + GAP_Y_BETWEEN_TITLE_LABEL_AND_INFO_VIEW
    //    + infoView.frame.size.height
    //    + GAP_Y_BETWEEN_INFO_VIEW_AND_BUTTON
    //    + self.oKButton.frame.size.height
    //    + GAP_Y_BETWEEN_BUTTON_AND_BOTTOM + CONTENT_VIEW_INSERT;
    
    
    
    if (_type == CommonDialogTypeCustomView &&
        infoView.frame.size.width > (self.contentView.frame.size.width - 2 * (ISIPAD ? 8 : 4) - CONTENT_VIEW_INSERT)) {
        
        CGFloat width = infoView.frame.size.width + 2 * (ISIPAD ? 16 : 8) + CONTENT_VIEW_INSERT;
        [self.contentView updateWidth:width];
        [self.contentView updateCenterX:self.center.x];
        [self.contentView setNeedsDisplay];
    }
    
    CGFloat centerX = self.contentView.frame.size.width/2;
    
    CGFloat originY = CONTENT_VIEW_INSERT;
    
    [_titleLabel updateCenterX:centerX];
    [_titleLabel updateOriginY:originY];
    [_titleLabel updateHeight:TITLE_LABEL_HEIGHT];
    
    [_closeButton updateOriginY:originY];
    
    //    originY += _titleLabel.frame.size.height + GAP_Y_BETWEEN_TITLE_LABEL_AND_INFO_VIEW;
    originY = CGRectGetMaxY(_titleLabel.frame) + GAP_Y_BETWEEN_TITLE_LABEL_AND_INFO_VIEW;
    
    [infoView updateCenterX:centerX];
    [infoView updateOriginY:(originY)];
    
    //    originY += infoView.frame.size.height + GAP_Y_BETWEEN_INFO_VIEW_AND_BUTTON;
    originY = CGRectGetMaxY(infoView.frame) + GAP_Y_BETWEEN_INFO_VIEW_AND_BUTTON;
    
    
    [self.oKButton updateOriginY:originY];
    [self.cancelButton updateOriginY:(originY)];
    
    if (_style == CommonDialogStyleSingleButton) {
        [self.oKButton updateCenterX:centerX];
    }else if(_style == CommonDialogStyleSingleButtonWithCross){
        [self.oKButton updateCenterX:centerX];
    }
    else{
        CGFloat gapX = (self.contentView.frame.size.width - 2 * BUTTON_WIDTH) / 4;
        [self.cancelButton updateOriginX:gapX];
        [self.oKButton updateOriginX:(gapX * 3 + BUTTON_WIDTH)];
    }
    
    // update content view height
    // 用高度來適應寬度。使得高度與寬度一樣
    CGFloat height = CGRectGetMaxX(infoView.frame)
    + GAP_Y_BETWEEN_INFO_VIEW_AND_BUTTON
    + self.oKButton.frame.size.height
    + GAP_Y_BETWEEN_BUTTON_AND_BOTTOM + CONTENT_VIEW_INSERT;
    
    CGFloat adpateHeight = (ISIPAD?200:50);
    [self.contentView updateHeight:height+adpateHeight];
    [self.contentView setNeedsDisplay];
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
            
        case CommonDialogStyleSingleButtonWithCross:
            [self.oKButton updateCenterX:self.contentView.frame.size.width/2];
            [_cancelButton removeFromSuperview];
            self.cancelButton = nil;
            break;
        case CommonSquareDialogStyleCross:
            break;
            
        default:
            break;
    }
}



+ (CommonDialog *)createDialogWithStyle:(CommonDialogStyle)aStyle
{
    CommonDialog* view =  (CommonDialog*)[self createInfoViewByXibName:@"CommonDialog"];

    [view setStyle:aStyle];
    
    view.titleLabel.textColor = COLOR_WHITE;
    view.titleLabel.font = FONT_TITLE_LABEL;
    
    SET_MESSAGE_LABEL_STYLE(view.messageLabel);
    
    SET_INPUT_VIEW_STYLE(view.inputTextField);
    SET_INPUT_VIEW_STYLE(view.inputTextView);
    
    [view.oKButton setTitle:NSLS(@"kOK") forState:UIControlStateNormal];
    [view.cancelButton setTitle:NSLS(@"kCancel") forState:UIControlStateNormal];
    
    SET_BUTTON_ROUND_STYLE_YELLOW(view.cancelButton);
    SET_BUTTON_ROUND_STYLE_YELLOW(view.oKButton);
    
    [view appear];

    return view;
}



- (void)didTextChange:(id)sender{
    
    
    NSString *text = nil;
    
    if ([sender respondsToSelector:@selector(text)]) {
        text = [sender text];
    }else{
        return;
    }
    
    PPDebug(@"text lengh = %d", text.length);
    
    if (_allowInputEmpty == NO && text.length <= 0) {
        [self enableOkButton:NO];
    }else if (self.maxInputLen > 0 && text.length > self.maxInputLen) {
        [self enableOkButton:NO];
    }else{
        [self enableOkButton:YES];
    }
    
    EXECUTE_BLOCK(_textChangedCallback, [sender text]);
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
    _messageLabel.numberOfLines = INT_MAX;
    CGSize cSize = CGSizeMake(_messageLabel.frame.size.width, MESSAGE_LABEL_MAX_HEIGHT);
    [_messageLabel wrapTextWithConstrainedSize:cSize];
    
    if (_messageLabel.frame.size.height < MESSAGE_LABEL_MIN_HEIGHT) {
        [_messageLabel updateHeight:MESSAGE_LABEL_MIN_HEIGHT];
    }
    
    [_messageLabel updateCenterX:self.contentView.bounds.size.width/2];
}

- (IBAction)clickOkButton:(id)sender
{
    if (_clickOkBlock != nil) {
        _clickOkBlock([self infoView]);
    } else if (_delegate && [_delegate respondsToSelector:@selector(didClickOk:infoView:)]) {
        [_delegate didClickOk:self infoView:[self infoView]];
    }
    if (!_manualClose) {
        [self disappear];
    }
}

- (IBAction)clickCancelButton:(id)sender
{
    if (_clickCancelBlock != nil) {
        _clickCancelBlock([self infoView]);
    } else if (_delegate && [_delegate respondsToSelector:@selector(didClickCancel:)]) {
        [_delegate didClickCancel:self];
    }
    if (!_manualClose) {
        [self disappear];
    }
}

- (IBAction)clickCloseButton:(id)sender {

    if (_clickCloseBlock != nil) {
        _clickCloseBlock([self infoView]);
    } else if (_delegate && [_delegate respondsToSelector:@selector(didClickClose:)]) {
        [_delegate didClickClose:self];
    }
    
    if (!_manualClose) {
        [self disappear];
    }
}

- (void)disappear
{
    [super disappear];
    self.clickOkBlock = nil;
    self.clickCancelBlock = nil;
    self.textChangedCallback = nil;
    self.clickCloseBlock = nil;
}

+ (CGFloat)edgeWidth
{
    return CONTENT_VIEW_INSERT;
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

- (void)layoutSubviews
{
    PPDebug(@"<DialogBGView> layoutSubviews");
    [super layoutSubviews];
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