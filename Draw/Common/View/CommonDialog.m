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
#import "DiceImageManager.h"
#import "LocaleUtils.h"
#import "CommonImageManager.h"
#import "UIImageUtil.h"
#import "ZJHImageManager.h"
#import "GameApp.h"

#define COMMON_DIALOG_THEME_DRAW    @"CommonDialog"
#define COMMON_DIALOG_THEME_DICE    @"CommonDiceDialog"
#define COMMON_DIALOG_THEME_STARRY    @"CommonStarryDialog"
#define COMMON_DIALOG_THEME_ZJH    @"CommonZJHDialog"

#define FONT_OF_TITLE_IPHONE [UIFont boldSystemFontOfSize:18]
#define FONT_OF_TITLE_IPAD [UIFont boldSystemFontOfSize:18*2]
#define FONT_OF_TITLE ([DeviceDetection isIPAD] ? (FONT_OF_TITLE_IPAD) : (FONT_OF_TITLE_IPHONE))

#define FONT_OF_MESSAGE_IPHONE [UIFont systemFontOfSize:14]
#define FONT_OF_MESSAGE_IPAD [UIFont systemFontOfSize:14*2]
#define FONT_OF_MESSAGE ([DeviceDetection isIPAD] ? (FONT_OF_MESSAGE_IPAD) : (FONT_OF_MESSAGE_IPHONE))

#define UP_SEPERATOR    ([DeviceDetection isIPAD]?14:7)
#define DOWN_SEPERATOR  ([DeviceDetection isIPAD]?52:26)

@implementation CommonDialog
@synthesize oKButton = _OKButton;
@synthesize backButton = _backButton;
@synthesize messageLabel = _messageLabel;
@synthesize titleLabel = _titleLabel;
@synthesize delegate = _delegate;
@synthesize contentBackground = _contentBackground;
@synthesize style = _style;

+ (CommonDialogTheme)globalGetTheme
{
    if (isDrawApp()) {
        return CommonDialogThemeDraw;
    }
    if (isDiceApp()) {
        return CommonDialogThemeDice;
    }
    return CommonDialogThemeDraw;
}
- (void)dealloc
{
    _delegate = nil;
    [_OKButton release];
    [_backButton release];
    [_messageLabel release];
    [_titleLabel release];
    [_contentBackground release];
    [_frontBackgroundImageView release];
    [_closeButton release];
    [super dealloc];
}

- (void)initStarryTheme
{
    _shouldResize = YES;
    [self.contentBackground setImage:[CommonImageManager defaultManager].starryDialogBackgroundImage];
    [self.frontBackgroundImageView setImage:[CommonImageManager defaultManager].starryDialogBackgroundSideImage];
    [self.oKButton setBackgroundImage:[CommonImageManager defaultManager].starryDialogButtonBackgroundImage forState:UIControlStateNormal];
    [self.backButton setBackgroundImage:[CommonImageManager defaultManager].starryDialogButtonBackgroundImage forState:UIControlStateNormal];
    [self.oKButton setImage:[UIImage shrinkImage:[CommonImageManager defaultManager].starryDialogClickImage withRate:0.8] forState:UIControlStateNormal];
    [self.backButton setImage:[UIImage shrinkImage:[CommonImageManager defaultManager].starryDialogCrossImage withRate:0.8] forState:UIControlStateNormal];
    
}

- (void)initTitlesWithTheme:(CommonDialogTheme)theme
{

}

- (void)initViewByTheme:(CommonDialogTheme)theme
{
    switch (theme) {
        case CommonDialogThemeStarry:
            [self initStarryTheme];
            break;
            
        default:
            break;
    }
}

- (CGSize) calculateHeightOfTextFromWidth:(NSString*)text font: (UIFont*)withFont width:(float)width linebreak:(UILineBreakMode)lineBreakMode{
	return [text sizeWithFont:withFont
			constrainedToSize:CGSizeMake(width, 960)
				lineBreakMode:lineBreakMode];
}

