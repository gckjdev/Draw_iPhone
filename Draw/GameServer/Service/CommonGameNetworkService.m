//
//  CommonGameNetworkService.m
//  Draw
//
//  Created by  on 12-7-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommonGameNetworkService.h"
#import "GameMessage.pb.h"
#import "PPDebug.h"
#import "UIUtils.h"
#import "UserManager.h"

@implementation CommonGameNetworkService

@synthesize serverAddress = _serverAddress;
@synthesize serverPort = _serverPort;
@synthesize roomList = _roomList;

- (void)dealloc
{    
    [self clearDisconnectTimer];
    [_serverAddress release];
    
    PPRelease(_serverAddress);   
    PPRelease(_roomList);
    
    [_networkClient disconnect];
    PPRelease(_networkClient);
    [super dealloc];
}

- (id)init
{
    self = [super init];

    _roomList = [[NSMutableArray alloc] init];
    
//    _networkClient = [[CommonGameNetworkClient alloc] init];
//    [_networkClient setDelegate:self]; 
    return self;
}

#pragma mark - Connect & Disconnect Handling

#define DISCONNECT_TIMER_INTERVAL   10

- (void)startDisconnectTimer
{
    [self clearDisconnectTimer];
    
    if ([self isConnected] == NO){
        PPDebug(@"<startDisconnectTimer> but server not connected");
        return;
    }
    
    PPDebug(@"Set disconnect timer after %d seconds", DISCONNECT_TIMER_INTERVAL);
    
    _disconnectTimer = [NSTimer scheduledTimerWithTimeInterval:DISCONNECT_TIMER_INTERVAL 
                                                        target:self 
                                                      selector:@selector(handleDisconnect:) 
                                                      userInfo:nil 
                                                       repeats:NO];
    [_disconnectTimer retain];
}

- (void)clearDisconnectTimer
{
    if (_disconnectTimer){
        PPDebug(@"Clear disconnect timer");
        if ([_disconnectTimer isValid]){
            [_disconnectTimer invalidate];
        }
        [_disconnectTimer release];
        _disconnectTimer = nil;
    }        
}

- (void)handleDisconnect:(NSTimer*)theTimer
{
    PPDebug(@"Fire disconnect timer");
    [self disconnectServer];
}

- (BOOL)isConnected
{
    return [_networkClient isConnected];
}

- (void)connectServer:(id<CommonGameServiceDelegate>)connectionDelegate
{
    _connectionDelegate = connectionDelegate;
    
    [self clearDisconnectTimer];
    [_networkClient setDelegate:self];
    [_networkClient start:_serverAddress port:_serverPort];        
}

- (void)disconnectServer
{
    [_networkClient disconnect];
    _connectionDelegate = nil;
}

#pragma CommonNetworkClientDelegate

- (void)didConnected
{
    if (_connectionDelegate == nil)
        return;
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        if ([_connectionDelegate respondsToSelector:@selector(didConnected)]){
            [_connectionDelegate didConnected];
        }
    });
}

- (void)didBroken
{    
    if (_connectionDelegate == nil)
        return;
    
    dispatch_sync(dispatch_get_main_queue(), ^{                
                
        if ([_connectionDelegate respondsToSelector:@selector(didBroken)]){
            [_connectionDelegate didBroken];
        }
    });
}


#pragma mark - Handle Game Message

- (void)handleGetRoomsResponse:(GameMessage*)message
{
    // save room into _roomList and fire the notification
    if ([message resultCode] != 0){
        return;
    }
    
    [self.roomList addObjectsFromArray:message.getRoomsResponse.sessionsList];
    
    
}

- (void)handleJoinGameResponse:(GameMessage*)message
{
    dispatch_async(dispatch_get_main_queue(), ^{ 
        
        // create game session
        if ([message resultCode] == 0){
//            PBGameSession* pbSession = [[message joinGameResponse] gameSession];
//            self.session = [GameSession fromPBGameSession:pbSession userId:_userId];
//            PPDebug(@"<handleJoinGameResponse> Create Session = %@", [self.session description]);

            // TODO update online user
            // [self updateOnlineUserCount:message];
            
        }
        
        // [self notifyGameObserver:@selector(didJoinGame:) message:message];
        
        // TODO add notification here
    });
}

- (void)handleCustomMessage:(GameMessage*)message
{
    PPDebug(@"<handleCustomMessage> NO IMPLEMENTATION HERE... VERY STRANGE, ARE YOU KIDDING?");
}

- (void)handleData:(GameMessage*)message
{
    switch ([message command]){
        case GameCommandTypeGetRoomsResponse:
            [self handleGetRoomsResponse:message];
            break;
        
        case GameCommandTypeJoinGameResponse:
            [self handleJoinGameResponse:message];
            break;
            
        default:
            [self handleCustomMessage:message];
            break;
    }
}

#pragma mark - Service Operations

- (void)getRoomList
{
    // send get room request here
    NSString* userId = [[UserManager defaultManager] userId];
    if (userId == nil){
        return;
    }
    
    [_networkClient sendGetRoomsRequest:userId];
}

- (void)joinGameRequest
{
    PPDebug(@"[SEND] JoinGameRequest");
    PBGameUser* user = [[UserManager defaultManager] toPBGameUser];
    [_networkClient sendJoinGameRequest:user gameId:_gameId];
}

@end
