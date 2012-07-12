//
//  FeedService.m
//  Draw
//
//  Created by  on 12-6-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FeedService.h"
#import "GameNetworkRequest.h"
#import "GameNetworkConstants.h"
#import "PPNetworkRequest.h"
#import "GameMessage.pb.h"
#import "GameBasic.pb.h"
#import "UserManager.h"
#import "GameNetworkConstants.h"
#import "ConfigManager.h"
#import "ItemType.h"

static FeedService *_staticFeedService = nil;
@implementation FeedService

+ (FeedService *)defaultService
{
    if (_staticFeedService == nil) {
        _staticFeedService = [[FeedService alloc] init];
    }
    return _staticFeedService;
}

- (void)getFeedList:(FeedListType)feedListType 
             offset:(NSInteger)offset 
              limit:(NSInteger)limit 
           delegate:(id<FeedServiceDelegate>)delegate;
{
    
    NSString *userId = [[UserManager defaultManager] userId];
    LanguageType lang = UnknowType;
    if (feedListType == FeedListTypeHot) {
        lang = [[UserManager defaultManager] getLanguageType];
    }
    
    dispatch_async(workingQueue, ^{
        
        CommonNetworkOutput* output = [GameNetworkRequest 
                                       getFeedListWithProtocolBuffer:TRAFFIC_SERVER_URL 
                                       userId:userId 
                                       feedListType:feedListType 
                                       offset:offset 
                                       limit:limit 
                                       lang:lang];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableArray *list = nil;
            NSInteger resultCode = output.resultCode;
            if (resultCode == ERROR_SUCCESS){
                DataQueryResponse *response = [DataQueryResponse parseFromData:output.responseData];
                resultCode = [response resultCode];
                NSArray *pbFeedList = [response feedList];
                if ([pbFeedList count] != 0) {
                    list = [NSMutableArray array];    
                    for (PBFeed *pbFeed in pbFeedList) {
                        Feed *feed = [[Feed alloc] initWithPBFeed:pbFeed];
                        [list addObject:feed];
                        [feed release];
                    }
                }
            }
            if (delegate && [delegate respondsToSelector:@selector(didGetFeedList:feedListType:resultCode:)]) {
                [delegate didGetFeedList:list feedListType:feedListType resultCode:resultCode];
            }
            
        });
    });

}

- (void)getUserFeedList:(NSString *)userId
                 offset:(NSInteger)offset 
                  limit:(NSInteger)limit 
               delegate:(id<FeedServiceDelegate>)delegate
{
    dispatch_async(workingQueue, ^{
        
        CommonNetworkOutput* output = [GameNetworkRequest 
                                       getFeedListWithProtocolBuffer:TRAFFIC_SERVER_URL 
                                       userId:userId 
                                       feedListType:FeedListTypeUser 
                                       offset:offset 
                                       limit:limit 
                                       lang:UnknowType];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableArray *list = nil;
            NSInteger resultCode = output.resultCode;
            if (resultCode == ERROR_SUCCESS){
                DataQueryResponse *response = [DataQueryResponse parseFromData:output.responseData];
                resultCode = [response resultCode];
                NSArray *pbFeedList = [response feedList];
                if ([pbFeedList count] != 0) {
                    list = [NSMutableArray array];    
                    for (PBFeed *pbFeed in pbFeedList) {
                        Feed *feed = [[Feed alloc] initWithPBFeed:pbFeed];
                        [list addObject:feed];
                        [feed release];
                    }
                }
            }
            if (delegate && [delegate respondsToSelector:@selector(didGetFeedList:targetUser:resultCode:)]) {
                [delegate didGetFeedList:list targetUser:userId resultCode:resultCode];
            }
        });
    });
}

