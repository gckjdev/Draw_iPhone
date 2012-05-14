//
//  RoomManager.m
//  Draw
//
//  Created by  on 12-5-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RoomManager.h"
#import "GameNetworkConstants.h"
#import "Room.h"
#import "TimeUtils.h"

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


- (RoomUser *)paserRoomUser:(NSDictionary *)dict
{
    if (dict && [[dict allKeys] count] != 0) {
        RoomUser *user = [[[RoomUser alloc] init] autorelease];
        user.userId = [dict objectForKey:PARA_USERID];
        user.nickName = [dict objectForKey:PARA_NICKNAME];
        user.gender = [dict objectForKey:PARA_GENDER];
        user.avatar = [dict objectForKey:PARA_AVATAR];
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
        room.creator.userId = [dict objectForKey:PARA_USERID];
        room.creator.nickName = [dict objectForKey:PARA_NICKNAME];

        
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
//    return self.roomList;
}

@end
