//
//  RoomPasswordDialog.m
//  Draw
//
//  Created by  on 12-5-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RoomPasswordDialog.h"
#import "ShareImageManager.h"
#import "AnimationManager.h"
#import "FontButton.h"
#import "DiceImageManager.h"
#import "ZJHImageManager.h"


@implementation RoomPasswordDialog
@synthesize passwordField;
@synthesize roomNameLabel;
@synthesize passwordLabel;
@synthesize isPasswordOptional = _isPasswordOptional;
@synthesize contentBackground;

+ (CommonInputDialogTheme)getTheme
{
    if (isDrawApp()) {
        return CommonInputDialogThemeDraw;
    }
    if (isDiceApp()) {
        return CommonInputDialogThemeZJH;
    }
    if (isZhajinhuaApp()) {
        return CommonInputDialogThemeZJH;
    }
    return CommonInputDialogThemeDraw;
}

- (void)initByDraw:(NSString*)title
{
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    float fontSize = [DeviceDetection isIPAD] ? 40 : 20;
    
    [self.targetTextField setBackground:[imageManager inputImage]];
    [self setDialogTitle:title];
    [self.cancelButton setBackgroundImage:[imageManager greenImage] forState:UIControlStateNormal];
    [self.cancelButton setTitle:NSLS(@"kCancel") forState:UIControlStateNormal];
    [self.okButton setTitle:NSLS(@"kOK") forState:UIControlStateNormal];
    [self.okButton setBackgroundImage:[imageManager redImage] forState:UIControlStateNormal];
    self.titleLabel.titleLabel.font = [UIFont boldSystemFontOfSize:fontSize];
    self.titleLabel.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
    [self.targetTextField setBackground:[imageManager inputImage]];
    [self.passwordField setBackground:[imageManager inputImage]];
}

- (void)initByZJH:(NSString*)title
{
    ZJHImageManager*  zjhImgManager = [ZJHImageManager defaultManager];
    float fontSize = [DeviceDetection isIPAD] ? 40 : 20;
    
    [self.contentBackground setImage:zjhImgManager.dialogBgImage];
    self.isPasswordOptional = YES;
    [self.titleLabel setTitle:title forState:UIControlStateNormal];
    
    [self.okButton setBackgroundImage:zjhImgManager.dialogBtnImage forState:UIControlStateNormal];
    [self.okButton.titleLabel setFont:[UIFont systemFontOfSize:fontSize]];
    
    [self.cancelButton setBackgroundImage:zjhImgManager.dialogBtnImage forState:UIControlStateNormal];
    [self.cancelButton.titleLabel setFont:[UIFont systemFontOfSize:fontSize]];
    
    [self.cancelButton setTitle:NSLS(@"kCancel") forState:UIControlStateNormal];
    [self.okButton setTitle:NSLS(@"kOK") forState:UIControlStateNormal];
    self.titleLabel.titleLabel.font = [UIFont boldSystemFontOfSize:fontSize];
    self.titleLabel.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
    [self.targetTextField setBackground:[zjhImgManager inputDialogBgImage]];
    [self.passwordField setBackground:[zjhImgManager inputDialogBgImage]];
}

- (void)initByDice:(NSString*)title
{
    DiceImageManager* diceImgManager = [DiceImageManager defaultManager];
    float fontSize = [DeviceDetection isIPAD] ? 40 : 20;
    
    [self.contentBackground setImage:[DiceImageManager defaultManager].helpBackgroundImage];
    self.isPasswordOptional = YES;
    [self.targetTextField setBackground:[diceImgManager inputBackgroundImage]];
    [self.titleLabel.fontLable setText:title];
    
//    [self.okButton setRoyButtonWithColor:[UIColor colorWithRed:120.0/255.0 green:230.0/255.0 blue:160.0/255.0 alpha:0.95]];
//    [self.cancelButton setRoyButtonWithColor:[UIColor colorWithRed:236.0/255.0 green:247.0/255.0 blue:63.0/255.0 alpha:0.95]];
    
    [self.cancelButton.fontLable setText:NSLS(@"kCancel")];
    [self.okButton.fontLable setText:NSLS(@"kOK")];
    self.titleLabel.fontLable.font = [UIFont boldSystemFontOfSize:fontSize];
    self.titleLabel.fontLable.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.fontLable.lineBreakMode = UILineBreakModeTailTruncation;
    [self.targetTextField setBackground:[diceImgManager inputBackgroundImage]];
    [self.passwordField setBackground:[diceImgManager inputBackgroundImage]];
}

