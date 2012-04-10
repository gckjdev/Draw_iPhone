//
//  DrawGameService.h
//  Draw
//
//  Created by  on 12-3-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommonService.h"
#import "GameNetworkClient.h"
#import "GameSession.h"
@class GameMessage;
@protocol DrawGameServiceDelegate <NSObject>

@optional;

// draw actions
- (void)didReceiveDrawData:(GameMessage *)message;
//- (void)didReceiveDrawWord:(NSString*)wordText level:(int)wordLevel;
- (void)didReceiveDrawWord:(NSString*)wordText level:(int)wordLevel language:(int)language;
//- (void)didReceiveGuessWord:(NSString*)wordText guessUserId:(NSString*)guessUserId guessCorrect:(BOOL)guessCorrect;
- (void)didReceiveGuessWord:(NSString*)wordText guessUserId:(NSString*)guessUserId guessCorrect:(BOOL)guessCorrect gainCoins:(int)gainCoins;
- (void)didReceiveRedrawResponse:(GameMessage *)message;

// game actions
- (void)didJoinGame:(GameMessage *)message;
- (void)didStartGame:(GameMessage *)message;
- (void)didGameStart:(GameMessage *)message;
- (void)didNewUserJoinGame:(GameMessage *)message;
- (void)didUserQuitGame:(GameMessage *)message;
- (void)didGameProlong:(GameMessage *)message;
- (void)didGameAskQuick:(GameMessage *)message;

// game turn result
- (void)didGameTurnGuessStart:(GameMessage *)message;
- (void)didGameTurnComplete:(GameMessage *)message;

// game ranking
- (void)didReceiveRank:(NSNumber*)rank fromUserId:(NSString*)userId;

// server connection
- (void)didConnected;
- (void)didBroken;

@end

@class GameSession;

@interface DrawGameService : CommonService<CommonNetworkClientDelegate>
{
    GameNetworkClient *_networkClient;
    
    NSString *_userId;
    NSString *_nickName;
    BOOL _gender;

//    int _sessionId;
    BOOL start;
    
    NSMutableSet *_historySessionSet;
}

@property (nonatomic, retain) NSString* userId;
@property (nonatomic, retain) NSString* nickName;
@property (nonatomic, retain) NSString* avatar;
@property (nonatomic, assign) BOOL gender;
@property (nonatomic, assign) id<DrawGameServiceDelegate> drawDelegate;
@property (nonatomic, assign) id<DrawGameServiceDelegate> showDelegate;
@property (nonatomic, assign) id<DrawGameServiceDelegate> roomDelegate;
@property (nonatomic, assign) id<DrawGameServiceDelegate> homeDelegate;

@property (nonatomic, retain) NSMutableArray *gameObserverList;
@property (nonatomic, retain) NSMutableSet *historySessionSet;
@property (nonatomic, retain) GameSession* session;
//@property (nonatomic, retain) NSMutableArray *drawActionList;
@property (nonatomic, retain) NSString* serverAddress;
@property (nonatomic, assign) int serverPort;

+ (DrawGameService*)defaultService;

- (void)sendDrawDataRequestWithPointList:(NSArray*)pointList 
                                   color:(int)color
                                   width:(float)width;

- (void)cleanDraw;
- (void)startGame;
- (void)joinGame:(NSString*)userId nickName:(NSString*)nickName avatar:(NSString*)avatar gender:(BOOL)gender;
- (void)quitGame;

- (BOOL)isMyTurn;
- (BOOL)isMeHost;
- (void)changeRoom;
- (void)prolongGame;
- (void)askQuickGame;

- (void)registerObserver:(id<DrawGameServiceDelegate>)observer;
- (void)unregisterObserver:(id<DrawGameServiceDelegate>)observer;

- (void)startDraw:(NSString*)word level:(int)level language:(int)language;
- (void)guess:(NSString*)word guessUserId:(NSString*)guessUserId;

- (BOOL)isConnected;
- (void)connectServer;
- (void)disconnectServer;

- (void)rankGameResult:(int)rank;
- (void)increaseRoundNumber;
- (NSInteger)roundNumber;
- (SessionStatus) sessionStatus;
@end
