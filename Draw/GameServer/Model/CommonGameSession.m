//
//  CommonGameRoom.m
//  Draw
//
//  Created by  on 12-7-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommonGameSession.h"

#import "GameBasic.pb.h"
#import "GameMessage.pb.h"
#import "PPDebug.h"

@interface CommonGameSession ()

- (void)addNewUser:(PBGameUser*)user;
- (void)removeUser:(NSString*)userId;

@end

@implementation CommonGameSession

@synthesize roomName = _roomName;
@synthesize userList = _userList;
@synthesize deletedUserList = _deletedUserList;
@synthesize sessionId = _sessionId;
@synthesize hostUserId = _hostUserId;
@synthesize userId = _userId;
@synthesize status = _status;
@synthesize roundNumber = _roundNumber;
@synthesize currentPlayUserId = _currentPlayUserId;
@synthesize ruleType = _ruleType;
@synthesize myTurnTimes = _myTurnTimes;
@synthesize isMeStandBy = _isMeStandBy;

- (void)dealloc
{
    PPDebug(@"dealloc game session");
    
    PPRelease(_currentPlayUserId);
    PPRelease(_deletedUserList);
    PPRelease(_userId);
    PPRelease(_roomName);
    PPRelease(_userList);
    PPRelease(_hostUserId);
    [super dealloc];
}

- (id)init
{
    PPDebug(@"init game session");    
    
    self = [super init];
    _userList = [[NSMutableArray alloc] init];
    _deletedUserList = [[NSMutableDictionary alloc] init];
        

    return self;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"[roomName=%@, userId=%@, sessionId=%d]", _roomName, _userId, _sessionId];
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
        [self.userList addObject:user];
    }
    
    self.ruleType = pbSession.ruleType;
    // set turn information
    
    self.roundNumber = 0;
    self.myTurnTimes = 0;
    self.isMeStandBy = YES;
//    [session.currentTurn setRound:1];
//    [session.currentTurn setNextPlayUserId:[pbSession nextPlayUserId]];
//    [session.currentTurn setCurrentPlayUserId:[pbSession currentPlayUserId]];

    
    return;
}

- (BOOL)isCurrentPlayUser:(NSString*)userId
{
    return [_currentPlayUserId isEqualToString:userId];
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
- (void)addNewUser:(PBGameUser*)user
{
    NSString* userId = [user userId];
    for (PBGameUser* user in _userList){
        if ([[user userId] isEqualToString:userId]){
            return;
        }
    }
    
    [_userList addObject:user];    
    PPDebug(@"<addNewUser> user = %@, %@", [user userId], [user nickName]);
}

- (void)removeUser:(NSString*)userId
{
    PBGameUser* userFound = nil;
    for (PBGameUser* user in _userList){
        if ([[user userId] isEqualToString:userId]){
            userFound = user;
        }
    }
    
    if (userFound != nil){
        PPDebug(@"<removeUser> userId = %@, %@", userId, [userFound nickName]);
        [_deletedUserList setObject:userFound forKey:[userFound userId]];
        [_userList removeObject:userFound];
    }
}

- (NSString *)getNickNameByUserId:(NSString *)userId
{
    return [[self getUserByUserId:userId] nickName];
}

- (PBGameUser *)getUserByUserId:(NSString *)userId
{
    for (PBGameUser *user in self.userList) {
        if([user.userId isEqualToString:userId])
        {
            return user;
        }
    }    
    
    return [_deletedUserList objectForKey:userId];
}

- (PBGameUser *)getNextSeatPlayerByUserId:(NSString*)userId
{
    NSArray* userArray = [self.userList sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        PBGameUser* user1 = (PBGameUser*)obj1;
        PBGameUser* user2 = (PBGameUser*)obj2;
        if (user1.seatId < user2.seatId) {
            return NSOrderedAscending;
        } else if (user1.seatId > user2.seatId) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
    for (int i = 0; i < userArray.count; i ++) {
        PBGameUser* user = (PBGameUser*)[userArray objectAtIndex:i];
        PPDebug(@"<test> number %d user is %@, sitting on %d", i, user.nickName, user.seatId);
        if ([user.userId isEqualToString:userId] && [user isPlaying]) {
            PBGameUser* nextUser = (PBGameUser*)[self.userList objectAtIndex:(i+1)%userArray.count];
            PPDebug(@"next user is %@ sitting on %d", nextUser.nickName, nextUser.seatId);
            return nextUser;
        }
    }
    return nil;
}

- (void)updateSession:(PBGameSessionChanged*)changeData
{
    if ([[changeData currentPlayUserId] length] > 0){
        [self setCurrentPlayUserId:[changeData currentPlayUserId]];
    }
    
    if ([changeData hasStatus]){
        [self setStatus:[changeData status]];
    }
    
    if ([changeData usersAddedList]){
        for (PBGameUser* user in [changeData usersAddedList]){
            [self addNewUser:user];
        }
    }
    
    if ([changeData userIdsDeletedList]){
        for (NSString* userId in [changeData userIdsDeletedList]){
            [self removeUser:userId];
        }
    }
}

- (NSArray *)playingUserList
{
    NSMutableArray *userList = [NSMutableArray array];
    
    for (PBGameUser *user in _userList) {
        if (user.isPlaying) {
            [userList addObject:user];
        }
    }
    
    return userList;
}

- (int)playingUserCount
{
    return [[self playingUserList] count];
}

- (BOOL)isGamePlaying
{
    return (_status == GameStatusPlaying || _status == GameStatusActualPlaying);
}

@end