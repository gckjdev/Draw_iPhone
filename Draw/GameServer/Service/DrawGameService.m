//
//  DrawGameService.m
//  Draw
//
//  Created by  on 12-3-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DrawGameService.h"
#import "GameMessage.pb.h"
#import "PPDebug.h"
#import "UIUtils.h"
#import "GameSession.h"
#import "GameConstants.h"
#import "DrawAction.h"
#import "Paint.h"
#import "GameTurn.h"
#import "Word.h"
#import "UserManager.h"
#import "CommonGameNetworkService.h"
#import "NotificationName.h"
#import "ConfigManager.h"
#import "LevelService.h"
#import "PaintAction.h"
#import "DrawUtils.h"

@implementation DrawGameService

static DrawGameService* _defaultService;

//@synthesize userId = [self userId];
//@synthesize nickName = _nickName;
@synthesize drawDelegate = _drawDelegate;
@synthesize roomDelegate = _roomDelegate;
@synthesize session = _session;
@synthesize gameObserverList = _gameObserverList;
@synthesize homeDelegate = _homeDelegate;
@synthesize historySessionSet = _historySessionSet;
//@synthesize avatar = _avatar;
@synthesize serverAddress = _serverAddress;
@synthesize serverPort = _serverPort;
//@synthesize gender = _gender;
@synthesize guessDiffLevel = _guessDiffLevel;
@synthesize showDelegate = _showDelegate;
@synthesize onlineUserCount = _onlineUserCount;
@synthesize roomId = _roomId;
@synthesize snsUserData = _snsUserData;
//@synthesize location = _location;

- (void)dealloc
{
    [self clearKeepAliveTimer];

//    [_location release];
    [_snsUserData release];
    [_roomId release];
    [_serverAddress release];
//    [_avatar release];
    [_historySessionSet release];
    [_session release];
//    [_nickName release];
//    [[self userId] release];
    [_networkClient disconnect];
    [_networkClient release];
    [_gameObserverList release];
//    [_drawActionList release];

    PPRelease(_roomList);
//    PPRelease(_userSimpleInfo);
    PPRelease(_gameId);

    [super dealloc];
}

+ (DrawGameService*)defaultService
{
    if (_defaultService != nil)
        return _defaultService;
    
    _defaultService = [[DrawGameService alloc] init];    
    return _defaultService;
}

- (id)init
{
    self = [super init];
    
    _gameObserverList = [[NSMutableArray alloc] init];
    _historySessionSet = [[NSMutableSet alloc] init];
        
    _networkClient = [[GameNetworkClient alloc] init];
    [_networkClient setDelegate:self]; 
//    _drawActionList = [[NSMutableArray alloc] init];
    _roomList = [[NSMutableArray alloc] init];
    _gameId = [GameApp gameId];
    return self;
}

#pragma mark - User Info
- (BOOL)gender
{
    return [[UserManager defaultManager] isUserMale];
}

- (NSString*)avatar
{
    return [[UserManager defaultManager] avatarURL];
}

- (NSString*)userId
{
    return [[UserManager defaultManager] userId];
}

- (NSString*)location
{
    return [[UserManager defaultManager] location];
}

- (NSString*)nickName
{
    return [[UserManager defaultManager] nickName];
}

- (int)userLevel
{
    return [[LevelService defaultService] level];
}

#define DISCONNECT_TIMER_INTERVAL   10

- (void)startDisconnectTimer
{
    [self clearDisconnectTimer];
    
    if ([self isConnected] == NO){
        PPDebug(@"<startDisconnectTimer> but server not connected");
        return;
    }
    
    PPDebug(@"Set disconnect timer");

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
        [_disconnectTimer invalidate];
        [_disconnectTimer release];
        _disconnectTimer = nil;
    }        
}

- (void)handleDisconnect:(NSTimer*)theTimer
{
    PPDebug(@"Fire disconnect timer");
    [self disconnectServer];
    
    if ([self.homeDelegate respondsToSelector:@selector(didBroken)]){
        [_homeDelegate didBroken];
    }
    if ([self.drawDelegate respondsToSelector:@selector(didBroken)]){
        [_drawDelegate didBroken];
    }
    if ([self.showDelegate respondsToSelector:@selector(didBroken)]){
        [_showDelegate didBroken];
    }
    
}

