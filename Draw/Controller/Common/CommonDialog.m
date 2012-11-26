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
#import "FontButton.h"
#import "LocaleUtils.h"

#define COMMON_DIALOG_THEME_DRAW    @"CommonDialog"
#define COMMON_DIALOG_THEME_DICE    @"CommonDiceDialog"
#define COMMON_DIALOG_THEME_STARRY    @"CommonStarryDialog"

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
    [super dealloc];
}

- (void)initTitlesWithTheme:(CommonDialogTheme)theme
{

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
 
            [self.backButton.fontLable setText:NSLS(@"kCancel")];
            [self.oKButton.fontLable setText:NSLS(@"kOK")];

            [self.contentBackground setImage:[diceImgManager popupBackgroundImage]];
            [self.oKButton setRoyButtonWithColor:[UIColor colorWithRed:244.0/255.0 green:93.0/255.0 blue:93.0/255.0 alpha:0.95]];
            [self.backButton setRoyButtonWithColor:[UIColor colorWithRed:236.0/255.0 green:247.0/255.0 blue:63.0/255.0 alpha:0.95]];
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

- (void)initButtonsWithStyle:(CommonDialogStyle)aStyle
{
//    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    self.style = aStyle;
    switch (aStyle) {
        case CommonDialogStyleSingleButton: {
            [self.oKButton setFrame:CGRectMake(self.oKButton.frame.origin.x, self.oKButton.frame.origin.y, self.oKButton.frame.size.width*2, self.oKButton.frame.size.height)];
            [self.oKButton setCenter:CGPointMake(self.contentView.frame.size.width/2, self.oKButton.frame.origin.y)];
//            [self.oKButton setBackgroundImage:[imageManager greenImage] forState:UIControlStateNormal];
            [self.backButton setHidden:YES];
        }
            break;
        case CommonDialogStyleDoubleButton: {
//            [self.oKButton setBackgroundImage:[imageManager redImage] forState:UIControlStateNormal];
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
    [view initButtonsWithTheme:[CommonDialog globalGetTheme]];
    [view appear];
    
    //init the button
//    ShareImageManager *imageManager = [ShareImageManager defaultManager];
//    [view.backButton setBackgroundImage:[imageManager greenImage] forState:UIControlStateNormal];
    [view.backButton setTitle:NSLS(@"kCancel") forState:UIControlStateNormal];
    [view.oKButton setTitle:NSLS(@"kOK") forState:UIControlStateNormal];
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
        view.tag = 0;
    }
    return view;
    
}


+ (CommonDialog *)createDialogWithTitle:(NSString *)title 
                                message:(NSString *)message 
                                  style:(CommonDialogStyle)aStyle 
                               delegate:(id<CommonDialogDelegate>)aDelegate
{
    CommonDialog* view = [CommonDialog createDialogWithStyle:aStyle theme:[self globalGetTheme]];
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
