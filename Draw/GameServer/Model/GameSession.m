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

@implementation GameSession

@synthesize roomName = _roomName;
@synthesize userList = _userList;
@synthesize turnList = _turnList;
@synthesize sessionId = _sessionId;
@synthesize hostUserId = _hostUserId;
@synthesize userId = _userId;
@synthesize currentTurn = _currentTurn;
@synthesize status = _status;

- (void)dealloc
{
    [_currentTurn release];
    [_userId release];
    [_roomName release];
    [_userList release];
    [_turnList release];
    [_hostUserId release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    self.userList = [NSMutableArray array];
    self.turnList = [NSMutableArray array];
    self.currentTurn = [[[GameTurn alloc] init] autorelease];
    return self;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"[roomName=%@, userId=%@, hostUserId=%@, sessionId=%d, \
             currentTurn=%@, status=%d, userList=%@]", _roomName, _userId, _hostUserId, _sessionId,
            _currentTurn, _status, _userList];
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



@end
