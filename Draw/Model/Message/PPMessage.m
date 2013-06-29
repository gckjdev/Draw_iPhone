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
@synthesize messageId = _messageId;
@synthesize createDate = _createDate;
@synthesize friendId = _friendId;
@synthesize status = _status; 
@synthesize messageType = _messageType;
@synthesize sourceType = _sourceType;
@synthesize text = _text;


+ (id)oldMessageWithPBMessage:(PBMessage *)pbMessage
{
    PPMessage *message = nil;
    if ([[pbMessage drawDataList] count] != 0) {
        message = [[[DrawMessage alloc] initWithPBMessage:pbMessage] autorelease];
        message.messageType = MessageTypeDraw;
    }else{
        message = [[[TextMessage alloc] initWithPBMessage:pbMessage] autorelease];
        message.messageType = MessageTypeText;
    }
    return message;
}


+ (id)messageWithPBMessage:(PBMessage *)pbMessage
{
    if ([pbMessage hasType] == NO || [[pbMessage drawDataList] count] != 0) {
        return [PPMessage oldMessageWithPBMessage:pbMessage];
    }
    
    switch (pbMessage.type) {
        case MessageTypeText:
            return [[[TextMessage alloc] initWithPBMessage:pbMessage] autorelease];
            
        case MessageTypeDraw:
            return [[[DrawMessage alloc] initWithPBMessage:pbMessage] autorelease];
            
        case MessageTypeLocationRequest:
            return [[[LocationAskMessage alloc] initWithPBMessage:pbMessage] autorelease];
            
        case MessageTypeLocationResponse:
            return [[[LocationReplyMessage alloc] initWithPBMessage:pbMessage] autorelease];

        case MessageTypeImage:
            return [[[ImageMessage alloc] initWithPBMessage:pbMessage] autorelease];
            
        case MessageTypeVoice:
            return [[[VoiceMessage alloc] initWithPBMessage:pbMessage] autorelease];

        default:
            return nil;
    }
}

- (void)dealloc
{
    PPDebug(@"PPMessage = %@ dealloc", self);
    PPRelease(_messageId);
    PPRelease(_createDate);
    PPRelease(_friendId);
    PPRelease(_text);
    [super dealloc];
}

- (id)initWithPBMessage:(PBMessage *)pbMessage
{
    self = [super init];
    if (self) {
        self.messageId = pbMessage.messageId;
        self.createDate = [NSDate dateWithTimeIntervalSince1970:pbMessage.createDate];
        self.status = pbMessage.status;
        self.messageType = pbMessage.type;

        self.text = pbMessage.text;
        if ([[UserManager defaultManager] isMe:pbMessage.from]) {
            self.friendId = pbMessage.to;
            self.sourceType = SourceTypeSend;
            //self.status = MessageStatusSent;
        }else{
            self.friendId = pbMessage.from;
            self.sourceType = SourceTypeReceive;
            self.status = MessageStatusRead;
        }        
    }
    return self;
}

- (void)updatePBMessageBuilder:(PBMessage_Builder *)builder
{
    [builder setMessageId:self.messageId];
    [builder setCreateDate:[self.createDate timeIntervalSince1970]];
    [builder setStatus:self.status];
    [builder setType:self.messageType];
    if (self.text) {
        [builder setText:self.text];
    }
    NSString *from = nil;
    NSString *to = nil;
    
    if (self.sourceType == SourceTypeSend) {
        from = [[UserManager defaultManager] userId];
        to = self.friendId;
    }else{
        from = self.friendId;
        to = [[UserManager defaultManager] userId];
    }
    if(from) [builder setFrom:from];
    if(to) [builder setTo:to];
}
- (PBMessage *)toPBMessage
{
    PBMessage_Builder *builder = [[[PBMessage_Builder alloc] init] autorelease];
    [self updatePBMessageBuilder:builder];
    return [builder build];
}

