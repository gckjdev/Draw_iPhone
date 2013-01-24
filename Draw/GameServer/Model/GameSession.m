//
//  GameSession.m
//  Draw
//
//  Created by  on 12-3-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GameSession.h"
#import "GameBasic.pb.h"
#import "GameSessionUser.h"
#import "GameTurn.h"
#import "GameMessage.pb.h"
#import "PPDebug.h"

@interface GameSession ()

- (void)addNewUser:(NSString*)userId 
          nickName:(NSString*)nickName 
            avatar:(NSString*)avatar 
            gender:(BOOL)gender
          location:(NSString*)location
         userLevel:(int)userLevel
       snsUserData:(NSArray*)snsUserData;

- (void)removeUser:(NSString*)userId;

@end

@implementation GameSession

@synthesize roomName = _roomName;
@synthesize userList = _userList;
@synthesize deletedUserList = _deletedUserList;
@synthesize turnList = _turnList;
@synthesize sessionId = _sessionId;
@synthesize hostUserId = _hostUserId;
@synthesize userId = _userId;
@synthesize currentTurn = _currentTurn;
@synthesize status = _status;
@synthesize roundNumber = _roundNumber;

- (void)dealloc
{
    PPDebug(@"dealloc game session");
    
    PPRelease(_deletedUserList);
    PPRelease(_currentTurn);
    PPRelease(_userId);
    PPRelease(_roomName);
    PPRelease(_userList);
    PPRelease(_turnList);
    PPRelease(_hostUserId);
    [super dealloc];
}

- (id)init
{
    PPDebug(@"init game session");    
    
    self = [super init];
    _userList = [[NSMutableArray alloc] init];
    _turnList = [[NSMutableArray alloc] init];
    _currentTurn = [[GameTurn alloc] init];
    _deletedUserList = [[NSMutableDictionary alloc] init];

    self.status = SESSION_WAITING;
    self.roundNumber = 0;
    return self;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"[roomName=%@, userId=%@, hostUserId=%@, sessionId=%d, \
             currentTurn=%@, status=%d, userList=%@]", _roomName, _userId, _hostUserId, _sessionId,
            _currentTurn, _status, _userList];
}

- (void)fromPBGameSession:(PBGameSession*)pbSession userId:(NSString*)userId
{
    self.userId = userId;
    self.sessionId = [pbSession sessionId];
    self.hostUserId = [pbSession host];
    self.status = [pbSession status];
    self.roomName = [pbSession name];
    
    // add all users
    [self.userList removeAllObjects];
    for (PBGameUser* user in [pbSession usersList]){
        GameSessionUser* sessionUser = [GameSessionUser fromPBUser:user];
        [self.userList addObject:sessionUser];
    }
    
    // set turn information
    [self.currentTurn setRound:1];
    [self.currentTurn setNextPlayUserId:[pbSession nextPlayUserId]];
    [self.currentTurn setCurrentPlayUserId:[pbSession currentPlayUserId]];
    
//    return session;
    
//    self.userId = userId;
//    self.sessionId = [pbSession sessionId];
//    self.hostUserId = [pbSession host];
//    self.status = [pbSession status];
//    self.roomName = [pbSession name];
//    
//    // add all users
//    [self.userList removeAllObjects];
//    
//    for (PBGameUser* user in [pbSession usersList]){
//        [self.userList addObject:user];
//    }
//    
//    self.ruleType = pbSession.ruleType;
//    self.roundNumber = 0;
//    self.myTurnTimes = 0;
//    self.isMeStandBy = YES;
//    return;
}

+ (GameSession*)fromPBGameSession:(PBGameSession*)pbSession userId:(NSString*)userId
{
    GameSession* session = [[[GameSession alloc] init] autorelease];
    session.userId = userId;
    session.sessionId = [pbSession sessionId];
    session.hostUserId = [pbSession host]; 
    session.status = [pbSession status];
    session.roomName = [pbSession name];
    
    // add all users
    [session.userList removeAllObjects];
    for (PBGameUser* user in [pbSession usersList]){
        GameSessionUser* sessionUser = [GameSessionUser fromPBUser:user];
        [session.userList addObject:sessionUser];
    }
    
    // set turn information
    [session.currentTurn setRound:1];
    [session.currentTurn setNextPlayUserId:[pbSession nextPlayUserId]];
    [session.currentTurn setCurrentPlayUserId:[pbSession currentPlayUserId]];
    
    return session;
}

- (void)updateByStartGameResponse:(StartGameResponse*)response
{
    [self.currentTurn setCurrentPlayUserId:[response currentPlayUserId]];
    [self.currentTurn setNextPlayUserId:[response nextPlayUserId]];
}