- (BOOL)isConnected
{
    return [_networkClient isConnected];
}

- (void)connectServer:(id<DrawGameServiceDelegate>)connectionDelegate
{
    _connectionDelegate = connectionDelegate;
    
    [self clearKeepAliveTimer];
    [self clearDisconnectTimer];
    [_networkClient start:_serverAddress port:_serverPort];    

}

- (void)disconnectServer
{
    [_networkClient disconnect];
    [self clearKeepAliveTimer];
}

- (BOOL)isMeHost
{
    if ([self.session isHostUser:[self userId]]) {
        return YES;
    }
    return NO;
}

- (BOOL)isMyTurn
{
    if ([self.session isCurrentPlayUser:[self userId]]) {
        return YES;
    }
    return NO;
}

- (void)saveDrawActionType:(DrawActionType)aType paint:(Paint*)aPaint
{
    PaintAction* action = [[[PaintAction alloc] init] autorelease];
    [action setPaint:aPaint];
    PPDebug(@"<DrawGameService>save an action:%d", aType);
//    [self.drawActionList addObject:action];
    [self.session addDrawAction:action];
}

- (void)clearHistoryUser
{
    [_historySessionSet removeAllObjects];
}

#pragma mark Online User Count

- (void)updateOnlineUserCount:(GameMessage*)message
{
    if ([message hasOnlineUserCount]){
        _onlineUserCount = [message onlineUserCount];
    }
}

#pragma mark Notification Handling

- (void)notifyGameObserver:(SEL)selector message:(GameMessage*)message
{
    NSArray* arrayForNotify = [NSArray arrayWithArray:_gameObserverList];    
    for (id observer in arrayForNotify){        
        if ([observer respondsToSelector:selector]){
            [observer performSelector:selector withObject:message];
        }
    }    
}

- (void)notifyGameObserver:(SEL)selector withObject:(NSObject*)object
{
    NSArray* arrayForNotify = [NSArray arrayWithArray:_gameObserverList];    
    for (id observer in arrayForNotify){        
        if ([observer respondsToSelector:selector]){
            [observer performSelector:selector withObject:object];
        }
    }    
}

- (void)notifyGameObserver:(SEL)selector withObject1:(NSObject*)object1 withObject2:(NSObject*)object2
{
    NSArray* arrayForNotify = [NSArray arrayWithArray:_gameObserverList];        
    for (id observer in arrayForNotify){        
        if ([observer respondsToSelector:selector]){
            [observer performSelector:selector withObject:object1 withObject:object2];
        }
    }    
}


- (void)registerObserver:(id<DrawGameServiceDelegate>)observer
{
    if ([self.gameObserverList containsObject:observer] == NO){
        PPDebug(@"<registerObserver> %@", [observer description]);
        [self.gameObserverList addObject:observer];
    }
}

- (void)unregisterObserver:(id<DrawGameServiceDelegate>)observer
{
    PPDebug(@"<unregisterObserver> %@", [observer description]);    
    [self.gameObserverList removeObject:observer];
}

#pragma mark Message Delegae Handle Methods

- (void)handleJoinGameResponse:(GameMessage*)message
{
    dispatch_async(dispatch_get_main_queue(), ^{ 
        
        // create game session
        if ([message resultCode] == 0){
            PBGameSession* pbSession = [[message joinGameResponse] gameSession];
            self.session = [GameSession fromPBGameSession:pbSession userId:[self userId]];
            PPDebug(@"<handleJoinGameResponse> Create Session = %@", [self.session description]);
            
            [self updateOnlineUserCount:message];
            
            // add into hisotry
            [_historySessionSet addObject:[NSNumber numberWithInt:[self.session sessionId]]];
        }
        [self postNotification:NOTIFICATION_JOIN_GAME_RESPONSE message:message];
        [self notifyGameObserver:@selector(didJoinGame:) message:message];
    });
}

