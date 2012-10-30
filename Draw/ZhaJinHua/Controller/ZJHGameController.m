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
#import "ZJHAvatarView.h"
#import "CommonGameSession.h"
#import "ZJHPokerView.h"
#import "ZJHUserInfo.h"
#import "GameMessage.pb.h"

#define AVATAR_TAG_OFFSET   8000
#define POKERS_TAG_OFFSET   2000
#define MAX_PLAYER_COUNT    5
#define NOTIFICATION_NEXT_PLAYER_START @""
#define NOTIFICATION_GAME_BEGIN    @""

@interface ZJHGameController ()

- (void)roomChanged;
- (ZJHPokerView*)getSelfPokersView;

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
    [self registerDiceGameNotifications];
    [self updateAllPlayersAvatar];
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

- (GameMessage *)messageFromNotification:(NSNotification *)notification
{
    return [CommonGameNetworkService userInfoToMessage:notification.userInfo];
}

- (NSString *)userIdOfNotification:(NSNotification *)notification
{
    return [[self messageFromNotification:notification] userId];
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
    
    [self registerZJHGameNotificationWithName:NOTIFICATION_GAME_START_NOTIFICATION_REQUEST
                                   usingBlock:^(NSNotification *notification) {
                                       [self gameStart];
                                   }];
    
    [self registerZJHGameNotificationWithName:NOTIFICATION_NEXT_PLAYER_START
                                    usingBlock:^(NSNotification *notification) {
                                        NSString* userId = [[self messageFromNotification:notification] currentPlayUserId];
                                        [self nextPlayerStart:[self getPositionByUserId:userId]];
                                    }];
    
    [self registerZJHGameNotificationWithName:NOTIFICATION_BET_REQUEST
                                   usingBlock:^(NSNotification *notification) {
                                       [self someoneBet:[self getPositionByUserId:[self userIdOfNotification:notification]]];
                                   }];
    
    [self registerZJHGameNotificationWithName:NOTIFICATION_BET_RESPONSE
                                   usingBlock:^(NSNotification *notification) {
                                       [self betSuccess];
                                   }];
    
    [self registerZJHGameNotificationWithName:NOTIFICATION_CHECK_CARD_REQUEST
                                   usingBlock:^(NSNotification *notification) {
                                       [self someoneCheckCard:[self getPositionByUserId:[self userIdOfNotification:notification]]];
                                   }];
    
    [self registerZJHGameNotificationWithName:NOTIFICATION_CHECK_CARD_RESPONSE
                                   usingBlock:^(NSNotification *notification) {
                                       [self checkCardSuccess];
                                   }];
    
    [self registerZJHGameNotificationWithName:NOTIFICATION_FOLD_CARD_REQUEST
                                   usingBlock:^(NSNotification *notification) {
                                       [self someoneFoldCard:[self getPositionByUserId:[self userIdOfNotification:notification]]];
                                   }];
    
    [self registerZJHGameNotificationWithName:NOTIFICATION_FOLD_CARD_RESPONSE
                                   usingBlock:^(NSNotification *notification) {
                                       [self foldCardSuccess];
                                   }];
    
    [self registerZJHGameNotificationWithName:NOTIFICATION_SHOW_CARD_REQUEST
                                   usingBlock:^(NSNotification *notification) {
                                       [self someoneShowCard:[self getPositionByUserId:[self userIdOfNotification:notification]]];
                                   }];
    
    [self registerZJHGameNotificationWithName:NOTIFICATION_SHOW_CARD_RESPONSE
                                   usingBlock:^(NSNotification *notification) {
                                       [self showCardSuccess];
                                   }];
    
    [self registerZJHGameNotificationWithName:NOTIFICATION_COMPARE_CARD_REQUEST
                                   usingBlock:^(NSNotification *notification) {
                                       NSString *userId = [self userIdOfNotification:notification];
                                       NSString *toUserId = [[[self messageFromNotification:notification] compareCardRequest] toUserId];
                                       
                                       [self someone:[self getPositionByUserId:userId]
                                     compareCardWith:[self getPositionByUserId:toUserId]];
                                   }];
                                       
    
    [self registerZJHGameNotificationWithName:NOTIFICATION_COMPARE_CARD_RESPONSE
                                   usingBlock:^(NSNotification *notification) {
                                       [self compareCardSuccess];
                                   }];    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

}

#pragma mark - player action

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
    ZJHPokerView* pokers = [self getSelfPokersView];
    [pokers faceupCards:YES];
}

- (IBAction)foldCard:(id)sender
{
    
}

- (IBAction)showCard:(id)sender
{
    
}

- (IBAction)clickQuitButton:(id)sender
{
    [self quitGame];
}

#pragma mark - player action response

- (void)betSuccess
{
    
}

- (void)checkCardSuccess
{
}

- (void)foldCardSuccess
{
}

- (void)showCardSuccess
{
}

- (void)compareCardSuccess
{
}

#pragma mark - service notification request

