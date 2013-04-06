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
#import "GameConstants.h"
#import "ShareGameServiceProtocol.h"
#import "StringUtil.h"

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
    [self connect:serverAddress port:port autoReconnect:NO];
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

- (void)sendJoinGameRequest:(NSString*)userId 
                   nickName:(NSString*)nickName 
                     avatar:(NSString*)avatar
                     gender:(BOOL)gender
                   location:(NSString*)location
                  userLevel:(int)userLevel
                snsUserList:(NSArray*)snsUserData
             guessDiffLevel:(int)guessDiffLevel
                  sessionId:(int)currentSessionId
                     roomId:(NSString*)roomId
                   roomName:(NSString*)roomName
          excludeSessionSet:(NSSet*)excludeSessionSet
{
    
    JoinGameRequest_Builder *requestBuilder = [[[JoinGameRequest_Builder alloc] init] autorelease];
    [requestBuilder setUserId:userId];
    [requestBuilder setGameId:@""];
    [requestBuilder setNickName:nickName];    
    [requestBuilder setAvatar:avatar];
    [requestBuilder setGender:gender];
    [requestBuilder setGuessDifficultLevel:guessDiffLevel];
    [requestBuilder setRoomName:roomName];
    [requestBuilder setUserLevel:userLevel];
    [requestBuilder setVersion:1];                  // new version
    

    if ([snsUserData count] > 0){
        [requestBuilder addAllSnsUsers:snsUserData];
    }
    
    if ([location length] > 0){
        [requestBuilder setLocation:location];
    }
    
    if ([roomId length] > 0){
        [requestBuilder setRoomId:roomId];
    }

    if ([excludeSessionSet count] > 0){
        [requestBuilder addAllExcludeSessionId:[excludeSessionSet allObjects]];
    }
    
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
    [self sendSimpleMessage:GameCommandTypeStartGameRequest userId:userId sessionId:sessionId];    
}

- (void)sendDrawActionRequest:(NSString*)userId
                    sessionId:(long)sessionId
                   drawAction:(PBDrawAction*)drawAction
                   canvasSize:(PBSize*)canvasSize
{
    SendDrawDataRequest_Builder *requestBuilder = [[[SendDrawDataRequest_Builder alloc] init] autorelease];
//    [requestBuilder setColor:color];
//    [requestBuilder addAllPoints:pointList];
//    [requestBuilder setWidth:width];
//    [requestBuilder setPenType:penType];

    if (drawAction != nil){
        [requestBuilder setDrawAction:drawAction];
    }
    
    if (canvasSize != nil){
        [requestBuilder setCanvasSize:canvasSize];
    }
    
    GameMessage_Builder *messageBuilder = [[[GameMessage_Builder alloc] init] autorelease];
    [messageBuilder setCommand:GameCommandTypeSendDrawDataRequest];
    [messageBuilder setMessageId:[self generateMessageId]];
    [messageBuilder setUserId:userId];
    [messageBuilder setSessionId:sessionId];
    [messageBuilder setSendDrawDataRequest:[requestBuilder build]];
    
    GameMessage* gameMessage = [messageBuilder build];
    [self sendData:[gameMessage data]];
}

- (void)sendDrawDataRequest:(NSString*)userId 
                  sessionId:(long)sessionId 
                  pointList:(NSArray*)pointList 
                      color:(int)color
                      width:(float)width 
                    penType:(int)penType
{
    SendDrawDataRequest_Builder *requestBuilder = [[[SendDrawDataRequest_Builder alloc] init] autorelease];
    [requestBuilder setColor:color];
    [requestBuilder addAllPoints:pointList];
    [requestBuilder setWidth:width];
    [requestBuilder setPenType:penType];
    
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
    [self sendSimpleMessage:GameCommandTypeCleanDrawRequest userId:userId sessionId:sessionId];
}

- (void)sendStartDraw:(NSString*)userId 
            sessionId:(long)sessionId
                 word:(NSString*)word 
                level:(int)level
             language:(int)language
{
    SendDrawDataRequest_Builder *requestBuilder = [[[SendDrawDataRequest_Builder alloc] init] autorelease];
    [requestBuilder setWord:word];
    [requestBuilder setLevel:level];
    [requestBuilder setLanguage:language];
    
    GameMessage_Builder *messageBuilder = [[[GameMessage_Builder alloc] init] autorelease];
    [messageBuilder setCommand:GameCommandTypeSendDrawDataRequest];
    [messageBuilder setMessageId:[self generateMessageId]];
    [messageBuilder setUserId:userId];
    [messageBuilder setSessionId:sessionId];
    [messageBuilder setSendDrawDataRequest:[requestBuilder build]];
    
    GameMessage* gameMessage = [messageBuilder build];
    [self sendData:[gameMessage data]];    
}

