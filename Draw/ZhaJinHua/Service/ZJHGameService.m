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

static ZJHGameService *_defaultService;

@interface ZJHGameService ()

@end

@implementation ZJHGameService

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

- (ZJHGameSession *)ZJHGameSession
{
    return (ZJHGameSession *)self.session;
}

- (void)bet
{
    [_networkClient sendBetRequest:self.userId
                         sessionId:[[self ZJHGameSession] sessionId]
                         singleBet:[[self ZJHGameSession] singleBet]
                             count:[[self ZJHGameSession] betCountOfUser:self.userId]
                         isAutoBet:FALSE];
}

- (void)raiseBet:(int)singleBet
{
    [_networkClient sendBetRequest:self.userId
                         sessionId:[[self ZJHGameSession] sessionId]
                         singleBet:singleBet
                             count:[[self ZJHGameSession] betCountOfUser:self.userId]
                         isAutoBet:FALSE];
}

- (void)autoBet
{
    [_networkClient sendBetRequest:self.userId
                         sessionId:[[self ZJHGameSession] sessionId]
                         singleBet:[[self ZJHGameSession] singleBet]
                             count:[[self ZJHGameSession] betCountOfUser:self.userId]
                         isAutoBet:TRUE];
}

- (void)checkCard
{
    [_networkClient sendCheckCardRequest:self.userId
                               sessionId:[[self ZJHGameSession] sessionId]];
}

- (void)foldCard
{
    [_networkClient sendFoldCardRequest:self.userId
                              sessionId:[[self ZJHGameSession] sessionId]];
}

- (void)compareCard:(NSString*)toUserId
{
    [_networkClient sendCompareCardRequest:self.userId
                                 sessionId:[[self ZJHGameSession] sessionId]
                                  toUserId:toUserId];
}

- (void)showCard:(NSArray *)cardIds
{
    [_networkClient sendShowCardRequest:self.userId
                              sessionId:[[self ZJHGameSession] sessionId]
                                cardIds:cardIds];
}

- (void)someoneBet:(NSString *)userId
         singleBet:(int)singleBet
             count:(int)count
         isAutoBet:(BOOL)isAutoBet
{
    [self ZJHGameSession].totalBet += singleBet * count;
    [self ZJHGameSession].singleBet = singleBet;
    
    [[self ZJHGameSession] userInfo:userId].totalBet += singleBet * count;
    [[self ZJHGameSession] userInfo:userId].isAutoBet = isAutoBet;
}


#pragma mark - overwrite methods

- (CommonGameSession *)createSession
{
    return [[[ZJHGameSession alloc] init] autorelease];
}

- (void)handleCustomMessage:(GameMessage*)message
{
}





@end