- (void)handleStartGameResponse:(GameMessage*)message
{    
    dispatch_async(dispatch_get_main_queue(), ^{

        // update session data      
        if ([message resultCode] == 0){
            
            [_session setStatus:SESSION_PICK_WORD];
            
            [self.session updateByStartGameResponse:[message startGameResponse]];
            PPDebug(@"<handleStartGameResponse> Update Session = %@", [self.session description]);
        }
        
        [self notifyGameObserver:@selector(didStartGame:) message:message];        

        [self.session removeAllDrawActions];
    });    
}

- (void)handleGameStartNotification:(GameMessage*)message
{    
    dispatch_async(dispatch_get_main_queue(), ^{      
        
        [_session setStatus:SESSION_PICK_WORD];
        
        // update session data
        [self.session updateByGameNotification:[message notification]];
        [self increaseRoundNumber];
        // notify every user including the drawer By Gamy
        [self notifyGameObserver:@selector(didGameStart:) message:message];
    });
}

- (void)handlNewUserJoinNotification:(GameMessage*)message
{    
    dispatch_async(dispatch_get_main_queue(), ^{
        // update session data
        [self.session updateByGameNotification:[message notification]];
        
        [self updateOnlineUserCount:message];

        // notify
        [self notifyGameObserver:@selector(didNewUserJoinGame:) message:message];
    });
}

- (void)handleChatNotification:(GameMessage*)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([message resultCode] == 0){
            NSString* content = [[message notification] chatContent];
            if ([content isEqualToString:PROLONG_GAME]){
                [self notifyGameObserver:@selector(didGameProlong:) message:message];
            }
            else if ([content isEqualToString:ASK_QUICK_GAME]){
                [self notifyGameObserver:@selector(didGameAskQuick:) message:message];
            }            
            else if ([content rangeOfString:CHAT_COMMAND_RANK].location != NSNotFound){
                int rank = [_networkClient stringToRank:content];
                [self notifyGameObserver:@selector(didReceiveRank:fromUserId:)
                             withObject1:[NSNumber numberWithInt:rank]
                             withObject2:[message userId]];
            }
            else if ([content hasPrefix:NORMAL_CHAT] ||
                     [content hasPrefix:EXPRESSION_CHAT]){
                [self notifyGameObserver:@selector(didGameReceiveChat:) message:message];
            }
        }
    });    
}

- (NSString*)reasonDescription:(int)reason
{
    switch (reason) {        
        case GameCompleteReasonReasonNotComplete:
            return @"NotComplete";
            
        case GameCompleteReasonReasonAllUserGuess:            
            return @"AllUserGuess";
            
        case GameCompleteReasonReasonAllUserQuit:
            return @"AllUserQuit";
            
        case GameCompleteReasonReasonDrawUserQuit:
            return @"DrawUserQuit";
            
        case GameCompleteReasonReasonOnlyOneUser:
            return @"OnlyOneUser";
            
        case GameCompleteReasonReasonExpired:
            return @"Expired";
            
        default:
            return @"";
    }
}

- (void)handleGameTurnCompleteNotification:(GameMessage*)message
{
    dispatch_async(dispatch_get_main_queue(), ^{   

        PPDebug(@"<handleGameTurnCompleteNotification> Game Turn[%d] Completed! Reason[%d][%@]",
                [message round], [message completeReason], [self reasonDescription:[message completeReason]]);
        
//        int serverRoundId = [message round];
//        if (serverRoundId != [[_session currentTurn] round]){
//            PPDebug(@"<handleGameTurnCompleteNotification> server round id(%d) not the same as session one(%d)",
//                    serverRoundId, [[_session currentTurn] round]);
//            return;
//        }
        
        [_session setStatus:SESSION_WAITING];
        [[_session currentTurn] updateLastWord];
        [self updateOnlineUserCount:message];
        
        // update session data
        [self.session updateByGameNotification:[message notification]];
//        [self.session removeAllDrawActions];
        [self.session.currentTurn resetData];
        self.canvasSize = CGSizeZero;

       [self notifyGameObserver:@selector(didGameTurnComplete:) message:message];
    }); 
}

- (void)handlUserQuitJoinNotification:(GameMessage*)message
{    
    dispatch_async(dispatch_get_main_queue(), ^{
        // update session data
        [self.session updateByGameNotification:[message notification]];
        
        [self updateOnlineUserCount:message];
        
        // notify
        [self notifyGameObserver:@selector(didUserQuitGame:) message:message];
    });
}

