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

- (void)sendRegisterRoomsNotificationRequest:(NSArray*)sessionList 
                                      userId:(NSString*)userId
{
    GameMessage_Builder *messageBuilder = [[[GameMessage_Builder alloc] init] autorelease];
    [messageBuilder setCommand:GameCommandTypeRegisterRoomsNotificationRequest];
    [messageBuilder setMessageId:[self generateMessageId]];
    [messageBuilder setUserId:userId];

    RegisterRoomsNotificationRequest_Builder* request_builder = [[[RegisterRoomsNotificationRequest_Builder alloc] init] autorelease];
    for (PBGameSession* session in sessionList) {
        [request_builder addSessionIds:session.sessionId];
    }
    
    [messageBuilder setRegisterRoomsNotificationRequest:[request_builder build]];
    GameMessage* gameMessage = [messageBuilder build];
    [self sendData:[gameMessage data]];   
}

- (void)sendUnRegisterRoomsNotificationRequest:(NSArray*)sessionList 
                                        userId:(NSString*)userId
{
    GameMessage_Builder *messageBuilder = [[[GameMessage_Builder alloc] init] autorelease];
    [messageBuilder setCommand:GameCommandTypeUnregisterRoomsNotificationRequest];
    [messageBuilder setMessageId:[self generateMessageId]];
    [messageBuilder setUserId:userId];
    
    UnRegisterRoomsNotificationRequest_Builder* request_builder = [[[UnRegisterRoomsNotificationRequest_Builder alloc] init] autorelease];
    for (PBGameSession* session in sessionList) {
        [request_builder addSessionIds:session.sessionId];
    }
    
    [messageBuilder setUnRegisterRoomsNotificationRequest:[request_builder build]];
    
    GameMessage* gameMessage = [messageBuilder build];
    [self sendData:[gameMessage data]];   
}

- (void)sendChatMessageRequest:(NSString *)content
                contentVoiceId:(NSString *)contentVoiceId
                  expressionId:(NSString *)expressionId
                     sessionId:(int)sessionId
                        userId:(NSString *)userId
{      
    GameChatRequest_Builder *builder = [[[GameChatRequest_Builder alloc] init] autorelease];
    
    if (content != nil && expressionId == nil) {
        [builder setContent:content];
        [builder setContentVoiceId:contentVoiceId];
        [builder setContentType:1];
    }
    
    if (content == nil && expressionId != nil) {
        [builder setExpressionId:expressionId];
        [builder setContentType:2];
    }

    GameChatRequest *chatRequest = [builder build];
    
    GameMessage_Builder *messageBuilder = [[[GameMessage_Builder alloc] init] autorelease];
    [messageBuilder setCommand:GameCommandTypeChatRequest];
    [messageBuilder setMessageId:[self generateMessageId]];
    [messageBuilder setUserId:userId];
    [messageBuilder setSessionId:sessionId];

    [messageBuilder setChatRequest:chatRequest];
    
    GameMessage *gameMessage = [messageBuilder build];
    [self sendData:[gameMessage data]];
}



- (void)sendGetRoomsRequest:(NSString*)userId 
                 startIndex:(int)index 
                      count:(int)count
{
    GameMessage_Builder *messageBuilder = [[[GameMessage_Builder alloc] init] autorelease];
    [messageBuilder setCommand:GameCommandTypeGetRoomsRequest];
    [messageBuilder setMessageId:[self generateMessageId]];
    [messageBuilder setUserId:userId];
    [messageBuilder setSessionId:0];
    [messageBuilder setStartOffset:index];
    [messageBuilder setMaxCount:count];
    
    GameMessage* gameMessage = [messageBuilder build];
    [self sendData:[gameMessage data]]; 
}

- (void)sendCreateRoomRequest:(PBGameUser*)user
                         name:(NSString*)roomName 
                       gameId:(NSString*)gameId 
                     password:(NSString *)password
{
    GameMessage_Builder *messageBuilder = [[[GameMessage_Builder alloc] init] autorelease];
    [messageBuilder setCommand:GameCommandTypeCreateRoomRequest];
    [messageBuilder setMessageId:[self generateMessageId]];
    [messageBuilder setUserId:user.userId];
    
    CreateRoomRequest_Builder* requestBuilder =[[[CreateRoomRequest_Builder alloc] init] autorelease]; 
    [requestBuilder setUser:user];
    [requestBuilder setRoomName:roomName];
    [requestBuilder setGameId:gameId];
    [requestBuilder setPassword:password];
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

- (void)sendJoinGameRequest:(PBGameUser*)user 
                     gameId:(NSString*)gameId 
                  sessionId:(long)sessionId
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
    [messageBuilder setSessionId:sessionId];
    [messageBuilder setJoinGameRequest:[requestBuilder build]];
    
    GameMessage* gameMessage = [messageBuilder build];
    [self sendData:[gameMessage data]];    
}

@end
