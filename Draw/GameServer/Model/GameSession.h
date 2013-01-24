//
//  GameSession.h
//  Draw
//
//  Created by  on 12-3-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GameSessionUser;
@class GameTurn;
@class PBGameSession;
@class GeneralNotification;
@class GameTurn;
@class StartGameResponse;
@class JoinGameResponse;
@class DrawAction;

typedef enum {
    SESSION_WAITING = 0,
    SESSION_PICK_WORD,
    SESSION_PLAYING        
} SessionStatus ;

@interface GameSession : NSObject

@property (nonatomic, retain) NSString *roomName;
@property (nonatomic, retain) NSMutableArray *userList;
@property (nonatomic, retain) NSMutableArray *turnList;
@property (nonatomic, retain) NSMutableDictionary *deletedUserList;
@property (nonatomic, assign) int sessionId;
@property (nonatomic, retain) NSString *hostUserId;
@property (nonatomic, retain) NSString *userId;
@property (nonatomic, assign) int status;
@property (nonatomic, retain) GameTurn *currentTurn;
@property (nonatomic, assign) NSInteger roundNumber;

+ (GameSession*)fromPBGameSession:(PBGameSession*)pbSession userId:(NSString*)userId;
- (void)fromPBGameSession:(PBGameSession*)pbSession userId:(NSString*)userId;
- (void)updateByStartGameResponse:(StartGameResponse*)response;
- (void)updateByGameNotification:(GeneralNotification*)notification;
- (void)updateCurrentTurnByMessage:(GeneralNotification*)notification;

- (BOOL)isCurrentPlayUser:(NSString*)userId;
- (BOOL)isMe:(NSString*)userId;
- (BOOL)isHostUser:(NSString*)userId;
- (void)addDrawAction:(DrawAction *)action;
- (void)removeAllDrawActions;


//- (void)startPlay;
//- (void)finishPlay;

- (NSString *)getNickNameByUserId:(NSString *)userId;
- (GameSessionUser *)getUserByUserId:(NSString *)userId;
- (NSString *)drawingUserId;
@end
