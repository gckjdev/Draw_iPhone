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
    
//    self.status = SESSION_WAITING;
    
    self.roundNumber = 0;
    return self;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"[roomName=%@, userId=%@, sessionId=%d]", _roomName, _userId, _sessionId];
}

+ (CommonGameSession*)fromPBGameSession:(PBGameSession*)pbSession userId:(NSString*)userId
{
    CommonGameSession* session = [[[CommonGameSession alloc] init] autorelease];
    session.userId = userId;
    session.sessionId = [pbSession sessionId];
    session.hostUserId = [pbSession host]; 
    session.status = [pbSession status];
    session.roomName = [pbSession name];
    
    // add all users
    [session.userList removeAllObjects];
    for (PBGameUser* user in [pbSession usersList]){                
        [session.userList addObject:user];
    }
    
    // set turn information
//    [session.currentTurn setRound:1];
//    [session.currentTurn setNextPlayUserId:[pbSession nextPlayUserId]];
//    [session.currentTurn setCurrentPlayUserId:[pbSession currentPlayUserId]];
    
    return session;
}

//- (void)updateByStartGameResponse:(StartGameResponse*)response
//{
//    [self.currentTurn setCurrentPlayUserId:[response currentPlayUserId]];
//    [self.currentTurn setNextPlayUserId:[response nextPlayUserId]];
//}
//
//- (void)updateByGameNotification:(GeneralNotification*)notification
//{
//    if ([[notification currentPlayUserId] length] > 0){
//        PPDebug(@"set current play user to %@", [notification currentPlayUserId]);
//        [self.currentTurn setLastPlayUserId:self.currentTurn.currentPlayUserId];
//        [self.currentTurn setCurrentPlayUserId:[notification currentPlayUserId]];
//    }
//    
//    if ([[notification nextPlayUserId] length] > 0){
//        [self.currentTurn setNextPlayUserId:[notification nextPlayUserId]];
//    }
//    
//    if ([[notification newUserId] length] > 0){
//        [self addNewUser:[notification newUserId]
//                nickName:[notification nickName]
//                  avatar:[notification userAvatar]
//                  gender:[notification userGender]
//                location:[notification location]
//               userLevel:[notification userLevel]
//             snsUserData:[notification snsUsersList]];
//    }
//    
//    NSString* quitUserId = [notification quitUserId];
//    if ([quitUserId length] > 0){
//        [self removeUser:quitUserId];
//    }
//    
//    if ([[notification sessionHost] length] > 0){
//        self.hostUserId = [notification sessionHost];
//    }
//}
//
//- (void)updateCurrentTurnByMessage:(GeneralNotification*)notification
//{
//    if ([notification hasRound] && [notification round] > 0){        
//        if ([self.currentTurn round] != [notification round]){        
//            [self.currentTurn setRound:[notification round]];
//            PPDebug(@"new round, set round to %d", [notification round]);
//        }
//    }
//    
//    if ([notification hasWord] && [[notification word] length] > 0){
//        [self.currentTurn setLastWord:self.currentTurn.word];
//        [self.currentTurn setWord:[notification word]];    
//        PPDebug(@"set current turn word to %@, last word = %@", 
//                [notification word], [self.currentTurn lastWord]);
//    }
//    
//    if ([notification hasLevel] && [notification level] > 0){
//        [self.currentTurn setLevel:[notification level]];
//        PPDebug(@"set current turn level to %d", [notification level]);
//    }
//    
//    if ([notification hasLanguage] && [notification language] > 0){
//        [self.currentTurn setLanguage:[notification language]];
//        PPDebug(@"set current turn language to %d", [notification language]);
//    }
//    
//    
//}

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
//            [_userList replaceObjectAtIndex:index withObject:user];
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

@end