//- (void)encodeWithCoder:(NSCoder *)aCoder
//{
//    [aCoder encodeObject:self.messageId forKey:KEY_MESSAGEID];
//    [aCoder encodeObject:self.createDate forKey:KEY_CREATE_DATE];
//    [aCoder encodeObject:self.friendId forKey:KEY_FRIEND_ID];
//    [aCoder encodeInteger:self.status forKey:KEY_STATUS];
//    [aCoder encodeInteger:self.messageType forKey:KEY_MESSAGE_TYPE];
//    [aCoder encodeInteger:self.sourceType forKey:KEY_SOURCE_TYPE];
//    [aCoder encodeObject:self.text forKey:KEY_TEXT];
//}
//
//- (id)initWithCoder:(NSCoder *)aDecoder
//{
//    self = [super init];
//    if (self) {
//        self.messageId = [aDecoder decodeObjectForKey:KEY_MESSAGEID];
//        self.createDate = [aDecoder decodeObjectForKey:KEY_CREATE_DATE];
//        self.friendId = [aDecoder decodeObjectForKey:KEY_FRIEND_ID];
//        self.status = [aDecoder decodeIntegerForKey:KEY_STATUS];
//        self.messageType = [aDecoder decodeIntegerForKey:KEY_MESSAGE_TYPE];
//        self.sourceType = [aDecoder decodeIntegerForKey:KEY_SOURCE_TYPE];
//        self.text = [aDecoder decodeObjectForKey:KEY_TEXT];
//    }
//    return self;
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

#pragma mark TextMessage

@implementation TextMessage


-(void)dealloc
{
    [super dealloc];
}

- (id)initWithPBMessage:(PBMessage *)pbMessage
{
    self = [super initWithPBMessage:pbMessage];
    if (self) {

    }
    return self;
}

- (PBMessage *)toPBMessage
{
    return [super toPBMessage];
}

//- (void)encodeWithCoder:(NSCoder *)aCoder
//{
//    [super encodeWithCoder:aCoder];
//
//}
//
//- (id)initWithCoder:(NSCoder *)aDecoder
//{
//    self = [super initWithCoder:aDecoder];
//    if (self) {
//
//    }
//    return self;
//}


@end

#pragma mark =======================DrawMessage=======================

@implementation DrawMessage
@synthesize drawActionList = _drawActionList;
@synthesize thumbImage = _thumbImage;
@synthesize thumbFilePath = _thumbFilePath;



- (void)dealloc
{
    PPRelease(_drawActionList);
    PPRelease(_thumbImage);
    PPRelease(_thumbFilePath);
    [super dealloc];
}

- (id)initWithPBMessage:(PBMessage *)pbMessage
{
    self = [super initWithPBMessage:pbMessage];
    if (self) {
        NSArray *pbAList = [pbMessage drawDataList];
//        _drawActionList = [[NSMutableArray alloc] initWithCapacity:[pbAList count]];
//        for (PBDrawAction *action in pbAList) {
//            DrawAction *da = [DrawAction drawActionWithPBDrawAction:action];
//            [_drawActionList addObject:da];
//        }
        
        _drawActionList = [[DrawAction drawActionListFromPBBMessage:pbMessage] retain];
        
        self.drawDataVersion = pbMessage.drawDataVersion;
        if ([pbMessage hasCanvasSize]) {
            self.canvasSize = CGSizeFromPBSize(pbMessage.canvasSize);
        }else{
            self.canvasSize = [CanvasRect deprecatedIPhoneRect].size;
        }
    }
    return self;
}

- (PBMessage *)toPBMessage
{
    PBMessage_Builder *builder = [[[PBMessage_Builder alloc] init] autorelease];
    [super updatePBMessageBuilder:builder];
    [builder setCanvasSize:CGSizeToPBSize(self.canvasSize)];
    [builder setDrawDataVersion:self.drawDataVersion];
    if ([self.drawActionList count] != 0) {
        for (DrawAction *action in self.drawActionList) {
            [builder addDrawData:[action toPBDrawAction]];
        }
    }
    return [builder build];
}

