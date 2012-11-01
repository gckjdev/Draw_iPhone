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
#import "ZJHUserPlayInfo.h"
#import "GameMessage.pb.h"
#import "BetTable.h"
#import "ConfigManager.h"
//#import "Poker.h"
#import "CMPopTipView.h"
#import "PokerView.h"

#define AVATAR_TAG_OFFSET   8000
#define POKERS_TAG_OFFSET   2000
#define MAX_PLAYER_COUNT    5
#define NOTIFICATION_NEXT_PLAYER_START @""
#define NOTIFICATION_GAME_BEGIN    @""

@interface ZJHGameController ()
{
    ZJHGameService  *_gameService;
    LevelService    *_levelService;
    UserManager     *_userManager;
    AudioManager    *_audioManager;
    AccountService  *_accountService;
    ZJHImageManager *_imageManager;
}

@end

@implementation ZJHGameController
@synthesize betTable = _betTable;

#pragma mark - life cycle

- (void)dealloc
{
    [_betTable release];
    [super dealloc];
}

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

- (void)didReceiveMemoryWarning
{
    // dealloc resource here when memory is not enough
    [self unregisterAllNotifications];
    [super didReceiveMemoryWarning];
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
                                        [self nextPlayerStart:userId];
                                    }];
    
    [self registerZJHGameNotificationWithName:NOTIFICATION_BET_REQUEST
                                   usingBlock:^(NSNotification *notification) {
                                       [self someoneBet:[self userIdOfNotification:notification]];
                                   }];
    
    [self registerZJHGameNotificationWithName:NOTIFICATION_BET_RESPONSE
                                   usingBlock:^(NSNotification *notification) {
                                       [self betSuccess];
                                   }];
    
    [self registerZJHGameNotificationWithName:NOTIFICATION_CHECK_CARD_REQUEST
                                   usingBlock:^(NSNotification *notification) {
                                       [self someoneCheckCard:[self userIdOfNotification:notification]];
                                   }];
    
    [self registerZJHGameNotificationWithName:NOTIFICATION_CHECK_CARD_RESPONSE
                                   usingBlock:^(NSNotification *notification) {
                                       [self checkCardSuccess];
                                   }];
    
    [self registerZJHGameNotificationWithName:NOTIFICATION_FOLD_CARD_REQUEST
                                   usingBlock:^(NSNotification *notification) {
                                       [self someoneFoldCard:[self userIdOfNotification:notification]];
                                   }];
    
    [self registerZJHGameNotificationWithName:NOTIFICATION_FOLD_CARD_RESPONSE
                                   usingBlock:^(NSNotification *notification) {
                                       [self foldCardSuccess];
                                   }];
    
    [self registerZJHGameNotificationWithName:NOTIFICATION_SHOW_CARD_REQUEST
                                   usingBlock:^(NSNotification *notification) {

                                       [self someoneShowCard:[self userIdOfNotification:notification] cardIds:[[[self messageFromNotification:notification] showCardRequest] cardIdsList]];
                                   }];
    
    [self registerZJHGameNotificationWithName:NOTIFICATION_SHOW_CARD_RESPONSE
                                   usingBlock:^(NSNotification *notification) {
                                       [self showCardSuccess];
                                   }];
    
    [self registerZJHGameNotificationWithName:NOTIFICATION_COMPARE_CARD_REQUEST
                                   usingBlock:^(NSNotification *notification) {
                                       NSString *userId = [self userIdOfNotification:notification];
                                       NSString *toUserId = [[[self messageFromNotification:notification] compareCardRequest] toUserId];
                                       
                                       [self someone:userId
                                     compareCardWith:toUserId];
                                   }];
    
    [self registerZJHGameNotificationWithName:NOTIFICATION_COMPARE_CARD_RESPONSE
                                   usingBlock:^(NSNotification *notification) {
                                       [self compareCardSuccess];
                                   }];    
}

#pragma mark - player action
- (IBAction)clickBetButton:(id)sender {
    [self.betTable someBetFrom:UserPositionCenter
                     chipValue:_gameService.gameState.singleBet
                         count:[[_gameService userPlayInfo:_userManager.userId] betCount]];
    
    [_gameService bet];
}

- (IBAction)clickRaiseBetButton:(id)sender
{
    [self.betTable clearAllChips:UserPositionCenter];
    
}

- (IBAction)clickAutoBetButton:(id)sender
{
    [self.betTable someBetFrom:UserPositionCenter
                     chipValue:_gameService.gameState.singleBet
                         count:[[_gameService userPlayInfo:_userManager.userId] betCount]];
    
    [_gameService autoBet];
}

- (IBAction)clickCompareCardButton:(id)sender
{
    Poker *poker1 = [Poker pokerWithPokerId:1 rank:14 suit:2 faceUp:0];
    Poker *poker2 = [Poker pokerWithPokerId:1 rank:14 suit:3 faceUp:0];
    Poker *poker3 = [Poker pokerWithPokerId:1 rank:14 suit:4 faceUp:0];

    ZJHPokerView* pokersView = [self getSelfPokersView];

    [pokersView updateWithPokers:[NSArray arrayWithObjects:poker1, poker2, poker3, nil] size:CGSizeMake(BIG_POKER_VIEW_WIDTH, BIG_POKER_VIEW_HEIGHT) gap:BIG_POKER_GAP delegate:self];
    
}

- (IBAction)clickCheckCardButton:(id)sender
{
    ZJHPokerView* pokersView = [self getSelfPokersView];
    [pokersView faceUpCards:YES];
    [_gameService checkCard];
}

