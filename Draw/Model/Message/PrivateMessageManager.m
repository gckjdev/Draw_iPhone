//
//  PrivateMessageManager.m
//  Draw
//
//  Created by haodong qiu on 12年6月8日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "PrivateMessageManager.h"
#import "Message.h"
#import "CoreDataUtil.h"
#import "GameBasic.pb.h"

@interface PrivateMessageManager ()
- (BOOL)isExist:(NSString *)messageId;
- (NSArray *)findAllMessages;
@end


@implementation PrivateMessageManager

static PrivateMessageManager *_privateMessageManager = nil;

+ (PrivateMessageManager *)defaultManager
{
    if (_privateMessageManager == nil) {
        _privateMessageManager = [[PrivateMessageManager alloc] init];
    }
    return _privateMessageManager;
}


- (BOOL)createMessageWithMessageId:(NSString *)messageId 
                              from:(NSString *)from 
                                to:(NSString *)to 
                          drawData:(NSData *)drawData 
                        createDate:(NSDate *)createDate 
                              text:(NSString *)text 
                            status:(NSNumber *)status
{
    if ([self isExist:messageId]) {
        return YES;
    }
    
    CoreDataManager *dataManager = [CoreDataManager defaultManager];
    [dataManager insert:@"Message"];
//    Message *newMessage = [dataManager insert:@"Message"];
//    [newMessage setMessageId:messageId];;
//    [newMessage setFrom:from];
//    [newMessage setTo:to];
//    [newMessage setDrawData:drawData];
//    [newMessage setCreateDate:createDate];
//    [newMessage setText:text];
//    [newMessage setStatus:status];
    return [dataManager save];
}


- (NSArray *)findAllMessages
{
    CoreDataManager *dataManager = [CoreDataManager defaultManager];
    return [dataManager execute:@"findAllMessages" sortBy:@"createDate" ascending:NO];
}


- (NSArray *)findMessagesByFriendUserId:(NSString *)friendUserId
{
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    NSArray *array = [self findAllMessages];
    for (Message *message in array) {
        if ([message.from isEqualToString:friendUserId] || [message.to isEqualToString:friendUserId]) {
            [mutableArray addObject:message];
        }
    }
    
    return mutableArray;
}


- (BOOL)isExist:(NSString *)messageId 
{
    NSArray *array = [self findAllMessages];
    for (Message *message in array) {
        if ([messageId isEqualToString:message.messageId]) {
            return YES;
        }
    }
    return NO;
}


- (BOOL)createByPBMessage:(PBMessage *)pbMessage
{
    //压缩
    //NSData* data = [NSKeyedArchiver archivedDataWithRootObject:drawDataList];
    
    //解压
    //NSData* temp = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    //NSArray* drawDataList = (NSArray*)temp;
    
    NSData* drawActionListData = [NSKeyedArchiver archivedDataWithRootObject:pbMessage.drawDataList];
    return  [self createMessageWithMessageId:pbMessage.messageId 
                                        from:pbMessage.from 
                                          to:pbMessage.to 
                                    drawData:drawActionListData
                                  createDate:nil   //待PBMessage增加一个createDate
                                        text:pbMessage.text
                                      status:[NSNumber numberWithInt:pbMessage.status]];
}


@end
