//
//  ZJHGameController.m
//  Draw
//
//  Created by 王 小涛 on 12-10-24.
//
//

#import "ZJHGameController.h"
#import "ZJHGameService.h"
#import "LevelService.h"
#import "UserManager.h"
#import "AudioManager.h"
#import "AccountService.h"
#import "ZJHImageManager.h"


#define NOTIFICATION_NEXT_PLAYER_START @""
#define NOTIFICATION_ROLL_DICE_BEGIN    @""

@interface ZJHGameController ()

- (void)roomChanged;

@end

@implementation ZJHGameController

- (id)init
{
    self = [super init];
    if (self) {
        _gameService = [ZJHGameService defaultService];
        _userManager = [UserManager defaultManager];
        _imageManager = [ZJHImageManager defaultManager];
        _levelService = [LevelService defaultService];
        _accountService = [AccountService defaultService];
        _audioManager = [AudioManager defaultManager];

    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}



#pragma mark - Register notifications.

- (void)registerZJHGameNotificationWithName:(NSString *)name
                                  usingBlock:(void (^)(NSNotification *note))block
{
    PPDebug(@"<%@> name", [self description]);
    
    [self registerNotificationWithName:name
                                object:nil
                                 queue:[NSOperationQueue mainQueue]
                            usingBlock:block];
}

- (void)registerDiceGameNotifications
{
    [self registerZJHGameNotificationWithName:NOTIFICATION_JOIN_GAME_RESPONSE
                                    usingBlock:^(NSNotification *notification) {
                                    }];
    
    
    [self registerZJHGameNotificationWithName:NOTIFICATION_ROOM
                                    usingBlock:^(NSNotification *notification) {
                                        [self roomChanged];
                                    }];
    
    [self registerZJHGameNotificationWithName:NOTIFICATION_NEXT_PLAYER_START
                                    usingBlock:^(NSNotification *notification) {

                                    }];
    
    [self registerZJHGameNotificationWithName:NOTIFICATION_ROLL_DICE_BEGIN
                                    usingBlock:^(NSNotification *notification) {
                                    }];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma player action

- (IBAction)bet:(id)sender
{
    
}

- (IBAction)raiseBet:(id)sender
{
    
}

- (IBAction)autoBet:(id)sender
{
    
}

- (IBAction)compareCard:(id)sender
{
    
}

- (IBAction)checkCard:(id)sender
{
    
}

- (IBAction)foldCard:(id)sender
{
    
}

- (IBAction)showCard:(id)sender
{
    
}

#pragma mark - private method

- (void)updateAllPlayersAvatar
{
   
}


- (void)updateWaittingForNextTurnNotLabel
{
    
}

- (void)roomChanged
{
    [self updateAllPlayersAvatar];
    [self updateWaittingForNextTurnNotLabel];
}

- (void)someOneBet:(GamePosition)position
{
    
}

- (void)someOneShowCard:(GamePosition)position
{
    
}

- (void)someOne:(GamePosition)player
    compareWith:(GamePosition)otherPlayer
{
    
}

- (void)someOneRaiseBet:(GamePosition)position
{
    
}

- (void)someOneAutoBet:(GamePosition)position
{
    
}

- (void)someOneCheckCard:(GamePosition)position
{
    
}

- (void)someOneFoldCard:(GamePosition)position
{
    
}

- (void)updateAllPlayers
{
    
}

@end
