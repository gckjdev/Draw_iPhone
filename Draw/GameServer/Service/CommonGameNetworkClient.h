//
//  CommonGameNetworkClient.h
//  Draw
//
//  Created by  on 12-7-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonNetworkClient.h"
#import "GameConstants.pb.h"

@class PBGameUser;

@interface CommonGameNetworkClient : CommonNetworkClient<CommonNetworkClientDelegate>
{
    int _messageIdIndex;    
}

+ (CommonGameNetworkClient*)defaultInstance;
- (void)start:(NSString*)serverAddress port:(int)port;

- (void)sendGetRoomsRequest:(NSString*)userId;
- (void)sendGetRoomsRequest:(NSString*)userId 
                 startIndex:(int)index 
                      count:(int)count;
- (void)sendJoinGameRequest:(PBGameUser*)user gameId:(NSString*)gameId;
- (void)sendJoinGameRequest:(PBGameUser*)user 
                     gameId:(NSString*)gameId 
                  sessionId:(long)sessionId;
- (int)generateMessageId;
- (void)sendSimpleMessage:(int)command
                   userId:(NSString*)userId 
                sessionId:(long)sessionId;
- (void)sendCreateRoomRequest:(PBGameUser*)user
                         name:(NSString*)roomName 
                       gameId:(NSString*)gameId 
                     password:(NSString*)password;
- (void)sendRegisterRoomsNotificationRequest:(NSArray*)sessionList 
                                      userId:(NSString*)userId;
- (void)sendUnRegisterRoomsNotificationRequest:(NSArray*)sessionList 
                                        userId:(NSString*)userId;

- (void)sendChatMessageRequest:(NSString *)content
                contentVoiceId:(NSString *)contentVoiceId
                  expressionId:(NSString *)expressionId
                     sessionId:(int)sessionId
                        userId:(NSString *)userId;
@end
