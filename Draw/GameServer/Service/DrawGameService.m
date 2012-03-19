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


@implementation DrawGameService

static DrawGameService* _defaultService;

@synthesize userId = _userId;
@synthesize nickName = _nickName;
@synthesize drawDelegate = _drawDelegate;
@synthesize roomDelegate = _roomDelegate;
@synthesize session = _session;
@synthesize gameObserverList = _gameObserverList;
@synthesize homeDelegate = _homeDelegate;
@synthesize historySessionSet = _historySessionSet;
@synthesize avatar = _avatar;

- (void)dealloc
{
    [_avatar release];
    [_historySessionSet release];
    [_session release];
    [_nickName release];
    [_userId release];
    [_networkClient disconnect];
    [_networkClient release];
    [_gameObserverList release];
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
    [_networkClient start:@"192.168.1.198" port:8080];

    return self;
}

- (BOOL)isMeHost
{
    if ([self.session isHostUser:_userId]) {
        return YES;
    }
    return NO;
}
- (BOOL)isMyTurn
{
    if ([self.session isHostUser:_userId]) {
        return YES;
    }
    return NO;
}

#pragma mark Notification Handling

- (void)notifyGameObserver:(SEL)selector message:(GameMessage*)message
{
    for (id observer in _gameObserverList){        
        if ([observer respondsToSelector:selector]){
            [observer performSelector:selector withObject:message];
        }
    }    
}

- (void)registerObserver:(id<DrawGameServiceDelegate>)observer
{
    if ([self.gameObserverList containsObject:observer] == NO){
        [self.gameObserverList addObject:observer];
    }
}

- (void)unregisterObserver:(id<DrawGameServiceDelegate>)observer
{
    [self.gameObserverList removeObject:observer];
}

#pragma Message Handle Methods

- (void)handleJoinGameResponse:(GameMessage*)message
{
    dispatch_async(dispatch_get_main_queue(), ^{ 
        
        // create game session
        PBGameSession* pbSession = [[message joinGameResponse] gameSession];
        self.session = [GameSession fromPBGameSession:pbSession userId:_userId];
        PPDebug(@"<handleJoinGameResponse> Create Session = %@", [self.session description]);
        
        // add into hisotry
        [_historySessionSet addObject:[NSNumber numberWithInt:[self.session sessionId]]];
        
        if ([_roomDelegate respondsToSelector:@selector(didJoinGame:)]){
            [_roomDelegate didJoinGame:message];
        }
    });
}

- (void)handleStartGameResponse:(GameMessage*)message
{    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // update session data        
        [self.session updateByStartGameResponse:[message startGameResponse]];
        PPDebug(@"<handleStartGameResponse> Update Session = %@", [self.session description]);
        
        if ([_roomDelegate respondsToSelector:@selector(didStartGame:)]){
            [_roomDelegate didStartGame:message];
        }
    });
}

- (void)handleGameStartNotification:(GameMessage*)message
{    
    dispatch_async(dispatch_get_main_queue(), ^{      
        
        // update session data
        [self.session updateByGameNotification:[message notification]];

        // notify
        [self notifyGameObserver:@selector(didGameStart:) message:message];
    });
}

- (void)handlNewUserJoinNotification:(GameMessage*)message
{    
    dispatch_async(dispatch_get_main_queue(), ^{
        // update session data
        [self.session updateByGameNotification:[message notification]];

        // notify
        [self notifyGameObserver:@selector(didNewUserJoinGame:) message:message];
    });
}

- (void)handleGameProlongNotification:(GameMessage*)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self notifyGameObserver:@selector(didGameProlong:) message:message];
    });    
}

- (void)handlUserQuitJoinNotification:(GameMessage*)message
{    
    dispatch_async(dispatch_get_main_queue(), ^{
        // update session data
        [self.session updateByGameNotification:[message notification]];
        
        // notify
        [self notifyGameObserver:@selector(didUserQuitGame:) message:message];
    });
}

- (void)handleNewDrawDataNotification:(GameMessage*)message
{
    dispatch_async(dispatch_get_main_queue(), ^{         
        
        // Update Game Session Data
        [_session updateCurrentTurnByMessage:[message notification]];
        
        // TODO chaneg to notifyGameObserver
        if ([[message notification] hasWord]){
            PPDebug(@"handleNewDrawDataNotification <Receive Word>");
            if ([_drawDelegate respondsToSelector:@selector(didReceiveDrawWord:level:)]) {
                [_drawDelegate didReceiveDrawWord:[[message notification] word] 
                                            level:[[message notification] level]];
            }
        }

        PPDebug(@"handleNewDrawDataNotification <Receive Draw Data>");
        if ([_drawDelegate respondsToSelector:@selector(didReceiveDrawData:)]) {
            [_drawDelegate didReceiveDrawData:message];
        }
    });
}

- (void)handleCleanDraw:(GameMessage *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{        
        // TODO chaneg to notifyGameObserver
        if ([_drawDelegate respondsToSelector:@selector(didReceiveRedrawResponse:)]) {
            [_drawDelegate didReceiveRedrawResponse:message];
        }
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
            
        case GameCommandTypeProlongGameNotificationRequest:
            [self handleGameProlongNotification:message];
            break;

        case GameCommandTypeCleanDrawNotificationRequest:
            [self handleCleanDraw:message];

        default:
            break;
    }
    
    
}

#pragma CommonNetworkClientDelegate

- (void)didConnected
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        if ([_homeDelegate respondsToSelector:@selector(didConnected)]){
            [_homeDelegate didConnected];
        }
    });
}

- (void)didBroken
{    
    dispatch_sync(dispatch_get_main_queue(), ^{
        if ([_homeDelegate respondsToSelector:@selector(didBroken)]){
            [_homeDelegate didBroken];
        }
    });
}


#pragma Methods for External (UI Thread)

- (void)joinGame
{
    [_networkClient sendJoinGameRequest:_userId 
                               nickName:_nickName 
                                 avatar:_avatar
                              sessionId:-1
                      excludeSessionSet:_historySessionSet];
}

- (void)startGame
{
    [_networkClient sendStartGameRequest:_userId sessionId:[_session sessionId]];             
}

- (void)changeRoom
{
    [_networkClient sendJoinGameRequest:_userId 
                               nickName:_nickName 
                                 avatar:_avatar
                              sessionId:[_session sessionId]
                      excludeSessionSet:_historySessionSet];
}

- (void)sendDrawDataRequestWithPointList:(NSArray*)pointList 
                                   color:(int)color
                                   width:(float)width
{
    [_networkClient sendDrawDataRequest:_userId
                              sessionId:[_session sessionId]
                              pointList:pointList
                                  color:color
                                  width:width];
}

- (void)cleanDraw
{
    [_networkClient sendCleanDraw:_userId
                        sessionId:[_session sessionId]];    
}

- (void)startDraw:(NSString*)word level:(int)level
{
    [_networkClient sendStartDraw:_userId
                        sessionId:[_session sessionId]
                             word:word
                            level:level];
     
}

- (void)prolongGame
{
    [_networkClient sendProlongGame:_userId
                          sessionId:[_session sessionId]];
}

@end
