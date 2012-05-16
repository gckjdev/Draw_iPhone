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

@implementation RoomPasswordDialog
@synthesize passwordField;
@synthesize roomNameLabel;
@synthesize passwordLabel;


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
    }else if([self isPasswordIllegal])
    {
        [self handlePasswordIllegal];
    }else{
        [self startRunOutAnimation];
        [self textFieldsResignFirstResponder];
        if (self.delegate && [self.delegate respondsToSelector:@selector(clickOk:targetText:)])
        {
            [self.delegate clickOk:self targetText:self.targetTextField.text];
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
    [super dealloc];
}
@end
