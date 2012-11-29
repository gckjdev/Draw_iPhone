//
//  ZJHGameService.m
//  Draw
//
//  Created by 王 小涛 on 12-10-24.
//
//

#import "ZJHGameService.h"
#import "GameApp.h"
#import "CommonGameNetworkClient+ZJHNetworkExtend.h"
#import "GameMessage.pb.h"
#import "CommonGameSession.h"
#import "UserManager.h"
#import "ConfigManager.h"

static ZJHGameService *_defaultService;

@interface ZJHGameService ()
{
    UserManager *_userManager;
    AccountService *_accountService;
}

@property (readwrite, retain, nonatomic) ZJHGameState *gameState;

@end

@implementation ZJHGameService

@synthesize gameState = _gameState;

#pragma mark - life cycle

+ (ZJHGameService*)defaultService
{
    if (_defaultService == nil){
        _defaultService = [[ZJHGameService alloc] init];
    }
    
    return _defaultService;
}

- (id)init
{
    if (self = [super init]) {
        _gameId = ZHAJINHUA_GAME_ID;
        _networkClient = [CommonGameNetworkClient defaultInstance];
        _userManager = [UserManager defaultManager];
        _accountService = [AccountService defaultService];
    }

    return self;
}

#pragma mark - public methods

- (ZJHUserPlayInfo *)userPlayInfo:(NSString *)userId
{
    return [_gameState userPlayInfo:userId];
}

- (NSArray *)pokersOfUser:(NSString *)userId
{
    return [[self userPlayInfo:userId] pokers];
}

- (int)betCountOfUser:(NSString *)userId
{
    return [[self userPlayInfo:userId] betCount];
}

- (int)totalBetOfUser:(NSString *)userId
{
    return [[self userPlayInfo:userId] totalBet];
}

- (int)myBetCount
{
    return [[self userPlayInfo:_userManager.userId] betCount];
}

- (void)bet:(BOOL)autoBet
{
    [_networkClient sendBetRequest:self.userId
                         sessionId:self.session.sessionId
                         singleBet:[_gameState singleBet]
                             count:[self myBetCount]
                         isAutoBet:autoBet];
}

- (void)raiseBet:(int)singleBet
{
    [_networkClient sendBetRequest:self.userId
                         sessionId:self.session.sessionId
                         singleBet:singleBet
                             count:[self myBetCount]
                         isAutoBet:FALSE];
}

- (void)setAutoBet:(BOOL)isAutobet
{
    [self userPlayInfo:_userManager.userId].isAutoBet = isAutobet;
}

- (BOOL)isMeAutoBet
{
    return [[self myPlayInfo] isAutoBet];
}

- (void)checkCard
{
    [_networkClient sendCheckCardRequest:self.userId
                               sessionId:self.session.sessionId];
}

- (void)foldCard
{
    PPDebug(@"################# fold card: %@ ##################", self.userId);

    [_networkClient sendFoldCardRequest:self.userId
                              sessionId:self.session.sessionId];
}

- (void)compareCard:(NSString*)toUserId
{
    [_networkClient sendCompareCardRequest:self.userId
                                 sessionId:self.session.sessionId
                                  toUserId:toUserId];
}

- (void)showCard:(int)cardId
{
    NSArray *cardIds = [NSArray arrayWithObjects:[NSNumber numberWithInt:cardId], nil];
    
    [_networkClient sendShowCardRequest:self.userId
                              sessionId:self.session.sessionId
                                cardIds:cardIds];
}

- (void)showCards:(NSArray *)cardIds
{
    [_networkClient sendShowCardRequest:self.userId
                              sessionId:self.session.sessionId
                                cardIds:cardIds];
}

- (NSArray *)chipValues
{
    return [NSArray arrayWithObjects:[NSNumber numberWithInt:5], [NSNumber numberWithInt:10], [NSNumber numberWithInt:25], [NSNumber numberWithInt:50], nil];
}

- (BOOL)isMyBalanceEnough
{
    return [self myBalance] >= _gameState.singleBet * [self myBetCount];
}

- (BOOL)canRaise
{
    if (_gameState.singleBet < [[self.chipValues lastObject] intValue]) {
        return YES;
    }else{
        return NO;
    }
}

- (BOOL)canIBet
{
    return [self isGamePlaying] && [self isMyTurn] && [self isMyBalanceEnough];
}

- (BOOL)canIRaiseBet
{
    return [self isGamePlaying] && [self isMyTurn] && [self canRaise] && [self isMyBalanceEnough];
}

- (BOOL)canIAutoBet
{
    return [self isGamePlaying] && [self isMyBalanceEnough] && [[self myPlayInfo] canAutoBet];
}

- (BOOL)canICheckCard
{
    return [self isGamePlaying] && [[self myPlayInfo] canCheckCard];
}

