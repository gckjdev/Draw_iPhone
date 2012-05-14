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
@synthesize serverAddress = _serverAddress;
@synthesize serverPort = _serverPort;
@synthesize gender = _gender;
@synthesize guessDiffLevel = _guessDiffLevel;
@synthesize showDelegate = _showDelegate;
@synthesize onlineUserCount = _onlineUserCount;

- (void)dealloc
{
    [self clearKeepAliveTimer];

    [_serverAddress release];
    [_avatar release];
    [_historySessionSet release];
    [_session release];
    [_nickName release];
    [_userId release];
    [_networkClient disconnect];
    [_networkClient release];
    [_gameObserverList release];
//    [_drawActionList release];
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
    return self;
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

- (void)connectServer
{

//    [_networkClient start:@"192.167.1.103" port:8080];
//    [_networkClient start:@"192.168.1.6" port:8080];    

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

- (void)saveDrawActionType:(DRAW_ACTION_TYPE)aType paint:(Paint*)aPaint
{
    DrawAction* action = [[DrawAction alloc] initWithType:aType paint:aPaint];
    PPDebug(@"<DrawGameService>save an action:%d", aType);
//    [self.drawActionList addObject:action];
    [self.session addDrawAction:action];
    [action release];
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

- (void)notifyGameObserver:(SEL)selector withObject1:(NSObject*)object1 withObject2:(NSObject*)object2
{
    for (id observer in _gameObserverList){        
        if ([observer respondsToSelector:selector]){
            [observer performSelector:selector withObject:object1 withObject:object2];
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
    // use this to avoid the issue of enumerate observer and call this method
    [self.gameObserverList performSelector:@selector(removeObject:) withObject:observer afterDelay:0.0f];
//    [self.gameObserverList removeObject:observer];
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
            
            [self updateOnlineUserCount:message];
            
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
            
            [_session setStatus:SESSION_PICK_WORD];
            
            [self.session updateByStartGameResponse:[message startGameResponse]];
            PPDebug(@"<handleStartGameResponse> Update Session = %@", [self.session description]);
        }
        
        [self notifyGameObserver:@selector(didStartGame:) message:message];        
    });
//    [self.drawActionList removeAllObjects];
    [self.session removeAllDrawActions];
    
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
        
        [self updateOnlineUserCount:message];
        
        // update session data
        [self.session updateByGameNotification:[message notification]];
//        [self.session removeAllDrawActions];
        [self.session.currentTurn resetData];

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

- (void)handleNewDrawDataNotification:(GameMessage*)message
{
    dispatch_async(dispatch_get_main_queue(), ^{         
        
        // Update Game Session Data
        [_session updateCurrentTurnByMessage:[message notification]];
        
        // TODO chaneg to notifyGameObserver
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
            NSArray* array = [[message notification] pointsList];
            int color = [[message notification] color];
            float width = [[message notification] width];
            Paint* paint = [[Paint alloc] initWithWidth:width intColor:color numberPointList:array];
            [self saveDrawActionType:DRAW_ACTION_TYPE_DRAW paint:paint];
            [paint release];
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
    });
    [self saveDrawActionType:DRAW_ACTION_TYPE_CLEAN paint:nil];
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
    
    [self updateOnlineUserCount:message];
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
        
        [self clearKeepAliveTimer];
        
        if ([_homeDelegate respondsToSelector:@selector(didBroken)]){
            [_homeDelegate didBroken];
        }
    });
}


#pragma mark Methods for External (UI Thread)

- (void)joinGame:(NSString*)userId 
        nickName:(NSString*)nickName 
          avatar:(NSString*)avatar 
          gender:(BOOL)gender
  guessDiffLevel:(int)guessDiffLevel
{
    [_session setStatus:SESSION_WAITING];
    [self clearHistoryUser];
    
    [self setUserId:userId];
    [self setNickName:nickName];
    [self setAvatar:avatar];
    [self setGender:gender];
    [self setGuessDiffLevel:guessDiffLevel];
    
    [_networkClient sendJoinGameRequest:_userId 
                               nickName:_nickName 
                                 avatar:_avatar
                                 gender:_gender
                         guessDiffLevel:guessDiffLevel
                              sessionId:-1
                      excludeSessionSet:_historySessionSet];  
    
    [self scheduleKeepAliveTimer];
}

- (void)startGame
{
    [_networkClient sendStartGameRequest:_userId sessionId:[_session sessionId]];    
    
    [self scheduleKeepAliveTimer];
    [self.session removeAllDrawActions];
//    [_drawActionList removeAllObjects];
}

- (void)changeRoom
{
    [_session setStatus:SESSION_WAITING];    
    
    [_networkClient sendJoinGameRequest:_userId 
                               nickName:_nickName 
                                 avatar:_avatar
                                 gender:_gender
                         guessDiffLevel:_guessDiffLevel
                              sessionId:[_session sessionId]
                      excludeSessionSet:_historySessionSet];
    
    [self scheduleKeepAliveTimer];
    

//    self.session.roundNumber = 1;
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
    Paint* paint = [[Paint alloc] initWithWidth:width intColor:color numberPointList:pointList];
    [self saveDrawActionType:DRAW_ACTION_TYPE_DRAW paint:paint];
    [paint release];
    
    [self scheduleKeepAliveTimer];
    
    
}

- (void)cleanDraw
{
    [_networkClient sendCleanDraw:_userId
                        sessionId:[_session sessionId]];  
    [self saveDrawActionType:DRAW_ACTION_TYPE_CLEAN paint:nil];
    
    [self scheduleKeepAliveTimer];
    
}

- (void)startDraw:(NSString*)word level:(int)level language:(int)language
{
    [_session setStatus:SESSION_PLAYING];   
    [[_session currentTurn] updateLastWord];
    [[_session currentTurn] setWord:word];
    [[_session currentTurn] setLevel:level];
    
    [_networkClient sendStartDraw:_userId
                        sessionId:[_session sessionId]
                             word:word
                            level:level
                         language:language];
    
    [self scheduleKeepAliveTimer];
    
     
}

- (void)prolongGame
{
    [_networkClient sendProlongGame:_userId
                          sessionId:[_session sessionId]];
    
    [self scheduleKeepAliveTimer];
    
}

- (void)askQuickGame
{
    [_networkClient sendAskQuickGame:_userId
                           sessionId:[_session sessionId]];

    [self scheduleKeepAliveTimer];
}


- (void)guess:(NSString*)word guessUserId:(NSString*)guessUserId
{
    
    PPDebug(@"<DrawGameService> userId = %@, guess word = %@", guessUserId,word);
    [_networkClient sendGuessWord:word
                      guessUserId:guessUserId
                           userId:_userId
                        sessionId:[_session sessionId]];
    
    [self scheduleKeepAliveTimer];
    
}

- (void)quitGame
{
    
//    [_networkClient sendQuitGame:_userId
//                       sessionId:[_session sessionId]];
    
    [_networkClient disconnect];

    // clear session data here
    self.session = nil;
}

- (void)rankGameResult:(int)rank
{
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
    
    [_networkClient sendKeepAlive:_userId sessionId:[_session sessionId]];
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

@end
