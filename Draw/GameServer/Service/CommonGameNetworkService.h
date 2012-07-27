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



@end

@interface CommonGameNetworkService : NSObject
{
    CommonGameNetworkClient         *_networkClient;    
    NSTimer                         *_disconnectTimer;
    id<CommonGameServiceDelegate>   _connectionDelegate;    
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

@end
