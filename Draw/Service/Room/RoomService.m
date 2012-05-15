//
//  RoomService.m
//  Draw
//
//  Created by  on 12-5-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RoomService.h"
#import "GameNetworkConstants.h"
#import "GameNetworkRequest.h"
#import "PPNetworkRequest.h"
#import "UserManager.h"
#import "Room.h"
#import "RoomManager.h"
#import "Friend.h"

RoomService *staticRoomService = nil;

@implementation RoomService


+ (RoomService *)defaultService
{
    if (staticRoomService == nil) {
        staticRoomService = [[RoomService alloc] init];
    }
    return staticRoomService;
}

- (id)init
{
    self = [super init];
    if(self){
        userManager = [UserManager defaultManager];
    }
    return self;
}
- (void)createRoom:(NSString *)roomName 
          password:(NSString *)password 
          delegate:(id<RoomServiceDelegate>) delegate
{
    dispatch_async(workingQueue, ^{
        NSString *userId = [userManager userId]; 
        NSString *nickName = [userManager nickName];
        NSString *gender = [userManager gender];
        NSString *avatar = [userManager avatarURL];
        
        CommonNetworkOutput* output = [GameNetworkRequest createRoom:TRAFFIC_SERVER_URL roomName:roomName password:password userId:userId nick:nickName avatar:avatar gender:gender];        
        Room *room = nil;
        if (output.resultCode == ERROR_SUCCESS) {
            room = [[RoomManager defaultManager] paserRoom:output.jsonDataDict];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didCreateRoom:resultCode:)]) {
                [delegate didCreateRoom:room resultCode:output.resultCode];
            }
        });
        
    });    

}

- (void)findMyRoomsWithOffset:(NSInteger)offset 
                        limit:(NSInteger)limit 
                     delegate: (id<RoomServiceDelegate>) delegate
{
    
    dispatch_async(workingQueue, ^{
        NSString *userId = [userManager userId]; 
        
        CommonNetworkOutput* output = [GameNetworkRequest findRoomByUser:TRAFFIC_SERVER_URL userId:userId offset:offset limit:limit];
        NSArray *roomList = nil;
        if (output.resultCode == ERROR_SUCCESS) {
            roomList = [[RoomManager defaultManager] paserRoomList:output.jsonDataArray];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didFindRoomByUser:roomList:resultCode:)]) {
                [delegate didFindRoomByUser:userId roomList:roomList resultCode:output.resultCode];
            }
        });
        
    });    
    
}

- (void)searchRoomsWithKeyWords:(NSString *)key 
                         offset:(NSInteger)offset 
                          limit:(NSInteger)limit 
                       delegate: (id<RoomServiceDelegate>) delegate
{
    dispatch_async(workingQueue, ^{
        
        CommonNetworkOutput* output = [GameNetworkRequest searhRoomWithKey:TRAFFIC_SERVER_URL keyword:key offset:offset limit:limit];
        
        NSArray *roomList = nil;
        if (output.resultCode == ERROR_SUCCESS) {
            roomList = [[RoomManager defaultManager] paserRoomList:output.jsonDataArray];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didSearhRoomWithKey:roomList:resultCode:)]) {
                [delegate didSearhRoomWithKey:key roomList:roomList resultCode:output.resultCode];
            }
        });
        
    });    

}

- (void)inviteUsers:(NSSet *)friendSet 
             toRoom:(Room *)room 
           delegate: (id<RoomServiceDelegate>) delegate
{
//    dispatch_async(workingQueue, ^{
    
    dispatch_async(workingQueue, ^{
        NSString *userId = [userManager userId]; 
        NSString *roomId = [room roomId];
        NSString *roomPassword = [room password];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (Friend *friend in friendSet) {
            if([friend.friendUserId length] != 0){
                NSString *nick = ([friend.nickName length] == 0) ? @"" :friend.nickName;
                NSString *temp = [NSString stringWithFormat:@"%@,%@",friend.friendUserId,nick];
                [array addObject:temp];
            }
        }
        NSString *usersString = [array componentsJoinedByString:@":"];
        [array release];
        CommonNetworkOutput* output = [GameNetworkRequest inviteUsersToRoom:TRAFFIC_SERVER_URL roomId:roomId password:roomPassword userId:userId userList:usersString];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didInviteFriends:resultCode:)]) {
                [delegate didInviteFriends:friendSet resultCode:output.resultCode];
            }
        });
        
    });    

}

- (void)updateRoom:(NSString *)roomId 
          password:(NSString *)roomPassword 
          roomName:(NSString *)roomName
{

}
@end
