//
//  GameNetworkClient.h
//  Draw
//
//  Created by  on 12-3-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonNetworkClient.h"
#import "GameConstants.pb.h"

#define PROLONG_GAME        @"PG"
#define ASK_QUICK_GAME      @"AG"
#define NORMAL_CHAT         @"NC$$_$$"
#define EXPRESSION_CHAT     @"EC$$_$$"

@class PBGameUser;

@interface GameNetworkClient : CommonNetworkClient<CommonNetworkClientDelegate>
{
    int _messageIdIndex;
}

+ (GameNetworkClient*)defaultInstance;
- (void)start:(NSString*)serverAddress port:(int)port;

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
          excludeSessionSet:(NSSet*)excludeSessionSet;

- (void)sendStartGameRequest:(NSString*)userId sessionId:(long)sessionId;

- (void)sendDrawDataRequest:(NSString*)userId 
                  sessionId:(long)sessionId 
                  pointList:(NSArray*)pointList 
                      color:(int)color
                      width:(float)width               
                    penType:(int)penType;

// new interface
- (void)sendDrawActionRequest:(NSString*)userId
                    sessionId:(long)sessionId
                   drawAction:(PBDrawAction*)drawAction
                   canvasSize:(PBSize*)canvasSize;

- (void)sendCleanDraw:(NSString*)userId 
            sessionId:(long)sessionId;

- (void)sendStartDraw:(NSString*)userId 
            sessionId:(long)sessionId
                 word:(NSString*)word 
                level:(int)level
             language:(int)language;

- (void)sendProlongGame:(NSString*)userId 
              sessionId:(long)sessionId;

- (void)sendQuitGame:(NSString*)userId 
           sessionId:(long)sessionId;

- (void)sendAskQuickGame:(NSString*)userId 
               sessionId:(long)sessionId;

- (void)sendChatMessage:(NSString*)userId 
              sessionId:(long)sessionId
               userList:(NSArray*)userList
                message:(NSString*)message
               chatType:(GameChatType)chatType;

- (void)sendChatExpression:(NSString*)userId 
                 sessionId:(long)sessionId
                  userList:(NSArray*)userList
                       key:(NSString*)key
                  chatType:(GameChatType)chatType;

- (void)sendGuessWord:(NSString*)guessWord
          guessUserId:(NSString*)guessUserId
               userId:(NSString*)userId
            sessionId:(long)sessionId;


- (void)sendRankGameResult:(int)rank
                    userId:(NSString*)userId
                 sessionId:(long)sessionId
                     round:(int)round;

- (void)sendKeepAlive:(NSString*)userId
            sessionId:(long)sessionId;

- (int)stringToRank:(NSString*)rankString;
- (NSString*)rankToString:(int)rank;

- (void)sendGetRoomsRequest:(NSString*)userId;
- (void)sendGetRoomsRequest:(NSString*)userId
                 startIndex:(int)index
                      count:(int)count
                   roomType:(int)type
                    keyword:(NSString*)keyword
                     gameId:(NSString*)gameId;
- (void)sendJoinGameRequest:(PBGameUser*)user gameId:(NSString*)gameId;
- (void)sendJoinGameRequest:(PBGameUser*)user
                     gameId:(NSString*)gameId
                  sessionId:(long)sessionId;
- (void)sendCreateRoomRequest:(PBGameUser*)user
                         name:(NSString*)roomName
                       gameId:(NSString*)gameId
                     password:(NSString *)password;
@end
