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
#import "ZJHGameSession.h"

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

- (CommonGameSession *)createSession
{
    return [[[ZJHGameSession alloc] init] autorelease];
}

- (ZJHGameSession *)ZJHGameSession
{
    return (ZJHGameSession *)self.session;
}


#pragma mark - public methods
//- (void)bet
//{
//    [_networkClient sendBetRequest:self.userId
//                         sessionId:self.session.sessionId
//                         singleBet:self.session.singleBet
//                             count:[]
//                         isAutoBet:FALSE];
//}
//
//- (void)raiseBet:(int)singleBet;                               // 加注
//{
//    [_networkClient sendBetRequest:self.userId
//                         sessionId:self.session.sessionId
//                         singleBet:singleBet
//                             count:[]
//                         isAutoBet:FALSE];
//}

//- (void)autoBet;                                // 自动跟注

//- (void)raiseBet;                               // 加注
//
//- (void)checkCard;                              // 看牌
//- (void)foldCard;                               // 弃牌
//- (void)compareCard:(NSString*)toUserId;        // 比牌
//- (void)showCard:(NSArray *)cardIds;            // 亮牌


@end