- (IBAction)clickFoldCardButton:(id)sender
{
    ZJHPokerView* pokers = [self getSelfPokersView];
    [pokers foldCards:YES];
    [_gameService foldCard];
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

- (void)nextPlayerStart:(NSString*)userId
{
    ZJHAvatarView* avatar = [self getAvatarViewByPosition:[self getPositionByUserId:userId]];
    [avatar startReciprocol:[ConfigManager getZJHTimeInterval]];
}

- (void)someoneBet:(NSString*)userId
{    
    [self.betTable someBetFrom:[self getPositionByUserId:userId]
                     chipValue:_gameService.gameState.singleBet
                         count:[[_gameService userPlayInfo:userId] betCount]];

}


- (void)someoneShowCard:(NSString*)userId cardIds:(NSArray *)cardIds
{
    for (NSNumber *cardId in cardIds) {
        [[self getPokersViewByPosition:[self getPositionByUserId:userId]] faceUpCard:cardId.intValue
                                                                           animation:YES];
    }
    
}

- (void)someone:(NSString*)userId
compareCardWith:(NSString*)targetUserId
{
    
}

- (void)someoneRaiseBet:(NSString*)userId
{
    [self.betTable someBetFrom:[self getPositionByUserId:userId]
                     chipValue:_gameService.gameState.singleBet
                         count:[[_gameService userPlayInfo:userId] betCount]];
}

- (void)someoneAutoBet:(NSString*)userId
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

- (void)someoneCheckCard:(NSString*)userId
{
    UserPosition position = [self getPositionByUserId:userId];
    ZJHPokerView *view = [self getPokersViewByPosition:position];
    
    [view makeSectorShape:[self getPokerSectorTypeByPosition:position] animation:YES];
}

- (void)someoneFoldCard:(NSString*)userId
{
    
    ZJHPokerView *view = [self getPokersViewByPosition:[self getPositionByUserId:userId]];
    [view foldCards:YES];
}

- (void)someoneWon:(NSString*)userId
{
    [self.betTable clearAllChips:[self getPositionByUserId:userId]];
}

#pragma mark - private method

- (PBGameUser*)getSelfUser
{
    return [_gameService.session getUserByUserId:_userManager.userId];
}

- (void)updateAllPlayersAvatar
{
    //init seats
    for (int i = 1; i <= MAX_PLAYER_COUNT; i ++) {
        ZJHAvatarView* avatar = (ZJHAvatarView*)[self.view viewWithTag:AVATAR_TAG_OFFSET+i];
        [avatar resetAvatar];
    }
    
    [[self getAvatarViewByPosition:UserPositionCenter] updateByPBGameUser:[_userManager toPBGameUser]];
    [[self getAvatarViewByPosition:UserPositionCenter] setDelegate:self];
    
    // set user on seat
    NSArray* userList = _gameService.session.userList;
    for (PBGameUser* user in userList) {
        //        PPDebug(@"<test>get user--%@, sitting at %d",user.nickName, user.seatId);

        ZJHAvatarView* avatar = [self getAvatarViewByUserId:user.userId];
        [avatar updateByPBGameUser:user];
    }
}

- (void)updateAllPokers
{
    for (int i = 1; i <= MAX_PLAYER_COUNT; i ++) {
        ZJHAvatarView* avatar = (ZJHAvatarView*)[self.view viewWithTag:AVATAR_TAG_OFFSET+i];
        ZJHPokerView* pokerView = (ZJHPokerView*)[self.view viewWithTag:POKERS_TAG_OFFSET+i];
        
        [pokerView clear];
        if (avatar.userInfo) {
            CGSize pokerSize;
            CGFloat gap;
            if ([_userManager isMe:avatar.userInfo.userId]) {
                pokerSize = CGSizeMake(BIG_POKER_VIEW_WIDTH, BIG_POKER_VIEW_HEIGHT);
                gap = BIG_POKER_GAP;
            }else {
                pokerSize = CGSizeMake(SMALL_POKER_VIEW_WIDTH, SMALL_POKER_VIEW_HEIGHT);
                gap = SMALL_POKER_GAP;
            }
            [pokerView updateWithPokers:[[_gameService userPlayInfo:avatar.userInfo.userId] pokers]
                                   size:pokerSize
                                    gap:gap
                               delegate:self];
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

- (GameMessage *)messageFromNotification:(NSNotification *)notification
{
    return [CommonGameNetworkService userInfoToMessage:notification.userInfo];
}

- (NSString *)userIdOfNotification:(NSNotification *)notification
{
    return [[self messageFromNotification:notification] userId];
}

- (void)viewDidUnload {
    [self setBetTable:nil];
    [super viewDidUnload];
}

#pragma mark - ZJHAvatarDelegate

- (void)didClickOnAvatar:(ZJHAvatarView*)view
{
    
}

- (void)reciprocalEnd:(ZJHAvatarView*)view
{
    [self clickFoldCardButton:nil];
}







+ (id)createShowCardButton
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PokerView" owner:self options:nil];
    // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
    if (topLevelObjects == nil || [topLevelObjects count] <= 1){
        return nil;
    }
    
    return [topLevelObjects objectAtIndex:1];
}

- (void)didClickPokerView:(PokerView *)pokerView
{
    pokerView.showCardButtonIsPopup ? [pokerView dismissShowCardButton] : [pokerView popupShowCardButtonInView:self.view aboveView:nil];
}

- (void)didClickShowCardButton:(PokerView *)pokerView
{
    PPDebug(@"didClickShowCardButton: card rank: %d, suit = %d", pokerView.poker.rank, pokerView.poker.suit);
    [_gameService showCard:pokerView.poker.pokerId];
}


@end
