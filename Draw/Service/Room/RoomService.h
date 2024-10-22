//
//  RoomService.h
//  Draw
//
//  Created by  on 12-5-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonService.h"
#import "Room.h"

@protocol RoomServiceDelegate <NSObject>

@optional
- (void)didCreateRoom:(Room*)room resultCode:(int)resultCode; 

- (void)didFindRoomByUser:(NSString *)userId
                 roomList:(NSArray*)roomList
               resultCode:(int)resultCode;

- (void)didSearhRoomWithKey:(NSString *)key 
                   roomList:(NSArray*)roomList
                 resultCode:(int)resultCode;

- (void)didRoom:(Room *)room 
  inviteFriends:(NSSet *)friendSet 
     resultCode:(int)resultCode;

- (void)didRemoveRoom:(Room *)room resultCode:(int)resultCode;
- (void)didJoinNewRoom:(int)resultCode;

@end
@class UserManager;
@interface RoomService : CommonService
{
    UserManager *userManager;
}
+ (RoomService *)defaultService;
- (void)createRoom:(NSString *)roomName 
          password:(NSString *)password 
          delegate:(id<RoomServiceDelegate>) delegate;

- (void)findMyRoomsWithOffset:(NSInteger)offset 
              limit:(NSInteger)limit 
           delegate: (id<RoomServiceDelegate>) delegate;

- (void)searchRoomsWithKeyWords:(NSString *)key 
                         offset:(NSInteger)offset 
                          limit:(NSInteger)limit 
                       delegate: (id<RoomServiceDelegate>) delegate;

- (void)inviteUsers:(NSSet *)friendSet 
             toRoom:(Room *)room 
           delegate: (id<RoomServiceDelegate>) delegate;

- (void)removeRoom:(Room *)room 
          delegate: (id<RoomServiceDelegate>) delegate;



- (void)updateRoom:(NSString *)roomId 
          password:(NSString *)roomPassword 
          roomName:(NSString *)roomName;


- (void)joinNewRoom:(Room *)room delegate:(id<RoomServiceDelegate>)delegate;
@end
