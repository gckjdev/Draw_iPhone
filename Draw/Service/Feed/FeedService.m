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
#import "UIImageExt.h"

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
           delegate:(id<FeedServiceDelegate>)delegate
{
    
    NSString *userId = [[UserManager defaultManager] userId];
    LanguageType lang = UnknowType;
    lang = [[UserManager defaultManager] getLanguageType];
    
    
//    [delegate showActivityWithText:NSLS(@"kParsingData")];
    
    dispatch_async(workingQueue, ^{
        
        CommonNetworkOutput* output = [GameNetworkRequest 
                                       getFeedListWithProtocolBuffer:TRAFFIC_SERVER_URL 
                                       userId:userId 
                                       feedListType:feedListType 
                                       offset:offset 
                                       limit:limit 
                                       lang:lang];
        NSArray *list = nil;
        NSInteger resultCode = output.resultCode;
        if (resultCode == ERROR_SUCCESS){
            PPDebug(@"<FeedService> getFeedList finish, start to parse data.");
            
            @try {
                DataQueryResponse *response = [DataQueryResponse parseFromData:output.responseData];
                resultCode = [response resultCode];
                NSArray *pbFeedList = [response feedList];
                list = [FeedManager parsePbFeedList:pbFeedList];
            }
            @catch (NSException *exception) {
                PPDebug(@"<getFeedList> catch exception while parsing data. exception=%@", [exception description]);
                resultCode = ERROR_CLIENT_PARSE_DATA;
            }
            @finally {
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didGetFeedList:feedListType:resultCode:)]) {
                [delegate didGetFeedList:list feedListType:feedListType resultCode:resultCode];
            }
            
        });
    });

}


- (void)getContestOpusList:(int)type 
                 contestId:(NSString *)contestId
                    offset:(NSInteger)offset 
                     limit:(NSInteger)limit 
                  delegate:(id<FeedServiceDelegate>)delegate
{
    
    NSString *userId = [[UserManager defaultManager] userId];
    LanguageType lang = UnknowType;
    lang = [[UserManager defaultManager] getLanguageType];
    
//    [delegate showActivityWithText:NSLS(@"kParsingData")];
    dispatch_async(workingQueue, ^{
        
        CommonNetworkOutput* output = [GameNetworkRequest 
                                       getContestOpusListWithProtocolBuffer:TRAFFIC_SERVER_URL contestId:contestId
                                       userId:userId 
                                       type:type 
                                       offset:offset
                                       limit:limit 
                                       lang:lang];
        NSArray *list = nil;
        NSInteger resultCode = output.resultCode;
        if (resultCode == ERROR_SUCCESS){
            @try {
                PPDebug(@"<FeedService> getFeedList finish, start to parse data.");
                DataQueryResponse *response = [DataQueryResponse parseFromData:output.responseData];
                resultCode = [response resultCode];
                NSArray *pbFeedList = [response feedList];
                list = [FeedManager parsePbFeedList:pbFeedList];            
            }
            @catch (NSException *exception) {
                PPDebug(@"<getContestOpusList> catch exception while parsing data. exception=%@", [exception description]);
                resultCode = ERROR_CLIENT_PARSE_DATA;
            }
            @finally {
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didGetContestOpusList:type:resultCode:)]) {
                [delegate didGetContestOpusList:list type:type resultCode:resultCode];
            }
            
        });
    });
    
}

- (void)getUserFeedList:(NSString *)userId
                 offset:(NSInteger)offset 
                  limit:(NSInteger)limit 
               delegate:(PPViewController<FeedServiceDelegate> *)delegate
{
    dispatch_async(workingQueue, ^{
        
        CommonNetworkOutput* output = [GameNetworkRequest 
                                       getFeedListWithProtocolBuffer:TRAFFIC_SERVER_URL 
                                       userId:userId 
                                       feedListType:FeedListTypeUserFeed 
                                       offset:offset 
                                       limit:limit 
                                       lang:UnknowType];
        NSArray *list = nil;
        NSInteger resultCode = output.resultCode;
        if (resultCode == ERROR_SUCCESS){
            PPDebug(@"<FeedService> getUserFeedList finish, start to parse data.");
            [delegate showActivityWithText:NSLS(@"kParsingData")];
            DataQueryResponse *response = [DataQueryResponse parseFromData:output.responseData];
            resultCode = [response resultCode];
            NSArray *pbFeedList = [response feedList];
            list = [FeedManager parsePbFeedList:pbFeedList];
        }
        PPDebug(@"<FeedService> parse data finish, start display the views.");        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didGetFeedList:targetUser:type:resultCode:)]) {
                [delegate didGetFeedList:list targetUser:userId type:FeedListTypeUserFeed resultCode:resultCode];
            }
        });
    });
}