- (void)getOpusCommentList:(NSString *)opusId
                    offset:(NSInteger)offset 
                     limit:(NSInteger)limit 
                  delegate:(id<FeedServiceDelegate>)delegate
{
    dispatch_async(workingQueue, ^{
        
        CommonNetworkOutput* output = [GameNetworkRequest 
                                       getFeedCommentListWithProtocolBuffer:TRAFFIC_SERVER_URL opusId:opusId offset:offset limit:limit];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableArray *list = nil;
            NSInteger resultCode = output.resultCode;
            if (resultCode == ERROR_SUCCESS){
                DataQueryResponse *response = [DataQueryResponse parseFromData:output.responseData];
                resultCode = [response resultCode];
                NSArray *pbFeedList = [response feedList];
                if ([pbFeedList count] != 0) {
                    list = [NSMutableArray array];    
                    for (PBFeed *pbFeed in pbFeedList) {
                        Feed *feed = [[Feed alloc] initWithPBFeed:pbFeed];
                        [list addObject:feed];
                        [feed release];
                    }
                }
            }
            if (delegate && [delegate respondsToSelector:@selector(didGetFeedCommentList:opusId:resultCode:)]) {
                [delegate didGetFeedCommentList:list opusId:opusId resultCode:resultCode];
            }            
        });
    });

}

- (void)commentOpus:(NSString *)opusId 
             author:(NSString *)author 
            comment:(NSString *)comment            
           delegate:(id<FeedServiceDelegate>)delegate
{
    NSString* userId = [[UserManager defaultManager] userId];
    NSString* nick = [[UserManager defaultManager] nickName];
    NSString* gender = [[UserManager defaultManager] gender];
    NSString* avatar = [[UserManager defaultManager] avatarURL];
    NSString* appId = [ConfigManager appId];
    
    
    dispatch_async(workingQueue, ^{
        CommonNetworkOutput* output = [GameNetworkRequest commentOpus:TRAFFIC_SERVER_URL appId:appId userId:userId nick:nick avatar:avatar gender:gender opusId:opusId opusCreatorUId:author comment:comment];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didCommentOpus:comment:resultCode:)]){
                [delegate didCommentOpus:opusId 
                                 comment:comment 
                              resultCode:output.resultCode];
            }
        });
    });
    
}

- (void)deleteFeed:(Feed *)feed
          delegate:(id<FeedServiceDelegate>)delegate
{
        NSString* userId = [[UserManager defaultManager] userId];
        NSString* appId = [ConfigManager appId];
    
        dispatch_async(workingQueue, ^{
            CommonNetworkOutput* output = [GameNetworkRequest deleteFeed:TRAFFIC_SERVER_URL appId:appId feedId:feed.feedId userId:userId];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (delegate && [delegate respondsToSelector:@selector(didDeleteFeed:resultCode:)]) {
                    [delegate didDeleteFeed:feed resultCode:output.resultCode];
                }
            });
        });

}

- (void)throwItem:(ItemType)itemType toOpus:(NSString *)opusId 
                   author:(NSString *)author   
                 delegate:(id<FeedServiceDelegate>)delegate
{
    NSString* userId = [[UserManager defaultManager] userId];
    NSString* nick = [[UserManager defaultManager] nickName];
    NSString* gender = [[UserManager defaultManager] gender];
    NSString* avatar = [[UserManager defaultManager] avatarURL];
    NSString* appId = [ConfigManager appId];
    
    
    dispatch_async(workingQueue, ^{
        CommonNetworkOutput* output = [GameNetworkRequest throwItemToOpus:TRAFFIC_SERVER_URL appId:appId userId:userId nick:nick avatar:avatar gender:gender opusId:opusId opusCreatorUId:author itemType:itemType];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (itemType == ItemTypeFlower && delegate && [delegate respondsToSelector:@selector(didThrowFlowerToOpus:resultCode:)]) {
                [delegate didThrowFlowerToOpus:opusId resultCode:output.resultCode];
                
            }else if(itemType == ItemTypeTomato && delegate && [delegate respondsToSelector:@selector(didThrowTomatoToOpus:resultCode:)]){
                [delegate didThrowTomatoToOpus:opusId resultCode:output.resultCode];
                
            }
        });
    });

}


- (void)throwFlowerToOpus:(NSString *)opusId 
                   author:(NSString *)author  
                 delegate:(id<FeedServiceDelegate>)delegate
{
    [self throwItem:ItemTypeFlower toOpus:opusId author:author delegate:delegate];
}

- (void)throwTomatoToOpus:(NSString *)opusId 
                   author:(NSString *)author 
                 delegate:(id<FeedServiceDelegate>)delegate;
{
    [self throwItem:ItemTypeTomato toOpus:opusId author:author delegate:delegate];    
}


@end
