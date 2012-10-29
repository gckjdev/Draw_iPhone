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

static ZJHGameService *_defaultService;

@interface ZJHGameService ()

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
    }

    return self;
}

#pragma mark - public methods

- (void)bet
{
    [_networkClient sendBetRequest:self.userId
                         sessionId:self.session.sessionId
                         singleBet:_gameState.singleBet
                             count:[_gameState betCountOfUser:self.userId]
                         isAutoBet:FALSE];
}

- (void)raiseBet:(int)singleBet
{
    [_networkClient sendBetRequest:self.userId
                         sessionId:self.session.sessionId
                         singleBet:singleBet
                             count:[_gameState betCountOfUser:self.userId]
                         isAutoBet:FALSE];
}

- (void)autoBet
{
    [_networkClient sendBetRequest:self.userId
                         sessionId:self.session.sessionId
                         singleBet:[_gameState singleBet]
                             count:[_gameState betCountOfUser:self.userId]
                         isAutoBet:TRUE];
}

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

#pragma mark - overwrite methods

- (void)updateGameState:(GameMessage *)message
{
    if ([[message joinGameResponse] hasZjhGameState]) {
        self.gameState = [ZJHGameState fromPBZJHGameState:message.joinGameResponse.zjhGameState];
    }
    
    if ([[message gameStartNotificationRequest] hasZjhGameState]) {
        self.gameState = [ZJHGameState fromPBZJHGameState:message.gameStartNotificationRequest.zjhGameState];
    }
}

#pragma mark -  message handler

- (void)updateBetModel:(GameMessage *)message
{
    ZJHUserInfo *userInfo = [_gameState userInfo:message.userId];
    if (userInfo == nil) {
        return;
    }
    
    if (userInfo.isAutoBet == TRUE) {
        userInfo.lastAction = PBZJHUserActionAutoBet;
    }else if (_gameState.singleBet == message.betRequest.singleBet) {
        userInfo.lastAction = PBZJHUserActionBet;
    }else {
        userInfo.lastAction = PBZJHUserActionRaiseBet;
    }
    
    _gameState.totalBet += message.betRequest.singleBet * message.betRequest.count;
    _gameState.singleBet = message.betRequest.singleBet;
    
    userInfo.totalBet += message.betRequest.singleBet * message.betRequest.count;
    userInfo.isAutoBet = message.betRequest.isAutoBet;
}

- (void)updateCheckCardModel:(GameMessage *)message
{
    ZJHUserInfo *userInfo = [_gameState userInfo:message.userId];
    if (userInfo == nil) {
        return;
    }
    
    userInfo.lastAction = PBZJHUserActionCheckCard;
    userInfo.alreadCheckCard = YES;
}

- (void)updateFoldCardModel:(GameMessage *)message
{
    ZJHUserInfo *userInfo = [_gameState userInfo:message.userId];
    if (userInfo == nil) {
        return;
    }
    
    userInfo.lastAction = PBZJHUserActionFoldCard;
    userInfo.alreadFoldCard = YES;
}

- (void)updateShowCardModel:(GameMessage *)message
{
    ZJHUserInfo *userInfo = [_gameState userInfo:message.userId];
    if (userInfo == nil) {
        return;
    }
    
    userInfo.lastAction = PBZJHUserActionShowCard;
    userInfo.alreadShowCard = YES;
    
    [userInfo setPokersFaceUp:message.showCardRequest.cardIdsList];
}

- (void)handleBetDiceRequest:(GameMessage *)message
{
    [self updateBetModel:message];
}

- (void)handleBetDiceResponse:(GameMessage *)message
{
    if (message.resultCode == 0) {
        [self updateBetModel:message];
    }
}

- (void)handleCheckCardRequest:(GameMessage *)message
{
    [self updateCheckCardModel:message];
}

- (void)handleCheckCardResponse:(GameMessage *)message
{
    if (message.resultCode == 0) {
        [self updateCheckCardModel:message];
    }
}

- (void)handleFoldCardRequest:(GameMessage *)message
{
    [self updateFoldCardModel:message];
}

- (void)handleFoldCardResponse:(GameMessage *)message
{
    if (message.resultCode == 0) {
        [self updateFoldCardModel:message];
    }
}

- (void)handleCompareCardRequest:(GameMessage *)message
{
//    [self updateCompareCardModel:message];
}

- (void)handleCompareCardResponse:(GameMessage *)message
{
//    if (message.resultCode == 0) {
//        [self updateCompareCardModel:message];
//    }
}

- (void)handleShowCardRequest:(GameMessage *)message
{
    [self updateShowCardModel:message];
}

- (void)handleShowCardResponse:(GameMessage *)message
{
    if (message.resultCode == 0) {
        [self updateShowCardModel:message];
    }
}

- (void)handleCustomMessage:(GameMessage*)message
{
    switch ([message command]){
        case GameCommandTypeBetDiceRequest:
            [self handleBetDiceRequest:message];
            break;
            
        case GameCommandTypeBetDiceResponse:
            [self handleBetDiceResponse:message];
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
    return @"192.168.1.8:8080";
}

@end
