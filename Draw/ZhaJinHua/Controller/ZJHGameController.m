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

#define AVATAR_TAG_OFFSET   8000
#define POKERS_TAG_OFFSET   2000
#define MAX_PLAYER_COUNT    5
#define NOTIFICATION_NEXT_PLAYER_START @""
#define NOTIFICATION_GAME_BEGIN    @""

@interface ZJHGameController ()

- (void)roomChanged;
- (ZJHPokerView*)getSelfPokersView;
- (ZJHPokerView*)getPokersViewByPosition:(UserPosition)position;

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
    
    [self registerZJHGameNotificationWithName:NOTIFICATION_GAME_START_NOTIFICATION_REQUEST
                                    usingBlock:^(NSNotification *notification) {
                                        [self gameStart];
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
    ZJHPokerView* pokers = [self getSelfPokersView];
    [pokers faceupCards:YES];
}

- (IBAction)foldCard:(id)sender
{
    
}

- (IBAction)showCard:(id)sender
{
    
}

#pragma mark - private method

- (PBGameUser*)getSelfUserFromUserList:(NSArray*)userList
{
    if (userList.count > 0) {
        for (int i = 0; i < userList.count; i ++) {
            PBGameUser* user = [userList objectAtIndex:i];
            if ([user.userId isEqualToString:[_userManager userId]]) {
                return user;
            }
        }
    }
    return nil;
}

- (void)updateAllPlayersAvatar
{
    NSArray* userList = _gameService.session.userList;
    PBGameUser* selfUser = [self getSelfUserFromUserList:userList];
    
    //init seats
    for (int i = 1; i <= MAX_PLAYER_COUNT; i ++) {
        ZJHAvatarView* avatar = (ZJHAvatarView*)[self.view viewWithTag:AVATAR_TAG_OFFSET+i];
        [avatar resetAvatar];
    }
    
    // set user on seat
    for (PBGameUser* user in userList) {
        //        PPDebug(@"<test>get user--%@, sitting at %d",user.nickName, user.seatId);
        int seat = user.seatId;
        int seatIndex = (MAX_PLAYER_COUNT + selfUser.seatId - seat)%MAX_PLAYER_COUNT + 1;
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


- (void)someOneBet:(UserPosition)position
           counter:(int)counter
{
    
}

- (void)someOneShowCard:(UserPosition)position
{
    
}

- (void)someOne:(UserPosition)player
    compareWith:(UserPosition)otherPlayer
{
    
}

- (void)someOneRaiseBet:(UserPosition)position
{
    
}

- (void)someOneAutoBet:(UserPosition)position
{
    
}

- (void)someOneCheckCard:(UserPosition)position
{
    ZJHPokerView* view = [self getPokersViewByPosition:position];
    ZJHPokerSectorType type;
    if (position == UserPositionLeft || position == UserPositionLeftTop) {
        type = ZJHPokerSectorTypeLeft;
    }
    if (position == UserPositionRight || position == UserPositionRightTop) {
        type = ZJHPokerSectorTypeRight;
    }
    [view makeSectorShape:type animation:YES];
}

- (void)someOneFoldCard:(UserPosition)position
{
    ZJHPokerView* view = [self getPokersViewByPosition:position];
    [view fold:YES];
}

- (ZJHPokerView*)getSelfPokersView
{
    return (ZJHPokerView*)[self.view viewWithTag:(POKERS_TAG_OFFSET+UserPositionCenter)];
}

- (ZJHPokerView*)getPokersViewByPosition:(UserPosition)position
{
    return (ZJHPokerView*)[self.view viewWithTag:(POKERS_TAG_OFFSET+position)];
}

- (UserPosition)getPositionByUserId:(NSString*)userId
{
    PBGameUser* user = [_gameService.session getUserByUserId:userId];
    PBGameUser* selfUser = [self getselfUser];
    return (UserPositionCenter + (user.seatId - selfUser.seatId))%MAX_PLAYER_COUNT;
}

- (ZJHPokerView*)getPokersViewByUserId:(NSString*)userId
{
    return [self getPokersViewByPosition:[self getPositionByUserId:userId]];
}

@end
