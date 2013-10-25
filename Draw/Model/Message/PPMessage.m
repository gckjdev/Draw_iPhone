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

#define DEFAULT_IMAGE_SIZE (ISIPAD ?  CGSizeMake(180, 180) : CGSizeMake(80, 80))

#pragma mark ======================= PPMessage =======================
@implementation PPMessage
//@synthesize messageId = _messageId;
//@synthesize createDate = _createDate;
//@synthesize friendId = _friendId;
//@synthesize status = _status; 
//@synthesize messageType = _messageType;
//@synthesize sourceType = _sourceType;
//@synthesize text = _text;

- (NSString*)description
{
    return [NSString stringWithFormat:@"id=%@, friendId=%@, status=%d, type=%d, source=%d, text=%@, date=%@",
            self.messageId, self.friendId, self.status, self.messageType, self.sourceType, self.text, [self.createDate description]];
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
//    PPDebug(@"PPMessage = %@ dealloc", self);
//    self.messageId = nil;
//    self.createDate = nil;
//    self.text = nil;
    PPRelease(_friendId);
    
    PPRelease(_drawActionList);
    PPRelease(_thumbImage);
    PPRelease(_thumbFilePath);

//    self.imageUrl = nil;
//    self.thumbImageUrl = nil;
    PPRelease(_image);

//    self.reqMessageId = nil;
    
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

- (id)initWithPBMessage:(PBMessage *)pbMessage
{
    self = [super init];
    if (self) {
//        self.messageId = pbMessage.messageId;
//        self.createDate = [NSDate dateWithTimeIntervalSince1970:pbMessage.createDate];
//        self.status = pbMessage.status;
//        self.messageType = pbMessage.type;

        self.messageBuilder = [PBMessage builderWithPrototype:pbMessage];
        
//        self.text = pbMessage.text;
        
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
            self.thumbImageSize = DEFAULT_IMAGE_SIZE;
            if (pbMessage.status == MessageStatusFail ||
                pbMessage.status == MessageStatusSending) {
                // TODO performance is so so here if load all images???
                _image = [[UIImage alloc] initWithContentsOfFile:self.imageUrl];    // thumb image
                if (_image) {
                    self.thumbImageSize = _image.size;
                }
            }
        }
        
        PPDebug(@"init message %@", [self description]);
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
            self.thumbImageSize = DEFAULT_IMAGE_SIZE;
        }
    }
}

//@property (nonatomic, retain) NSMutableArray * drawActionList;
//@property (nonatomic, retain) NSString *thumbFilePath;
//@property (nonatomic, assign) NSInteger drawDataVersion;
//@property (nonatomic, assign) CGSize canvasSize;
//
////@property (nonatomic, retain) NSDate * createDate;
//@property (nonatomic, retain) NSString * friendId;
//@property (nonatomic, retain) NSString * text;
//
//@property (nonatomic, assign) MessageStatus status; //read or unread //use in the future
//@property (nonatomic, assign) MessageType messageType; //create message by the type
//@property (nonatomic, assign) SourceType sourceType; //send receive or system message
//
//// for image
//@property (nonatomic, retain) UIImage *image;
//@property (nonatomic, retain) NSString *imageUrl;
//@property (nonatomic, retain) UIImage *thumbImage;
//@property (nonatomic, retain) NSString *thumbImageUrl;
//@property (nonatomic, assign) CGSize thumbImageSize;
//@property (nonatomic, assign) BOOL hasCalSize;
//
//// for draw
//@property (nonatomic, retain) NSMutableArray * drawActionList;
//@property (nonatomic, retain) NSString *thumbFilePath;
//@property (nonatomic, assign) NSInteger drawDataVersion;
//@property (nonatomic, assign) CGSize canvasSize;
//
//// for location ask & reply
//@property (nonatomic, assign) double latitude;
//@property (nonatomic, assign) double longitude;
//
//// for location reply
//@property (nonatomic, retain) NSString *reqMessageId;
//@property (nonatomic, assign) NSInteger replyResult;

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
    