- (void)handleSendDrawDataRequest:(GameMessage*)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // Update Game Session Data
        PPDebug(@"<handleSendDrawDataRequest>");

        PBDrawAction* drawAction = [[message sendDrawDataRequest] drawAction];

        if ([[message sendDrawDataRequest] hasDrawAction]) {
            [[self session] addDrawAction:[DrawAction drawActionWithPBDrawAction:drawAction]];
        }
        
        BOOL isSetCanvasSize = [[message sendDrawDataRequest] hasCanvasSize];
        if (isSetCanvasSize){
            PBSize* drawSize = [[message sendDrawDataRequest] canvasSize];            
            CGSize size = CGSizeFromPBSize(drawSize);
            if (CGSizeEqualToSize(size, CGSizeZero) == NO &&
                CGSizeEqualToSize(size, self.canvasSize) == NO){
                PPDebug(@"<handleSendDrawDataRequest> set canvas size to %@", NSStringFromCGSize(size));
                self.canvasSize = size;
                isSetCanvasSize = YES;
            }
            else{
                PPDebug(@"<handleSendDrawDataRequest> receive canvas size zero");
                isSetCanvasSize = NO;
            }
        }
        
        if ([_showDelegate respondsToSelector:@selector(didReceiveDrawActionData:isSetCanvasSize:canvasSize:)]) {
            [_showDelegate didReceiveDrawActionData:drawAction
                                    isSetCanvasSize:isSetCanvasSize
                                         canvasSize:self.canvasSize];
        }
    });
}

- (void)handleNewDrawDataNotification:(GameMessage*)message
{
    dispatch_async(dispatch_get_main_queue(), ^{         
        
        // Update Game Session Data
        [_session updateCurrentTurnByMessage:[message notification]];
        
        // TODO change to notifyGameObserver
        if ([[[message notification] word] length] > 0){
            
            // receive user pick word, set status to playing
            [_session setStatus:SESSION_PLAYING];

            PPDebug(@"handleNewDrawDataNotification <Game Turn Start>");
            [self notifyGameObserver:@selector(didGameTurnGuessStart:) message:message];

            PPDebug(@"handleNewDrawDataNotification <Receive Word>");
            if ([_showDelegate respondsToSelector:@selector(didReceiveDrawWord:level:language:)]) {
                [_showDelegate didReceiveDrawWord:[[message notification] word] 
                                            level:[[message notification] level]
                                         language:[[message notification] language]];
            }
                        
        }
        
        if ([[[message notification] guessWord] length] > 0){
            PPDebug(@"handleNewDrawDataNotification <Receive Guess Word> %@, %@, %d, %d",
                    [[message notification] guessWord],
                    [[message notification] guessUserId],
                    [[message notification] guessCorrect],
                    [[message notification] guessGainCoins]);
            
            if ([_drawDelegate respondsToSelector:@selector(didReceiveGuessWord:guessUserId:guessCorrect:gainCoins:)]) {
                [_drawDelegate didReceiveGuessWord:[[message notification] guessWord]
                                       guessUserId:[[message notification] guessUserId]
                                      guessCorrect:[[message notification] guessCorrect]
                                         gainCoins:[[message notification] guessGainCoins]];
            }            

            if ([_showDelegate respondsToSelector:@selector(didReceiveGuessWord:guessUserId:guessCorrect:gainCoins:)]) {
                [_showDelegate didReceiveGuessWord:[[message notification] guessWord]
                                       guessUserId:[[message notification] guessUserId]
                                      guessCorrect:[[message notification] guessCorrect]
                                         gainCoins:[[message notification] guessGainCoins]];
            }            
        }

        if ([[[message notification] pointsList] count] > 0){
            PPDebug(@"handleNewDrawDataNotification <Receive Draw Data>");
            if ([_showDelegate respondsToSelector:@selector(didReceiveDrawData:)]) {
                [_showDelegate didReceiveDrawData:message];
            }
//            NSArray* array = [[message notification] pointsList];
//            int color = [[message notification] color];
//            int penType = [[message notification] penType];
//            float width = [[message notification] width];
//            Paint* paint = [[Paint alloc] initWithWidth:width intColor:color numberPointList:array penType:penType];
//            [self saveDrawActionType:DrawActionTypePaint paint:paint];
//            [paint release];
        }
        
        
    });
}

