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
    return self;
}

- (BOOL)isConnected
{
    return [_networkClient isConnected];
}

- (void)connectServer
{
    [_networkClient start:@"192.168.1.198" port:8080];
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
    if ([self.session isCurrentPlayUser:_userId]) {
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

- (void)notifyGameObserver:(SEL)selector withObject:(NSObject*)object
{
    for (id observer in _gameObserverList){        
        if ([observer respondsToSelector:selector]){
            [observer performSelector:selector withObject:object];
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

#pragma mark Message Delegae Handle Methods

- (void)handleJoinGameResponse:(GameMessage*)message
{
    dispatch_async(dispatch_get_main_queue(), ^{ 
        
        // create game session
        if ([message resultCode] == 0){
            PBGameSession* pbSession = [[message joinGameResponse] gameSession];
            self.session = [GameSession fromPBGameSession:pbSession userId:_userId];

            PPDebug(@"<handleJoinGameResponse> Create Session = %@", [self.session description]);
            
            // add into hisotry
            [_historySessionSet addObject:[NSNumber numberWithInt:[self.session sessionId]]];
        }
        
        [self notifyGameObserver:@selector(didJoinGame:) message:message];
    });
}

- (void)handleStartGameResponse:(GameMessage*)message
{    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // update session data      
        if ([message resultCode] == 0){
            [self.session updateByStartGameResponse:[message startGameResponse]];
            PPDebug(@"<handleStartGameResponse> Update Session = %@", [self.session description]);
        }
        
        [self notifyGameObserver:@selector(didStartGame:) message:message];        
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
                [self notifyGameObserver:@selector(didReceiveRank:) withObject:[NSNumber numberWithInt:rank]];
            }
        }
    });    
}

- (void)handleGameTurnCompleteNotification:(GameMessage*)message
{
    dispatch_async(dispatch_get_main_queue(), ^{   
        PPDebug(@"<handleGameTurnCompleteNotification> Game Turn Completed!");
        if ([_drawDelegate respondsToSelector:@selector(didGameTurnComplete:)]) {
            [_drawDelegate didGameTurnComplete:message];
        }
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
        if ([[[message notification] word] length] > 0){
            PPDebug(@"handleNewDrawDataNotification <Receive Word>");
            if ([_drawDelegate respondsToSelector:@selector(didReceiveDrawWord:level:)]) {
                [_drawDelegate didReceiveDrawWord:[[message notification] word] 
                                            level:[[message notification] level]];
            }
            
            PPDebug(@"handleNewDrawDataNotification <Game Turn Start>");
            if ([_drawDelegate respondsToSelector:@selector(didGameTurnGuessStart:)]) {
                [_drawDelegate didGameTurnGuessStart:message];
            }
        }
        
        if ([[[message notification] guessWord] length] > 0){
            PPDebug(@"handleNewDrawDataNotification <Receive Guess Word> %@, %@, %d",
                    [[message notification] guessWord],
                    [[message notification] guessUserId],
                    [[message notification] guessCorrect]);
            
            if ([_drawDelegate respondsToSelector:@selector(didReceiveGuessWord:guessUserId:guessCorrect:)]) {
                [_drawDelegate didReceiveGuessWord:[[message notification] guessWord]
                                       guessUserId:[[message notification] guessUserId]
                                      guessCorrect:[[message notification] guessCorrect]];
            }            
        }

        if ([[[message notification] pointsList] count] > 0){
            PPDebug(@"handleNewDrawDataNotification <Receive Draw Data>");
            if ([_drawDelegate respondsToSelector:@selector(didReceiveDrawData:)]) {
                [_drawDelegate didReceiveDrawData:message];
            }
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

- (void)handleUserQuitGameResponse:(GameMessage*)message
{
    dispatch_async(dispatch_get_main_queue(), ^{    
        PPDebug(@"<handleUserQuitGameResponse>");
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


#pragma mark Methods for External (UI Thread)

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

- (void)askQuickGame
{
    [_networkClient sendAskQuickGame:_userId
                           sessionId:[_session sessionId]];
}


- (void)guess:(NSString*)word guessUserId:(NSString*)guessUserId
{
    [_networkClient sendGuessWord:word
                      guessUserId:guessUserId
                           userId:_userId
                        sessionId:[_session sessionId]];
}

- (void)quitGame
{
    [_networkClient sendQuitGame:_userId
                       sessionId:[_session sessionId]];

    // clear session data here
    self.session = nil;
}

- (void)rankGameResult:(int)rank
{
    [_networkClient sendRankGameResult:rank
                                userId:[_session userId]
                             sessionId:[_session sessionId]
                                 round:[[_session currentTurn] round]];
}

@end
