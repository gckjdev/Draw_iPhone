//
//  RoomManager.m
//  Draw
//
//  Created by  on 12-5-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RoomManager.h"
#import "GameNetworkConstants.h"
#import "TimeUtils.h"
#import "UserManager.h"
#import "Friend.h"

RoomManager *staticRoomManager = nil;
@implementation RoomManager
@synthesize roomList = _roomList;

-(void)dealloc
{
    [_roomList release];
    [super dealloc];
}

+ (RoomManager *)defaultManager
{
    if (staticRoomManager == nil) {
        staticRoomManager = [[RoomManager alloc] init];
    }
    return staticRoomManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        _roomList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)cleanData
{
    [_roomList removeAllObjects];
}
- (NSArray *)getLocalRoomList
{
    return self.roomList;
}
- (NSArray *)getMyRoomList
{
    return self.roomList;
}
- (NSArray *)getInvitedRoomList
{
    return self.roomList;
}
- (NSArray *)getJoinedRoomList
{
    return self.roomList;
}

- (NSString *)nickStringFromUsers:(NSArray *)userList 
                            split:(NSString *)split 
                            count:(NSInteger)count
{
    if ([userList count] == 0) {
        return nil;
    }
    NSMutableArray *nickList = [[NSMutableArray alloc]init];
    int i = 0;
    for (RoomUser *user in userList) {
        if (user.nickName) {
            [nickList addObject:user.nickName];
            if (++ i == count) {
                break;
            }
        }
    }
    NSString *retString = [nickList componentsJoinedByString:split];
    [nickList release];
    return retString;
}

- (RoomUser *)paserRoomUser:(NSDictionary *)dict
{
    if (dict && [[dict allKeys] count] != 0) {
        UserManager *userManager = [UserManager defaultManager];
        RoomUser *user = [[[RoomUser alloc] init] autorelease];
        user.userId = [dict objectForKey:PARA_USERID];
        user.nickName = [dict objectForKey:PARA_NICKNAME];
        user.gender = [dict objectForKey:PARA_GENDER];
        user.avatar = [dict objectForKey:PARA_AVATAR];
        if ([userManager isMe:user.userId] && [user.avatar length] == 0) {
            user.avatar = [userManager avatarURL];
        }
        user.status = ((NSNumber *)[dict objectForKey:PARA_STATUS]).intValue;
        user.playTimes = ((NSNumber *)[dict objectForKey:PARA_PLAY_TIMES]).integerValue;
        NSString *lastPlayDateString = [dict objectForKey:PARA_LAST_PLAY_DATE];
        if ([lastPlayDateString length] != 0) {
            user.lastPlayDate = dateFromStringByFormat(lastPlayDateString, DEFAULT_DATE_FORMAT);    
        }
        return user;
    }
    return nil;
}

- (Room *)paserRoom:(NSDictionary *)dict
{
    if (dict && [[dict allKeys] count] != 0) {
        Room *room = [[[Room alloc] init]autorelease];
        room.roomId = [dict objectForKey:PARA_ROOM_ID];
        room.roomName = [dict objectForKey:PARA_ROOM_NAME];
        room.password = [dict objectForKey:PARA_PASSWORD];
        room.gameServerAddress = [dict objectForKey:PARA_SERVER_ADDRESS];
        room.gameServerPort = [dict objectForKey:PARA_SERVER_PORT];
        room.status = ((NSNumber *)[dict objectForKey:PARA_STATUS]).integerValue;
        room.creator = [[[RoomUser alloc] init] autorelease];
        room.creator.userId = [dict objectForKey:PARA_CREATOR_USERID];
        room.creator.nickName = [dict objectForKey:PARA_NICKNAME];
        room.myStatus = UserUnInvited;
        NSString *createrDateString = [dict objectForKey:PARA_CREATE_DATE];
        if ([createrDateString length] != 0) {
            room.createDate = dateFromStringByFormat(createrDateString, DEFAULT_DATE_FORMAT);    
        }
        NSString *expireDateString = [dict objectForKey:PARA_EXPIRE_DATE];
        if ([expireDateString length] != 0) {
            room.createDate = dateFromStringByFormat(expireDateString, DEFAULT_DATE_FORMAT);    
        }
        
        
        //set the creator and the room user list
        NSArray *usersData = [dict objectForKey:PAPA_ROOM_USERS];
        if ([usersData count] != 0) {
            NSMutableArray *userList = [[NSMutableArray alloc] init];
            for (NSDictionary *userDict in usersData) {
                RoomUser *user = [self paserRoomUser:userDict];
                if (user) {
                    if ([user.userId isEqualToString:room.creator.userId]) {
                        room.creator = user;
                    }else{
                        [userList addObject:user];
                        if ([[UserManager defaultManager] isMe:user.userId]) {
                        }
                    }
                    if ([[UserManager defaultManager] isMe:user.userId]) {
                        room.myStatus = user.status;
                        if ([user.userId isEqualToString:room.creator.userId]) {
                            room.myStatus = UserCreator;
                        }
                    }
                }
            }
            if ([userList count] != 0) {
                room.userList = userList;    
            }
            [userList release];
        }
        return room;
    }
    return nil;
}

- (NSArray *)paserRoomList:(NSArray *)data
{
    if ([data count] != 0) {
        NSMutableArray *roomList = [[[NSMutableArray alloc] init]autorelease];
        for(NSDictionary *dict in data)
        {
            Room *room = [self paserRoom:dict];
            if (room) {
                [roomList addObject:room];
            }
        }
        return roomList;
    }
    return nil;
}

- (RoomUserStatus)aFriend:(Friend *)aFriend statusAtRoom:(Room *)room
{
    if (aFriend == nil || room == nil) {
        return NO;
    }
    for (RoomUser *user in room.userList) {
        if ([user.userId isEqualToString:aFriend.friendUserId]) {
            return user.status;
        }
    }
    return UserUnInvited;
}

- (NSMutableArray *)sortRoomList:(NSArray *)roomList
{
    NSArray *array = [roomList sortedArrayUsingComparator:^(id obj1,id obj2){
        Room *room1 = (Room *)obj1;
        Room *room2 = (Room *)obj2;
        NSInteger value = room1.myStatus - room2.myStatus;
        if (value > 0) {
            return NSOrderedDescending;
        }else if(value < 0){
            return NSOrderedAscending;
        }else{
            time_t time1 = [room1.createDate timeIntervalSince1970];
            time_t time2 = [room1.createDate timeIntervalSince1970];
            long v = time1 - time2;
            if (v > 0) {
                return NSOrderedAscending;
            }else{
                return NSOrderedDescending;
            }
        }
    } ];
    return [NSMutableArray arrayWithArray:array];
}

- (BOOL)room:(Room *)room containsUser:(NSString *)userId
{
    if (room && userId) {        
        for (RoomUser *user in room.userList) {
            if ([user.userId isEqualToString:userId]) {
                return YES;
            }
        }
        if ([userId isEqualToString:room.creator.userId]) {
            return YES;
        }
    }
    return NO;
}

- (NSInteger)roomCapacity
{
    return 2;
}
@end