- (BOOL)canIFoldCard
{
    return [self isGamePlaying] && [[self myPlayInfo] canFoldCard];
}

- (BOOL)canICompareCard
{
    return [self isGamePlaying] && [self isMyTurn] && [[self myPlayInfo] canCompareCard] && (self.session.myTurnTimes >=2) && ([[self compareUserIdList] count] > 0);
}

- (BOOL)canIShowCard:(int)cardId
{
    return [self isGamePlaying] && [self isMyTurn] && [[self myPlayInfo] canShowCard:cardId];
}

- (BOOL)canUserBeCompared:(NSString *)userId
{
    return [[_gameState userPlayInfo:userId] canBeCompared] && ![_userManager isMe:userId];
}

- (PBZJHCardType)myCardType
{
    return [[self myPlayInfo] cardType];
}

- (NSString *)myCardTypeString
{
    return [[self myPlayInfo] cardTypeString];
}

- (NSString *)cardTypeOfUser:(NSString *)userId
{
    return [[self userPlayInfo:userId] cardTypeString];
}

- (BOOL)doIWin
{
    return [_userManager isMe:_gameState.winner];
}

- (NSString *)winner
{
    return _gameState.winner;
}

#pragma mark - overwrite methods

- (void)handleMoreOnJoinGameResponse:(GameMessage*)message
{
    self.gameState = [ZJHGameState fromPBZJHGameState:message.joinGameResponse.zjhGameState];
}

- (void)handleMoreOnGameStartNotificationRequest:(GameMessage*)message
{
    self.gameState = [ZJHGameState fromPBZJHGameState:message.gameStartNotificationRequest.zjhGameState];
}

- (void)handleMoreOnGameOverNotificationRequest:(GameMessage*)message
{
    for (PBUserResult *result in message.gameOverNotificationRequest.zjhgameResult.userResultList) {
        
        if (result.win) {
            self.gameState.winner = result.userId;
        }
        
        [self userPlayInfo:result.userId].resultAward = result.gainCoins;
    }
}

#pragma mark -  message handler

- (void)updateBetModel:(GameMessage *)message
{
    ZJHUserPlayInfo *userPlayInfo = [_gameState userPlayInfo:message.userId];
    if (userPlayInfo == nil) {
        return;
    }
    
    PPDebug(@"################### User: %@, bet #####################", userPlayInfo.userId);
    
    if (message.betRequest.isAutoBet == TRUE) {
        userPlayInfo.lastAction = PBZJHUserActionAutoBet;
    }else if (message.betRequest.singleBet == _gameState.singleBet) {
        userPlayInfo.lastAction = PBZJHUserActionBet;
    }else {
        userPlayInfo.lastAction = PBZJHUserActionRaiseBet;
    }
    
    _gameState.totalBet += message.betRequest.singleBet * message.betRequest.count;
    _gameState.singleBet = message.betRequest.singleBet;
    
    userPlayInfo.totalBet += (message.betRequest.singleBet * message.betRequest.count);
    userPlayInfo.isAutoBet = message.betRequest.isAutoBet;
}

- (void)updateCheckCardModel:(GameMessage *)message
{
    ZJHUserPlayInfo *userPlayInfo = [_gameState userPlayInfo:message.userId];
    if (userPlayInfo == nil) {
        return;
    }
    
    userPlayInfo.lastAction = PBZJHUserActionCheckCard;
    userPlayInfo.alreadCheckCard = YES;
}

- (void)updateFoldCardModel:(GameMessage *)message
{
    ZJHUserPlayInfo *userPlayInfo = [_gameState userPlayInfo:message.userId];
    if (userPlayInfo == nil) {
        return;
    }
    
    userPlayInfo.lastAction = PBZJHUserActionFoldCard;
    userPlayInfo.alreadFoldCard = YES;
    userPlayInfo.isAutoBet = NO;
}

- (void)updateShowCardModel:(GameMessage *)message
{
    ZJHUserPlayInfo *userPlayInfo = [_gameState userPlayInfo:message.userId];
    if (userPlayInfo == nil) {
        return;
    }
    
    userPlayInfo.lastAction = PBZJHUserActionShowCard;
    userPlayInfo.alreadShowCard = YES;    
    [userPlayInfo setPokersFaceUp:message.showCardRequest.cardIdsList];
}

- (void)updateCompareCardModel:(GameMessage *)message
{
    NSArray *resultList = message.compareCardResponse.userResultList;
    ZJHUserPlayInfo *userPlayInfo;
    for (PBUserResult *result in resultList) {
        userPlayInfo = [_gameState userPlayInfo:result.userId];
        userPlayInfo.lastAction = PBZJHUserActionCompareCard;
        if (!result.win) {
            userPlayInfo.alreadCompareLose = YES;
            userPlayInfo.isAutoBet = NO;
        }
        
        userPlayInfo.compareAward += result.gainCoins;
    }
}

