//
//  Room.h
//  Draw
//
//  Created by  on 12-5-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    RoomWaitting = 1,
    RoomPlaying = 2,
    RoomFull = 3
}RoomStatus;


typedef enum {
    UserJoined = 1,
    UserInvited = 2,
    UserCreator = 3
}RoomUserStatus;

@class RoomUser;
@interface Room : NSObject
{

}


@property(nonatomic, retain)NSString *roomId;
@property(nonatomic, retain)NSString *roomName;
@property(nonatomic, retain)NSString *gameServerAddress;
@property(nonatomic, retain)NSString *gameServerPort;
@property(nonatomic, retain)NSString *password;
@property(nonatomic, assign)RoomStatus status;
@property(nonatomic, retain)NSDate *createDate;
@property(nonatomic, retain)NSDate *expireDate;
@property(nonatomic, retain)RoomUser *creator;
@property(nonatomic, retain)NSArray *userList;


@end


@interface RoomUser : NSObject {
    
}
@property(nonatomic,retain)NSString *userId;
@property(nonatomic,retain)NSString *nickName;
@property(nonatomic,retain)NSString *gender;
@property(nonatomic,retain)NSString *avatar;
@property(nonatomic,assign)NSInteger playTimes;
@property(nonatomic,retain)NSDate *lastPlayDate;
@property(nonatomic, assign)RoomStatus status;


- (BOOL)isFemale;
- (BOOL)isMe;

@end