- (void)initWithTheme:(CommonInputDialogTheme)theme title:(NSString*)title
{
    switch (theme) {
        case CommonInputDialogThemeZJH: {
            [self initByZJH:title];
        } break;
        case CommonInputDialogThemeDice:{
            [self initByDice:title];
            
        } break;
        case CommonInputDialogThemeDraw: 
        default: {
            [self initByDraw:title];
        }break;
    }
    [self.targetTextField setPlaceholder:NSLS(@"kNicknameHolder")];
    [self.passwordField setPlaceholder:NSLS(@"kRoomPasswordHolder")];
    [self.targetTextField setPlaceholder:NSLS(@"kRoomNameHolder")];
    self.roomNameLabel.text = NSLS(@"kRoomNameLabel");
    self.passwordLabel.text = NSLS(@"kRoomPasswordLabel");
}

- (void)initView:(NSString*)title
{
//    float fontSize = [DeviceDetection isIPAD] ? 40 : 20;
    
    [self.contentBackground setImage:[[GameApp getImageManager] inputDialogBgImage]];
    self.isPasswordOptional = YES;
    [self.titleLabel setTitle:title forState:UIControlStateNormal];
    
    [self.okButton setBackgroundImage:[[GameApp getImageManager] inputDialogRightBtnImage]forState:UIControlStateNormal];
//    [self.okButton.titleLabel setFont:[UIFont systemFontOfSize:fontSize]];
    
    [self.cancelButton setBackgroundImage:[[GameApp getImageManager] inputDialogLeftBtnImage] forState:UIControlStateNormal];
//    [self.cancelButton.titleLabel setFont:[UIFont systemFontOfSize:fontSize]];
    
    [self.cancelButton setTitle:NSLS(@"kCancel") forState:UIControlStateNormal];
    [self.okButton setTitle:NSLS(@"kOK") forState:UIControlStateNormal];
//    self.titleLabel.titleLabel.font = [UIFont boldSystemFontOfSize:fontSize];
    self.titleLabel.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
    [self.targetTextField setBackground:[[GameApp getImageManager] inputDialogInputBgImage]];
    [self.passwordField setBackground:[[GameApp getImageManager] inputDialogInputBgImage]];
    
    [self.targetTextField setPlaceholder:NSLS(@"kNicknameHolder")];
    [self.passwordField setPlaceholder:NSLS(@"kRoomPasswordHolder")];
    [self.targetTextField setPlaceholder:NSLS(@"kRoomNameHolder")];
    self.roomNameLabel.text = NSLS(@"kRoomNameLabel");
    self.passwordLabel.text = NSLS(@"kRoomPasswordLabel");
}

- (void)updateTextFields
{
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    [self.targetTextField setBackground:[imageManager inputImage]];
    [self.passwordField setBackground:[imageManager inputImage]];
    

    [self.passwordField setPlaceholder:NSLS(@"kRoomPasswordHolder")];
    [self.targetTextField setPlaceholder:NSLS(@"kRoomNameHolder")];
}

+ (RoomPasswordDialog *)dialogWith:(NSString *)title delegate:(id<InputDialogDelegate>)delegate
{
    RoomPasswordDialog* view = (RoomPasswordDialog*)[self createInfoViewByXibName:[GameApp getRoomPasswordDialogXibName]];
    [view initView:title];
    view.delegate = delegate;
    return view;
}

