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

- (void)initWithTheme:(CommonInputDialogTheme)theme title:(NSString*)title
{
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    DiceImageManager* diceImgManager = [DiceImageManager defaultManager];
    float fontSize = [DeviceDetection isIPAD] ? 40 : 20;
    switch (theme) {
        case CommonInputDialogThemeZJH:
        case CommonInputDialogThemeDice:{
            [self.contentBackground setImage:[DiceImageManager defaultManager].helpBackgroundImage];
            if (theme == CommonInputDialogThemeZJH) {
                [self.contentBackground setImage:[ZJHImageManager defaultManager].ZJHUserInfoBackgroundImage];
            }
            self.isPasswordOptional = YES;
            [self.targetTextField setBackground:[diceImgManager inputBackgroundImage]];
            [self.titleLabel.fontLable setText:title];
            
            [self.okButton setRoyButtonWithColor:[UIColor colorWithRed:120.0/255.0 green:230.0/255.0 blue:160.0/255.0 alpha:0.95]];
            [self.cancelButton setRoyButtonWithColor:[UIColor colorWithRed:236.0/255.0 green:247.0/255.0 blue:63.0/255.0 alpha:0.95]];
            
            [self.cancelButton.fontLable setText:NSLS(@"kCancel")];
            [self.okButton.fontLable setText:NSLS(@"kOK")];
            self.titleLabel.fontLable.font = [UIFont boldSystemFontOfSize:fontSize];
            self.titleLabel.fontLable.adjustsFontSizeToFitWidth = YES;
            self.titleLabel.fontLable.lineBreakMode = UILineBreakModeTailTruncation;
            [self.targetTextField setBackground:[diceImgManager inputBackgroundImage]];
            [self.passwordField setBackground:[diceImgManager inputBackgroundImage]];
            
        } break;
        case CommonInputDialogThemeDraw: 
        default: {
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
        }break;
    }
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
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"RoomPasswordDialog" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create <RoomPasswordDialog> but cannot find cell object from Nib");
        return nil;
    }
    RoomPasswordDialog* view =  (RoomPasswordDialog*)[topLevelObjects objectAtIndex:0];
    
    //init the button
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    
    [view updateTextFields];
    
    [view setDialogTitle:title];
    
    [view.cancelButton setBackgroundImage:[imageManager greenImage] forState:UIControlStateNormal];
    [view.cancelButton setTitle:NSLS(@"kCancel") forState:UIControlStateNormal];
    [view.okButton setTitle:NSLS(@"kOK") forState:UIControlStateNormal];
    [view.okButton setBackgroundImage:[imageManager redImage] forState:UIControlStateNormal];
    view.delegate = delegate;
    view.roomNameLabel.text = NSLS(@"kRoomNameLabel");
    view.passwordLabel.text = NSLS(@"kRoomPasswordLabel");
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
        //init the button
        [view initWithTheme:theme title:title];
//        ShareImageManager *imageManager = [ShareImageManager defaultManager];
//        
//        [view updateTextFields];
//        
//        [view setDialogTitle:title];
//        
//        [view.cancelButton setBackgroundImage:[imageManager greenImage] forState:UIControlStateNormal];
//        [view.cancelButton setTitle:NSLS(@"kCancel") forState:UIControlStateNormal];
//        [view.okButton setTitle:NSLS(@"kOK") forState:UIControlStateNormal];
//        [view.okButton setBackgroundImage:[imageManager redImage] forState:UIControlStateNormal];
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
    [passwordField release];
    [roomNameLabel release];
    [passwordLabel release];
    [contentBackground release];
    [super dealloc];
}
@end
