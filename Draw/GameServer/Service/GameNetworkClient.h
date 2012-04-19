//
//  GameNetworkClient.h
//  Draw
//
//  Created by  on 12-3-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonNetworkClient.h"

#define PROLONG_GAME        @"PG"
#define ASK_QUICK_GAME      @"AG"

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
                  sessionId:(int)currentSessionId
          excludeSessionSet:(NSSet*)excludeSessionSet;

- (void)sendStartGameRequest:(NSString*)userId sessionId:(long)sessionId;

- (void)sendDrawDataRequest:(NSString*)userId 
                  sessionId:(long)sessionId 
                  pointList:(NSArray*)pointList 
                      color:(int)color
                      width:(float)width;

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



@end
