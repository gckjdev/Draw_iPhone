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
#import "NotificationName.h"
#import "UserService.h"
#import "MyFriend.h"

@interface CommonGameNetworkService()
{
    dispatch_queue_t _getUserInfoQueue;
}

@end


@implementation CommonGameNetworkService

@synthesize serverAddress = _serverAddress;
@synthesize serverPort = _serverPort;
@synthesize roomList = _roomList;
@synthesize session = _session;
@synthesize serverStringList = _serverStringList;
@synthesize rule = _rule;

- (void)dealloc
{    
    [self clearDisconnectTimer];
    [_serverAddress release];
    
    PPRelease(_session);
    PPRelease(_serverAddress);   
    PPRelease(_roomList);
    PPRelease(_userSimpleInfo);
    
    [_networkClient disconnect];
    PPRelease(_networkClient);
    [_serverStringList release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        _roomList = [[NSMutableArray alloc] init];
        _getUserInfoQueue = dispatch_queue_create("ZJHGameServiceGetUserInfoQueue", NULL);
        self.userSimpleInfo = [NSMutableDictionary dictionary];
    }

    return self;
}

- (NSString*)userId
{
    return [[UserManager defaultManager] userId];
}

#pragma mark - Connect & Disconnect Handling

#define DISCONNECT_TIMER_INTERVAL   30

- (void)startDisconnectTimer
{
    [self clearDisconnectTimer];
    
    if ([self isConnected] == NO){
        PPDebug(@"%@ <startDisconnectTimer> but server not connected", [self description]);
        return;
    }
    
    PPDebug(@"%@ Set disconnect timer after %d seconds", [self description], DISCONNECT_TIMER_INTERVAL);
    
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
        PPDebug(@"%@ Clear disconnect timer", [self description]);
        if ([_disconnectTimer isValid]){
            [_disconnectTimer invalidate];
        }
        [_disconnectTimer release];
        _disconnectTimer = nil;
    }        
}

- (void)handleDisconnect:(NSTimer*)theTimer
{
    PPDebug(@"%@ Fire disconnect timer", [self description]);
    [self disconnectServer];
}

- (BOOL)isConnected
{
    return [_networkClient isConnected];
}

- (void)dispatchServer
{
    if (_serverStringList == nil) {
        return;
    }
    
    NSArray *serverStringArray = [_serverStringList componentsSeparatedByString:SERVER_LIST_SEPERATOR];
    NSString *serverString = [serverStringArray objectAtIndex:rand()%serverStringArray.count];
    
    NSArray *arr = [serverString componentsSeparatedByString:SERVER_PORT_SEPERATOR];
    if ([arr count] == 2) {
        self.serverAddress = [arr objectAtIndex:0];
        self.serverPort = [[arr objectAtIndex:1] intValue];
    }else {
        PPDebug(@"ERROR: Service %@ is not valid(format error)", serverString);
    }
}

//- (void)connectServer:(id<CommonGameServiceDelegate>)connectionDelegate
- (void)connectServer
{
//    _connectionDelegate = connectionDelegate;
    
    [self clearDisconnectTimer];
    [_networkClient setDelegate:self];
    
    self.serverStringList = [self getServerListString];
    [self dispatchServer];
    
    [_networkClient start:_serverAddress port:_serverPort];
}

- (NSString *)getServerListString
{
    PPDebug(@"WARNNIG: getServerListString has not been implementation yet.");
    return @"";
}

- (void)disconnectServer
{
    if ([_networkClient isConnected]){
        [_networkClient disconnect];
    }
//    _connectionDelegate = nil;
}

#pragma CommonNetworkClientDelegate

- (void)didConnected
{
    [self postNotification:NOTIFICATION_NETWORK_CONNECTED message:nil];
        
/*    if (_connectionDelegate == nil)
        return;
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        if ([_connectionDelegate respondsToSelector:@selector(didConnected)]){
            [_connectionDelegate didConnected];
        }
    });*/
}

- (void)didBroken:(NSError *)error
{
    [self postNotification:NOTIFICATION_NETWORK_DISCONNECTED error:error];
    
    /*
    if (_connectionDelegate == nil)
        return;
    
    dispatch_sync(dispatch_get_main_queue(), ^{                
                
        if (_connectionDelegate && [_connectionDelegate respondsToSelector:@selector(didBroken)]){
            [_connectionDelegate didBroken];
        }
    });
     */
}

#pragma mark Online User Count

- (void)updateOnlineUserCount:(GameMessage*)message
{
    if ([message hasOnlineUserCount]){
        _onlineUserCount = [message onlineUserCount];
    }
}


#pragma mark - Handle Game Message