//- (void)encodeWithCoder:(NSCoder *)aCoder
//{
//    [super encodeWithCoder:aCoder];
//    [aCoder encodeObject:self.drawActionList forKey:KEY_ACTION_LIST];
//    [aCoder encodeObject:self.thumbFilePath forKey:KEY_THUMB_PATH];
//}
//
//- (id)initWithCoder:(NSCoder *)aDecoder
//{
//    self = [super initWithCoder:aDecoder];
//    if (self) {
//        self.drawActionList = [aDecoder decodeObjectForKey:KEY_ACTION_LIST];
//        self.thumbFilePath = [aDecoder decodeObjectForKey:KEY_THUMB_PATH];
//    }
//    return self;
//}


@end


#pragma mark =======================LocationAskMessage=======================

@implementation LocationAskMessage
@synthesize latitude = _latitude;
@synthesize longitude = _longitude;


- (void)dealloc
{
    PPRelease(_text);
    [super dealloc];
}

- (id)initWithPBMessage:(PBMessage *)pbMessage
{
    self = [super initWithPBMessage:pbMessage];
    if (self) {
        self.longitude = pbMessage.longitude;
        self.latitude = pbMessage.latitude;
    }
    return self;
}

- (PBMessage *)toPBMessage
{
    PBMessage_Builder *builder = [[[PBMessage_Builder alloc] init] autorelease];
    [super updatePBMessageBuilder:builder];
    [builder setLatitude:self.latitude];
    [builder setLongitude:self.longitude];
    return [builder build];
}

//- (void)encodeWithCoder:(NSCoder *)aCoder
//{
//    [super encodeWithCoder:aCoder];
//    [aCoder encodeDouble:self.longitude forKey:KEY_LONGITUDE];
//    [aCoder encodeDouble:self.latitude forKey:KEY_LATITUDE];
//}
//
//- (id)initWithCoder:(NSCoder *)aDecoder
//{
//    self = [super initWithCoder:aDecoder];
//    if (self) {
//        self.latitude = [aDecoder decodeDoubleForKey:KEY_LATITUDE];
//        self.longitude = [aDecoder decodeDoubleForKey:KEY_LONGITUDE];
//    }
//    return self;
//}
@end


#pragma mark =======================LocationReplyMessage=======================

@implementation LocationReplyMessage
@synthesize latitude = _latitude;
@synthesize longitude = _longitude;
@synthesize replyResult = _replyResult;
@synthesize reqMessageId = _reqMessageId;

- (void)dealloc
{
    PPRelease(_reqMessageId);
    [super dealloc];
}

- (id)initWithPBMessage:(PBMessage *)pbMessage
{
    self = [super initWithPBMessage:pbMessage];
    if (self) {
        self.longitude = pbMessage.longitude;
        self.latitude = pbMessage.latitude;
        self.reqMessageId = pbMessage.reqMessageId;
        self.replyResult = pbMessage.replyResult;
    }
    return self;
}

- (PBMessage *)toPBMessage
{
    PBMessage_Builder *builder = [[[PBMessage_Builder alloc] init] autorelease];
    [super updatePBMessageBuilder:builder];
    [builder setLatitude:self.latitude];
    [builder setLongitude:self.longitude];
    [builder setReplyResult:self.replyResult];
    [builder setReqMessageId:self.reqMessageId];
    return [builder build];
}

