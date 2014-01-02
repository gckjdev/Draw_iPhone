//
//  PPMessage.m
//  Draw
//
//  Created by  on 12-10-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PPMessage.h"
#import "GameBasic.pb.h"
#import "UserManager.h"
#import "DrawAction.h"
#import "GameMessage.pb.h"
#import "CanvasRect.h"
#import "GameBasic.pb-c.h"

#define KEY_MESSAGE_PB_DATA @"KEY_MESSAGE_PB_DATA"
#define KEY_MESSAGEID @"KEY_MESSAGEID"
#define KEY_CREATE_DATE @"KEY_CREATE_DATE"
#define KEY_FRIEND_ID @"KEY_FRIEND_ID"
#define KEY_STATUS @"KEY_STATUS"
#define KEY_MESSAGE_TYPE @"KEY_MESSAGE_TYPE"
#define KEY_SOURCE_TYPE @"KEY_SOURCE_TYPE"
#define KEY_TEXT @"KEY_TEXT"
#define KEY_ACTION_LIST @"KEY_ACTION_LIST"
#define KEY_LATITUDE @"KEY_LATITUDE"
#define KEY_LONGITUDE @"KEY_LONGITUDE"
#define KEY_THUMB_PATH @"KEY_THUMB_PATH"
#define KEY_IMAGE_URL @"KEY_IMAGE_URL"

#define KEY_REPLY_RESULT @"KEY_REPLY_RESULT"
#define KEY_REQ_MESSAGEID @"KEY_REQ_MESSAGEID"

#pragma mark ======================= PPMessage =======================

@implementation PPMessage