+ (RoomPasswordDialog *)createDialogWithTheme:(CommonInputDialogTheme)theme
{
    RoomPasswordDialog* view;
    switch (theme) {
        case CommonInputDialogThemeDice: {
            view = (RoomPasswordDialog*)[self createInfoViewByXibName:DICE_ROOM_PASSWORD_DIALOG]; 
        } break;
        case CommonInputDialogThemeDraw: {
            view = (RoomPasswordDialog*)[self createInfoViewByXibName:ROOM_PASSWORD_DIALOG];
        } break;
        case CommonInputDialogThemeZJH: {
            view = (RoomPasswordDialog*)[self createInfoViewByXibName:ZJH_ROOM_PASSWORD_DIALOG];
            [view.bgView setImage:[ZJHImageManager defaultManager].ZJHUserInfoBackgroundImage];
        } break;
        default:
            PPDebug(@"<RoomPasswordDialog> theme %d do not exist",theme);
            view = nil;
    }   
    return view;
}


+ (RoomPasswordDialog *)dialogWith:(NSString *)title 
                          delegate:(id<InputDialogDelegate>)delegate 
                             theme:(CommonInputDialogTheme)theme
{
    RoomPasswordDialog* view = [self createDialogWithTheme:theme];
    if (view) {

        [view initWithTheme:theme title:title];

        view.delegate = delegate;
        
    }
    return view;
}

- (void)decreaseView:(UIView *)view height:(CGFloat)height
{
    CGFloat x = view.frame.origin.x;
    CGFloat y = view.frame.origin.y; 
    CGFloat width = view.frame.size.width;
    CGFloat nHeight = view.frame.size.height - height;
    view.frame = CGRectMake(x, y, width, nHeight);
}


- (void)upView:(UIView *)view height:(CGFloat)height
{
    
    CGFloat y = view.center.y - height;
    view.center = CGPointMake(view.center.x, y);
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    NSString* value = [anim valueForKey:@"AnimationKey"];
    if ([value isEqualToString:@"runOut"]) {
        [self setHidden:YES];
        [self removeFromSuperview];
    }else{
        [self.passwordField becomeFirstResponder];
    }
    
}



- (BOOL)isPasswordIllegal
{

    return [self.passwordField.text length] < 1;
}

- (BOOL)isRoomNameIllegal
{
    return [self.targetTextField.text length] < 1;
}

- (void)textFieldsResignFirstResponder
{
    [self.passwordField resignFirstResponder];
    [self.targetTextField resignFirstResponder];
}


- (void)handlePasswordIllegal
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(passwordIsIllegal:)]) {
        [self.delegate passwordIsIllegal:self.passwordField.text];
    }
    [self.passwordField becomeFirstResponder];
}

- (void)handleRoomNameIllegal
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(roomNameIsIllegal:)]) {
        [self.delegate roomNameIsIllegal:self.passwordField.text];
    }
    [self.targetTextField becomeFirstResponder];
}


- (IBAction)clickOkButton:(id)sender {
    
    if ([self isRoomNameIllegal]) 
    {
        [self handleRoomNameIllegal];
    }else if([self isPasswordIllegal] && !_isPasswordOptional)
    {
        [self handlePasswordIllegal];
    }else{
        [self disappear];
        [self textFieldsResignFirstResponder];
        if (self.delegate && [self.delegate respondsToSelector:@selector(didClickOk:targetText:)])
        {
            [self.delegate didClickOk:self targetText:self.targetTextField.text];
        }
    }
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.targetTextField) {
        if ([self isRoomNameIllegal]) {
            [self handleRoomNameIllegal];
        }else{
            [textField resignFirstResponder];
        }
    }else if(textField == self.passwordField)
    {
        if ([self isPasswordIllegal]) {
            [self handlePasswordIllegal];
        }else{
            [textField resignFirstResponder];
        }
        [self clickOkButton:self.okButton];
    }
    return YES;
}

- (void)dealloc {
    PPRelease(passwordField);
    PPRelease(roomNameLabel);
    PPRelease(passwordLabel);
    PPRelease(contentBackground);
    [super dealloc];
}
@end