//- (void)encodeWithCoder:(NSCoder *)aCoder
//{
//    [super encodeWithCoder:aCoder];
//    
//    [aCoder encodeObject:self.reqMessageId forKey:KEY_REQ_MESSAGEID];
//    
//    [aCoder encodeDouble:self.longitude forKey:KEY_LONGITUDE];
//    [aCoder encodeDouble:self.latitude forKey:KEY_LATITUDE];
//    
//    [aCoder encodeInteger:self.replyResult forKey:KEY_REPLY_RESULT];
//
//    
//}
//
//- (id)initWithCoder:(NSCoder *)aDecoder
//{
//    self = [super initWithCoder:aDecoder];
//    if (self) {
//        self.latitude = [aDecoder decodeDoubleForKey:KEY_LATITUDE];
//        self.longitude = [aDecoder decodeDoubleForKey:KEY_LONGITUDE];
//        self.replyResult = [aDecoder decodeIntegerForKey:KEY_REPLY_RESULT];
//        self.reqMessageId = [aDecoder decodeObjectForKey:KEY_REQ_MESSAGEID];
//    }
//    return self;
//}
@end


#pragma mark =======================ImageMessage=======================

#define DEFAULT_IMAGE_SIZE (ISIPAD ?  CGSizeMake(180, 180) : CGSizeMake(80, 80))

@implementation ImageMessage
@synthesize image = _image;
@synthesize imageUrl = _imageUrl;

- (id)initWithPBMessage:(PBMessage *)pbMessage
{
    self = [super initWithPBMessage:pbMessage];
    if (self) {
        self.imageUrl = pbMessage.imageUrl;
        self.thumbImageUrl = pbMessage.thumbImageUrl;
        self.thumbImageSize = DEFAULT_IMAGE_SIZE;
        if (pbMessage.status == MessageStatusFail ||
            pbMessage.status == MessageStatusSending) {
            self.image = [UIImage imageWithContentsOfFile:self.imageUrl];
            if (self.image) {
                self.thumbImageSize = _image.size;
            }
        }

    }
    return self;
}


- (id)init
{
    self = [super init];
    if (self) {
        self.thumbImageSize = DEFAULT_IMAGE_SIZE;
        self.messageType = MessageTypeImage;
    }
    return self;
}

- (void)setImage:(UIImage *)image
{
    if (_image != image) {
        PPRelease(_image);
        _image = [image retain];
        self.thumbImageSize = _image.size;
    }
}

- (PBMessage *)toPBMessage
{
    PBMessage_Builder *builder = [[[PBMessage_Builder alloc] init] autorelease];
    [super updatePBMessageBuilder:builder];
    [builder setImageUrl:self.imageUrl];
    [builder setThumbImageUrl:self.thumbImageUrl];
    return [builder build];
}



- (void)dealloc
{
    PPRelease(_imageUrl);
    PPRelease(_image);
    PPRelease(_thumbImage);
    PPRelease(_thumbImageUrl);
    [super dealloc];
}
//- (void)encodeWithCoder:(NSCoder *)aCoder
//{
//    [super encodeWithCoder:aCoder];
//    
//    [aCoder encodeObject:self.imageUrl forKey:KEY_IMAGE_URL];    
//    
//}
//
//- (id)initWithCoder:(NSCoder *)aDecoder
//{
//    self = [super initWithCoder:aDecoder];
//    if (self) {
//        self.imageUrl = [aDecoder decodeObjectForKey:KEY_IMAGE_URL];
//    }
//    return self;
//}

@end


#pragma mark ======================VoiceMessage =======================

@implementation VoiceMessage

- (void)dealloc
{
    [super dealloc];
}

- (id)initWithPBMessage:(PBMessage *)pbMessage
{
    self = [super initWithPBMessage:pbMessage];
    if (self) {
        //TODO set voice data.
    }
    return self;
}

//- (void)encodeWithCoder:(NSCoder *)aCoder
//{
//    [super encodeWithCoder:aCoder];
//}
//
//- (id)initWithCoder:(NSCoder *)aDecoder
//{
//    self = [super initWithCoder:aDecoder];
//    if (self) {
//        //init the attributes.
//    }
//    return self;
//}

@end