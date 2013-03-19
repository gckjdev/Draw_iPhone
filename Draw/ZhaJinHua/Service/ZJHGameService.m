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
#import "ZJHRuleConfigFactory.h"
#import "MyFriend.h"
#import "ConfigManager.h"
#import "AccountManager.h"

static ZJHGameService *_defaultService;

@interface ZJHGameService ()
{
    UserManager *_userManager;
    AccountService *_accountService;
//    dispatch_queue_t _getUserInfoQueue;
}

@property (readwrite, retain, nonatomic) ZJHGameState *gameState;
//@property (retain, nonatomic) NSMutableDictionary *userSimpleInfo;
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
        _timeoutAcion = PBZJHUserActionFoldCard;
    }

    return self;
}

- (void)dealloc
{
    [super dealloc];
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
                         singleBet:MAX(singleBet, _gameState.singleBet)
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

- (void)changeCard:(int)cardId
{
    [_networkClient sendChangeCardRequest:self.userId
                                sessionId:self.session.sessionId
                                   cardId:cardId];
}


//- (void)showCards:(NSArray *)cardIds
//{
//    [_networkClient sendShowCardRequest:self.userId
//                              sessionId:self.session.sessionId
//                                cardIds:cardIds];
//}


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

- (int)remainUserCount
{
    int count = 0;
    for (NSString *key in [_gameState.usersInfo allKeys]) {
        ZJHUserPlayInfo *user = [_gameState.usersInfo objectForKey:key];
        if (user.alreadCompareLose || user.alreadFoldCard) {
            continue;
        }
        count++;
    }
    
    PPDebug(@"count: %d", count);
    
    return count;
}

- (BOOL)canICompareCard
{
    if ([self isMyBalanceEnough]) {
        return [self isGamePlaying] && [self isMyTurn] && [[self myPlayInfo] canCompareCard] && (self.session.myTurnTimes >=2) && ([[self compareUserIdList] count] > 0) && ([self remainUserCount] > 2);
    }else{
        return [self isGamePlaying] && [self isMyTurn] && [[self myPlayInfo] canCompareCard] && (self.session.myTurnTimes >=2) && ([[self compareUserIdList] count] > 0);
    }
}

- (BOOL)canIShowCard:(int)cardId
{
    return [self isGamePlaying] && [self isMyTurn] && [[self myPlayInfo] canShowCard:cardId];
}

- (BOOL)canIChangeCard:(int)cardId
{
    return [self isGamePlaying] && [self isMyTurn] && [[self myPlayInfo] canChangeCard:cardId] && ([self.session myTurnTimes] >= ([[self myPlayInfo] changeCardTimes] + 1) * 4);
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
    for (PBUserResult *result in message.gameOverNotificationRequest.zjhGameResult.userResultList) {
        
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

- (void)updateChangeCardModel:(GameMessage *)message
{
    ZJHUserPlayInfo *userPlayInfo = [_gameState userPlayInfo:message.userId];
    if (userPlayInfo == nil) {
        return;
    }
    
    userPlayInfo.lastAction = PBZJHUserActionChangeCard;
    userPlayInfo.cardType = message.changeCardResponse.cardType;
    [userPlayInfo changePoker:message.changeCardResponse.oldCardId newPoker:message.changeCardResponse.newPoker];
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

- (void)handleChangeCardRequest:(GameMessage *)message
{
    [self updateChangeCardModel:message];
    [self postNotification:NOTIFICATION_CHANGE_CARD_REQUEST message:message];
}

- (void)handleChangeCardResponse:(GameMessage *)message
{
    if (message.resultCode == 0) {
        [self updateChangeCardModel:message];
        [self postNotification:NOTIFICATION_CHANGE_CARD_RESPONSE message:message];
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
            
        case GameCommandTypeChangeCardRequest:
            [self handleChangeCardRequest:message];
            break;
            
        case GameCommandTypeChangeCardResponse:
            [self handleChangeCardResponse:message];
            break;
            
        default:
            PPDebug(@"<handleCustomMessage> unknown command=%d", [message command]);
            break;
    }
}

- (NSString *)getServerListString
{
    switch (self.rule) {
        case PBZJHRuleTypeDual:
            return [ConfigManager getZJHServerListStringWithDual];
            break;
            
        case PBZJHRuleTypeNormal:
            return [ConfigManager getZJHServerListStringWithNormal];
            break;
            
        case PBZJHRuleTypeRich:
            return [ConfigManager getZJHServerListStringWithRich];
            break;
            
        default:
            break;
    }
    
    return nil;
}

- (ZJHUserPlayInfo *)myPlayInfo
{
    return [_gameState userPlayInfo:_userManager.userId];
}

- (int)myBalance
{
    int balance = [[AccountManager defaultManager] getBalanceWithCurrency:PBGameCurrencyCoin] - [[self myPlayInfo] totalBet] + [[self myPlayInfo] compareAward] + [[self myPlayInfo] resultAward];
    if (balance < 0) {
        return 0;
    }
    return balance;
}

- (int)balanceOfUser:(NSString *)userId
{
    if (userId == nil) {
        return 0;
    }
    
    if ([_userManager isMe:userId]) {
        return [self myBalance];
    }
    
    int balance = [[self.userSimpleInfo objectForKey:userId] coins] - [[self userPlayInfo:userId] totalBet] + [[self userPlayInfo:userId] compareAward] + [[self userPlayInfo:userId] resultAward];
    
    PPDebug(@"user: %@", userId);
    PPDebug(@"coins(%d) - totalBet(%d) + compareAward(%d) + resultAward(%d) = %d", [[self.userSimpleInfo objectForKey:userId] coins], [[self userPlayInfo:userId] totalBet], [[self userPlayInfo:userId] compareAward], [[self userPlayInfo:userId] resultAward], balance);
    
    if (balance < 0) {
        return 0;
    }
    return balance;
}

- (int)levelOfUser:(NSString *)userId
{
    if (userId == nil) {
        return -1;
    }
        
    return [[self.userSimpleInfo objectForKey:userId] level];
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

- (BOOL)canIQuitGameDirectly
{
    if (!self.session.isGamePlaying) {
        return YES;
    }
    
    if (self.session.isMeStandBy) {
        return YES;
    }
    
    return [[self myPlayInfo] alreadFoldCard] || [[self myPlayInfo] alreadCompareLose];
}

- (void)chargeAccount:(int)amount
               source:(BalanceSourceType)source
{
    [_accountService chargeAccount:amount source:source];
}

- (void)syncAccount:(id<AccountServiceDelegate>)delegate
{
    [_accountService syncAccount:delegate];
}

- (NSArray *)myReplacedCards
{
    return [[self myPlayInfo] replacedPokers];
}

- (NSArray *)replacedCardsOfUser:(NSString *)userId
{
    return [[self userPlayInfo:userId] replacedPokers];
}

- (void)reset
{
    self.gameState = nil;
    self.timeoutAcion = PBZJHUserActionFoldCard;
}

- (void)setTimeoutSettingWithAction:(PBZJHUserAction)action
{
    _timeoutAcion = action;
    [_networkClient sendTimeoutSettingRequest:self.userId
                                    sessionId:self.session.sessionId
                                       action:action];
}

- (BOOL)canISetTimeoutSetting
{
    PPDebug(@"alreadCompareLose: %d", [[self myPlayInfo] alreadCompareLose]);
    PPDebug(@"alreadFoldCard: %d", [[self myPlayInfo] alreadFoldCard]);
    
    ZJHUserPlayInfo *myInfo = [self myPlayInfo];
    if (![self isGamePlaying]) {
        return NO;
    }
    
    if ([myInfo alreadCompareLose] || [myInfo alreadFoldCard]) {
        return NO;
    }
    
    if ([myInfo alreadCheckCard]) {
        return YES;
    }else{
        return NO;
    }
}

@end