- (void)updateByGameNotification:(GeneralNotification*)notification
{
    if ([[notification currentPlayUserId] length] > 0){
        PPDebug(@"set current play user to %@", [notification currentPlayUserId]);
        [self.currentTurn setLastPlayUserId:self.currentTurn.currentPlayUserId];
        [self.currentTurn setCurrentPlayUserId:[notification currentPlayUserId]];
    }
    
    if ([[notification nextPlayUserId] length] > 0){
        [self.currentTurn setNextPlayUserId:[notification nextPlayUserId]];
    }
    
    if ([[notification newUserId] length] > 0){
        [self addNewUser:[notification newUserId]
                nickName:[notification nickName]
                  avatar:[notification userAvatar]
                  gender:[notification userGender]
                location:[notification location]
               userLevel:[notification userLevel]
             snsUserData:[notification snsUsersList]];
    }
    
    NSString* quitUserId = [notification quitUserId];
    if ([quitUserId length] > 0){
        [self removeUser:quitUserId];
    }
    
    if ([[notification sessionHost] length] > 0){
        self.hostUserId = [notification sessionHost];
    }
}

- (void)updateCurrentTurnByMessage:(GeneralNotification*)notification
{
    if ([notification hasRound] && [notification round] > 0){        
        if ([self.currentTurn round] != [notification round]){        
            [self.currentTurn setRound:[notification round]];
            PPDebug(@"new round, set round to %d", [notification round]);
        }
    }

    if ([notification hasWord] && [[notification word] length] > 0){
        [self.currentTurn setLastWord:self.currentTurn.word];
        [self.currentTurn setWord:[notification word]];    
        PPDebug(@"set current turn word to %@, last word = %@", 
                [notification word], [self.currentTurn lastWord]);
    }
    
    if ([notification hasLevel] && [notification level] > 0){
        [self.currentTurn setLevel:[notification level]];
        PPDebug(@"set current turn level to %d", [notification level]);
    }
    
    if ([notification hasLanguage] && [notification language] > 0){
        [self.currentTurn setLanguage:[notification language]];
        PPDebug(@"set current turn language to %d", [notification language]);
    }

    
}

- (BOOL)isCurrentPlayUser:(NSString*)userId
{
    return [[[self currentTurn] currentPlayUserId] isEqualToString:userId];
}

- (BOOL)isMe:(NSString*)userId
{
    return [[self userId] isEqualToString:userId];
}

- (BOOL)isHostUser:(NSString*)userId
{
    return [[self hostUserId] isEqualToString:userId];    
}


#pragma User Management
- (void)addNewUser:(NSString*)userId 
          nickName:(NSString*)nickName 
            avatar:(NSString*)avatar 
            gender:(BOOL)gender
          location:(NSString*)location
         userLevel:(int)userLevel
       snsUserData:(NSArray*)snsUserData
{
    for (GameSessionUser* user in _userList){
        if ([[user userId] isEqualToString:userId]){
            // already exist, don't add
            return;
        }
    }
    
    GameSessionUser *user = [[GameSessionUser alloc] init];
    [user setUserId:userId];
    [user setNickName:nickName];
    [user setUserAvatar:avatar];
    [user setGender:gender];
    [user setLocation:location];
    [user setSnsUserData:snsUserData];
    [user setLevel:userLevel];
    [_userList addObject:user];
    [user release];
    
    PPDebug(@"<addNewUser> user = %@", [user description]);
}

- (void)removeUser:(NSString*)userId
{
    GameSessionUser* userFound = nil;
    for (GameSessionUser* user in _userList){
        if ([[user userId] isEqualToString:userId]){
            userFound = user;
        }
    }
    
    if (userFound != nil){
        PPDebug(@"<removeUser> userId = %@", userId);
        [_deletedUserList setObject:userFound forKey:[userFound userId]];
        [_userList removeObject:userFound];
    }
}

//- (void)startPlay
//{
//    self.status = SESSION_PLAYING;
//}
//
//- (void)finishPlay
//{
//    self.status = SESSION_WAITING;
//}

- (NSString *)getNickNameByUserId:(NSString *)userId
{
//    for (GameSessionUser *user in self.userList) {
//        if([user.userId isEqualToString:userId])
//        {
//            return user.nickName;
//        }
//    }
//    
//    return [[_deletedUserList objectForKey:userId] nickName];
    
    return [[self getUserByUserId:userId] nickName];
}

- (GameSessionUser *)getUserByUserId:(NSString *)userId
{
    for (GameSessionUser *user in self.userList) {
        if([user.userId isEqualToString:userId])
        {
            return user;
        }
    }    
    
    return [_deletedUserList objectForKey:userId];
}

- (NSString *)drawingUserId
{
    return [self.currentTurn currentPlayUserId];
}

- (void)addDrawAction:(DrawAction *)action
{
    [self.currentTurn.drawActionList addObject:action];
}

- (void)removeAllDrawActions
{
    [self.currentTurn.drawActionList removeAllObjects];
}
@end