- (void)handleCleanDraw:(GameMessage *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{        
        // TODO chaneg to notifyGameObserver
        if ([_showDelegate respondsToSelector:@selector(didReceiveRedrawResponse:)]) {
            [_showDelegate didReceiveRedrawResponse:message];
        }

        [self saveDrawActionType:DrawActionTypeClean paint:nil];
    });
}

- (void)handleUserQuitGameResponse:(GameMessage*)message
{
    dispatch_async(dispatch_get_main_queue(), ^{    
        PPDebug(@"<handleUserQuitGameResponse>");
    });    
}

- (void)postNotification:(NSString*)name message:(GameMessage*)message
{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:name
     object:self
     userInfo:[CommonGameNetworkService messageToUserInfo:message]];
    
    PPDebug(@"<%@> post notification %@", [self description], name);
}

- (void)handleMoreOnRoomNotificationRequest:(GameMessage*)message
{
}

- (GameSession*)createSession
{
    return [[[GameSession alloc] init] autorelease];
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



- (void)handleData:(GameMessage*)message
{
    switch ([message command]) {
        case GameCommandTypeJoinGameResponse:   
            [self handleJoinGameResponse:message];
            break;
            
        case GameCommandTypeStartGameResponse:   
            [self handleStartGameResponse:message];
            break;

        case GameCommandTypeGameStartNotificationRequest:
            [self handleGameStartNotification:message]; 
            break;
            
        case GameCommandTypeUserJoinNotificationRequest:
            [self handlNewUserJoinNotification:message]; 
            break;
            
        case GameCommandTypeUserQuitNotificationRequest:
            [self handlUserQuitJoinNotification:message]; 
            break;

        case GameCommandTypeNewDrawDataNotificationRequest:
            [self handleNewDrawDataNotification:message];
            break;
            
        case GameCommandTypeHostChangeNotificationRequest:
            break;
            
        case GameCommandTypeCleanDrawNotificationRequest:
            [self handleCleanDraw:message];
            break;
            
        case GameCommandTypeGameTurnCompleteNotificationRequest:
            [self handleGameTurnCompleteNotification:message];
            break;
            
        case GameCommandTypeChatNotificationRequest:
            [self handleChatNotification:message];
            break;
            
        case GameCommandTypeQuitGameResponse:
            [self handleUserQuitGameResponse:message];
            break;

        // for new interface 2013-01-23
        case GameCommandTypeGetRoomsResponse:
            [self handleGetRoomsResponse:message];
            break;
            
//        case GameCommandTypeRoomNotificationRequest:
//            [self handleRoomNotificationRequest:message];
//            break;
            
        case GameCommandTypeCreateRoomResponse:
            [self handleCreateRoomResponse:message];
            break;
            
        case GameCommandTypeSendDrawDataRequest:
            [self handleSendDrawDataRequest:message];
            break;
            
//        case GameCommandTypeJoinGameResponse:
//            [self handleJoinGameResponse:message];
//            break;
            
            
        default:
            break;
    }
    
    [self updateOnlineUserCount:message];
}

#pragma CommonNetworkClientDelegate

- (void)didConnected
{
    [self postNotification:NOTIFICATION_NETWORK_CONNECTED message:nil];
        
    // TODO check whether keep delegate
    if (_connectionDelegate == nil)
        return;
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        if ([_connectionDelegate respondsToSelector:@selector(didConnected)]){
            [_connectionDelegate didConnected];
        }
    });
}

- (void)postNotification:(NSString*)name error:(NSError*)error
{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:name
     object:self
     userInfo:[CommonGameNetworkService errorToUserInfo:error]];
    
    PPDebug(@"<%@> post notification %@ with error", [self description], name);
}

- (void)didBroken:(NSError *)error
{
//    [self postNotification:NOTIFICATION_NETWORK_DISCONNECTED error:error];
    
    // TODO check whether keep delegate
    dispatch_sync(dispatch_get_main_queue(), ^{
        
        [self clearKeepAliveTimer];
        [self postNotification:NOTIFICATION_NETWORK_DISCONNECTED error:error];
    });
    
}

