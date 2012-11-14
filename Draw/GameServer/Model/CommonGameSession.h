//
//  CommonGameRoom.h
//  Draw
//
//  Created by  on 12-7-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    GameStatusOver = 0,
    GameStatusPlaying = 1,
} GameStatus;

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
@property (nonatomic, assign) GameStatus status;
@property (nonatomic, assign) NSInteger roundNumber;
@property (nonatomic, retain) NSString *currentPlayUserId;
@property (nonatomic, assign) NSInteger myTurnTimes;
@property (nonatomic, assign) int ruleType;

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