//    PPDebug(@"<toPBMessage> before %@", [self description]);
    PBMessage* message = [_messageBuilder build];
    self.messageBuilder = [PBMessage builderWithPrototype:message];
//    PPDebug(@"<toPBMessage> after %@", [self description]);
    return message;
}

//- (void)updatePBMessageBuilder:(PBMessage_Builder *)builder
//{        
//    [builder setMessageId:self.messageId];
//    [builder setCreateDate:[self.createDate timeIntervalSince1970]];
//    [builder setStatus:self.status];
//    [builder setType:self.messageType];
//    if (self.text) {
//        [builder setText:self.text];
//    }
//    NSString *from = nil;
//    NSString *to = nil;
//    
//    if (self.sourceType == SourceTypeSend) {
//        from = [[UserManager defaultManager] userId];
//        to = self.friendId;
//    }else{
//        from = self.friendId;
//        to = [[UserManager defaultManager] userId];
//    }
//    if(from) [builder setFrom:from];
//    if(to) [builder setTo:to];
//}

//- (PBMessage *)toPBMessage
//{
//    PBMessage_Builder *builder = [[[PBMessage_Builder alloc] init] autorelease];
//    [self updatePBMessageBuilder:builder];
//    return [builder build];
//}

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

@end

//#pragma mark TextMessage
//
//@implementation TextMessage
//
//
//-(void)dealloc
//{
//    [super dealloc];
//}
//
//- (id)initWithPBMessage:(PBMessage *)pbMessage
//{
//    self = [super initWithPBMessage:pbMessage];
//    if (self) {
//
//    }
//    return self;
//}
//
//- (PBMessage *)toPBMessage
//{
//    return [super toPBMessage];
//}
//
//@end

//#pragma mark =======================DrawMessage=======================
//
//@implementation DrawMessage
//@synthesize drawActionList = _drawActionList;
//@synthesize thumbImage = _thumbImage;
//@synthesize thumbFilePath = _thumbFilePath;
//
//
//
//- (void)dealloc
//{
//    PPRelease(_drawActionList);
//    PPRelease(_thumbImage);
//    PPRelease(_thumbFilePath);
//    [super dealloc];
//}
//
//- (id)initWithPBMessage:(PBMessage *)pbMessage
//{
//    self = [super initWithPBMessage:pbMessage];
//    if (self) {
//        
//        _drawActionList = [[DrawAction drawActionListFromPBMessage:pbMessage] retain];
//        
//        self.drawDataVersion = pbMessage.drawDataVersion;
//        if ([pbMessage hasCanvasSize]) {
//            self.canvasSize = CGSizeFromPBSize(pbMessage.canvasSize);
//        }else{
//            self.canvasSize = [CanvasRect deprecatedIPhoneRect].size;
//        }
//    }
//    return self;
//}
//
//- (PBMessage *)toPBMessage
//{
//    PBMessage_Builder *builder = [[[PBMessage_Builder alloc] init] autorelease];
//    [super updatePBMessageBuilder:builder];
//    [builder setCanvasSize:CGSizeToPBSize(self.canvasSize)];
//    [builder setDrawDataVersion:self.drawDataVersion];
//    if ([self.drawActionList count] != 0) {
//        for (DrawAction *action in self.drawActionList) {
//            NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
//
//            NSData *data = [action toData];
//            
//            PBDrawAction* pbDrawAction = [PBDrawAction parseFromData:data];
//            [builder addDrawData:pbDrawAction];
//            
//            [pool drain];
//            
//        }
//    }
//    return [builder build];
//}