- (void)roomChanged
{
    [self updateAllPlayersAvatar];
    [self updateWaittingForNextTurnNotLabel];
}

- (void)gameStart
{
    PPDebug(@"<ZJHGameController> game start!");
    [self updateAllPokers];
    
}

- (void)nextPlayerStart:(UserPosition)position
{
    
}

- (void)someoneBet:(UserPosition)position
{
    

}

- (void)someoneShowCard:(UserPosition)position
{
    
}

- (void)someone:(UserPosition)player
compareCardWith:(UserPosition)otherPlayer
{
    
}

- (void)someoneRaiseBet:(UserPosition)position
{
    
}

- (void)someoneAutoBet:(UserPosition)position
{
    
}

- (ZJHPokerSectorType)getPokerSectorTypeByPosition:(UserPosition)position
{
    switch (position) {
        case UserPositionLeft:
        case UserPositionLeftTop:
            return ZJHPokerSectorTypeLeft;
            break;
            
        case UserPositionRight:
        case UserPositionRightTop:
            return ZJHPokerSectorTypeRight;
            break;
            
        default:
            return ZJHPokerSectorTypeNone;
            break;
    }
}

- (void)someoneCheckCard:(UserPosition)position
{
    ZJHPokerView *view = [self getPokersViewByPosition:position];
    
    [view makeSectorShape:[self getPokerSectorTypeByPosition:position] animation:YES];
}

- (void)someoneFoldCard:(UserPosition)position
{
    
    
}

#pragma mark - private method

- (PBGameUser*)getSelfUser
{
    return [_gameService.session getUserByUserId:_userManager.userId];
}

- (void)updateAllPlayersAvatar
{
    PBGameUser* selfUser = [self getSelfUser];
    
    //init seats
    for (int i = 1; i <= MAX_PLAYER_COUNT; i ++) {
        ZJHAvatarView* avatar = (ZJHAvatarView*)[self.view viewWithTag:AVATAR_TAG_OFFSET+i];
        [avatar resetAvatar];
    }
    
    // set user on seat
    NSArray* userList = _gameService.session.userList;
    for (PBGameUser* user in userList) {
        //        PPDebug(@"<test>get user--%@, sitting at %d",user.nickName, user.seatId);
        int seat = user.seatId;
        int seatIndex = (MAX_PLAYER_COUNT + selfUser.seatId - seat) % MAX_PLAYER_COUNT + 1;
        ZJHAvatarView* avatar = (ZJHAvatarView*)[self.view viewWithTag:AVATAR_TAG_OFFSET+seatIndex];
        [avatar setUserInfo:user];
    }
}

- (void)updateAllPokers
{
    for (int i = 1; i <= MAX_PLAYER_COUNT; i ++) {
        ZJHAvatarView* avatar = (ZJHAvatarView*)[self.view viewWithTag:AVATAR_TAG_OFFSET+i];
        ZJHPokerView* pokerView = (ZJHPokerView*)[self.view viewWithTag:POKERS_TAG_OFFSET+i];
        
        [pokerView clearPokerViews];
        if (avatar.userInfo) {
            [pokerView updatePokerViewsWithPokers:[[_gameService userInfo:avatar.userInfo.userId] pokers]];
        } else {
            [pokerView updatePokerViewsWithPokers:[[_gameService userInfo:_userManager.userId] pokers]];
        }
    }
}


- (void)updateWaittingForNextTurnNotLabel
{
    
}


- (ZJHPokerView*)getSelfPokersView
{
    return (ZJHPokerView*)[self.view viewWithTag:(POKERS_TAG_OFFSET+UserPositionCenter)];
}

- (ZJHPokerView*)getPokersViewByPosition:(UserPosition)position
{
    return (ZJHPokerView*)[self.view viewWithTag:(POKERS_TAG_OFFSET+position)];
}


- (ZJHAvatarView*)getAvatarViewByPosition:(UserPosition)position
{
    return (ZJHAvatarView*)[self.view viewWithTag:(AVATAR_TAG_OFFSET+position)];
}

- (UserPosition)getPositionByUserId:(NSString*)userId
{
    PBGameUser* user = [_gameService.session getUserByUserId:userId];
    PBGameUser* selfUser = [self getSelfUser];
    return (UserPositionCenter + (user.seatId - selfUser.seatId))%MAX_PLAYER_COUNT;
}

- (ZJHPokerView*)getPokersViewByUserId:(NSString*)userId
{
    return [self getPokersViewByPosition:[self getPositionByUserId:userId]];
}

- (ZJHAvatarView*)getAvatarViewByUserId:(NSString*)userId
{
    return [self getAvatarViewByPosition:[self getPositionByUserId:userId]];
}

- (void)quitGame
{
//    [self clearAllReciprocol];
//    [self clearAllPlayersAvatar];
//    [self clearAllResultViews];
//    [self dismissAllPopupViews];
    [_gameService quitGame];
    [self unregisterAllNotifications];
    [self.navigationController popViewControllerAnimated:YES];
    //[_audioManager backgroundMusicStop];
}

@end