- (NSString*)description
{
    return [NSString stringWithFormat:@"id=%@, friendId=%@, status=%d, type=%d, source=%d, text=%@, date=%@",
            self.messageId, self.friendId, self.status, self.messageType, self.sourceType, self.text, [self.createDate description]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{    
    PBMessage* message = [self.messageBuilder build];

    if (message){
        self.messageBuilder = [PBMessage builderWithPrototype:message];
        [aCoder encodeObject:[message data] forKey:KEY_MESSAGE_PB_DATA];
    }
    
    [aCoder encodeObject:self.messageId forKey:KEY_MESSAGEID];
//    [aCoder encodeInt:self.status forKey:KEY_STATUS];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    
    //    PPDebug(@"PPMessage<initWithCoder> starts");
    self = [super init];
    if (self) {
//        self.status = [aDecoder decodeIntForKey:KEY_STATUS];
        NSData* data = [aDecoder decodeObjectForKey:KEY_MESSAGE_PB_DATA];
        if (data){
            @try {
                PBMessage* pbMessage = [PBMessage parseFromData:data];
                [self setDataWithPBMessage:pbMessage];
            }
            @catch (NSException *exception) {
                PPDebug(@"<PBMessage> initWithCoder error catch exception(%@)", [exception description]);
            }
            @finally {
            }
        }
        
    }

    return self;
}


+ (id)oldMessageWithPBMessage:(PBMessage *)pbMessage
{
    PPDebug(@"<oldMessageWithPBMessage> invoke");
    PPMessage *message = nil;
    if ([[pbMessage drawDataList] count] != 0) {
        message = [[[PPMessage alloc] initWithPBMessage:pbMessage] autorelease];
        message.messageType = MessageTypeDraw;
    }else{
        message = [[[PPMessage alloc] initWithPBMessage:pbMessage] autorelease];
        message.messageType = MessageTypeText;
    }
    return message;
}


+ (id)messageWithPBMessage:(PBMessage *)pbMessage
{
    if ([pbMessage hasType] == NO || [[pbMessage drawDataList] count] != 0) {
        return [PPMessage oldMessageWithPBMessage:pbMessage];
    }
    else{
        return [[[PPMessage alloc] initWithPBMessage:pbMessage] autorelease];
    }
}

- (void)dealloc
{
    PPRelease(_friendId);
    PPRelease(_drawActionList);
    PPRelease(_thumbImage);
    PPRelease(_thumbFilePath);
    PPRelease(_image);
    PPRelease(_messageBuilder);    
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self){
        _messageBuilder = [[PBMessage_Builder alloc] init];

        PPDebug(@"init empty message");        
    }
    return self;
}

- (void)setDataWithPBMessage:(PBMessage *)pbMessage
{
    self.messageBuilder = [PBMessage builderWithPrototype:pbMessage];
    
    if ([[UserManager defaultManager] isMe:pbMessage.from]) {
        self.friendId = pbMessage.to;
        self.sourceType = SourceTypeSend;
    }else{
        self.friendId = pbMessage.from;
        self.sourceType = SourceTypeReceive;
        self.status = MessageStatusRead;
    }
    
    // for draw
    if ([pbMessage.drawDataList count] > 0){
        self.drawActionList = [DrawAction drawActionListFromPBMessage:pbMessage];
    }
    
    // for image
    if (self.messageType == MessageTypeImage){
        self.thumbImageSize = DEFAULT_MESSAGE_IMAGE_SIZE;
        if (pbMessage.status == MessageStatusFail ||
            pbMessage.status == MessageStatusSending) {
            // TODO performance is so so here if load all images???
            _image = [[UIImage alloc] initWithContentsOfFile:self.imageUrl];    // thumb image
            if (_image) {
                self.thumbImageSize = _image.size;
            }
        }
    }
    
//    PPDebug(@"init message %@", [self description]);
}

- (id)initWithPBMessage:(PBMessage *)pbMessage
{
    self = [super init];
    if (self) {
        [self setDataWithPBMessage:pbMessage];
    }
    return self;
}

- (BOOL)isTextMessage
{
    return [_messageBuilder type] == MessageTypeText;
}

- (BOOL)isDrawMessage
{
    return [_messageBuilder type] == MessageTypeDraw;
}

- (BOOL)isImageMessage
{
    return [_messageBuilder type] == MessageTypeImage;
}

- (MessageType)messageType
{
    return [_messageBuilder type];
}

- (void)setMessageType:(MessageType)messageType
{
    [_messageBuilder setType:messageType];
}

- (MessageStatus)status
{
    return [_messageBuilder status];
}

- (void)setStatus:(MessageStatus)status
{
    [_messageBuilder setStatus:status];
}

- (void)setIsGroup:(BOOL)isGroup
{
    [_messageBuilder setIsGroup:isGroup];
}

- (BOOL)isGroup
{
    return [_messageBuilder isGroup];
}

- (NSString*)messageId
{
    return [_messageBuilder messageId];
}

- (void)setMessageId:(NSString *)messageId
{
    [_messageBuilder setMessageId:messageId];
}

- (NSDate*)createDate
{
    return [NSDate dateWithTimeIntervalSince1970:[_messageBuilder createDate]];
}

- (void)setCreateDate:(NSDate *)createDate
{
    [_messageBuilder setCreateDate:[createDate timeIntervalSince1970]];
}

- (NSString*)text
{
    return [_messageBuilder text];
}

- (void)setText:(NSString *)text
{
    if (text == nil)
        return;
    
    [_messageBuilder setText:text];
}

- (NSString*)imageUrl
{
    return [_messageBuilder imageUrl];
}

- (void)setImageUrl:(NSString *)imageUrl
{
    if (imageUrl == nil)
        return;
    
    [_messageBuilder setImageUrl:imageUrl];
}

- (NSString*)thumbImageUrl
{

    return [_messageBuilder thumbImageUrl];
}

- (void)setFriendId:(NSString *)friendId nickName:(NSString*)nickName
{
    [self setFriendId:friendId];
    
    // set from user info
    [_messageBuilder setFromUser:[UserManager defaultManager].pbUser];
    [_messageBuilder setFrom:[UserManager defaultManager].userId];
    [_messageBuilder setTo:friendId];
    
    if (friendId == nil || nickName == nil){
        return;
    }
    
    // set TO user info
    PBGameUser_Builder* toUserBuilder = [PBGameUser builder];
    [toUserBuilder setUserId:friendId];
    [toUserBuilder setNickName:nickName];
    [_messageBuilder setToUser:[toUserBuilder build]];
}

- (void)setThumbImageUrl:(NSString *)thumbImageUrl
{
    if (thumbImageUrl == nil)
        return;

    [_messageBuilder setThumbImageUrl:thumbImageUrl];
}

- (NSInteger)drawDataVersion
{
    return [_messageBuilder drawDataVersion];
}

- (void)setDrawDataVersion:(NSInteger)drawDataVersion
{
    [_messageBuilder setDrawDataVersion:drawDataVersion];
}

- (CGSize)canvasSize
{
    if ([_messageBuilder hasCanvasSize]) {
        return CGSizeFromPBSize(_messageBuilder.canvasSize);
    }else{
        return [CanvasRect deprecatedIPhoneRect].size;
    }
}

- (void)setCanvasSize:(CGSize)canvasSize
{
    [_messageBuilder setCanvasSize:CGSizeToPBSize(canvasSize)];
}

- (double)latitude
{
    return [_messageBuilder latitude];
}

- (void)setLatitude:(double)latitude
{
    [_messageBuilder setLatitude:latitude];
}

- (double)longitude
{
    return [_messageBuilder longitude];
}

- (void)setLongitude:(double)longitude
{
    [_messageBuilder setLongitude:longitude];
}

- (NSString*)reqMessageId
{
    return [_messageBuilder reqMessageId];
}

- (void)setReqMessageId:(NSString *)reqMessageId
{
    if (reqMessageId == nil)
        return;
    
    [_messageBuilder setReqMessageId:reqMessageId];
}

- (NSInteger)replyResult
{
    return [_messageBuilder replyResult];
}

- (void)setReplyResult:(NSInteger)replyResult
{
    [_messageBuilder setReplyResult:replyResult];
}

- (void)setImage:(UIImage *)image
{
    if (_image != image) {
        PPRelease(_image);
        _image = [image retain];
        if (_image != nil){
            self.thumbImageSize = _image.size;
        }
        else{
            self.thumbImageSize = DEFAULT_MESSAGE_IMAGE_SIZE;
        }
    }
}
- (PBMessage*)toPBMessage
{
    // set from and to
    NSString* from;
    NSString* to;
    if (self.sourceType == SourceTypeSend) {
        from = [[UserManager defaultManager] userId];
        to = self.friendId;
    }else{
        from = self.friendId;
        to = [[UserManager defaultManager] userId];
    }
    [_messageBuilder setFrom:from];
    [_messageBuilder setTo:to];
    
    // TODO this may cause some performance issues, to be checked
    // create draw actions
    [_messageBuilder clearDrawDataList];
    if ([self.drawActionList count] != 0) {
        for (DrawAction *action in self.drawActionList) {
            NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
            
            NSData *data = [action toData];
            
            PBDrawAction* pbDrawAction = [PBDrawAction parseFromData:data];
            [_messageBuilder addDrawData:pbDrawAction];
            
            [pool drain];            
        }
    }
    
    PBMessage* message = [_messageBuilder build];
    self.messageBuilder = [PBMessage builderWithPrototype:message];
    return message;
}

- (BOOL)isSendMessage
{
    return self.status == MessageStatusSent || self.status == MessageStatusSending || self.status == MessageStatusFail;
}
- (BOOL)isReceiveMessage
{
    return self.status == MessageStatusRead || self.status == MessageStatusUnread;
}

- (BOOL)isMessageSentOrReceived
{
    return self.status == MessageStatusRead || self.status == MessageStatusSent || self.status == MessageStatusUnread;
}

- (PBGameUser*)fromUserToGroup
{
    return self.messageBuilder.fromUser;
}


@end

