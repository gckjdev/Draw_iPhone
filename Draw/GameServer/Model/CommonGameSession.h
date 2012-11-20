//
//  CommonGameRoom.h
//  Draw
//
//  Created by  on 12-7-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    GameStatusInit = 0,             // 从加入房间的第一个玩家收到JoinGameResponse到下发GameStartNotification消息的这段时间。
    GameStatusWait = 1,             // 从GameOverNotification到下一个GameStartNotification这段时间。
    GameStatusPlaying = 2,          // 从下发GameStartNotifiction到NextPlayerStart这段时间。
    GameStatusActualPlaying = 3     // 从第一个NextPlayerStart到GameOverNotification这段时间。
} CommonSessionStatus;

@class PBGameSession;
@class PBGameUser;
@class PBGameSessionChanged;

@interface CommonGameSession : NSObject

@property (nonatomic, retain) NSString *roomName;
@property (nonatomic, retain) NSMutableArray *userList;
@property (nonatomic, retain) NSMutableDictionary *deletedUserList;
@property (nonatomic, assign) int sessionId;
@property (nonatomic, retain) NSString *hostUserId;
@property (nonatomic, retain) NSString *userId;
@property (nonatomic, assign) CommonSessionStatus status;
@property (nonatomic, assign) NSInteger roundNumber;
@property (nonatomic, retain) NSString *currentPlayUserId;
@property (nonatomic, assign) NSInteger myTurnTimes;
@property (nonatomic, assign) int ruleType;
@property (nonatomic, assign) BOOL isMeStandBy;

- (void)fromPBGameSession:(PBGameSession*)pbSession userId:(NSString*)userId;

- (BOOL)isCurrentPlayUser:(NSString*)userId;
- (BOOL)isMe:(NSString*)userId;
- (BOOL)isHostUser:(NSString*)userId;

- (NSString *)getNickNameByUserId:(NSString *)userId;
- (PBGameUser *)getUserByUserId:(NSString *)userId;
- (PBGameUser *)getNextSeatPlayerByUserId:(NSString*)userId;

- (void)updateSession:(PBGameSessionChanged*)changeData;

- (NSArray *)playingUserList;
- (int)playingUserCount;

- (BOOL)isGamePlaying;

@end
