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
        
        CommonNetworkOutput* output = [GameNetworkRequest createRoom:SERVER_URL roomName:roomName password:password userId:userId nick:nickName avatar:avatar gender:gender];        
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
        
        CommonNetworkOutput* output = [GameNetworkRequest findRoomByUser:SERVER_URL userId:userId offset:offset limit:limit];
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
        
        CommonNetworkOutput* output = [GameNetworkRequest searhRoomWithKey:SERVER_URL keyword:key offset:offset limit:limit];
        
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

- (void)inviteUsers:(NSString *)roomId 
           password:(NSString *)roomPassword
           userList:(NSArray *)userList
{
    
}

- (void)updateRoom:(NSString *)roomId 
          password:(NSString *)roomPassword 
          roomName:(NSString *)roomName
{
    
}
@end
