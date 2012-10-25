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

- (void)showCard:(NSArray *)cardIds
{
    [_networkClient sendShowCardRequest:self.userId
                              sessionId:self.session.sessionId
                                cardIds:cardIds];
}

- (void)someoneBet:(NSString *)userId
         singleBet:(int)singleBet
             count:(int)count
         isAutoBet:(BOOL)isAutoBet
{
    _gameState.totalBet += singleBet * count;
    _gameState.singleBet = singleBet;
    
    [_gameState userInfo:userId].totalBet += singleBet * count;
    [_gameState userInfo:userId].isAutoBet = isAutoBet;
}


#pragma mark - overwrite methods

- (void)handleCustomMessage:(GameMessage*)message
{
    
}

- (void)handleJoinGameResponse:(GameMessage*)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([message resultCode] == 0){
            PBGameSession* pbSession = [[message joinGameResponse] gameSession];
            self.session = [self createSession];
            [self.session fromPBGameSession:pbSession userId:self.userId];
            
            self.gameState = [[[ZJHGameState alloc] init] autorelease];
            [_gameState fromPBZJHGameState:[[message joinGameResponse] zjhGameState]];
        }
        
        [self postNotification:NOTIFICATION_JOIN_GAME_RESPONSE message:message];
    });
}






@end
