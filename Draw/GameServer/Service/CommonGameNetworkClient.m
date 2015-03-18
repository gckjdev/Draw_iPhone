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
#import "StringUtil.h"
#import "ShareGameServiceProtocol.h"

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

#pragma mark - Build Message With MAC

- (GameMessage*)build:(GameMessageBuilder*)builder
{
    [builder setTimeStamp:time(0)];
    NSString* strForEncode = [NSString stringWithFormat:@"%d%d", 
                              [builder messageId], [builder timeStamp]];
    
    [builder setMac:[strForEncode encodeMD5Base64:PROTOCOL_BUFFER_SHARE_KEY]]; 

//    PPDebug(@"[TEST] PB MAC=%@", [builder mac]);    
    return [builder build];
}

#pragma mark - Send Message

- (void)sendSimpleMessage:(int)command
                   userId:(NSString*)userId 
                sessionId:(long)sessionId
{
    GameMessageBuilder *messageBuilder = [[[GameMessageBuilder alloc] init] autorelease];
    [messageBuilder setCommand:command];
    [messageBuilder setMessageId:[self generateMessageId]];
    [messageBuilder setUserId:userId];
    [messageBuilder setSessionId:sessionId];
    
    GameMessage* gameMessage = [self build:messageBuilder];
    [self sendData:[gameMessage data]];                
}

- (void)sendGetRoomsRequest:(NSString*)userId
{
    [self sendSimpleMessage:GameCommandTypeGetRoomsRequest userId:userId sessionId:0];
}

- (void)sendRegisterRoomsNotificationRequest:(NSArray*)sessionList 
                                      userId:(NSString*)userId
{
    GameMessageBuilder *messageBuilder = [[[GameMessageBuilder alloc] init] autorelease];
    [messageBuilder setCommand:GameCommandTypeRegisterRoomsNotificationRequest];
    [messageBuilder setMessageId:[self generateMessageId]];
    [messageBuilder setUserId:userId];

    RegisterRoomsNotificationRequestBuilder* requestBuilder = [[[RegisterRoomsNotificationRequestBuilder alloc] init] autorelease];
    for (PBGameSession* session in sessionList) {
        [requestBuilder addSessionIds:session.sessionId];
    }
    
    [messageBuilder setRegisterRoomsNotificationRequest:[requestBuilder build]];
    GameMessage* gameMessage = [self build:messageBuilder];
    [self sendData:[gameMessage data]];   
}

- (void)sendUnRegisterRoomsNotificationRequest:(NSArray*)sessionList 
                                        userId:(NSString*)userId
{
    GameMessageBuilder *messageBuilder = [[[GameMessageBuilder alloc] init] autorelease];
    [messageBuilder setCommand:GameCommandTypeUnregisterRoomsNotificationRequest];
    [messageBuilder setMessageId:[self generateMessageId]];
    [messageBuilder setUserId:userId];
    
    UnRegisterRoomsNotificationRequestBuilder* requestBuilder = [[[UnRegisterRoomsNotificationRequestBuilder alloc] init] autorelease];
    for (PBGameSession* session in sessionList) {
        [requestBuilder addSessionIds:session.sessionId];
    }
    
    [messageBuilder setUnRegisterRoomsNotificationRequest:[requestBuilder build]];
    
    GameMessage* gameMessage = [self build:messageBuilder];
    [self sendData:[gameMessage data]];   
}

- (void)sendChatMessageRequest:(NSString *)content
                contentVoiceId:(NSString *)contentVoiceId
                  expressionId:(NSString *)expressionId
                     sessionId:(int)sessionId
                        userId:(NSString *)userId
{      
    GameChatRequestBuilder *builder = [[[GameChatRequestBuilder alloc] init] autorelease];
    
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
    
    GameMessageBuilder *messageBuilder = [[[GameMessageBuilder alloc] init] autorelease];
    [messageBuilder setCommand:GameCommandTypeChatRequest];
    [messageBuilder setMessageId:[self generateMessageId]];
    [messageBuilder setUserId:userId];
    [messageBuilder setSessionId:sessionId];

    [messageBuilder setChatRequest:chatRequest];
    
    GameMessage *gameMessage = [self build:messageBuilder];
    [self sendData:[gameMessage data]];
}