- (void)didBroken
{    
    if (_connectionDelegate == nil)
        return;

    dispatch_sync(dispatch_get_main_queue(), ^{                
        
        [self clearKeepAliveTimer];
        
        /*
        if ([_connectionDelegate respondsToSelector:@selector(didBroken)]){
            [_connectionDelegate didBroken];
        }
        */
        
        [self postNotification:NOTIFICATION_NETWORK_DISCONNECTED error:nil];
    });
}


#pragma mark Methods for External (UI Thread)

- (void)joinGame:(NSString*)userId 
        nickName:(NSString*)nickName 
          avatar:(NSString*)avatar 
          gender:(BOOL)gender
        location:(NSString*)location
       userLevel:(int)userLevel
  guessDiffLevel:(int)guessDiffLevel
     snsUserData:(NSArray*)snsUserData;
{
    PPDebug(@"<joinGame> %@, %@", userId, nickName);
    
    [_session setStatus:SESSION_WAITING];
    
    [self clearHistoryUser];
    
    [self setGuessDiffLevel:guessDiffLevel];
    
    [_networkClient sendJoinGameRequest:[self userId] 
                               nickName:[self nickName]
                                 avatar:[self avatar]
                                 gender:[self gender]
                               location:[self location]
                              userLevel:[self userLevel]
                            snsUserList:snsUserData
                         guessDiffLevel:guessDiffLevel
                              sessionId:-1
                                 roomId:nil 
                               roomName:nil
                      excludeSessionSet:_historySessionSet];  
    
    [self scheduleKeepAliveTimer];
}

- (void)startGame
{
    
    PPDebug(@"<startGame> %@ at %d", [self userId], [_session sessionId]);
    if ([_networkClient isConnected] == NO){
        return;
    }
    
    [_networkClient sendStartGameRequest:[self userId] sessionId:[_session sessionId]];    
    
    [self scheduleKeepAliveTimer];
    [self.session removeAllDrawActions];
//    [_drawActionList removeAllObjects];
}

- (void)changeRoom
{
    PPDebug(@"<changeRoom> %@, %@", [self userId], [self nickName]);
    
    [_session setStatus:SESSION_WAITING];    
    
    [_networkClient sendJoinGameRequest:[self userId] 
                               nickName:[self nickName]
                                 avatar:[self avatar]
                                 gender:[self gender]
                               location:[self location]
                              userLevel:[self userLevel]
                            snsUserList:_snsUserData
                         guessDiffLevel:[self guessDiffLevel]
                              sessionId:[_session sessionId]
                                 roomId:nil
                               roomName:nil
                      excludeSessionSet:_historySessionSet];
    
    [self scheduleKeepAliveTimer];
    

//    self.session.roundNumber = 1;
}

- (void)sendDrawDataRequestWithPointList:(NSArray*)pointList 
                                   color:(int)color
                                   width:(float)width                     
                                 penType:(int)penType
{
    PPDebug(@"<sendDrawData>");

    
    [_networkClient sendDrawDataRequest:[self userId]
                              sessionId:[_session sessionId]
                              pointList:pointList
                                  color:color
                                  width:width 
                                penType:penType];
//    Paint* paint = [[Paint alloc] initWithWidth:width intColor:color numberPointList:pointList penType:penType];
//    [self saveDrawActionType:DrawActionTypePaint paint:paint];
//    [paint release];
    
    [self scheduleKeepAliveTimer];
    
    
}

- (void)sendDrawAction:(PBDrawAction*)drawAction
            canvasSize:(PBSize*)canvasSize
{
    PPDebug(@"<sendDrawAction> canvasSize=(%d, %d)", canvasSize.width, canvasSize.height);
    [_networkClient sendDrawActionRequest:[self userId]
                              sessionId:[_session sessionId]
                             drawAction:drawAction
                             canvasSize:canvasSize];
//    Paint* paint = [[Paint alloc] initWithWidth:width intColor:color numberPointList:pointList penType:penType];
//    [self saveDrawActionType:DrawActionTypePaint paint:paint];
//    [paint release];
    
    [self scheduleKeepAliveTimer];
}

