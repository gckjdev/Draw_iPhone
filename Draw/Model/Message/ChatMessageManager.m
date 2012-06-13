//
//  ChatMessageManager.m
//  Draw
//
//  Created by haodong qiu on 12年6月8日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "ChatMessageManager.h"
#import "ChatMessage.h"
#import "CoreDataUtil.h"
#import "GameBasic.pb.h"
#import "DrawAction.h"

@interface ChatMessageManager ()
- (BOOL)isExist:(NSString *)messageId;
- (NSArray *)findAllMessages;
@end


@implementation ChatMessageManager

static ChatMessageManager *_chatMessageManager = nil;

+ (ChatMessageManager *)defaultManager
{
    if (_chatMessageManager == nil) {
        _chatMessageManager = [[ChatMessageManager alloc] init];
    }
    return _chatMessageManager;
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
    ChatMessage *newMessage = [dataManager insert:@"ChatMessage"];
    [newMessage setMessageId:messageId];
    [newMessage setFrom:from];
    [newMessage setTo:to];
    [newMessage setDrawData:drawData];
    [newMessage setCreateDate:createDate];
    [newMessage setText:text];
    [newMessage setStatus:status];
    return [dataManager save];
}


- (NSArray *)findAllMessages
{
    CoreDataManager *dataManager = [CoreDataManager defaultManager];
    return [dataManager execute:@"findAllMessages" sortBy:@"createDate" ascending:YES];
}


- (NSArray *)findMessagesByFriendUserId:(NSString *)friendUserId
{
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    NSArray *array = [self findAllMessages];
    for (ChatMessage *message in array) {
        if ([message.from isEqualToString:friendUserId] || [message.to isEqualToString:friendUserId]) {
            [mutableArray addObject:message];
        }
    }
    
    return mutableArray;
}


- (BOOL)isExist:(NSString *)messageId 
{
    NSArray *array = [self findAllMessages];
    for (ChatMessage *message in array) {
        if ([messageId isEqualToString:message.messageId]) {
            return YES;
        }
    }
    return NO;
}


- (NSData *)archiveDataFromDrawActionList:(NSArray *)aDrawActionList
{
    //压缩
    //NSData* data = [NSKeyedArchiver archivedDataWithRootObject:drawDataList];
    
    //解压
    //NSData* temp = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    //NSArray* drawDataList = (NSArray*)temp;
    
    NSData* reData = [NSKeyedArchiver archivedDataWithRootObject:aDrawActionList];
    return reData;
}

- (NSArray *)unarchiveDataToDrawActionList:(NSData *)aData
{
    NSData* temp = [NSKeyedUnarchiver unarchiveObjectWithData:aData];
    NSArray* drawDataList = (NSArray*)temp;
    return drawDataList;
}


- (BOOL)createByPBMessage:(PBMessage *)pbMessage
{
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    for (PBDrawAction *pbDrawAction in pbMessage.drawDataList) {
        DrawAction *drawAction = [[DrawAction alloc] initWithPBDrawAction:pbDrawAction];
        [mutableArray addObject:drawAction];
        [drawAction release];
    }
    NSData *data = [self archiveDataFromDrawActionList:mutableArray];
    
    
    return  [self createMessageWithMessageId:pbMessage.messageId 
                                        from:pbMessage.from 
                                          to:pbMessage.to 
                                    drawData:data
                                  createDate:nil   //待PBMessage增加一个createDate
                                        text:pbMessage.text
                                      status:[NSNumber numberWithInt:pbMessage.status]];
}


@end