- (void)resize
{
    if (!_shouldResize) {
        return;
    }
    CGSize titleSize = [self calculateHeightOfTextFromWidth:self.titleLabel.text font:FONT_OF_TITLE width:self.titleLabel.frame.size.width linebreak:UILineBreakModeWordWrap];
    CGSize messageSize = [self calculateHeightOfTextFromWidth:self.messageLabel.text font:FONT_OF_TITLE width:self.messageLabel.frame.size.width linebreak:UILineBreakModeWordWrap];
    
    [self.contentView setFrame:CGRectMake(0, 0, self.contentView.frame.size.width, UP_SEPERATOR + DOWN_SEPERATOR + titleSize.height + messageSize.height + self.oKButton.frame.size.height)];
    [self.contentView setCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2)];
    
    [self.titleLabel setFrame:CGRectMake(self.contentView.frame.size.width/2 - titleSize.width/2, UP_SEPERATOR, titleSize.width, titleSize.height)];
    [self.messageLabel setFrame:CGRectMake(self.contentView.frame.size.width/2 - messageSize.width/2, UP_SEPERATOR + titleSize.height, messageSize.width, messageSize.height)];
    [self.messageLabel setFont:FONT_OF_MESSAGE];
    
    [self.oKButton setCenter:CGPointMake(self.oKButton.center.x, self.contentView.frame.size.height - DOWN_SEPERATOR - self.oKButton.frame.size.height/2)];
    [self.backButton setCenter:CGPointMake(self.backButton.center.x, self.contentView.frame.size.height - DOWN_SEPERATOR - self.backButton.frame.size.height/2)];
}

- (void)initButtonsWithTheme:(CommonDialogTheme)theme
{
    DiceImageManager* diceImgManager = [DiceImageManager defaultManager];
    ShareImageManager* imgManager = [ShareImageManager defaultManager];
    switch (theme) {
        case CommonDialogThemeDice: {
            //init the button
            [self.messageLabel setNumberOfLines:5];
            
            if ([LocaleUtils isChinese]) {
                [self.messageLabel setLineBreakMode:UILineBreakModeCharacterWrap];
            }else {
                [self.messageLabel setLineBreakMode:UILineBreakModeWordWrap];
            }
 
            [self.backButton.titleLabel setText:NSLS(@"kCancel")];
            [self.oKButton.titleLabel setText:NSLS(@"kOK")];

            [self.contentBackground setImage:[diceImgManager popupBackgroundImage]];
        } break;
        case CommonDialogThemeDraw:
            [self.oKButton setBackgroundImage:[imgManager redImage] forState:UIControlStateNormal];
            [self.backButton setBackgroundImage:[imgManager greenImage] forState:UIControlStateNormal];
            [self.oKButton setTitle:NSLS(@"kOK") forState:UIControlStateNormal];
            [self.backButton setTitle:NSLS(@"kCancel") forState:UIControlStateNormal];
        default:
            break;
    }
}

- (void)initView
{
    [self.messageLabel setNumberOfLines:5];
    
    if ([LocaleUtils isChinese]) {
        [self.messageLabel setLineBreakMode:UILineBreakModeCharacterWrap];
    }else {
        [self.messageLabel setLineBreakMode:UILineBreakModeWordWrap];
    }
    
    [self.oKButton setTitle:NSLS(@"kOK") forState:UIControlStateNormal];
    [self.backButton setTitle:NSLS(@"kCancel") forState:UIControlStateNormal];
    
    [self.contentBackground setImage:[[GameApp getImageManager] commonDialogBgImage]];
    
    [self.oKButton setBackgroundImage:[[GameApp getImageManager] commonDialogRightBtnImage] forState:UIControlStateNormal];
    [self.backButton setBackgroundImage:[[GameApp getImageManager] commonDialogLeftBtnImage] forState:UIControlStateNormal];
}

- (void)initButtonsWithStyle:(CommonDialogStyle)aStyle
{
//    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    self.style = aStyle;
    switch (aStyle) {
        case CommonDialogStyleSingleButton: {
            [self.oKButton setFrame:CGRectMake(self.oKButton.frame.origin.x, self.oKButton.frame.origin.y, self.oKButton.frame.size.width*2, self.oKButton.frame.size.height)];
            [self.oKButton setCenter:CGPointMake(self.contentView.frame.size.width/2, self.oKButton.frame.origin.y)];
            [self.backButton setHidden:YES];
            self.closeButton.hidden = YES;
        }
            break;
        case CommonDialogStyleDoubleButton: {
            self.closeButton.hidden = YES;
        }
            break;
        case CommonDialogStyleDoubleButtonWithCross: {
            self.closeButton.hidden = NO;
        } break;
        default:
            break;
    }
}