- (void)sendGuessWord:(NSString*)guessWord
          guessUserId:(NSString*)guessUserId
               userId:(NSString*)userId
            sessionId:(long)sessionId
{
    SendDrawDataRequest_Builder *requestBuilder = [[[SendDrawDataRequest_Builder alloc] init] autorelease];
    [requestBuilder setGuessWord:guessWord];
    [requestBuilder setGuessUserId:guessUserId];
    
    GameMessage_Builder *messageBuilder = [[[GameMessage_Builder alloc] init] autorelease];
    [messageBuilder setCommand:GameCommandTypeSendDrawDataRequest];
    [messageBuilder setMessageId:[self generateMessageId]];
    [messageBuilder setUserId:userId];
    [messageBuilder setSessionId:sessionId];
    [messageBuilder setSendDrawDataRequest:[requestBuilder build]];
    
    GameMessage* gameMessage = [messageBuilder build];
    [self sendData:[gameMessage data]];    

}

- (void)sendChatMessage:(NSString*)userId 
              sessionId:(long)sessionId
             toUserList:(NSArray*)toUserList
                content:(NSString*)content
               chatType:(GameChatType)chatType
                  round:(int)round
{
    GameChatRequest_Builder *requestBuilder = [[[GameChatRequest_Builder alloc] init] autorelease];
    if (content != nil){
        [requestBuilder setContent:content];
    }
    if (toUserList != nil){
        [requestBuilder addAllToUserId:toUserList];
    }
    
    [requestBuilder setChatType:chatType];
    
    GameMessage_Builder *messageBuilder = [[[GameMessage_Builder alloc] init] autorelease];
    [messageBuilder setCommand:GameCommandTypeChatRequest];
    [messageBuilder setMessageId:[self generateMessageId]];
    [messageBuilder setUserId:userId];
    [messageBuilder setSessionId:sessionId];
    [messageBuilder setChatRequest:[requestBuilder build]];
    [messageBuilder setRound:round];    
    
    GameMessage* gameMessage = [messageBuilder build];
    [self sendData:[gameMessage data]];                
}

- (void)sendChatMessage:(NSString*)userId 
              sessionId:(long)sessionId
             toUserList:(NSArray*)toUserList
                content:(NSString*)content
               chatType:(GameChatType)chatType
{
    [self sendChatMessage:userId
                sessionId:sessionId
               toUserList:toUserList
                  content:content
                 chatType:chatType
                    round:0];
}

- (void)sendProlongGame:(NSString*)userId 
              sessionId:(long)sessionId
{
    [self sendChatMessage:userId 
                sessionId:sessionId 
               toUserList:nil 
                  content:PROLONG_GAME
                 chatType:GameChatTypeChatGroup];
}

- (void)sendAskQuickGame:(NSString*)userId 
               sessionId:(long)sessionId
{
    [self sendChatMessage:userId 
                sessionId:sessionId 
               toUserList:nil 
                  content:ASK_QUICK_GAME
                 chatType:GameChatTypeChatGroup];
}

- (void)sendChatMessage:(NSString*)userId 
              sessionId:(long)sessionId
               userList:(NSArray*)userList
                message:(NSString*)message
               chatType:(GameChatType)chatType
{
    [self sendChatMessage:userId 
                sessionId:sessionId 
               toUserList:userList 
                  content:[NORMAL_CHAT stringByAppendingString:message]
                 chatType:chatType];
}

- (void)sendChatExpression:(NSString*)userId 
                 sessionId:(long)sessionId
                  userList:(NSArray*)userList
                   key:(NSString*)key
                  chatType:(GameChatType)chatType
{
    [self sendChatMessage:userId 
                sessionId:sessionId 
               toUserList:userList 
                  content:[EXPRESSION_CHAT stringByAppendingString:key]
                 chatType:chatType];
}

- (void)sendQuitGame:(NSString*)userId 
           sessionId:(long)sessionId
{
    [self sendSimpleMessage:GameCommandTypeQuitGameRequest userId:userId sessionId:sessionId];    
}

