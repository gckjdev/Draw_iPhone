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
                      wilds:(BOOL)wilds
{
    CallDiceRequest_Builder *callDiceRequestBuilder = [[[CallDiceRequest_Builder alloc] init] autorelease];
    [callDiceRequestBuilder setDice:dice];
    [callDiceRequestBuilder setNum:count];
    [callDiceRequestBuilder setWilds:wilds];
    CallDiceRequest *callDiceRequest = [callDiceRequestBuilder build];
    
    GameMessage_Builder *messageBuilder = [[[GameMessage_Builder alloc] init] autorelease];
    [messageBuilder setCommand:GameCommandTypeCallDiceRequest];
    [messageBuilder setMessageId:[self generateMessageId]];
    [messageBuilder setUserId:userId];
    [messageBuilder setSessionId:sessionId];
    
    [messageBuilder setCallDiceRequest:callDiceRequest];
    
    GameMessage* gameMessage = [messageBuilder build];
    
    [self sendData:[gameMessage data]];  
}


//- (void)sendCallDiceRequest:(NSString*)userId
//                  sessionId:(int)sessionId
//                       dice:(int)dice
//                      count:(int)count
//{
//    CallDiceRequest_Builder *callDiceRequestBuilder = [[[CallDiceRequest_Builder alloc] init] autorelease];
//    [callDiceRequestBuilder setDice:dice];
//    [callDiceRequestBuilder setNum:count];
//    CallDiceRequest *callDiceRequest = [callDiceRequestBuilder build];
//    
//    GameMessage_Builder *messageBuilder = [[[GameMessage_Builder alloc] init] autorelease];
//    [messageBuilder setCommand:GameCommandTypeCallDiceRequest];
//    [messageBuilder setMessageId:[self generateMessageId]];
//    [messageBuilder setUserId:userId];
//    [messageBuilder setSessionId:sessionId];
//    
//    [messageBuilder setCallDiceRequest:callDiceRequest];
//    
//    GameMessage* gameMessage = [messageBuilder build];
//    
//    [self sendData:[gameMessage data]];  
//}

- (void)sendOpenDiceRequest:(NSString*)userId
                  sessionId:(int)sessionId
                   openType:(int)openType
{
    OpenDiceRequest_Builder *openDiceRequestBuilder = [[[OpenDiceRequest_Builder alloc] init] autorelease];
    [openDiceRequestBuilder setOpenType:openType];
    OpenDiceRequest *openDiceRequest = [openDiceRequestBuilder build];
    
    GameMessage_Builder *messageBuilder = [[[GameMessage_Builder alloc] init] autorelease];
    [messageBuilder setCommand:GameCommandTypeOpenDiceRequest];
    [messageBuilder setMessageId:[self generateMessageId]];
    [messageBuilder setUserId:userId];
    [messageBuilder setSessionId:sessionId];
    
    [messageBuilder setOpenDiceRequest:openDiceRequest];
    
    GameMessage* gameMessage = [messageBuilder build];
    
    [self sendData:[gameMessage data]];  
}

- (void)sendUserItemRequest:(NSString*)userId
                  sessionId:(int)sessionId
                     itemId:(int)itemId
{
    UseItemRequest_Builder *useItemRequestBuilder = [[[UseItemRequest_Builder alloc] init] autorelease];
    [useItemRequestBuilder setItemId:itemId];
    UseItemRequest *useItemRequest = [useItemRequestBuilder build];
    
    GameMessage_Builder *messageBuilder = [[[GameMessage_Builder alloc] init] autorelease];
    [messageBuilder setCommand:GameCommandTypeOpenDiceRequest];
    [messageBuilder setMessageId:[self generateMessageId]];
    [messageBuilder setUserId:userId];
    [messageBuilder setSessionId:sessionId];
    
    [messageBuilder setUseItemRequest:useItemRequest];
    
    GameMessage* gameMessage = [messageBuilder build];
    
    [self sendData:[gameMessage data]];  
}

@end
