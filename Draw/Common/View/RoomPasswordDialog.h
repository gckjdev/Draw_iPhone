//
//  RoomPasswordDialog.h
//  Draw
//
//  Created by  on 12-5-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#define ROOM_PASSWORD_DIALOG    @"RoomPasswordDialog"
#define DICE_ROOM_PASSWORD_DIALOG   @"DiceRoomPasswordDialog"
#define ZJH_ROOM_PASSWORD_DIALOG   @"ZJHRoomPasswordDialog"

@protocol RoomPasswordDialogDelegate <NSObject>


- (void)roomNameIsIllegal;


@end

@interface RoomPasswordDialog : UIView

@property (assign, nonatomic) id<RoomPasswordDialogDelegate> delegate;

@property (retain, nonatomic) IBOutlet UITextField *passwordField;
@property (retain, nonatomic) IBOutlet UITextField *roomNameField;
@property (retain, nonatomic) IBOutlet UILabel *roomNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *passwordLabel;
@property (assign, nonatomic) BOOL isPasswordOptional;


+ (id)create;

- (BOOL)isRoomNameIllegal;


@end