- (void)handleBetRequest:(GameMessage *)message
{
    [self updateBetModel:message];
    [self postNotification:NOTIFICATION_BET_REQUEST message:message];
}

- (void)handleBetResponse:(GameMessage *)message
{
    if (message.resultCode == 0) {
        [self updateBetModel:message];
        [self postNotification:NOTIFICATION_BET_RESPONSE message:message];
    }
}

- (void)handleCheckCardRequest:(GameMessage *)message
{
    [self updateCheckCardModel:message];
    [self postNotification:NOTIFICATION_CHECK_CARD_REQUEST message:message];
}

- (void)handleCheckCardResponse:(GameMessage *)message
{
    if (message.resultCode == 0) {
        [self updateCheckCardModel:message];
        [self postNotification:NOTIFICATION_CHECK_CARD_RESPONSE message:message];
    }
}

- (void)handleFoldCardRequest:(GameMessage *)message
{
    [self updateFoldCardModel:message];
    [self postNotification:NOTIFICATION_FOLD_CARD_REQUEST message:message];

}

- (void)handleFoldCardResponse:(GameMessage *)message
{
    if (message.resultCode == 0) {
        [self updateFoldCardModel:message];
        [self postNotification:NOTIFICATION_FOLD_CARD_RESPONSE message:message];
    }
}

- (void)handleCompareCardRequest:(GameMessage *)message
{
    
}

- (void)handleCompareCardResponse:(GameMessage *)message
{
    if (message.resultCode == 0) {
        [self updateCompareCardModel:message];
        [self postNotification:NOTIFICATION_COMPARE_CARD_RESPONSE message:message];
    }
}

- (void)handleShowCardRequest:(GameMessage *)message
{
    [self updateShowCardModel:message];
    [self postNotification:NOTIFICATION_SHOW_CARD_REQUEST message:message];
}

- (void)handleShowCardResponse:(GameMessage *)message
{
    if (message.resultCode == 0) {
        [self updateShowCardModel:message];
        [self postNotification:NOTIFICATION_SHOW_CARD_RESPONSE message:message];
    }
}

- (void)handleCustomMessage:(GameMessage*)message
{
    switch ([message command]){
            
        case GameCommandTypeBetRequest:
            [self handleBetRequest:message];
            break;
            
        case GameCommandTypeBetResponse:
            [self handleBetResponse:message];
            break;
            
        case GameCommandTypeCheckCardRequest:
            [self handleCheckCardRequest:message];
            break;
            
        case GameCommandTypeCheckCardResponse:
            [self handleCheckCardResponse:message];
            break;
            
        case GameCommandTypeFoldCardRequest:
            [self handleFoldCardRequest:message];
            break;
            
        case GameCommandTypeFoldCardResponse:
            [self handleFoldCardResponse:message];
            break;
            
        case GameCommandTypeCompareCardRequest:
            [self handleCompareCardRequest:message];
            break;
            
        case GameCommandTypeCompareCardResponse:
            [self handleCompareCardResponse:message];
            break;
            
        case GameCommandTypeShowCardRequest:
            [self handleShowCardRequest:message];
            break;
            
        case GameCommandTypeShowCardResponse:
            [self handleShowCardResponse:message];
            break;
            
        default:
            PPDebug(@"<handleCustomMessage> unknown command=%d", [message command]);
            break;
    }
}

- (NSString *)getServerListString
{
    return @"58.215.172.169:8018"; 
//    return @"192.168.1.5:8018";
    return @"127.0.0.1:8018";

}

- (ZJHUserPlayInfo *)myPlayInfo
{
    return [_gameState userPlayInfo:_userManager.userId];
}

- (int)myBalance
{
    int balance = [_accountService getBalance] - [[self myPlayInfo] totalBet] + [[self myPlayInfo] compareAward] + [[self myPlayInfo] resultAward];
    if (balance < 0) {
        return 0;
    }
    return balance;
}

- (NSArray *)compareUserIdList
{
    NSMutableArray *arr = [NSMutableArray array];
    for (PBGameUser *user in self.session.userList) {
        if ([self canUserBeCompared:user.userId]) {
            [arr addObject:user.userId];
        }
    }
    
    return arr;
}

- (NSString *)getRoomName
{
    if ([self.session.roomName length] > 0) {
        return self.session.roomName;
    }
    
    return [NSString stringWithFormat:NSLS(@"kZJHRoomTitle"), self.session.sessionId];
}

- (void)chargeAccount:(int)amount
               source:(BalanceSourceType)source
{
    [_accountService chargeAccount:amount source:source];
}

- (void)syncAccount:(id<AccountServiceDelegate>)delegate
{
    [_accountService syncAccount:delegate forceServer:YES];
}

@end
