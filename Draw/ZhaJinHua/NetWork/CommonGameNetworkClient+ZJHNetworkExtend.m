//
//  ZJHNetworkClient.m
//  Draw
//
//  Created by 王 小涛 on 12-10-24.
//
//

#import "CommonGameNetworkClient+ZJHNetworkExtend.h"
#import "GameMessage.pb.h"

@implementation CommonGameNetworkClient (ZJHNetworkExtend)

- (void)sendBetRequest:(NSString *)userId
             sessionId:(int)sessionId
             singleBet:(int)singleBet
                 count:(int)count
             isAutoBet:(BOOL)isAutoBet
{
    BetRequest_Builder *betRequestBuilder = [[[BetRequest_Builder alloc] init] autorelease];
    [betRequestBuilder setSingleBet:singleBet];
    [betRequestBuilder setCount:count];
    [betRequestBuilder setIsAutoBet:isAutoBet];
    BetRequest *betRequest = [betRequestBuilder build];
    
    GameMessage_Builder *messageBuilder = [[[GameMessage_Builder alloc] init] autorelease];
    [messageBuilder setCommand:GameCommandTypeBetDiceRequest];
    [messageBuilder setMessageId:[self generateMessageId]];
    [messageBuilder setUserId:userId];
    [messageBuilder setSessionId:sessionId];
    [messageBuilder setBetRequest:betRequest];
    
    GameMessage* gameMessage = [self build:messageBuilder];
    [self sendData:[gameMessage data]];
}


- (void)sendCheckCardRequest:(NSString *)userId
                   sessionId:(int)sessionId
{
    GameMessage_Builder *messageBuilder = [[[GameMessage_Builder alloc] init] autorelease];
    [messageBuilder setCommand:GameCommandTypeCheckCardRequest];
    [messageBuilder setMessageId:[self generateMessageId]];
    [messageBuilder setUserId:userId];
    [messageBuilder setSessionId:sessionId];
    
    GameMessage* gameMessage = [self build:messageBuilder];
    [self sendData:[gameMessage data]];
}

- (void)sendFoldCardRequest:(NSString *)userId
                  sessionId:(int)sessionId
{
    GameMessage_Builder *messageBuilder = [[[GameMessage_Builder alloc] init] autorelease];
    [messageBuilder setCommand:GameCommandTypeFoldCardRequest];
    [messageBuilder setMessageId:[self generateMessageId]];
    [messageBuilder setUserId:userId];
    [messageBuilder setSessionId:sessionId];
    
    GameMessage* gameMessage = [self build:messageBuilder];
    [self sendData:[gameMessage data]];
}

- (void)sendCompareCardRequest:(NSString *)userId
                     sessionId:(int)sessionId
                      toUserId:(NSString *)toUserId
{
    CompareCardRequest_Builder *compareCardRequestBuilder = [[[CompareCardRequest_Builder alloc] init] autorelease];
    [compareCardRequestBuilder setToUserId:toUserId];
    CompareCardRequest *compareCardRequest = [compareCardRequestBuilder build];
    
    GameMessage_Builder *messageBuilder = [[[GameMessage_Builder alloc] init] autorelease];
    [messageBuilder setCommand:GameCommandTypeCompareCardRequest];
    [messageBuilder setMessageId:[self generateMessageId]];
    [messageBuilder setUserId:userId];
    [messageBuilder setSessionId:sessionId];
    [messageBuilder setCompareCardRequest:compareCardRequest];
    
    GameMessage* gameMessage = [self build:messageBuilder];
    [self sendData:[gameMessage data]];
}

- (void)sendShowCardRequest:(NSString *)userId
                  sessionId:(int)sessionId
                    cardIds:(NSArray *)cardIds
{
    GameMessage_Builder *messageBuilder = [[[GameMessage_Builder alloc] init] autorelease];
    [messageBuilder setCommand:GameCommandTypeShowCardRequest];
    [messageBuilder setMessageId:[self generateMessageId]];
    [messageBuilder setUserId:userId];
    [messageBuilder setSessionId:sessionId];
    
    GameMessage* gameMessage = [self build:messageBuilder];
    [self sendData:[gameMessage data]];
}

@end
