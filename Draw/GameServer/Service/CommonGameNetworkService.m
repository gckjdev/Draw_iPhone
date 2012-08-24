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
#import "CommonGameSession.h"

@implementation CommonGameNetworkService

@synthesize serverAddress = _serverAddress;
@synthesize serverPort = _serverPort;
@synthesize roomList = _roomList;
@synthesize session = _session;
@synthesize user = _user;

- (void)dealloc
{    
    [self clearDisconnectTimer];
    [_serverAddress release];
    
    PPRelease(_user);
    PPRelease(_session);
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
                
        if (_connectionDelegate && [_connectionDelegate respondsToSelector:@selector(didBroken)]){
            [_connectionDelegate didBroken];
        }
    });
}


#pragma mark - Handle Game Message

- (void)handleGetRoomsResponse:(GameMessage*)message
{
    // save room into _roomList and fire the notification
    
//    if ([message resultCode] != 0){
//        return;
//    }

    if (message.resultCode == 0){    
        [self.roomList removeAllObjects];
        [self.roomList addObjectsFromArray:message.getRoomsResponse.sessionsList];
    }
    
    [self postNotification:NOTIFICAIION_GET_ROOMS_RESPONSE message:message];
}

- (void)handleJoinGameResponse:(GameMessage*)message
{
    dispatch_async(dispatch_get_main_queue(), ^{ 
        
        // create game session
        if ([message resultCode] == 0){
            PBGameSession* pbSession = [[message joinGameResponse] gameSession];
            self.session = [self createSession];
            [_session fromPBGameSession:pbSession userId:[self.user userId]];
            PPDebug(@"<handleJoinGameResponse> Create Session = %@", [self.session description]);

            // TODO update online user
            // [self updateOnlineUserCount:message];
            
        }
        
        [self postNotification:NOTIFICATION_JOIN_GAME_RESPONSE message:message];
    });
}

- (void)handleRoomNotification:(GameMessage*)message
{
    dispatch_async(dispatch_get_main_queue(), ^{ 
        
        PPDebug(@"<handleRoomNotification> handle room nitification");
        RoomNotificationRequest* notification = [message roomNotificationRequest];
        
        if ([notification sessionsChangedList]){
            for (PBGameSessionChanged* sessionChanged in [notification sessionsChangedList]){
                int sessionId = [sessionChanged sessionId];
                if (sessionId == _session.sessionId){
                    // current play session
                    [_session updateSession:sessionChanged];   
                }
            }
        }
        
        [self postNotification:NOTIFICATION_ROOM message:message];
    });
}

- (void)handleCreateRoomResponse:(GameMessage*)message
{
    dispatch_async(dispatch_get_main_queue(), ^{ 
        
        // create game session
        if ([message resultCode] == 0){
            PBGameSession* pbSession = [[message createRoomResponse] gameSession];
            self.session = [self createSession];
            [_session fromPBGameSession:pbSession userId:[self.user userId]];
            PPDebug(@"<handleCreateRoomResponse> Create Session = %@", [self.session description]);
            
            // TODO update online user
            // [self updateOnlineUserCount:message];
            
        }
        
        [self postNotification:NOTIFICAIION_CREATE_ROOM_RESPONSE message:message];
    });
    
}

- (void)handleCustomMessage:(GameMessage*)message
{
    PPDebug(@"<handleCustomMessage> NO IMPLEMENTATION HERE... VERY STRANGE, ARE YOU KIDDING?");
}

- (void)handleChatRequest:(GameMessage*)message
{
    [self postNotification:NOTIFICAIION_CHAT_REQUEST message:message];
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
            
        case GameCommandTypeRoomNotificationRequest:
            [self handleRoomNotification:message];
            break;
        case GameCommandTypeCreateRoomResponse:
            [self handleCreateRoomResponse:message];
            break;
            
        case GameCommandTypeChatRequest:
            [self handleChatRequest:message];
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

- (void)getRoomList:(int)startIndex count:(int)count shouldReloadData:(BOOL)shouldReloadData
{
    NSString* userId = [[UserManager defaultManager] userId];
    if (userId == nil){
        return;
    }
//    if (shouldReloadData) {
//        [self.roomList removeAllObjects];
//    }
    [_networkClient sendGetRoomsRequest:userId 
                             startIndex:startIndex 
                                  count:count];
}

- (void)joinGameRequest
{
    PPDebug(@"[SEND] JoinGameRequest");
    self.user = [[UserManager defaultManager] toPBGameUser];
    [_networkClient sendJoinGameRequest:_user gameId:_gameId];
}

- (void)joinGameRequest:(long)sessionId 
{
    PPDebug(@"[SEND] JoinGameRequest");
    self.user = [[UserManager defaultManager] toPBGameUser];
    [_networkClient sendJoinGameRequest:[[UserManager defaultManager] toPBGameUser] 
                                 gameId:_gameId 
                              sessionId:sessionId];
}

- (CommonGameSession*)createSession
{    
    PPDebug(@"<createSession> NOT IMPLEMENTED YET");
    return nil;
}

- (void)createRoomWithName:(NSString*)name 
                  password:(NSString *)password
{
    [_networkClient sendCreateRoomRequest:[[UserManager defaultManager] toPBGameUser] 
                                     name:name 
                                   gameId:_gameId 
                                 password:password];
}

- (void)registerRoomsNotification:(NSArray*)sessionIdList
{
    PPDebug(@"[SEND] registerRoomsNotificationRequest");
    NSString* userId = [[UserManager defaultManager] userId];
    [_networkClient sendRegisterRoomsNotificationRequest:sessionIdList userId:userId];
}

- (void)unRegisterRoomsNotification:(NSArray*)sessionIdList
{
    PPDebug(@"[SEND] unRegisterRoomsNotificationRequest");
    NSString* userId = [[UserManager defaultManager] userId];
    [_networkClient sendUnRegisterRoomsNotificationRequest:sessionIdList userId:userId];
}

- (void)quitGame
{
    [self disconnectServer];
}

#pragma mark - notification methods

#define KEY_GAME_MESSAGE @"KEY_GAME_MESSAGE"

+ (NSDictionary*)messageToUserInfo:(GameMessage*)message
{
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:[message data]
                                                         forKey:KEY_GAME_MESSAGE];
    
    return userInfo;                              
}

+ (GameMessage*)userInfoToMessage:(NSDictionary*)userInfo
{
    return [GameMessage parseFromData:[userInfo objectForKey:KEY_GAME_MESSAGE]];
}

- (void)postNotification:(NSString*)name message:(GameMessage*)message
{
    [[NSNotificationCenter defaultCenter] 
     postNotificationName:name 
     object:self
     userInfo:[CommonGameNetworkService messageToUserInfo:message]];    

    PPDebug(@"<%@> post notification %@", [self description], name);    
}

#pragma mark - room management

- (PBGameSession*)sessionInRoom:(int)index
{
    if (index >= 0 && index < self.roomList.count) {
        return [self.roomList objectAtIndex:index];
    }
    return nil;
}


- (void)chatWithContent:(NSString *)chatMsg contentVoiceId:(NSString *)contentVoiceId
{
    [_networkClient sendChatMessageRequest:chatMsg
                            contentVoiceId:contentVoiceId 
                              expressionId:nil 
                                 sessionId:self.session.sessionId 
                                    userId:self.user.userId];
}

- (void)chatWithExpression:(NSString *)expression
{
    [_networkClient sendChatMessageRequest:nil 
                            contentVoiceId:nil 
                              expressionId:expression 
                                 sessionId:self.session.sessionId 
                                    userId:self.user.userId];
}


@end