- (NSString*)rankToString:(int)rank
{
    return [NSString stringWithFormat:@"%@%d", CHAT_COMMAND_RANK, rank];
}

- (int)stringToRank:(NSString*)rankString
{
    NSString* str = [rankString stringByReplacingOccurrencesOfString:CHAT_COMMAND_RANK withString:@""];
    return [str intValue];
}

- (void)sendRankGameResult:(int)rank
                    userId:(NSString*)userId
                 sessionId:(long)sessionId
                     round:(int)round
{
    [self sendChatMessage:userId 
                sessionId:sessionId 
               toUserList:nil 
                  content:[self rankToString:rank]
                 chatType:GameChatTypeChatGroup
                    round:round];
}

- (void)sendKeepAlive:(NSString*)userId
            sessionId:(long)sessionId
{
    [self sendSimpleMessage:GameCommandTypeKeepAliveRequest userId:userId sessionId:sessionId];        
}

#pragma mark - Build Message With MAC

- (GameMessage*)build:(GameMessage_Builder*)builder
{
    [builder setTimeStamp:time(0)];
    NSString* strForEncode = [NSString stringWithFormat:@"%d%d",
                              [builder messageId], [builder timeStamp]];
    
    [builder setMac:[strForEncode encodeMD5Base64:PROTOCOL_BUFFER_SHARE_KEY]];
    
    //    PPDebug(@"[TEST] PB MAC=%@", [builder mac]);
    return [builder build];
}

#pragma mark - for room list request
- (void)sendGetRoomsRequest:(NSString*)userId
{
    [self sendSimpleMessage:GameCommandTypeGetRoomsRequest userId:userId sessionId:0];
}

- (void)sendGetRoomsRequest:(NSString*)userId
                 startIndex:(int)index
                      count:(int)count
                   roomType:(int)type
                    keyword:(NSString*)keyword
                     gameId:(NSString*)gameId
{
    GameMessage_Builder *messageBuilder = [[[GameMessage_Builder alloc] init] autorelease];
    [messageBuilder setCommand:GameCommandTypeGetRoomsRequest];
    [messageBuilder setMessageId:[self generateMessageId]];
    [messageBuilder setUserId:userId];
    [messageBuilder setSessionId:0];
    [messageBuilder setStartOffset:index];
    [messageBuilder setMaxCount:count];
    
    GetRoomsRequest_Builder *getRoomsRequestBuilder = [[[GetRoomsRequest_Builder alloc] init] autorelease];
    [getRoomsRequestBuilder setGameId:gameId];
    [getRoomsRequestBuilder setRoomType:type];
    [getRoomsRequestBuilder setKeyword:keyword];
    
    [messageBuilder setGetRoomsRequest:[getRoomsRequestBuilder build]];
    GameMessage* gameMessage = [self build:messageBuilder];
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
    [requestBuilder setAvatar:[user avatar]];
    [requestBuilder setGender:[user gender]];    
    [requestBuilder setUser:user];
    [requestBuilder setUserLevel:user.level];
    [requestBuilder setVersion:1];                  // new version
    
    GameMessage_Builder *messageBuilder = [[[GameMessage_Builder alloc] init] autorelease];
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
    
    JoinGameRequest_Builder *requestBuilder = [[[JoinGameRequest_Builder alloc] init] autorelease];
    [requestBuilder setUserId:userId];
    [requestBuilder setGameId:gameId];
    [requestBuilder setNickName:[user nickName]];
    [requestBuilder setAvatar:[user avatar]];
    [requestBuilder setGender:[user gender]];
    [requestBuilder setUser:user];
    [requestBuilder setUserLevel:user.level];
    [requestBuilder setVersion:1];                  // new version
    
    GameMessage_Builder *messageBuilder = [[[GameMessage_Builder alloc] init] autorelease];
    [messageBuilder setCommand:GameCommandTypeJoinGameRequest];
    [messageBuilder setMessageId:[self generateMessageId]];
    [messageBuilder setSessionId:sessionId];
    [messageBuilder setJoinGameRequest:[requestBuilder build]];
    
    GameMessage* gameMessage = [self build:messageBuilder];
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
    [requestBuilder setVersion:1];
    CreateRoomRequest* request = [requestBuilder build];
    [messageBuilder setCreateRoomRequest:request];
    
    GameMessage* gameMessage = [self build:messageBuilder];
    [self sendData:[gameMessage data]];
}

@end
