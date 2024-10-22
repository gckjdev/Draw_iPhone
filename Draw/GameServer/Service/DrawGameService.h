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
#import "ShareGameServiceProtocol.h"
@class GameMessage;
@protocol DrawGameServiceDelegate <NSObject>

@optional;

// draw actions
- (void)didReceiveDrawData:(GameMessage *)message;

// new draw action delegate methods, add by Benson 2013-04-02
- (void)didReceiveDrawActionData:(PBDrawAction*)drawAction
                 isSetCanvasSize:(BOOL)isSetCanvasSize
                      canvasSize:(CGSize)canvasSize;

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
- (void)didGameReceiveChat:(GameMessage *)message;

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
@class Word;
@class PBGameUser;

@interface DrawGameService : CommonService<CommonNetworkClientDelegate, ShareGameServiceProtocol>
{
    GameNetworkClient *_networkClient;
    
//    NSString *_userId;
//    NSString *_nickName;
//    BOOL _gender;
    int  _guessDiffLevel;
    NSString *_roomId;
//    NSString *_location;
//    int      _userLevel;
    NSArray  *_snsUserData;

//    int _sessionId;
    BOOL start;
    
    NSTimer *_disconnectTimer;
    NSTimer *_keepAliveTimer;    
    
    NSMutableSet *_historySessionSet;
    
    int _onlineUserCount;
    
    id<DrawGameServiceDelegate> _connectionDelegate;
    NSMutableArray *_gameObserverList;
    
    NSString                        *_gameId;
    NSMutableArray                  *_roomList;    
}

//@property (nonatomic, retain) NSString* userId;
//@property (nonatomic, retain) NSString* nickName;
//@property (nonatomic, retain) NSString* avatar;
@property (nonatomic, retain) NSString* roomId;
//@property (nonatomic, retain) NSString* location;
@property (nonatomic, retain) NSArray* snsUserData;
//@property (nonatomic, assign) BOOL gender;
@property (nonatomic, assign) int guessDiffLevel;

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
@property (nonatomic, assign) CGSize canvasSize;

@property (nonatomic, assign) int onlineUserCount;

@property (nonatomic, retain) NSString              *serverStringList;
@property (nonatomic, retain) NSMutableArray        *roomList;
//@property (nonatomic, retain) CommonGameSession     *session;
@property (nonatomic, assign) int                   rule;           // 游戏规则类型，用来区分不同的游戏场，如普通场和高级场。
//@property (retain, nonatomic) NSMutableDictionary *userSimpleInfo;

+ (DrawGameService*)defaultService;

- (void)sendDrawDataRequestWithPointList:(NSArray*)pointList 
                                   color:(int)color
                                   width:(float)width           
                                 penType:(int)penType;

- (void)sendDrawAction:(PBDrawAction*)drawAction
            canvasSize:(PBSize*)canvasSize;

- (void)cleanDraw;
- (void)startGame;
- (void)joinGame:(NSString*)userId 
        nickName:(NSString*)nickName 
          avatar:(NSString*)avatar 
          gender:(BOOL)gender
        location:(NSString*)location
       userLevel:(int)userLevel
  guessDiffLevel:(int)guessDiffLevel
     snsUserData:(NSArray*)snsUserData;

- (void)quitGame;

- (BOOL)isMyTurn;
- (BOOL)isMeHost;
- (void)changeRoom;
- (void)prolongGame;
- (void)askQuickGame;
- (void)groupChatMessage:(NSString*)message;
- (void)privateChatMessage:(NSArray*)userList message:(NSString*)message;
- (void)groupChatExpression:(NSString*)key;
- (void)privateChatExpression:(NSArray*)userList key:(NSString*)key;

- (void)registerObserver:(id<DrawGameServiceDelegate>)observer;
- (void)unregisterObserver:(id<DrawGameServiceDelegate>)observer;

- (void)startDraw:(NSString*)word level:(int)level language:(int)language;
- (void)guess:(NSString*)word guessUserId:(NSString*)guessUserId;

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

- (BOOL)isConnected;
- (void)connectServer:(id<DrawGameServiceDelegate>)delegate;
- (void)disconnectServer;

- (void)startDisconnectTimer;
- (void)clearDisconnectTimer;

- (void)rankGameResult:(int)rank;
- (void)increaseRoundNumber;
- (NSInteger)roundNumber;
- (SessionStatus) sessionStatus;

- (void)scheduleKeepAliveTimer;
- (void)clearKeepAliveTimer;

- (NSArray *)drawActionList;
- (Word *)word;
- (NSInteger)language;

- (NSString *)userId;

@end
