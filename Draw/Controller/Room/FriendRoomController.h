//
//  FriendRoomController.h
//  Draw
//
//  Created by  on 12-5-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPTableViewController.h"
#import "RoomService.h"
#import "DrawGameService.h"
#import "RoomPasswordDialog.h"

@class UserManager;

@interface FriendRoomController : PPTableViewController<RoomServiceDelegate, DrawGameServiceDelegate,InputDialogDelegate>
{
    UserManager *_userManager;
    BOOL _isTryJoinGame;    
    Room *_currentSelectRoom;

    RoomService *roomService;

}
@property (retain, nonatomic) IBOutlet UIButton *editButton;
@property (retain, nonatomic) IBOutlet UIButton *createButton;
@property (retain, nonatomic) IBOutlet UIButton *searchButton;
- (IBAction)clickEditButton:(id)sender;
- (IBAction)clickCreateButton:(id)sender;
- (IBAction)clickSearchButton:(id)sender;
- (IBAction)clickMyFriendButton:(id)sender;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIButton *myFriendButton;
@property (retain, nonatomic) IBOutlet UILabel *noRoomTips;

@end
