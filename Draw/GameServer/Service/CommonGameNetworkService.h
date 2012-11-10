//
//  CommonGameNetworkService.h
//  Draw
//
//  Created by  on 12-7-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonGameNetworkClient.h"

#define NOTIFICATION_JOIN_GAME_RESPONSE         @"NOTIFICATION_JOIN_GAME_RESPONSE"
#define NOTIFICATION_ENTER_ROOM_RESPONSE        @"NOTIFICATION_ENTER_ROOM_RESPONSE"
#define NOTIFICAIION_CREATE_ROOM_RESPONSE       @"NOTIFICAIION_CREATE_ROOM_RESPONSE"
#define NOTIFICAIION_GET_ROOMS_RESPONSE         @"NOTIFICAIION_GET_ROOMS_RESPONSE"
#define NOTIFICATION_ROOM                       @"NOTIFICATION_ROOM"
#define NOTIFICAIION_CHAT_REQUEST               @"NOTIFICAIION_CHAT_REQUEST"

#define NOTIFICATION_GAME_START_NOTIFICATION_REQUEST @"NOTIFICATION_GAME_START_NOTIFICATION_REQUEST"
#define NOTIFICATION_GAME_OVER_NOTIFICATION_REQUEST @"NOTIFICATION_GAME_OVER_NOTIFICATION_REQUEST"

#define NOTIFICATION_NEXT_PLAYER_START          @"NOTIFICATION_NEXT_PLAYER_START"

#define NOTIFICATION_NETWORK_CONNECTED          @"NOTIFICATION_NETWORK_CONNECTED"
#define NOTIFICATION_NETWORK_DISCONNECTED       @"NOTIFICATION_NETWORK_DISCONNECTED"


#define SERVER_LIST_SEPERATOR   @"$"
#define SERVER_PORT_SEPERATOR   @":"


@class PBGameSession;

/*@protocol CommonGameServiceDelegate <NSObject>

- (void)didConnected;
- (void)didBroken;

@end*/

@class CommonGameSession;
@class GameMessage;

@interface CommonGameNetworkService : NSObject<CommonNetworkClientDelegate>
{
    CommonGameNetworkClient         *_networkClient;    
    NSTimer                         *_disconnectTimer;
//    id<CommonGameServiceDelegate>   _connectionDelegate;
    
    NSString                        *_gameId;
    NSMutableArray                  *_roomList;
    NSInteger                       _onlineUserCount;
}

@property (nonatomic, retain) NSString              *serverStringList;
@property (nonatomic, retain) NSString              *serverAddress;
@property (nonatomic, assign) int                   serverPort;
@property (nonatomic, retain) NSMutableArray        *roomList;
@property (nonatomic, retain) CommonGameSession     *session;

- (BOOL)isConnected;
//- (void)connectServer:(id<CommonGameServiceDelegate>)delegate;
- (void)connectServer;
- (void)disconnectServer;

// Left to Sub Class to implementation.
- (NSString *)getServerListString;
- (void)handleMoreOnGameStartNotificationRequest:(GameMessage*)message;
- (void)handleMoreOnGameOverNotificationRequest:(GameMessage*)message;
- (void)handleMoreOnJoinGameResponse:(GameMessage*)message;

- (void)startDisconnectTimer;
- (void)clearDisconnectTimer;

- (void)getRoomList;
- (void)getRoomList:(int)startIndex 
              count:(int)count;

- (void)getRoomList:(int)startIndex 
              count:(int)count 
           roomType:(int)type
            keyword:(NSString*)keyword 
             gameId:(NSString*)gameId;

- (void)joinGameRequest;
- (void)joinGameRequestWithCustomUser:(PBGameUser*)customSelfUser;

- (void)joinGameRequest:(long)sessionId;
- (void)joinGameRequest:(long)sessionId customSelfUser:(PBGameUser*)customSelfUser;

- (void)quitGame;

- (CommonGameSession*)createSession;

- (void)createRoomWithName:(NSString*)name 
                  password:(NSString*)password;

+ (GameMessage*)userInfoToMessage:(NSDictionary*)userInfo;
+ (NSDictionary*)messageToUserInfo:(GameMessage*)message;

+ (NSDictionary*)errorToUserInfo:(NSError*)error;
+ (NSError*)userInfoToError:(NSDictionary*)userInfo;

- (void)postNotification:(NSString*)name message:(GameMessage*)message;
- (void)registerRoomsNotification:(NSArray*)sessionIdList;
- (void)unRegisterRoomsNotification:(NSArray*)sessionIdList;

- (PBGameSession*)sessionInRoom:(int)index;

- (void)chatWithContent:(NSString *)chatMsg contentVoiceId:(NSString *)contentVoiceId;
- (void)chatWithExpression:(NSString *)expression;

- (NSString*)userId;
- (int)onlineUserCount;

- (BOOL)isMyTurn;
- (BOOL)isGamePlaying;

@end
