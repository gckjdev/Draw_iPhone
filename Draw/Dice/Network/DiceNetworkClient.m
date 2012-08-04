//
//  DiceNetworkClient.m
//  Draw
//
//  Created by  on 12-7-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DiceNetworkClient.h"
#import "GameMessage.pb.h"

@implementation DiceNetworkClient

- (void)sendCallDiceRequest:(NSString*)userId
                  sessionId:(int)sessionId
                       dice:(int)dice
                      count:(int)count
{
    GameMessage_Builder *messageBuilder = [[[GameMessage_Builder alloc] init] autorelease];
    [messageBuilder setCommand:GameCommandTypeCallDiceRequest];
    [messageBuilder setMessageId:[self generateMessageId]];
    [messageBuilder setUserId:userId];
    [messageBuilder setSessionId:sessionId];
    
    CallDiceRequest_Builder *callDiceRequestBuilder = [[[CallDiceRequest_Builder alloc] init] autorelease];
    [callDiceRequestBuilder setDice:dice];
    [callDiceRequestBuilder setNum:count];
    CallDiceRequest *callDiceRequest = [callDiceRequestBuilder build];
    
    [messageBuilder setCallDiceRequest:callDiceRequest];
    
    GameMessage* gameMessage = [messageBuilder build];
    
    [self sendData:[gameMessage data]];  
}

@end