- (void)getUserOpusList:(NSString *)userId
                 offset:(NSInteger)offset 
                  limit:(NSInteger)limit
                   type:(FeedListType)type
               delegate:(PPViewController<FeedServiceDelegate> *)delegate
{
    dispatch_async(workingQueue, ^{
        
        CommonNetworkOutput* output = [GameNetworkRequest 
                                       getFeedListWithProtocolBuffer:TRAFFIC_SERVER_URL 
                                       userId:userId 
                                       feedListType:type
                                       offset:offset 
                                       limit:limit 
                                       lang:UnknowType];
        NSArray *list = nil;
        NSInteger resultCode = output.resultCode;
        if (resultCode == ERROR_SUCCESS){
            PPDebug(@"<FeedService> getUserFeedList finish, start to parse data.");
            [delegate showActivityWithText:NSLS(@"kParsingData")];
            DataQueryResponse *response = [DataQueryResponse parseFromData:output.responseData];
            resultCode = [response resultCode];
            NSArray *pbFeedList = [response feedList];
            list = [FeedManager parsePbFeedList:pbFeedList];
        }
        PPDebug(@"<FeedService> parse data finish, start display the views.");        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didGetFeedList:targetUser:type:resultCode:)]) {
                [delegate didGetFeedList:list 
                              targetUser:userId
                                    type:type
                              resultCode:resultCode];
            }
        });
    });
}

- (void)getOpusCommentList:(NSString *)opusId 
                      type:(int)type
                    offset:(NSInteger)offset 
                     limit:(NSInteger)limit 
                  delegate:(id<FeedServiceDelegate>)delegate
{
    dispatch_async(workingQueue, ^{
        
        CommonNetworkOutput* output = [GameNetworkRequest 
                                       getFeedCommentListWithProtocolBuffer:TRAFFIC_SERVER_URL
                                       opusId:opusId 
                                       type:type 
                                       offset:offset 
                                       limit:limit];
        NSArray *list = nil;
        NSInteger resultCode = output.resultCode;
        if (resultCode == ERROR_SUCCESS){
            DataQueryResponse *response = [DataQueryResponse parseFromData:output.responseData];
            resultCode = [response resultCode];
            NSArray *pbFeedList = [response feedList];
            list = [FeedManager parsePbCommentFeedList:pbFeedList];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didGetFeedCommentList:opusId:type:resultCode:)]) {
                [delegate didGetFeedCommentList:list opusId:opusId type:type resultCode:resultCode];
            }            
        });
    });

}

- (void)getMyCommentList:(NSInteger)offset 
                   limit:(NSInteger)limit 
                delegate:(id<FeedServiceDelegate>)delegate
{
    dispatch_async(workingQueue, ^{
        
        NSString *userId = [[UserManager defaultManager] userId];
        NSString *appId = [ConfigManager appId];
        CommonNetworkOutput* output = [GameNetworkRequest 
                                       getMyCommentListWithProtocolBuffer:TRAFFIC_SERVER_URL 
                                       userId:userId 
                                       appId:appId 
                                       offset:offset 
                                       limit:limit];
        NSArray *list = nil;
        NSInteger resultCode = output.resultCode;
        if (resultCode == ERROR_SUCCESS){
            DataQueryResponse *response = [DataQueryResponse parseFromData:output.responseData];
            resultCode = [response resultCode];
            NSArray *pbFeedList = [response feedList];
            list = [FeedManager parsePbCommentFeedList:pbFeedList];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didGetMyCommentList:resultCode:)]) {
                [delegate didGetMyCommentList:list resultCode:resultCode];
            }            
        });
    });
}


