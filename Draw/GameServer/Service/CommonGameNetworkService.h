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


@class PBGameSession;

@protocol CommonGameServiceDelegate <NSObject>

- (void)didConnected;
- (void)didBroken;

@end

@class CommonGameSession;
@class GameMessage;

@interface CommonGameNetworkService : NSObject<CommonNetworkClientDelegate>
{
    CommonGameNetworkClient         *_networkClient;    
    NSTimer                         *_disconnectTimer;
    id<CommonGameServiceDelegate>   _connectionDelegate;    
    
    NSString                        *_gameId;
    NSMutableArray                  *_roomList;

}

@property (nonatomic, retain) NSString       *serverAddress;
@property (nonatomic, assign) int            serverPort;
@property (nonatomic, retain) NSMutableArray *roomList;
@property (nonatomic, retain) CommonGameSession *session;
@property (nonatomic, retain) PBGameUser        *user;

- (BOOL)isConnected;
- (void)connectServer:(id<CommonGameServiceDelegate>)delegate;
- (void)disconnectServer;

- (void)startDisconnectTimer;
- (void)clearDisconnectTimer;

- (void)getRoomList;
- (void)getRoomList:(int)startIndex 
              count:(int)count 
   shouldReloadData:(BOOL)shouldReloadData;
- (void)joinGameRequest;
- (void)joinGameRequest:(long)sessionId;
- (BOOL)joinGameRequestWithCondiction:(BOOL (^)(void))condiction;
- (BOOL)joinGameRequest:(long)sessionId condiction:(BOOL (^)(void))condiction;

- (void)quitGame;

- (CommonGameSession*)createSession;
- (void)createRoomWithName:(NSString*)name 
                  password:(NSString*)password;

+ (GameMessage*)userInfoToMessage:(NSDictionary*)userInfo;
+ (NSDictionary*)messageToUserInfo:(GameMessage*)message;

- (void)postNotification:(NSString*)name message:(GameMessage*)message;
- (void)registerRoomsNotification:(NSArray*)sessionIdList;
- (void)unRegisterRoomsNotification:(NSArray*)sessionIdList;

- (PBGameSession*)sessionInRoom:(int)index;

- (void)chatWithContent:(NSString *)chatMsg contentVoiceId:(NSString *)contentVoiceId;
- (void)chatWithExpression:(NSString *)expression;

@end
