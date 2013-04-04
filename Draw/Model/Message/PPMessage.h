//
//  PPMessage.h
//  Draw
//
//  Created by  on 12-10-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@class PBMessage;
//the super message of all the message

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

@interface PPMessage : NSObject
{
    NSString * _messageId;
    NSDate * _createDate;
    NSString * _friendId;
    NSString *_text;
    MessageStatus _status;
    MessageType _messageType;
    SourceType _sourceType;
}
+ (id)messageWithPBMessage:(PBMessage *)pbMessage;
- (id)initWithPBMessage:(PBMessage *)pbMessage;
- (BOOL)isSendMessage;
- (BOOL)isReceiveMessage;
- (BOOL)isMessageSentOrReceived;
- (PBMessage *)toPBMessage;
- (void)updatePBMessageBuilder:(PBMessage_Builder *)builder;

@property (nonatomic, retain) NSString * messageId;
@property (nonatomic, retain) NSDate * createDate;
@property (nonatomic, retain) NSString * friendId;
@property (nonatomic, retain) NSString * text;

@property (nonatomic, assign) MessageStatus status; //read or unread //use in the future
@property (nonatomic, assign) MessageType messageType; //create message by the type
@property (nonatomic, assign) SourceType sourceType; //send receive or system message




@end

@interface TextMessage : PPMessage {

}
- (id)initWithPBMessage:(PBMessage *)pbMessage;

@end

@interface DrawMessage : PPMessage {
    NSMutableArray *_drawActionList;
    UIImage *_thumbImage; //create from the drawActionList
    NSString *_thumbFilePath;
}

- (id)initWithPBMessage:(PBMessage *)pbMessage;

@property (nonatomic, retain) NSMutableArray * drawActionList;
@property (nonatomic, retain) UIImage *thumbImage;
@property (nonatomic, retain) NSString *thumbFilePath;
@property (nonatomic, assign) NSInteger drawDataVersion;
@property (nonatomic, assign) CGSize canvasSize;
@end


@interface ImageMessage : PPMessage {
    UIImage *_image; //create from the drawActionList
    NSString *_imageUrl;
}

- (id)initWithPBMessage:(PBMessage *)pbMessage;

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) NSString *imageUrl;

@end


@interface VoiceMessage : PPMessage {

}

- (id)initWithPBMessage:(PBMessage *)pbMessage;

//use in the future.
@end


@interface LocationAskMessage : PPMessage {
    double _latitude;
    double _longitude;

}
- (id)initWithPBMessage:(PBMessage *)pbMessage;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;

@end

@interface LocationReplyMessage : PPMessage {
    double _latitude;
    double _longitude;
    NSInteger _replyResult;
    NSString *_reqMessageId;
}
- (id)initWithPBMessage:(PBMessage *)pbMessage;

@property (nonatomic, retain) NSString *reqMessageId;

@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (nonatomic, assign) NSInteger replyResult;

@end

