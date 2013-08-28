//
//  RoomController.h
//  Draw
//
//  Created by  on 12-3-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPViewController.h"
#import "DrawGameService.h"
#import "CommonDialog.h"
#import "ChatController.h"

enum{
    ROOM_DIALOG_QUIT_ROOM = 9001,
    ROOM_DIALOG_CHANGE_ROOM
};

@class UserManager;

@interface RoomController : PPViewController<DrawGameServiceDelegate, CommonDialogDelegate, ChatControllerDelegate, AvatarViewDelegate>
{
    int _currentTimeCounter;
    BOOL _hasClickStartGame;
    time_t quickDuration;
    int _clickCount;
    UIButton *popupButton;
    int _dialogAction;
    int _changeRoomTimes;
    
    UserManager *_userManager;
}
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;

@property (retain, nonatomic) IBOutlet UIButton *prolongButton;
@property (retain, nonatomic) IBOutlet UILabel *roomNameLabel;
@property (retain, nonatomic) IBOutlet UIButton *startGameButton;
@property (retain, nonatomic) NSTimer *startTimer;
@property (assign, nonatomic) int clickCount;
@property (assign, nonatomic) BOOL isFriendRoom;
@property (retain, nonatomic) IBOutlet UILabel *onlinePlayerCountLabel;
@property (retain, nonatomic) IBOutlet UIButton *changeRoomButton;
@property (retain, nonatomic) ChatController *privateChatController;
@property (retain, nonatomic) ChatController *groupChatController;
@property (retain, nonatomic) IBOutlet CommonTitleView *titleView;


- (IBAction)clickStart:(id)sender;
- (IBAction)clickChangeRoom:(id)sender;
- (IBAction)clickProlongStart:(id)sender;
- (IBAction)clickMenu:(id)sender;

// use this method when first enter room
// + (void)enterRoom:(UIViewController*)superController;

// use this method for returning from draw/guess to room
+ (void)returnRoom:(UIViewController*)superController startNow:(BOOL)startNow;

// use this method when enter room (don't know first enter or not)
+ (void)enterRoom:(UIViewController*)superController isFriendRoom:(BOOL)isFriendRoom;


@end
