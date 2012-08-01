//
//  CommonGameNetworkService.h
//  Draw
//
//  Created by  on 12-7-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonGameNetworkClient.h"

#define NOTIFICATION_JOIN_GAME_RESPONSE @"NOTIFICATION_JOIN_GAME_RESPONSE"
#define NOTIFICATION_ROOM               @"NOTIFICATION_ROOM"

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
- (void)joinGameRequest;

- (void)quitGame;

- (CommonGameSession*)createSession;

+ (GameMessage*)userInfoToMessage:(NSDictionary*)userInfo;
+ (NSDictionary*)messageToUserInfo:(GameMessage*)message;

@end
