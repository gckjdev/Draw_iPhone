//
//  RoomPasswordDialog.h
//  Draw
//
//  Created by  on 12-5-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "InputDialog.h"

@class CustomUITextField;

#define ROOM_PASSWORD_DIALOG    @"RoomPasswordDialog"
#define DICE_ROOM_PASSWORD_DIALOG   @"DiceRoomPasswordDialog"
#define ZJH_ROOM_PASSWORD_DIALOG   @"ZJHRoomPasswordDialog"

@interface RoomPasswordDialog : InputDialog
@property (retain, nonatomic) IBOutlet CustomUITextField *passwordField;
@property (retain, nonatomic) IBOutlet UILabel *roomNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *passwordLabel;
@property (assign, nonatomic) BOOL isPasswordOptional;
@property (retain, nonatomic) IBOutlet UIImageView *contentBackground;


+ (RoomPasswordDialog *)dialogWith:(NSString *)title 
                          delegate:(id<InputDialogDelegate>)delegate;
+ (RoomPasswordDialog *)dialogWith:(NSString *)title 
                          delegate:(id<InputDialogDelegate>)delegate 
                             theme:(CommonInputDialogTheme)theme;

@end
