//
//  PPMessage.h
//  Draw
//
//  Created by  on 12-10-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DEFAULT_MESSAGE_IMAGE_SIZE (ISIPAD ? CGSizeMake(300,300) : CGSizeMake(120,120))

@class PBMessage;

typedef enum {
    MessageTypeText = 0,
    MessageTypeLocationRequest = 1,
    MessageTypeLocationResponse = 2,
    MessageTypeDraw = 4,
    MessageTypeImage = 5,
    MessageTypeVoice = 6,
} MessageType ;

typedef enum {
    SourceTypeSend = 0,
    SourceTypeReceive = 1,
    SourceTypeSystem = 2,
} SourceType;

typedef enum {
    MessageStatusRead = 0,
    MessageStatusUnread = 1,
    MessageStatusSending = 2,
    MessageStatusSent = 3,
    MessageStatusFail = 4,
} MessageStatus;

@interface PPMessage : NSObject<NSCoding>
{
}
+ (id)messageWithPBMessage:(PBMessage *)pbMessage;
- (id)initWithPBMessage:(PBMessage *)pbMessage;
- (BOOL)isSendMessage;
- (BOOL)isReceiveMessage;
- (BOOL)isMessageSentOrReceived;
- (PBMessage *)toPBMessage;

@property (nonatomic, retain) PBMessage_Builder *messageBuilder;

// for all, PB
@property (nonatomic, assign) NSString * messageId;
@property (nonatomic, assign) NSDate * createDate;
@property (nonatomic, assign) NSString * text;

// for all, non PB
@property (nonatomic, retain) NSString * friendId;
@property (nonatomic, assign) MessageStatus status;         //read or unread //use in the future
@property (nonatomic, assign) MessageType messageType;      //create message by the type
@property (nonatomic, assign) SourceType sourceType;        //send receive or system message

// for image, PB
@property (nonatomic, assign) NSString *imageUrl;
@property (nonatomic, assign) NSString *thumbImageUrl;

// for image, non-PB
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) UIImage *thumbImage;
@property (nonatomic, assign) CGSize thumbImageSize;
@property (nonatomic, assign) BOOL hasCalSize;

// for draw, PB
@property (nonatomic, assign) NSInteger drawDataVersion;
@property (nonatomic, assign) CGSize canvasSize;

// for draw, non-PB
@property (nonatomic, retain) NSMutableArray * drawActionList;
@property (nonatomic, retain) NSString *thumbFilePath;

// for location ask & reply, PB
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;

// for location reply, PB
@property (nonatomic, assign) NSString *reqMessageId;
@property (nonatomic, assign) NSInteger replyResult;

- (BOOL)isTextMessage;
- (BOOL)isDrawMessage;
- (BOOL)isImageMessage;

- (void)setIsGroup:(BOOL)isGroup;
- (BOOL)isGroup;

- (void)setFriendId:(NSString *)friendId nickName:(NSString*)nickName;

- (PBGameUser*)fromUserToGroup;

@end