- (void)sendGetRoomsRequest:(NSString*)userId 
                 startIndex:(int)index 
                      count:(int)count
{
    GameMessageBuilder *messageBuilder = [[[GameMessageBuilder alloc] init] autorelease];
    [messageBuilder setCommand:GameCommandTypeGetRoomsRequest];
    [messageBuilder setMessageId:[self generateMessageId]];
    [messageBuilder setUserId:userId];
    [messageBuilder setSessionId:0];
    [messageBuilder setStartOffset:index];
    [messageBuilder setMaxCount:count];
    
    GameMessage* gameMessage = [self build:messageBuilder];
    [self sendData:[gameMessage data]]; 
}

- (void)sendGetRoomsRequest:(NSString*)userId 
                 startIndex:(int)index 
                      count:(int)count 
                   roomType:(int)type 
                    keyword:(NSString*)keyword 
                     gameId:(NSString*)gameId
{
    GameMessageBuilder *messageBuilder = [[[GameMessageBuilder alloc] init] autorelease];
    [messageBuilder setCommand:GameCommandTypeGetRoomsRequest];
    [messageBuilder setMessageId:[self generateMessageId]];
    [messageBuilder setUserId:userId];
    [messageBuilder setSessionId:0];
    [messageBuilder setStartOffset:index];
    [messageBuilder setMaxCount:count];
    
    GetRoomsRequestBuilder *getRoomsRequestBuilder = [[[GetRoomsRequestBuilder alloc] init] autorelease];
    [getRoomsRequestBuilder setGameId:gameId];
    [getRoomsRequestBuilder setRoomType:type];
    [getRoomsRequestBuilder setKeyword:keyword];
    
    [messageBuilder setGetRoomsRequest:[getRoomsRequestBuilder build]];    
    GameMessage* gameMessage = [self build:messageBuilder];
    [self sendData:[gameMessage data]]; 
}

- (void)sendCreateRoomRequest:(PBGameUser*)user
                         name:(NSString*)roomName 
                       gameId:(NSString*)gameId 
                     password:(NSString *)password
{
    GameMessageBuilder *messageBuilder = [[[GameMessageBuilder alloc] init] autorelease];
    [messageBuilder setCommand:GameCommandTypeCreateRoomRequest];
    [messageBuilder setMessageId:[self generateMessageId]];
    [messageBuilder setUserId:user.userId];
    
    CreateRoomRequestBuilder* requestBuilder =[[[CreateRoomRequestBuilder alloc] init] autorelease]; 
    [requestBuilder setUser:user];
    [requestBuilder setRoomName:roomName];
    [requestBuilder setGameId:gameId];
    [requestBuilder setPassword:password];
    CreateRoomRequest* request = [requestBuilder build];
    [messageBuilder setCreateRoomRequest:request];
    
    GameMessage* gameMessage = [self build:messageBuilder];
    [self sendData:[gameMessage data]]; 
}

- (void)sendCreateRoomRequest:(PBGameUser*)user
                         name:(NSString*)roomName 
                       gameId:(NSString*)gameId 
                     password:(NSString *)password
                     ruleType:(int)ruleType
{
    GameMessageBuilder *messageBuilder = [[[GameMessageBuilder alloc] init] autorelease];
    [messageBuilder setCommand:GameCommandTypeCreateRoomRequest];
    [messageBuilder setMessageId:[self generateMessageId]];
    [messageBuilder setUserId:user.userId];
    
    CreateRoomRequestBuilder* requestBuilder =[[[CreateRoomRequestBuilder alloc] init] autorelease]; 
    [requestBuilder setUser:user];
    [requestBuilder setRoomName:roomName];
    [requestBuilder setGameId:gameId];
    [requestBuilder setPassword:password];
    [requestBuilder setRuleType:ruleType];
    CreateRoomRequest* request = [requestBuilder build];
    [messageBuilder setCreateRoomRequest:request];
    
    GameMessage* gameMessage = [self build:messageBuilder];
    [self sendData:[gameMessage data]]; 
}

