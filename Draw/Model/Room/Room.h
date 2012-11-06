//
//  Room.h
//  Draw
//
//  Created by  on 12-5-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyFriend.h"

typedef enum {
    RoomUnknow = 0,
    RoomFree = 1,
    RoomUnFull = 2,
    RoomFull = 3
}RoomStatus;


typedef enum {
    UserInvited = 1,
    UserCreator = 2,
    UserJoined = 3,
    UserPlaying = 4,
    UserUnInvited = 100
}RoomUserStatus;

@class RoomUser;
@interface Room : NSObject
{

}


@property(nonatomic, retain)NSString *roomId;
@property(nonatomic, retain)NSString *roomName;
@property(nonatomic, retain)NSString *gameServerAddress;
@property(nonatomic, assign)NSInteger gameServerPort;
@property(nonatomic, retain)NSString *password;
@property(nonatomic, assign)RoomStatus status;
@property(nonatomic, retain)NSDate *createDate;
@property(nonatomic, retain)NSDate *expireDate;
@property(nonatomic, retain)RoomUser *creator;
@property(nonatomic, retain)NSArray *userList;

@property(nonatomic, assign)RoomUserStatus myStatus;


- (NSArray *)playingUserList;
- (BOOL)isMeCreator;
- (RoomUserStatus)myStatus;
@end


@interface RoomUser : NSObject {
    
}
@property(nonatomic,retain)NSString *userId;
@property(nonatomic,retain)NSString *nickName;
@property(nonatomic,retain)NSString *gender;
@property(nonatomic,retain)NSString *avatar;
@property(nonatomic,assign)NSInteger playTimes;
@property(nonatomic,retain)NSDate *lastPlayDate;
@property(nonatomic, assign)RoomUserStatus status;

- (id)initWithFriend:(MyFriend *)aFriend
              status:(RoomUserStatus)status;
- (BOOL)isMale;
- (BOOL)isMe;

@end
