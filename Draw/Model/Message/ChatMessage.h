//
//  ChatMessage.h
//  Draw
//
//  Created by haodong qiu on 12年6月8日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

enum {
    MessageTypeNormal,
    MessageTypeAskLocation,
    MessageTypeReplyLocation
} ChatMessageType ;

@interface ChatMessage : NSManagedObject

@property (nonatomic, retain) NSString * messageId;
@property (nonatomic, retain) NSString * from;
@property (nonatomic, retain) NSString * to;
@property (nonatomic, retain) NSData * drawData;
@property (nonatomic, retain) NSDate * createDate;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber *type;
@property (nonatomic, retain) NSNumber *hasLocation;
@property (nonatomic, retain) NSNumber *latitude;
@property (nonatomic, retain) NSNumber *longitude;
@property (nonatomic, retain) NSNumber *replyResult;
@property (nonatomic, retain) NSNumber *reMessageId;

@end
