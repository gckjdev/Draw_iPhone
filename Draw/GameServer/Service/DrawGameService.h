//
//  DrawGameService.h
//  Draw
//
//  Created by  on 12-3-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommonService.h"
#import "GameNetworkClient.h"

@class GameMessage;
@protocol DrawGameServiceDelegate <NSObject>

@optional;
- (void)didReceiveDrawData:(GameMessage *)message;
- (void)didReceiveDrawWord:(NSString*)wordText level:(int)wordLevel;
- (void)didReceiveRedrawResponse:(GameMessage *)message;

- (void)didJoinGame:(GameMessage *)message;
- (void)didStartGame:(GameMessage *)message;
- (void)didGameStart:(GameMessage *)message;
- (void)didNewUserJoinGame:(GameMessage *)message;
- (void)didUserQuitGame:(GameMessage *)message;

- (void)didConnected;
- (void)didBroken;


@end

@class GameSession;

@interface DrawGameService : CommonService<CommonNetworkClientDelegate>
{
    GameNetworkClient *_networkClient;
    
    NSString *_userId;
    NSString *_nickName;

//    int _sessionId;
    BOOL start;
    
    NSMutableSet *_historySessionSet;
}

@property (nonatomic, retain) NSString* userId;
@property (nonatomic, retain) NSString* nickName;
@property (nonatomic, retain) NSString* avatar;
@property (nonatomic, assign) id<DrawGameServiceDelegate> drawDelegate;
@property (nonatomic, assign) id<DrawGameServiceDelegate> roomDelegate;
@property (nonatomic, assign) id<DrawGameServiceDelegate> homeDelegate;
@property (nonatomic, retain) NSMutableArray *gameObserverList;
@property (nonatomic, retain) NSMutableSet *historySessionSet;
@property (nonatomic, retain) GameSession* session;

+ (DrawGameService*)defaultService;

- (void)sendDrawDataRequestWithPointList:(NSArray*)pointList 
                                   color:(int)color
                                   width:(float)width;

- (void)cleanDraw;
- (void)startGame;
- (void)joinGame;
- (BOOL)isMyTurn;
- (BOOL)isMeHost;
- (void)changeRoom;
- (void)registerObserver:(id<DrawGameServiceDelegate>)observer;
- (void)unregisterObserver:(id<DrawGameServiceDelegate>)observer;

- (void)startDraw:(NSString*)word level:(int)level;

@end
