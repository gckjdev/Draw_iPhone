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

enum{
    ROOM_DIALOG_QUIT_ROOM = 9001,
    ROOM_DIALOG_CHANGE_ROOM
};

@class UserManager;

@interface RoomController : PPViewController<DrawGameServiceDelegate, CommonDialogDelegate>
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

@property (retain, nonatomic) IBOutlet UIButton *prolongButton;
@property (retain, nonatomic) IBOutlet UILabel *roomNameLabel;
@property (retain, nonatomic) IBOutlet UIButton *startGameButton;
@property (retain, nonatomic) NSTimer *startTimer;
@property (assign, nonatomic) int clickCount;
@property (retain, nonatomic) IBOutlet UILabel *onlinePlayerCountLabel;

- (IBAction)clickStart:(id)sender;
- (IBAction)clickChangeRoom:(id)sender;
- (IBAction)clickProlongStart:(id)sender;
- (IBAction)clickMenu:(id)sender;

// use this method when first enter room
+ (void)firstEnterRoom:(UIViewController*)superController;

// use this method for returning from draw/guess to room
+ (void)returnRoom:(UIViewController*)superController startNow:(BOOL)startNow;

@end