- (void)cleanDraw
{
    PPDebug(@"<cleanDraw>");

    [_networkClient sendCleanDraw:[self userId]
                        sessionId:[_session sessionId]];  
    [self saveDrawActionType:DrawActionTypeClean paint:nil];
    
    [self scheduleKeepAliveTimer];
    
}

- (void)startDraw:(NSString*)word level:(int)level language:(int)language
{
    PPDebug(@"<startDraw> %@, %d", word, level);    
    
    [_session setStatus:SESSION_PLAYING];   
    [[_session currentTurn] updateLastWord];
    [[_session currentTurn] setWord:word];
    [[_session currentTurn] setLevel:level];
    
    [_networkClient sendStartDraw:[self userId]
                        sessionId:[_session sessionId]
                             word:word
                            level:level
                         language:language];
    
    [self scheduleKeepAliveTimer];
    
     
}

- (void)prolongGame
{
    PPDebug(@"prolong game");
    
    [_networkClient sendProlongGame:[self userId]
                          sessionId:[_session sessionId]];
    
    [self scheduleKeepAliveTimer];
    
}

- (void)askQuickGame
{
    PPDebug(@"<askQuickGame>");
    
    [_networkClient sendAskQuickGame:[self userId]
                           sessionId:[_session sessionId]];

    [self scheduleKeepAliveTimer];
}

- (void)groupChatMessage:(NSString*)message
{
    PPDebug(@"<sendGroupChatMessage>");

    [_networkClient sendChatMessage:[self userId] 
                          sessionId:[_session sessionId] 
                           userList:nil 
                            message:message
                           chatType:GameChatTypeChatGroup];    
}

- (void)privateChatMessage:(NSArray*)userList message:(NSString*)message
{
    PPDebug(@"<sendPrivateChatMessage>");
    [_networkClient sendChatMessage:[self userId] 
                          sessionId:[_session sessionId] 
                           userList:userList 
                            message:message
                           chatType:GameChatTypeChatPrivate];
}

- (void)groupChatExpression:(NSString*)key 
{
    PPDebug(@"<sendGroupChatExpression>");    
    [_networkClient sendChatExpression:[self userId] 
                             sessionId:[_session sessionId] 
                              userList:nil 
                                   key:key
                              chatType:GameChatTypeChatGroup];
}

- (void)privateChatExpression:(NSArray*)userList key:(NSString*)key 
{
    PPDebug(@"<sendGroupChatExpression> to all users");    
    [_networkClient sendChatExpression:[self userId] 
                             sessionId:[_session sessionId] 
                              userList:userList 
                                   key:key
                              chatType:GameChatTypeChatPrivate];
}

- (void)guess:(NSString*)word guessUserId:(NSString*)guessUserId
{
    
    PPDebug(@"<DrawGameService> userId = %@, guess word = %@", guessUserId,word);
    [_networkClient sendGuessWord:word
                      guessUserId:guessUserId
                           userId:[self userId]
                        sessionId:[_session sessionId]];
    
    [self scheduleKeepAliveTimer];
    
}

- (void)quitGame
{
    PPDebug(@"<quitGame>");
    
//    [_networkClient sendQuitGame:[self userId]
//                       sessionId:[_session sessionId]];
    
    [_networkClient disconnect];

    // clear session data here
    self.session = nil;
}

- (void)rankGameResult:(int)rank
{
    PPDebug(@"<rankGameResult> rank = %d", rank);    
    [_networkClient sendRankGameResult:rank
                                userId:[_session userId]
                             sessionId:[_session sessionId]
                                 round:[[_session currentTurn] round]];
    
    [self scheduleKeepAliveTimer];
    
}
- (void)increaseRoundNumber
{
    self.session.roundNumber ++;
}
- (NSInteger)roundNumber
{
    return _session.roundNumber;
}
- (SessionStatus) sessionStatus
{
    return _session.status;
}

#pragma mark - Keep Network Alive Timer Handling

- (void)keepAlive:(NSTimer*)timer
{
    PPDebug(@"<keepAlive>");
    
    [_networkClient sendKeepAlive:[self userId] sessionId:[_session sessionId]];
}

