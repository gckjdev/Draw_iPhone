//
//  CommonGameNetworkService.h
//  Draw
//
//  Created by  on 12-7-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonGameNetworkClient.h"

@protocol CommonGameServiceDelegate <NSObject>

- (void)didConnected;
- (void)didBroken;

@end

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


- (BOOL)isConnected;
- (void)connectServer:(id<CommonGameServiceDelegate>)delegate;
- (void)disconnectServer;

- (void)startDisconnectTimer;
- (void)clearDisconnectTimer;

- (void)getRoomList;
- (void)joinGameRequest;

@end
