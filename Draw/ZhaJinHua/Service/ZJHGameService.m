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

static ZJHGameService *_defaultService;

@interface ZJHGameService ()
{
    UserManager *_userManager;
}

@property (readwrite, retain, nonatomic) ZJHGameState *gameState;

@end

@implementation ZJHGameService

//@synthesize gameState = _gameState;

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

//- (void)autoBet
//{
//    [_networkClient sendBetRequest:self.userId
//                         sessionId:self.session.sessionId
//                         singleBet:[_gameState singleBet]
//                             count:[self myBetCount]
//                         isAutoBet:TRUE];
//}

- (void)checkCard
{
    [_networkClient sendCheckCardRequest:self.userId
                               sessionId:self.session.sessionId];
}

- (void)foldCard
{
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

- (BOOL)canIBet
{
    return [self isMyTurn];
}

- (BOOL)canIRaiseBet
{
    if (![self isMyTurn]) {
        return NO;
    }
    
    if (_gameState.singleBet < [[self.chipValues objectAtIndex:([self.chipValues count] - 1)] intValue]) {
        return YES;
    }else {
        return NO;
    }
}

- (BOOL)canIAutoBet
{
    return [self isMyTurn];
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
    if (![self isMyTurn]) {
        return NO;
    }else {
        return [[self myPlayInfo] canCompareCard];
    }
}

- (BOOL)canIShowCard:(int)cardId
{
    if (![self isMyTurn]) {
        return NO;
    }else {
        return [[self myPlayInfo] canShowCard:cardId];
    }
}

- (BOOL)canUserCompareCard:(NSString *)userId
{
    return [[_gameState userPlayInfo:userId] canCompareCard];
}

- (NSString *)myCardType
{
    return [[self myPlayInfo] cardTypeString];
}

- (BOOL)isMeAutoBet
{
    return [[self userPlayInfo:_userManager.userId] isAutoBet];
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
    if ([[message joinGameResponse] hasZjhGameState]) {
        self.gameState = [ZJHGameState fromPBZJHGameState:message.joinGameResponse.zjhGameState];
    }
}

- (void)hanldMoreOnGameStartNotificationRequest:(GameMessage*)message
{
    if ([[message gameStartNotificationRequest] hasZjhGameState]) {
        self.gameState = [ZJHGameState fromPBZJHGameState:message.gameStartNotificationRequest.zjhGameState];
    }
}

- (void)handleMoreOnGameOverNotificationRequest:(GameMessage*)message
{
    for (PBUserResult *userResult in message.gameOverNotificationRequest.zjhgameResult.userResultList) {
        if (userResult.win) {
            self.gameState.winner = userResult.userId;
        }
    }
}

#pragma mark -  message handler

- (void)updateBetModel:(GameMessage *)message
{
    ZJHUserPlayInfo *userPlayInfo = [_gameState userPlayInfo:message.userId];
    if (userPlayInfo == nil) {
        return;
    }
    
    if (userPlayInfo.isAutoBet == TRUE) {
        userPlayInfo.lastAction = PBZJHUserActionAutoBet;
    }else if (_gameState.singleBet == message.betRequest.singleBet) {
        userPlayInfo.lastAction = PBZJHUserActionBet;
    }else {
        userPlayInfo.lastAction = PBZJHUserActionRaiseBet;
    }
    
    _gameState.totalBet += message.betRequest.singleBet * message.betRequest.count;
    _gameState.singleBet = message.betRequest.singleBet;
    
    userPlayInfo.totalBet += message.betRequest.singleBet * message.betRequest.count;
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
            userPlayInfo.alreadLose = YES;
        }
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
    return @"192.168.1.10:8080";
}

- (ZJHUserPlayInfo *)myPlayInfo
{
    return [_gameState userPlayInfo:_userManager.userId];
}

@end
