//
//  MessageStat.h
//  Draw
//
//  Created by  on 12-10-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PPMessage.h"

@class PBMessageStat;
@class MyFriend;

@interface MessageStat : NSObject<NSCoding>
{
    NSString *_friendId;
    NSString *_friendNickName;
    NSString *_friendAvatar;
    BOOL _friendGender;
    
    
    NSString *_latestText;
    NSDate *_latestCreateDate;
    NSInteger _numberOfNewMessage;
    NSInteger _numberOfMessage;
    MessageType _messageType;
    SourceType _sourceType;
}
//@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * friendId;
@property (nonatomic, retain) NSString * friendNickName;
@property (nonatomic, retain) NSString * friendAvatar;
@property (nonatomic, retain) NSString * latestText;
@property (nonatomic, retain) NSDate * latestCreateDate;

@property (nonatomic, assign) BOOL friendGender;
@property (nonatomic, assign) NSInteger numberOfNewMessage;
@property (nonatomic, assign) NSInteger numberOfMessage;
@property (nonatomic, assign) MessageType messageType;
@property (nonatomic, assign) SourceType sourceType;


- (id)initWithPBMessageStat:(PBMessageStat *)pbMessageStat;

+ (MessageStat *)messageStatWithFriend:(MyFriend *)myFriend;
- (NSString *)desc;
- (NSString *)friendGenderString;
@end