- (void)handleGameStartNotificationRequest:(GameMessage*)message
{
    self.session.status = GameStatusPlaying;
    self.session.myTurnTimes = 0;
    self.session.roundNumber ++;
    self.session.isMeStandBy = NO;
    [self.session.deletedUserList removeAllObjects];
    [self handleMoreOnGameStartNotificationRequest:message];
    [self postNotification:NOTIFICATION_GAME_START_NOTIFICATION_REQUEST message:message];
}

- (void)handleGameOverNotificationRequest:(GameMessage*)message
{
    self.session.status = GameStatusWait;
    [self handleMoreOnGameOverNotificationRequest:message];
    [self postNotification:NOTIFICATION_GAME_OVER_NOTIFICATION_REQUEST message:message];
}

- (void)handleNextPlayerStartNotificationRequest:(GameMessage *)message
{
    PPDebug(@"(*************** next player: %@ *****************", [message currentPlayUserId]);
    self.session.status = GameStatusActualPlaying;
    self.session.currentPlayUserId = [message currentPlayUserId];
    if ([self isMyTurn]) {
        self.session.myTurnTimes++;
    }
    [self handleMoreOnNextPlayerStartNotificationRequest:message];
    [self postNotification:NOTIFICATION_NEXT_PLAYER_START message:message];
}

- (void)handleGetRoomsResponse:(GameMessage*)message
{
    // save room into _roomList and fire the notification
    
    [self updateOnlineUserCount:message];
    if (message.resultCode == 0){    
        [self.roomList removeAllObjects];
        [self.roomList addObjectsFromArray:message.getRoomsResponse.sessionsList];
    }
    [self postNotification:NOTIFICAIION_GET_ROOMS_RESPONSE message:message];
}

- (void)handleMoreOnGameStartNotificationRequest:(GameMessage*)message
{
}

- (void)handleMoreOnGameOverNotificationRequest:(GameMessage*)message
{
}

- (void)handleMoreOnJoinGameResponse:(GameMessage*)message
{
    [_userSimpleInfo  removeAllObjects];
}

- (void)handleMoreOnNextPlayerStartNotificationRequest:(GameMessage*)message
{
}

- (void)handleMoreOnRoomNotificationRequest:(GameMessage*)message
{
}

- (void)handleJoinGameResponse:(GameMessage*)message
{
    dispatch_async(dispatch_get_main_queue(), ^{ 
        if ([message resultCode] == 0){
            PBGameSession* pbSession = [[message joinGameResponse] gameSession];
            self.session = [self createSession];
            [_session fromPBGameSession:pbSession userId:[self userId]];
            PPDebug(@"<handleJoinGameResponse> Create Session = %@", [self.session description]);

            [self handleMoreOnJoinGameResponse:message];
        }
        [self postNotification:NOTIFICATION_JOIN_GAME_RESPONSE message:message];
    });
}

