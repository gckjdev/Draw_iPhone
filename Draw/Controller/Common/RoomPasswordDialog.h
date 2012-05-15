//
//  RoomPasswordDialog.h
//  Draw
//
//  Created by  on 12-5-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "InputDialog.h"

@interface RoomPasswordDialog : InputDialog
@property (retain, nonatomic) IBOutlet UITextField *passwordField;
@property (retain, nonatomic) IBOutlet UILabel *roomNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *passwordLabel;


+ (RoomPasswordDialog *)dialogWith:(NSString *)title delegate:(id<InputDialogDelegate>)delegate;

@end
