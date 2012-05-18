//
//  RoomManager.h
//  Draw
//
//  Created by  on 12-5-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Room.h"
@class Friend;

@interface RoomManager : NSObject
{
    NSMutableArray *_roomList;
}

@property(nonatomic, retain)NSMutableArray *roomList;
+ (RoomManager *)defaultManager;

- (void)cleanData;
- (NSArray *)getLocalRoomList;
- (NSArray *)getMyRoomList;
- (NSArray *)getInvitedRoomList;
- (NSArray *)getJoinedRoomList;
- (Room *)paserRoom:(NSDictionary *)dict;
- (NSArray *)paserRoomList:(NSArray *)data;
- (NSString *)nickStringFromUsers:(NSArray *)userList 
                            split:(NSString *)split 
                            count:(NSInteger)count;
- (RoomUserStatus)aFriend:(Friend *)aFriend statusAtRoom:(Room *)room;
- (NSMutableArray *)sortRoomList:(NSArray *)roomList;
- (BOOL)room:(Room *)room containsUser:(NSString *)userId;
- (NSInteger)roomFriendCapacity;
- (NSInteger)roomCapacity;
@end