#define KEEP_ALIVE_TIMER_INTERVAL       90

- (void)clearKeepAliveTimer
{
    if (_keepAliveTimer){
        PPDebug(@"clearKeepAliveTimer");
        [_keepAliveTimer invalidate];
        [_keepAliveTimer release];
        _keepAliveTimer = nil;
    }
}

- (void)scheduleKeepAliveTimer
{
    // add by Benson, disable keep alive since it's useless in server side
    return;
    
    [self clearKeepAliveTimer];
    
    PPDebug(@"<scheduleKeepAliveTimer>");
    
    _keepAliveTimer = [NSTimer scheduledTimerWithTimeInterval:KEEP_ALIVE_TIMER_INTERVAL target:self selector:@selector(keepAlive:) userInfo:nil repeats:YES];
    [_keepAliveTimer retain];
}
 
- (NSArray *)drawActionList
{
    return self.session.currentTurn.drawActionList;
}
- (Word *)word
{
    if (self.session.currentTurn.word) {
        return [Word wordWithText:self.session.currentTurn.word level:self.session.currentTurn.level];
    }
    return nil;
}

- (NSInteger)language
{
    return self.session.currentTurn.language;
}

#pragma mark - Friend Play

- (void)joinFriendRoom:(NSString*)userId 
                roomId:(NSString*)roomId
              roomName:(NSString*)roomName
              nickName:(NSString*)nickName 
                avatar:(NSString*)avatar 
                gender:(BOOL)gender
              location:(NSString*)location
             userLevel:(int)userLevel
        guessDiffLevel:(int)guessDiffLevel
           snsUserData:(NSArray*)snsUserData;

{
    PPDebug(@"<joinFriendRoom> roomId=%@", roomId);
    
    [_session setStatus:SESSION_WAITING];
    [self clearHistoryUser];
    
    [self setGuessDiffLevel:guessDiffLevel];
    [self setRoomId:roomId];
    
    [_networkClient sendJoinGameRequest:[self userId] 
                               nickName:[self nickName]
                                 avatar:[self avatar]
                                 gender:[self gender]
                               location:[self location]
                              userLevel:[self userLevel]
                            snsUserList:snsUserData     
                         guessDiffLevel:guessDiffLevel
                              sessionId:-1
                                 roomId:roomId
                               roomName:roomName
                      excludeSessionSet:[NSSet set]];  
    
    [self scheduleKeepAliveTimer];
    
}
#pragma mark - ShareGameServiceProtocol

- (void)getRoomList:(int)startIndex
              count:(int)count
{
    // send get room request here
    NSString* userId = [[UserManager defaultManager] userId];
    if (userId == nil){
        return;
    }
    
//    [_networkClient sendGetRoomsRequest:userId];

    [_networkClient sendGetRoomsRequest:userId
                             startIndex:0
                                  count:count
                               roomType:allRoom
                                keyword:nil
                                 gameId:[GameApp gameId]];

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
- (void)joinGameRequestWithCustomUser:(PBGameUser*)customSelfUser
{
    PPDebug(@"[SEND] JoinGameRequest");
    [_networkClient sendJoinGameRequest:customSelfUser gameId:_gameId];
}

- (void)createRoomWithName:(NSString*)name
                  password:(NSString*)password
{
    [_networkClient sendCreateRoomRequest:[[UserManager defaultManager] toPBGameUser]
                                     name:name
                                   gameId:_gameId
                                 password:password];
}
//- (int)onlineUserCount
//{
//    
//}
//- (NSArray*)roomList
//{
//    
//}
//- (void)quitGame
//{
//    
//}
//- (BOOL)isConnected
//{
//    
//}
- (void)connectServer
{
    self.serverStringList = [self getServerListString];
    [self dispatchServer];
    [self connectServer:nil];
}
//- (int)rule
//{
//    
//}

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

- (NSString *)getServerListString
{
    return [ConfigManager getDrawServerString];
}

- (PBGameSession*)sessionInRoom:(int)index
{
    if (index >= 0 && index < self.roomList.count) {
        return [self.roomList objectAtIndex:index];
    }
    return nil;}

@end
