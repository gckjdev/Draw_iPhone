//
//  ChatService.m
//  Draw
//
//  Created by haodong qiu on 12年6月8日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "ChatService.h"

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
{
    dispatch_async(workingQueue, ^{            
        //send url
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //save data
            
            if ([delegate respondsToSelector:@selector(didFindAllMessageTotals:)]){
                [delegate didFindAllMessageTotals:nil];
            }
        }); 
    });
}


- (void)findAllMessagesByFriendUserId:(NSString *)friendUserId delegate:(id<ChatServiceDelegate>)delegate
{
    dispatch_async(workingQueue, ^{            
        //send url
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //save data
            
            if ([delegate respondsToSelector:@selector(didFindAllMessagesByFriendUserId:)]){
                [delegate didFindAllMessagesByFriendUserId:nil];
            }
        }); 
    });
}


- (void)sendMessage:(NSString *)friendUserId 
               text:(NSString *)text 
               data:(NSData *)data 
           delegate:(id<ChatServiceDelegate>)delegate;
{
    dispatch_async(workingQueue, ^{            
        //send url
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //update status
            
            if ([delegate respondsToSelector:@selector(didSendMessage:)]){
                [delegate didSendMessage:0];
            }
        }); 
    });
}


- (void)sendHasReadMessage:(NSArray*)messageIdArray delegate:(id<ChatServiceDelegate>)delegate
{
    dispatch_async(workingQueue, ^{            
        //send url
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //update status
            
            if ([delegate respondsToSelector:@selector(didSendHasReadMessage:)]){
                [delegate didSendHasReadMessage:0];
            }
        }); 
    });
}

@end