+ (CommonDialog *)createDialogWithStyle:(CommonDialogStyle)aStyle
{
    CommonDialog* view =  (CommonDialog*)[self createInfoViewByXibName:[GameApp getCommonDialogXibName]];
    [view initButtonsWithStyle:aStyle];
    [view initView];
    [view appear];
    view.tag = 0;
    return view;
    
}

+ (CommonDialog *)createDialogWithTheme:(CommonDialogTheme)theme
{
    CommonDialog* view;
    switch (theme) {
        case CommonDialogThemeDice: {
            view = (CommonDialog*)[self createInfoViewByXibName:COMMON_DIALOG_THEME_DICE]; 
        } break;
        case CommonDialogThemeDraw: {
            view = (CommonDialog*)[self createInfoViewByXibName:COMMON_DIALOG_THEME_DRAW];
        } break;
        case CommonDialogThemeStarry: {
            view = (CommonDialog*)[self createInfoViewByXibName:COMMON_DIALOG_THEME_STARRY];
        } break;
        case CommonDialogThemeZJH: {
            view = (CommonDialog*)[self createInfoViewByXibName:COMMON_DIALOG_THEME_ZJH];
            [view.contentBackground setImage:[ZJHImageManager defaultManager].ZJHUserInfoBackgroundImage];
        } break;
        default:
            PPDebug(@"<CommonDialog> theme %d do not exist",theme);
            view = nil;
    }   
    return view;
}

+ (CommonDialog *)createDialogWithStyle:(CommonDialogStyle)aStyle 
                                  theme:(CommonDialogTheme)theme
{

    CommonDialog* view = [self createDialogWithTheme:theme];
    if (view) {
        [view initButtonsWithStyle:aStyle];
        [view initButtonsWithTheme:theme];
        [view initTitlesWithTheme:theme];
        [view initViewByTheme:theme];
        view.tag = 0;
    }
    return view;
    
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
    [self resize];
}

- (IBAction)clickOk:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(clickOk:)]) {
        [_delegate clickOk:self];
    }
    if (_clickOkBlock != nil) {
        _clickOkBlock();
    }
    [self disappear];
}

- (IBAction)clickBack:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(clickBack:)]) {
        [_delegate clickBack:self];
    }
    if (_clickBackBlock != nil) {
        _clickBackBlock();
    }
    [self disappear];
}

- (IBAction)clickMask:(id)sender {
    
    if (_delegate && [_delegate respondsToSelector:@selector(clickMask:)]) {
        [_delegate clickMask:self];
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

- (void)setClickOkBlock:(DialogSelectionBlock)block
{
    [_clickOkBlock release];
    _clickOkBlock = [block copy];
}
- (void)setClickBackBlock:(DialogSelectionBlock)block
{
    [_clickBackBlock release];
    _clickBackBlock = [block copy];
}

+ (CommonDialog *)createDialogWithTitle:(NSString *)title
                                message:(NSString *)message
                                  style:(CommonDialogStyle)aStyle
                               delegate:(id<CommonDialogDelegate>)aDelegate
                           clickOkBlock:(DialogSelectionBlock)block1
                       clickCancelBlock:(DialogSelectionBlock)block2
{
    CommonDialog* dialog = [self createDialogWithTitle:title message:message style:aStyle delegate:aDelegate];
    [dialog setClickOkBlock:block1];
    [dialog setClickBackBlock:block2];
    return dialog;
}
+ (CommonDialog *)createDialogWithTitle:(NSString *)title
                                message:(NSString *)message
                                  style:(CommonDialogStyle)aStyle
                               delegate:(id<CommonDialogDelegate>)aDelegate
                                  theme:(CommonDialogTheme)theme
                           clickOkBlock:(DialogSelectionBlock)block1
                       clickCancelBlock:(DialogSelectionBlock)block2
{
    CommonDialog* dialog = [self createDialogWithTitle:title message:message style:aStyle delegate:aDelegate theme:theme];
    [dialog setClickOkBlock:block1];
    [dialog setClickBackBlock:block2];
    return dialog;
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