//
//
//- (void)setThumbImage:(UIImage *)thumbImage
//{
//    if (thumbImage != _thumbImage) {
//        PPRelease(_thumbImage);
//        _thumbImage = [thumbImage retain];
//    }
//
//}
//
//@end
//
//
//#pragma mark =======================LocationAskMessage=======================
//
//@implementation LocationAskMessage
//@synthesize latitude = _latitude;
//@synthesize longitude = _longitude;
//
//
//- (void)dealloc
//{
//    PPRelease(_text);
//    [super dealloc];
//}
//
//- (id)initWithPBMessage:(PBMessage *)pbMessage
//{
//    self = [super initWithPBMessage:pbMessage];
//    if (self) {
//        self.longitude = pbMessage.longitude;
//        self.latitude = pbMessage.latitude;
//    }
//    return self;
//}
//
//- (PBMessage *)toPBMessage
//{
//    PBMessage_Builder *builder = [[[PBMessage_Builder alloc] init] autorelease];
//    [super updatePBMessageBuilder:builder];
//    [builder setLatitude:self.latitude];
//    [builder setLongitude:self.longitude];
//    return [builder build];
//}


//@end


//#pragma mark =======================LocationReplyMessage=======================
//
//@implementation LocationReplyMessage
//@synthesize latitude = _latitude;
//@synthesize longitude = _longitude;
//@synthesize replyResult = _replyResult;
//@synthesize reqMessageId = _reqMessageId;
//
//- (void)dealloc
//{
//    PPRelease(_reqMessageId);
//    [super dealloc];
//}
//
//- (id)initWithPBMessage:(PBMessage *)pbMessage
//{
//    self = [super initWithPBMessage:pbMessage];
//    if (self) {
//        self.longitude = pbMessage.longitude;
//        self.latitude = pbMessage.latitude;
//        self.reqMessageId = pbMessage.reqMessageId;
//        self.replyResult = pbMessage.replyResult;
//    }
//    return self;
//}
//
//- (PBMessage *)toPBMessage
//{
//    PBMessage_Builder *builder = [[[PBMessage_Builder alloc] init] autorelease];
//    [super updatePBMessageBuilder:builder];
//    [builder setLatitude:self.latitude];
//    [builder setLongitude:self.longitude];
//    [builder setReplyResult:self.replyResult];
//    [builder setReqMessageId:self.reqMessageId];
//    return [builder build];
//}

//@end


#pragma mark =======================ImageMessage=======================



//@implementation ImageMessage
//@synthesize image = _image;
//@synthesize imageUrl = _imageUrl;
//
//- (id)initWithPBMessage:(PBMessage *)pbMessage
//{
//    self = [super initWithPBMessage:pbMessage];
//    if (self) {
//        self.imageUrl = pbMessage.imageUrl;
//        self.thumbImageUrl = pbMessage.thumbImageUrl;
//        self.thumbImageSize = DEFAULT_IMAGE_SIZE;
//        if (pbMessage.status == MessageStatusFail ||
//            pbMessage.status == MessageStatusSending) {
//            self.image = [UIImage imageWithContentsOfFile:self.imageUrl];
//            if (self.image) {
//                self.thumbImageSize = _image.size;
//            }
//        }
//
//    }
//    return self;
//}
//
//
//- (id)init
//{
//    self = [super init];
//    if (self) {
//        self.thumbImageSize = DEFAULT_IMAGE_SIZE;
//        self.messageType = MessageTypeImage;
//    }
//    return self;
//}
//
//- (void)setImage:(UIImage *)image
//{
//    if (_image != image) {
//        PPRelease(_image);
//        _image = [image retain];
//        if (_image != nil){
//            self.thumbImageSize = _image.size;
//        }
//        else{
//            self.thumbImageSize = DEFAULT_IMAGE_SIZE;
//        }
//    }
//}
//
//- (PBMessage *)toPBMessage
//{
//    PBMessage_Builder *builder = [[[PBMessage_Builder alloc] init] autorelease];
//    [super updatePBMessageBuilder:builder];
//    [builder setImageUrl:self.imageUrl];
//    [builder setThumbImageUrl:self.thumbImageUrl];
//    return [builder build];
//}
//
//
//
//- (void)dealloc
//{
//    PPRelease(_imageUrl);
//    PPRelease(_image);
//    PPRelease(_thumbImage);
//    PPRelease(_thumbImageUrl);
//    [super dealloc];
//}

//@end


