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
    [_networkClient start:_serverAddress port:_serverPort];        
}

- (void)disconnectServer
{
    [_networkClient disconnect];
    _connectionDelegate = nil;
}

#pragma mark - Handle Game Message

- (void)handleGetRoomsResponse:(GameMessage*)message
{
    // save room into _roomList and fire the notification
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
            
        default:
            [self handleCustomMessage:message];
            break;
    }
}

- (void)getRoomList
{
    // send get room request here
}

@end
