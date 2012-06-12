//
//  ChatService.m
//  Draw
//
//  Created by haodong qiu on 12年6月8日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "ChatService.h"
#import "GameNetworkRequest.h"
#import "GameNetworkConstants.h"
#import "UserManager.h"
#import "PPNetworkRequest.h"
#import "LogUtil.h"
#import "GameMessage.pb.h"
#import "GameBasic.pb.h"
#import "ChatMessageManager.h"
#import "MessageTotalManager.h"

static ChatService *_chatService = nil;

@implementation ChatService

+ (ChatService*)defaultService
{
    if (_chatService == nil) {
        _chatService = [[ChatService alloc] init];
    }
    return _chatService;
}


- (void)findAllMessageTotals:(id<ChatServiceDelegate>)delegate 
                  starOffset:(int)starOffset 
                    maxCount:(int)maxCount
{
    NSString *userId = [[UserManager defaultManager] userId];
    
    dispatch_async(workingQueue, ^{            
        CommonNetworkOutput* output = [GameNetworkRequest getUserMessage:SERVER_URL 
                                                                   appId:APP_ID 
                                                                  userId:userId
                                                            friendUserId:nil 
                                                             startOffset:starOffset 
                                                                maxCount:maxCount];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            
            if (output.resultCode == ERROR_SUCCESS){
                
                //to do save data
                DataQueryResponse *travelResponse = [DataQueryResponse parseFromData:output.responseData];
                NSArray *messageStatList = [travelResponse messageStatList];
                for (PBMessageStat *pbMessageStat in messageStatList) {
                    [[MessageTotalManager defaultManager] createByPBMessageStat:pbMessageStat];
                }
                
                PPDebug(@"<ChatService>findAllMessageTotals success");
            }else {
                PPDebug(@"<ChatService>findAllMessageTotals failed");
            }
            
            if ([delegate respondsToSelector:@selector(didFindAllMessageTotals:)]){
                NSArray *array = [[MessageTotalManager defaultManager] findAllMessageTotals];
                [delegate didFindAllMessageTotals:array];
            }
        }); 
    });
}


- (void)findAllMessages:(id<ChatServiceDelegate>)delegate 
           friendUserId:(NSString *)friendUserId 
             starOffset:(int)starOffset 
               maxCount:(int)maxCount
{
    NSString *userId = [[UserManager defaultManager] userId];
    
    dispatch_async(workingQueue, ^{            
        CommonNetworkOutput* output = [GameNetworkRequest getUserMessage:SERVER_URL 
                                                                   appId:APP_ID 
                                                                  userId:userId
                                                            friendUserId:friendUserId 
                                                             startOffset:starOffset 
                                                                maxCount:maxCount];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (output.resultCode == ERROR_SUCCESS){
                
                //to do save data
                DataQueryResponse *travelResponse = [DataQueryResponse parseFromData:output.responseData];
                NSArray *messageList = [travelResponse messageList];
                for (PBMessage *pbMessage in messageList) {
                    [[ChatMessageManager defaultManager] createByPBMessage:pbMessage];
                }
                
                PPDebug(@"<ChatService>findAllMessages success");
            }else {
                PPDebug(@"<ChatService>findAllMessages failed");
            }
            
            if ([delegate respondsToSelector:@selector(didFindAllMessagesByFriendUserId:)]){
                NSArray *array = [[ChatMessageManager defaultManager] findMessagesByFriendUserId:friendUserId];
                [delegate didFindAllMessagesByFriendUserId:array];
            }
        }); 
    });
}


- (void)sendMessage:(id<ChatServiceDelegate>)delegate
       friendUserId:(NSString *)friendUserId
               text:(NSString *)text 
               data:(NSData *)data 
{
    NSString *userId = [[UserManager defaultManager] userId];
    
    dispatch_async(workingQueue, ^{            
        CommonNetworkOutput* output = [GameNetworkRequest sendMessage:SERVER_URL 
                                                                appId:APP_ID 
                                                               userId:userId 
                                                         targetUserId:friendUserId 
                                                                 text:text
                                                                 data:data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (output.resultCode == ERROR_SUCCESS){
                PPDebug(@"<ChatService>sendMessage success");
            }else {
                PPDebug(@"<ChatService>sendMessage failed");
            }
            
            if ([delegate respondsToSelector:@selector(didSendMessage:)]){
                [delegate didSendMessage:output.resultCode];
            }
        }); 
    });
}


- (void)sendHasReadMessage:(id<ChatServiceDelegate>)delegate messageIdArray:(NSArray*)messageIdArray 
{
    NSString *userId = [[UserManager defaultManager] userId];
    
    dispatch_async(workingQueue, ^{
        //要改成可以发送一个messageId列表
        CommonNetworkOutput* output = [GameNetworkRequest userHasReadMessage:SERVER_URL 
                                                                       appId:APP_ID 
                                                                      userId:userId 
                                                                   messageId:[messageIdArray objectAtIndex:0]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (output.resultCode == ERROR_SUCCESS){
                PPDebug(@"<ChatService>sendHasReadMessage success");
            }else {
                PPDebug(@"<ChatService>sendHasReadMessage failed");
            }
            
            if ([delegate respondsToSelector:@selector(didSendHasReadMessage:)]){
                [delegate didSendHasReadMessage:output.resultCode];
            }
        }); 
    });
}

@end