- (void)sendJoinGameRequest:(PBGameUser*)user gameId:(NSString*)gameId
{
    if (user == nil || gameId == nil)
        return;
    
    NSString* userId = [user userId];
    
    JoinGameRequestBuilder *requestBuilder = [[[JoinGameRequestBuilder alloc] init] autorelease];
    [requestBuilder setUserId:userId];
    [requestBuilder setGameId:gameId];
    [requestBuilder setNickName:[user nickName]];
    [requestBuilder setUser:user];

    GameMessageBuilder *messageBuilder = [[[GameMessageBuilder alloc] init] autorelease];
    [messageBuilder setCommand:GameCommandTypeJoinGameRequest];
    [messageBuilder setMessageId:[self generateMessageId]];
    [messageBuilder setJoinGameRequest:[requestBuilder build]];
    
    GameMessage* gameMessage = [self build:messageBuilder];
    [self sendData:[gameMessage data]];    
}

- (void)sendJoinGameRequest:(PBGameUser*)user 
                     gameId:(NSString*)gameId
                   ruleType:(int)ruleType
{
    if (user == nil || gameId == nil)
        return;
    
    NSString* userId = [user userId];
    
    JoinGameRequestBuilder *requestBuilder = [[[JoinGameRequestBuilder alloc] init] autorelease];
    [requestBuilder setUserId:userId];
    [requestBuilder setGameId:gameId];
    [requestBuilder setNickName:[user nickName]];
    [requestBuilder setUser:user];
    [requestBuilder setRuleType:ruleType];
    
    GameMessageBuilder *messageBuilder = [[[GameMessageBuilder alloc] init] autorelease];
    [messageBuilder setCommand:GameCommandTypeJoinGameRequest];
    [messageBuilder setMessageId:[self generateMessageId]];
    [messageBuilder setJoinGameRequest:[requestBuilder build]];
    
    GameMessage* gameMessage = [self build:messageBuilder];
    [self sendData:[gameMessage data]];    
}

- (void)sendJoinGameRequest:(PBGameUser*)user 
                     gameId:(NSString*)gameId 
                  sessionId:(long)sessionId
{
    if (user == nil || gameId == nil)
        return;
    
    NSString* userId = [user userId];
    
    JoinGameRequestBuilder *requestBuilder = [[[JoinGameRequestBuilder alloc] init] autorelease];
    [requestBuilder setUserId:userId];
    [requestBuilder setGameId:gameId];
    [requestBuilder setNickName:[user nickName]];
    [requestBuilder setUser:user];
    
    GameMessageBuilder *messageBuilder = [[[GameMessageBuilder alloc] init] autorelease];
    [messageBuilder setCommand:GameCommandTypeJoinGameRequest];
    [messageBuilder setMessageId:[self generateMessageId]];
    [messageBuilder setSessionId:sessionId];
    [messageBuilder setJoinGameRequest:[requestBuilder build]];
    
    GameMessage* gameMessage = [self build:messageBuilder];
    [self sendData:[gameMessage data]];    
}

- (void)sendJoinGameRequest:(PBGameUser*)user 
                     gameId:(NSString*)gameId 
                  sessionId:(long)sessionId
                   ruleType:(int)ruleType
{
    if (user == nil || gameId == nil)
        return;
    
    NSString* userId = [user userId];
    
    JoinGameRequestBuilder *requestBuilder = [[[JoinGameRequestBuilder alloc] init] autorelease];
    [requestBuilder setUserId:userId];
    [requestBuilder setGameId:gameId];
    [requestBuilder setNickName:[user nickName]];
    [requestBuilder setUser:user];
    [requestBuilder setRuleType:ruleType];
    
    GameMessageBuilder *messageBuilder = [[[GameMessageBuilder alloc] init] autorelease];
    [messageBuilder setCommand:GameCommandTypeJoinGameRequest];
    [messageBuilder setMessageId:[self generateMessageId]];
    [messageBuilder setSessionId:sessionId];
    [messageBuilder setJoinGameRequest:[requestBuilder build]];
    
    GameMessage* gameMessage = [self build:messageBuilder];
    [self sendData:[gameMessage data]];    
}

- (void)sendQuitGameRequest:(NSString*)userId
                  sessionId:(int)sessionId
{
    [self sendSimpleMessage:GameCommandTypeQuitGameRequest userId:userId sessionId:sessionId];
}

@end
