//
//  GameNetworkClient.m
//  Draw
//
//  Created by  on 12-3-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GameNetworkClient.h"
#import "GameMessage.pb.h"
#import "LogUtil.h"

@implementation GameNetworkClient

static GameNetworkClient* _defaultGameNetworkClient;

#pragma LifeCycle Management

- (void)dealloc
{
    [super dealloc];
}

+ (GameNetworkClient*)defaultInstance
{
    if (_defaultGameNetworkClient != nil)
        return _defaultGameNetworkClient;
    
    _defaultGameNetworkClient = [[GameNetworkClient alloc] init];
    return _defaultGameNetworkClient;
}

- (void)start:(NSString*)serverAddress port:(int)port
{
    [self connect:serverAddress port:port autoReconnect:YES];
}

#pragma Data Handler

- (void)handleData:(NSData*)data
{
    @try
    {
        GameMessage *message = [GameMessage parseFromData:data];
        PPDebug(@"RECV MESSAGE, COMMAND = %d, RESULT = %d", [message command], [message resultCode]);
        if ([self.delegate respondsToSelector:@selector(handleData:)]){
            [self.delegate performSelector:@selector(handleData:) withObject:message];
        }
    }
    @catch(NSException* ex)
    {
        NSLog(@"catch exception while handleData, exception = %@", [ex debugDescription]);
    }
}

#pragma Message ID Methods

- (int)generateMessageId
{
    _messageIdIndex ++;
    return _messageIdIndex;
}

#pragma Methods

- (void)sendJoinGameRequest:(NSString*)userId 
                   nickName:(NSString*)nickName 
                     avatar:(NSString*)avatar
                  sessionId:(int)currentSessionId
          excludeSessionSet:(NSSet*)excludeSessionSet
{
    
    JoinGameRequest_Builder *requestBuilder = [[[JoinGameRequest_Builder alloc] init] autorelease];
    [requestBuilder setUserId:userId];
    [requestBuilder setGameId:@""];
    [requestBuilder setNickName:nickName];    
    [requestBuilder setAvatar:avatar];
    [requestBuilder addAllExcludeSessionId:[excludeSessionSet allObjects]];
    if (currentSessionId > 0){
        [requestBuilder setSessionToBeChange:currentSessionId];
    }

    GameMessage_Builder *messageBuilder = [[[GameMessage_Builder alloc] init] autorelease];
    [messageBuilder setCommand:GameCommandTypeJoinGameRequest];
    [messageBuilder setMessageId:[self generateMessageId]];
    [messageBuilder setJoinGameRequest:[requestBuilder build]];
    if (currentSessionId > 0){
        [messageBuilder setUserId:userId];
        [messageBuilder setSessionId:currentSessionId];
    }
    
    GameMessage* gameMessage = [messageBuilder build];
    [self sendData:[gameMessage data]];
}

- (void)sendStartGameRequest:(NSString*)userId sessionId:(long)sessionId
{
//    StartGameRequest_Builder *requestBuilder = [[[StartGameRequest_Builder alloc] init] autorelease];
//    [requestBuilder setUserId:userId];
//    [requestBuilder setSessionId:sessionId];
    
    GameMessage_Builder *messageBuilder = [[[GameMessage_Builder alloc] init] autorelease];
    [messageBuilder setCommand:GameCommandTypeStartGameRequest];
    [messageBuilder setMessageId:[self generateMessageId]];
    [messageBuilder setSessionId:sessionId];
    [messageBuilder setUserId:userId];
//    [messageBuilder setStartGameRequest:[requestBuilder build]];
    
    GameMessage* message = [messageBuilder build];
    [self sendData:[message data]];
}


- (void)sendDrawDataRequest:(NSString*)userId 
                  sessionId:(long)sessionId 
                  pointList:(NSArray*)pointList 
                      color:(int)color
                      width:(float)width
{
    SendDrawDataRequest_Builder *requestBuilder = [[[SendDrawDataRequest_Builder alloc] init] autorelease];
    [requestBuilder setColor:color];
    [requestBuilder addAllPoints:pointList];
    [requestBuilder setWidth:width];
    
    GameMessage_Builder *messageBuilder = [[[GameMessage_Builder alloc] init] autorelease];
    [messageBuilder setCommand:GameCommandTypeSendDrawDataRequest];
    [messageBuilder setMessageId:[self generateMessageId]];
    [messageBuilder setUserId:userId];
    [messageBuilder setSessionId:sessionId];
    [messageBuilder setSendDrawDataRequest:[requestBuilder build]];
    
    GameMessage* gameMessage = [messageBuilder build];
    [self sendData:[gameMessage data]];    
}

- (void)sendCleanDraw:(NSString*)userId 
            sessionId:(long)sessionId
{
    GameMessage_Builder *messageBuilder = [[[GameMessage_Builder alloc] init] autorelease];
    [messageBuilder setCommand:GameCommandTypeCleanDrawRequest];
    [messageBuilder setMessageId:[self generateMessageId]];
    [messageBuilder setUserId:userId];
    [messageBuilder setSessionId:sessionId];
    
    GameMessage* gameMessage = [messageBuilder build];
    [self sendData:[gameMessage data]];        
}

- (void)sendStartDraw:(NSString*)userId 
            sessionId:(long)sessionId
                 word:(NSString*)word 
                level:(int)level
{
    SendDrawDataRequest_Builder *requestBuilder = [[[SendDrawDataRequest_Builder alloc] init] autorelease];
    [requestBuilder setWord:word];
    [requestBuilder setLevel:level];
    
    GameMessage_Builder *messageBuilder = [[[GameMessage_Builder alloc] init] autorelease];
    [messageBuilder setCommand:GameCommandTypeSendDrawDataRequest];
    [messageBuilder setMessageId:[self generateMessageId]];
    [messageBuilder setUserId:userId];
    [messageBuilder setSessionId:sessionId];
    [messageBuilder setSendDrawDataRequest:[requestBuilder build]];
    
    GameMessage* gameMessage = [messageBuilder build];
    [self sendData:[gameMessage data]];    
}


@end
