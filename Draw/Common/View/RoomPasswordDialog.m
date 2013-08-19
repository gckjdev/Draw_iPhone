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
#import "DiceImageManager.h"
#import "ZJHImageManager.h"
#import "CustomUITextField.h"
#import "AutoCreateViewByXib.h"

@implementation RoomPasswordDialog

AUTO_CREATE_VIEW_BY_XIB(RoomPasswordDialog)

- (void)dealloc {
    PPRelease(_passwordField);
    PPRelease(_roomNameField);
    PPRelease(_roomNameLabel);
    PPRelease(_passwordLabel);

    [super dealloc];
}

+ (id)create{
    
    RoomPasswordDialog *view = [RoomPasswordDialog createView];
    
    [view.passwordField setPlaceholder:NSLS(@"kRoomPasswordHolder")];
    [view.roomNameField setPlaceholder:NSLS(@"kRoomNameHolder")];
    view.roomNameLabel.text = NSLS(@"kRoomNameLabel");
    view.passwordLabel.text = NSLS(@"kRoomPasswordLabel");
    return view;
}

//- (BOOL)isPasswordIllegal
//{
//
//    return [self.passwordField.text length] < 1;
//}

- (BOOL)isRoomNameIllegal
{
    return [self.roomNameField.text length] < 1;
}

- (void)textFieldsResignFirstResponder
{
    [self.passwordField resignFirstResponder];
    [self.roomNameField resignFirstResponder];
}

- (void)handleRoomNameIllegal
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(roomNameIsIllegal)]) {
        [self.delegate roomNameIsIllegal];
    }
    [self.roomNameField becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.roomNameField) {
        if ([self isRoomNameIllegal]) {
            [self handleRoomNameIllegal];
        }else{
            [textField resignFirstResponder];
        }
    }else if(textField == self.passwordField)
    {
        [textField resignFirstResponder];
    }
    return YES;
}

@end
