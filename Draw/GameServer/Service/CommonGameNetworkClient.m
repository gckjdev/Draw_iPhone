//
//  CommonGameNetworkClient.m
//  Draw
//
//  Created by  on 12-7-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommonGameNetworkClient.h"
#import "GameMessage.pb.h"
#import "LogUtil.h"
#import "GameConstants.h"

@implementation CommonGameNetworkClient

static CommonGameNetworkClient* _defaultGameNetworkClient;

#pragma LifeCycle Management

- (void)dealloc
{
    [super dealloc];
}

+ (CommonGameNetworkClient*)defaultInstance
{
    if (_defaultGameNetworkClient != nil)
        return _defaultGameNetworkClient;
    
    _defaultGameNetworkClient = [[CommonGameNetworkClient alloc] init];
    return _defaultGameNetworkClient;
}

- (void)start:(NSString*)serverAddress port:(int)port
{
    [self connect:serverAddress port:port autoReconnect:NO];
}

#pragma mark - Data Handler

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

#pragma mark - Message ID Methods

- (int)generateMessageId
{
    _messageIdIndex ++;
    return _messageIdIndex;
}

#pragma mark - Send Message

- (void)sendSimpleMessage:(int)command
                   userId:(NSString*)userId 
                sessionId:(long)sessionId
{
    GameMessage_Builder *messageBuilder = [[[GameMessage_Builder alloc] init] autorelease];
    [messageBuilder setCommand:command];
    [messageBuilder setMessageId:[self generateMessageId]];
    [messageBuilder setUserId:userId];
    [messageBuilder setSessionId:sessionId];
    
    GameMessage* gameMessage = [messageBuilder build];
    [self sendData:[gameMessage data]];                
}

- (void)sendGetRoomsRequest:(NSString*)userId
{
    [self sendSimpleMessage:GameCommandTypeGetRoomsRequest userId:userId sessionId:0];
}

- (void)sendCreateRoomRequest:(PBGameUser*)user
                         name:(NSString*)roomName 
                       gameId:(NSString*)gameId
{
    GameMessage_Builder *messageBuilder = [[[GameMessage_Builder alloc] init] autorelease];
    [messageBuilder setCommand:GameCommandTypeCreateRoomRequest];
    [messageBuilder setMessageId:[self generateMessageId]];
    [messageBuilder setUserId:user.userId];
    
    CreateRoomRequest_Builder* requestBuilder =[[[CreateRoomRequest_Builder alloc] init] autorelease]; 
    [requestBuilder setUser:user];
    [requestBuilder setRoomName:roomName];
    [requestBuilder setGameId:gameId];
    CreateRoomRequest* request = [requestBuilder build];
    [messageBuilder setCreateRoomRequest:request];
    
    GameMessage* gameMessage = [messageBuilder build];
    [self sendData:[gameMessage data]]; 
}

- (void)sendJoinGameRequest:(PBGameUser*)user gameId:(NSString*)gameId
{
    if (user == nil || gameId == nil)
        return;
    
    NSString* userId = [user userId];
    
    JoinGameRequest_Builder *requestBuilder = [[[JoinGameRequest_Builder alloc] init] autorelease];
    [requestBuilder setUserId:userId];
    [requestBuilder setGameId:gameId];
    [requestBuilder setNickName:[user nickName]];
    [requestBuilder setUser:user];

    GameMessage_Builder *messageBuilder = [[[GameMessage_Builder alloc] init] autorelease];
    [messageBuilder setCommand:GameCommandTypeJoinGameRequest];
    [messageBuilder setMessageId:[self generateMessageId]];
    [messageBuilder setJoinGameRequest:[requestBuilder build]];
    
    GameMessage* gameMessage = [messageBuilder build];
    [self sendData:[gameMessage data]];    
}

- (void)sendEnterRoomRequest:(long)sessionId 
                        user:(PBGameUser *)user 
{
    GameMessage_Builder *messageBuilder = [[[GameMessage_Builder alloc] init] autorelease];
    [messageBuilder setCommand:GameCommandTypeEnterRoomRequest];
    [messageBuilder setMessageId:[self generateMessageId]];
    [messageBuilder setUserId:user.userId];
    [messageBuilder setSessionId:sessionId];
    
    EnterRoomRequest* request;
    EnterRoomRequest_Builder* builder;
    
    // TODO no builder initialize here
    
    [builder setUser:user];
    request = [builder build];
    
    [messageBuilder setEnterRoomRequest:request];
    GameMessage* gameMessage = [messageBuilder build];
    [self sendData:[gameMessage data]];   
}

@end
