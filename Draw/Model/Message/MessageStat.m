//
//  MessageStat.m
//  Draw
//
//  Created by  on 12-10-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MessageStat.h"
#import "GameBasic.pb.h"
#import "UserManager.h"
#import "MyFriend.h"

#define KEY_FRIEND_ID @"KEY_FRIEND_ID"
#define KEY_FRIEND_NICK @"KEY_FRIEND_NICK"
#define KEY_FRIEND_AVATAR @"KEY_FRIEND_AVATAR"
#define KEY_FRIEND_GENDER @"KEY_FRIEND_GENDER"
#define KEY_TEXT @"KEY_TEXT"
#define KEY_CREATE_DATE @"KEY_CREATE_DATE"
#define KEY_NUMBER_TOTAL @"KEY_NUMBER_TOTAL"
#define KEY_NUMBER_NEW @"KEY_NUMBER_NEW"
#define KEY_SOURCE_TYPE @"KEY_SOURCE_TYPE"
#define KEY_MESSAGE_TYPE @"KEY_MESSAGE_TYPE"

@implementation MessageStat

@synthesize friendId = _friendId;
@synthesize friendNickName = _friendNickName;
@synthesize friendAvatar = _friendAvatar;
@synthesize friendGender = _friendGender;


@synthesize latestText = _latestText;
@synthesize latestCreateDate = _latestCreateDate;
@synthesize numberOfNewMessage = _numberOfNewMessage;
@synthesize numberOfMessage = _numberOfMessage;
@synthesize messageType = _messageType;
@synthesize sourceType = _sourceType;


+ (MessageStat *)messageStatWithFriend:(MyFriend *)myFriend
{
    MessageStat *messageStat = [[[MessageStat alloc] init] autorelease];
    [messageStat setFriendId:myFriend.friendUserId];
    [messageStat setFriendNickName:myFriend.nickName];
    [messageStat setFriendAvatar:myFriend.avatar];
    [messageStat setFriendGender:myFriend.isMale];
    
    [messageStat setLatestText:nil];
    [messageStat setLatestCreateDate:[NSDate date]];
    [messageStat setMessageType:MessageTypeText];
    [messageStat setSourceType:SourceTypeSend];
    
    return messageStat;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.friendId forKey:KEY_FRIEND_ID];
    [aCoder encodeObject:self.friendNickName forKey:KEY_FRIEND_NICK];
    [aCoder encodeObject:self.friendAvatar forKey:KEY_FRIEND_AVATAR];
    [aCoder encodeBool:self.friendGender forKey:KEY_FRIEND_GENDER];
    
    [aCoder encodeObject:self.latestText forKey:KEY_TEXT];
    [aCoder encodeObject:self.latestCreateDate forKey:KEY_CREATE_DATE];
    
    [aCoder encodeInteger:self.numberOfMessage forKey:KEY_NUMBER_TOTAL];
    [aCoder encodeInteger:self.numberOfNewMessage forKey:KEY_NUMBER_NEW];
    [aCoder encodeInteger:self.messageType forKey:KEY_MESSAGE_TYPE];
    [aCoder encodeInteger:self.sourceType forKey:KEY_SOURCE_TYPE];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    
    PPDebug(@"PPMessage<initWithCoder> starts");
    self = [super init];
    if (self) {
        
        self.friendId = [aDecoder decodeObjectForKey:KEY_FRIEND_ID];
        self.friendNickName = [aDecoder decodeObjectForKey:KEY_FRIEND_NICK];
        self.friendAvatar = [aDecoder decodeObjectForKey:KEY_FRIEND_AVATAR];
        self.friendGender = [aDecoder decodeBoolForKey:KEY_FRIEND_GENDER];
        
        self.messageType = [aDecoder decodeIntegerForKey:KEY_MESSAGE_TYPE];
        self.sourceType = [aDecoder decodeIntegerForKey:KEY_SOURCE_TYPE];
        
        self.numberOfMessage = [aDecoder decodeIntegerForKey:KEY_NUMBER_TOTAL];
        self.numberOfNewMessage = [aDecoder decodeIntegerForKey:KEY_NUMBER_NEW];
        
        self.latestCreateDate = [aDecoder decodeObjectForKey:KEY_CREATE_DATE];
        self.latestText = [aDecoder decodeObjectForKey:KEY_TEXT];
    }
    PPDebug(@"fid = %@\nick = %@\ntype=%d\ntext=%@\n", self.friendId, self.friendNickName,self.messageType,self.latestText);
    
    PPDebug(@"PPMessage<initWithCoder> end");
    return self;
}




- (id)initWithPBMessageStat:(PBMessageStat *)pbMessageStat
{
    self = [super init];
    if (self) {
        self.friendId = pbMessageStat.friendUserId;
        self.friendNickName = pbMessageStat.friendNickName;
        self.friendAvatar = pbMessageStat.friendAvatar;
        self.friendGender = pbMessageStat.friendGender;
        
        self.latestText = pbMessageStat.text;
        self.messageType = pbMessageStat.type;
        
        self.latestCreateDate = [NSDate dateWithTimeIntervalSince1970:pbMessageStat.modifiedDate];
        
        self.numberOfMessage = pbMessageStat.totalMessageCount;
        self.numberOfNewMessage = pbMessageStat.newMessageCount;
                
        if ([[UserManager defaultManager] isMe:pbMessageStat.from]) {
            self.sourceType = SourceTypeSend;
        }else{
            self.sourceType = SourceTypeReceive;
        }

        //use for the old version by Gamy @2012.10.27
        if ([pbMessageStat.text length] == 0) {
            self.messageType = MessageTypeDraw;
        }else{
            self.messageType = MessageTypeText;
        }

    }
    return self;
}

- (void)dealloc
{
    PPRelease(_friendId);
    PPRelease(_friendAvatar);
    PPRelease(_friendNickName);
    PPRelease(_latestText);
    PPRelease(_latestCreateDate);
    
    [super dealloc];
}

- (NSString *)desc
{
    switch (self.messageType) {

        case MessageTypeDraw:
            return NSLS(@"kDrawMessage");
        case MessageTypeImage:
            return NSLS(@"kImageMessage");
        case MessageTypeVoice:
            return NSLS(@"kVoiceMessage");
            
        case MessageTypeText:
        case MessageTypeLocationRequest:
        case MessageTypeLocationResponse:
        default:
            return self.latestText;
    }
}

- (NSString *)friendGenderString
{
    return self.friendGender ? @"m" : @"f";
}
@end