#define GET_FEED_DETAIL_QUEUE @"GET_FEED_DETAIL_QUEUE"
- (void)getFeedByFeedId:(NSString *)feedId
               delegate:(id<FeedServiceDelegate>)delegate
{
    NSOperationQueue *queue = [self getOperationQueue:GET_FEED_DETAIL_QUEUE];
    [queue cancelAllOperations];
    [queue addOperationWithBlock:^{
        
        BOOL loadRemoteData = NO;

        FeedManager *manager = [FeedManager defaultManager];
        
        PBFeed *pbFeed = [manager loadPBFeedWithFeedId:feedId];
        NSInteger resultCode = 0;
        DrawFeed *feed = nil;
        
        //if local data is nil, load data from remote service
        if (pbFeed == nil) {
            PPDebug(@"<getFeedByFeedId> load remote data, feedId = %@",feedId);
            loadRemoteData = YES;
            NSString* userId = [[UserManager defaultManager] userId];
            
            CommonNetworkOutput* output = [GameNetworkRequest
                                           getFeedWithProtocolBuffer:TRAFFIC_SERVER_URL
                                           userId:userId feedId:feedId];
            
            
            resultCode = [output resultCode];
            if (output.resultCode == ERROR_SUCCESS && [output.responseData length] > 0) {
                DataQueryResponse *response = [DataQueryResponse parseFromData:output.responseData];
                NSArray *list = [response feedList];
                pbFeed = ([list count] != 0) ? [list objectAtIndex:0] : nil;
                resultCode = [response resultCode];
            }        

        }
        
        //parse the draw feed.
        if (pbFeed && (pbFeed.actionType == FeedTypeDraw || pbFeed.actionType == FeedTypeDrawToUser || pbFeed.actionType == FeedTypeDrawToContest)) {
            feed = (DrawFeed*)[FeedManager parsePbFeed:pbFeed];
        }
        
        //send back to delegate
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didGetFeed:resultCode:fromCache:)]) {
                [delegate didGetFeed:(DrawFeed *)feed
                          resultCode:resultCode
                           fromCache:!loadRemoteData];
            }
        });
        //save feed
        if (loadRemoteData) {
            PPDebug(@"<getFeedByFeedId> save pb feed");
            [manager cachePBFeed:pbFeed];
        }
        pbFeed = nil;
    }];
}
- (void)commentOpus:(NSString *)opusId 
             author:(NSString *)author 
            comment:(NSString *)comment          
        commentType:(int)commentType 
          commentId:(NSString *)commentId 
     commentSummary:(NSString *)commentSummary
      commentUserId:(NSString *)commentUserId 
    commentNickName:(NSString *)commentNickName
           delegate:(id<FeedServiceDelegate>)delegate
{
    NSString* userId = [[UserManager defaultManager] userId];
    NSString* nick = [[UserManager defaultManager] nickName];
    NSString* gender = [[UserManager defaultManager] gender];
    NSString* avatar = [[UserManager defaultManager] avatarURL];
    NSString* appId = [ConfigManager appId];
    
    dispatch_async(workingQueue, ^{
        
        CommonNetworkOutput* output = [GameNetworkRequest commentOpus:TRAFFIC_SERVER_URL 
                                                                appId:appId 
                                                               userId:userId 
                                                                 nick:nick 
                                                               avatar:avatar 
                                                               gender:gender
                                                               opusId:opusId
                                                       opusCreatorUId:author
                                                              comment:comment
                                                          commentType:commentType 
                                                            commentId:commentId 
                                                       commentSummary:commentSummary 
                                                        commentUserId:commentUserId
                                                      commentNickName:commentNickName];
        
        NSString *commentId = nil;
        if (output.resultCode == 0) {
            commentId = [output.jsonDataDict objectForKey:PARA_FEED_ID];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didCommentOpus:commentFeedId:comment:resultCode:)]){
                [delegate didCommentOpus:opusId 
                           commentFeedId:commentId
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


- (void)updateFeedTimes:(DrawFeed *)feed
               delegate:(id<FeedServiceDelegate>)delegate
{
    NSString *feedId = feed.feedId;
    NSString *appId = [GameApp appId];
    dispatch_async(workingQueue, ^{
        CommonNetworkOutput* output = [GameNetworkRequest getOpusTimes:TRAFFIC_SERVER_URL appId:appId feedId:feedId];
        if (output.resultCode == 0) {
            [feed updateFeedTimesFromDict:output.jsonDataDict];
        }        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didUpdateFeedTimes:resultCode:)]) {
                [delegate didUpdateFeedTimes:feed resultCode:output.resultCode];
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

- (void)actionSaveOpus:(NSString *)opusId 
            actionName:(NSString*)actionName
{
    NSString* userId = [[UserManager defaultManager] userId];
    NSString* appId = [ConfigManager appId];    
    
    dispatch_async(workingQueue, ^{
        CommonNetworkOutput* output = [GameNetworkRequest actionSaveOnOpus:TRAFFIC_SERVER_URL
                                                                     appId:appId
                                                                    userId:userId
                                                                actionName:actionName
                                                                    opusId:opusId];
        
        PPDebug(@"<actionSaveOpus> opusId=%@, action=%@, resultCode=%d",
                opusId, actionName, output.resultCode);
        
//        dispatch_async(dispatch_get_main_queue(), ^{
//        });
    });
    
}


- (void)updateOpus:(NSString *)opusId image:(UIImage *)image
{
    NSString* userId = [[UserManager defaultManager] userId];
    NSString* appId = [ConfigManager appId];    
    
    dispatch_async(workingQueue, ^{
        CommonNetworkOutput* output = [GameNetworkRequest updateOpus:TRAFFIC_SERVER_URL appId:appId userId:userId opusId:opusId data:nil imageData:[image data]];
        if (output.resultCode == 0) {
            PPDebug(@"<updateOpus> succ!");
        }else{
            PPDebug(@"<updateOpus> fail!");
        }
    });
}

@end