- (void)handleRoomNotificationRequest:(GameMessage*)message
{
    dispatch_async(dispatch_get_main_queue(), ^{ 
        
        PPDebug(@"<handleRoomNotificationRequest> handle room nitification");
        RoomNotificationRequest* notification = [message roomNotificationRequest];
        
        if ([notification sessionsChangedList]){
            for (PBGameSessionChanged* sessionChanged in [notification sessionsChangedList]){
                int sessionId = [sessionChanged sessionId];
                if (sessionId == _session.sessionId){
                    // current play session
                    [_session updateSession:sessionChanged];
                    
                    if (sessionChanged.usersAddedList) {
                        [self getAccount];
                    }
                }
            }
        }
        [self handleMoreOnRoomNotificationRequest:message];
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
            [_session fromPBGameSession:pbSession userId:[self userId]];
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
            
        case GameCommandTypeRoomNotificationRequest:
            [self handleRoomNotificationRequest:message];
            break;
            
        case GameCommandTypeCreateRoomResponse:
            [self handleCreateRoomResponse:message];
            break;
            
        case GameCommandTypeJoinGameResponse:
            [self handleJoinGameResponse:message];
            break;
            
        case GameCommandTypeGameStartNotificationRequest:
            [self handleGameStartNotificationRequest:message];
            break;
            
        case GameCommandTypeGameOverNotificationRequest:
            [self handleGameOverNotificationRequest:message];
            break;
            
        case GameCommandTypeNextPlayerStartNotificationRequest:
            [self handleNextPlayerStartNotificationRequest:message];
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

- (void)getRoomList:(int)startIndex 
              count:(int)count 
{
    NSString* userId = [[UserManager defaultManager] userId];
    if (userId == nil){
        return;
    }

    [_networkClient sendGetRoomsRequest:userId 
                             startIndex:startIndex 
                                  count:count];
}

- (void)getRoomList:(int)startIndex 
              count:(int)count 
           roomType:(int)type 
            keyword:(NSString*)keyword 
             gameId:(NSString*)gameId
{
    NSString* userId = [[UserManager defaultManager] userId];
    if (userId == nil){
        return;
    }

    [_networkClient sendGetRoomsRequest:userId 
                             startIndex:startIndex 
                                  count:count 
                               roomType:type 
                                keyword:keyword 
                                 gameId:gameId];
}

- (void)joinGameRequest
{
    PPDebug(@"[SEND] JoinGameRequest");
    PBGameUser* user = [[UserManager defaultManager] toPBGameUser];
    [_networkClient sendJoinGameRequest:user gameId:_gameId];
}

- (void)joinGameRequestWithCustomUser:(PBGameUser*)customSelfUser
{
    PPDebug(@"[SEND] JoinGameRequest");
    [_networkClient sendJoinGameRequest:customSelfUser gameId:_gameId];
}

- (void)joinGameRequest:(long)sessionId 
{
    PPDebug(@"[SEND] JoinGameRequest");
    PBGameUser* user = [[UserManager defaultManager] toPBGameUser];
    [_networkClient sendJoinGameRequest:user
                                 gameId:_gameId 
                              sessionId:sessionId];
}

- (void)joinGameRequest:(long)sessionId customSelfUser:(PBGameUser*)customSelfUser
{
    PPDebug(@"[SEND] JoinGameRequest");
    [_networkClient sendJoinGameRequest:customSelfUser
                                 gameId:_gameId 
                              sessionId:sessionId];
}


- (CommonGameSession*)createSession
{
    return [[[CommonGameSession alloc] init] autorelease];
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
    if (_session != nil){
        NSString* userId = [[UserManager defaultManager] userId];
        [_networkClient sendQuitGameRequest:userId sessionId:_session.sessionId];
    }
    [self disconnectServer];
}

#pragma mark - notification methods

#define KEY_GAME_MESSAGE    @"KEY_GAME_MESSAGE"
#define KEY_GAME_ERROR      @"KEY_GAME_ERROR"

+ (NSDictionary*)messageToUserInfo:(GameMessage*)message
{
    if (message == nil)
        return nil;
    
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:[message data]
                                                         forKey:KEY_GAME_MESSAGE];
    
    return userInfo;                              
}

+ (GameMessage*)userInfoToMessage:(NSDictionary*)userInfo
{
    return [GameMessage parseFromData:[userInfo objectForKey:KEY_GAME_MESSAGE]];
}

+ (NSDictionary*)errorToUserInfo:(NSError*)error
{
    if (error == nil)
        return nil;
    
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:error
                                                         forKey:KEY_GAME_ERROR];
    
    return userInfo;
}

+ (NSError*)userInfoToError:(NSDictionary*)userInfo
{
    return [userInfo objectForKey:KEY_GAME_ERROR];
}

- (void)postNotification:(NSString*)name error:(NSError*)error
{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:name
     object:self
     userInfo:[CommonGameNetworkService errorToUserInfo:error]];
    
    PPDebug(@"<%@> post notification %@ with error", [self description], name);    
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
                                    userId:[self userId]];
}

- (void)chatWithExpression:(NSString *)expression
{
    [_networkClient sendChatMessageRequest:nil 
                            contentVoiceId:nil 
                              expressionId:expression 
                                 sessionId:self.session.sessionId 
                                    userId:[self userId]];
}

- (int)onlineUserCount
{
    return _onlineUserCount;
}

- (BOOL)isMyTurn
{
    return [[UserManager defaultManager] isMe:self.session.currentPlayUserId];
}

- (BOOL)isGamePlaying
{
    return [self.session isGamePlaying];
}

- (void)getAccount
{
//    [_userSimpleInfo removeAllObjects];
    NSArray* userArray = [self.session userList];
    dispatch_async(_getUserInfoQueue, ^{
        
        //获取concurrent queue
        dispatch_queue_t aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        //创建1个queue group
        dispatch_group_t queueGroup = dispatch_group_create();
        
        for (PBGameUser *user in userArray) {
            if ([self.userId isEqualToString:user.userId]) {
                continue;
            }
            
            dispatch_group_async(queueGroup, aQueue, ^{
                MyFriend *userInfo = [[UserService defaultService] getUserSimpleInfo:user.userId];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_userSimpleInfo setValue:userInfo forKey:user.userId];
                    PPDebug(@"<getUserInfo> complete %@ %@ %ld", user.userId, userInfo.nickName, userInfo.coins);
                });
            });
        }
        
        //等待组内任务全部完成
        PPDebug(@"wait for getting all user info");
        dispatch_group_wait(queueGroup, DISPATCH_TIME_FOREVER);
        PPDebug(@"all user info get finished.");
        
        //释放组
        dispatch_release(queueGroup);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self postNotification:NOTIFICATION_BALANCE_UPDATED message:nil];
        });
        
    });
}

@end
