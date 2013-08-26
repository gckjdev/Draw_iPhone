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
#import "FeedDownloadService.h"
#import "PPGameNetworkRequest.h"

#define GET_FEED_DETAIL_QUEUE   @"GET_FEED_DETAIL_QUEUE"
#define GET_PBDRAW_QUEUE        @"GET_PBDRAW_QUEUE"
#define GET_FEED_COMMENT_QUEUE  @"GET_FEED_COMMENT_QUEUE"

static FeedService *_staticFeedService = nil;
@implementation FeedService

+ (FeedService *)defaultService
{
    if (_staticFeedService == nil) {
        _staticFeedService = [[FeedService alloc] init];
    }
    return _staticFeedService;
}

- (NSString *)cachedKeyForFeedListType:(FeedListType)type
{
    return [NSString stringWithFormat:@"CACHED_FEED_LIST_%d",type];
}

- (NSArray *)getCachedFeedList:(FeedListType)feedListType
{
    return [[FeedManager defaultManager] loadFeedListForKey:[self cachedKeyForFeedListType:feedListType]];
}

#define GET_FEEDLIST_QUEUE @"GET_FEEDLIST_QUEUE"

- (void)getFeedList:(FeedListType)feedListType 
             offset:(NSInteger)offset 
              limit:(NSInteger)limit 
           delegate:(id<FeedServiceDelegate>)delegate
{
    
    NSString *userId = [[UserManager defaultManager] userId];
    if (userId  == nil){
        // this is mainly for HOME display
        userId = [ConfigManager getSystemUserId];
    }
    
    LanguageType lang = UnknowType;
    lang = [[UserManager defaultManager] getLanguageType];
    
    //little gee force chinese opus --kira
    if ([GameApp forceChineseOpus]) {
        lang = ChineseType;
    }
    
    dispatch_queue_t getFeedListQueue = [self getQueue:GET_FEEDLIST_QUEUE];
    if (getFeedListQueue == NULL) {
        getFeedListQueue = workingQueue;
    }
    
    dispatch_async(getFeedListQueue, ^{
        
        // add by Benson
        NSAutoreleasePool *subPool = [[NSAutoreleasePool alloc] init];        
        
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
                if ([list count] != 0 && offset == 0) {
                    [[FeedManager defaultManager] cacheFeedDataQueryResponse:response forKey:[self cachedKeyForFeedListType:feedListType]];
                }
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
        
        [subPool drain];
    });

}

- (void)getFeedListByIds:(NSArray*)idList
                delegate:(id<FeedServiceDelegate>)delegate
{
    NSString *userId = [[UserManager defaultManager] userId];
    if (userId  == nil){
        // this is mainly for HOME display
        userId = [ConfigManager getSystemUserId];
    }
    
    dispatch_queue_t getFeedListQueue = [self getQueue:GET_FEEDLIST_QUEUE];
    if (getFeedListQueue == NULL) {
        getFeedListQueue = workingQueue;
    }
    
    NSString* ids = [idList componentsJoinedByString:OPUS_ID_SEPERATOR];
    if (ids == nil){
        ids = @"";
    }
    
    FeedListType feedListType = FeedListTypeIdList;
    
    dispatch_async(workingQueue, ^{
        
        // add by Benson
        NSAutoreleasePool *subPool = [[NSAutoreleasePool alloc] init];
        
       
        NSDictionary* para = @{ PARA_USERID : userId,
//                                PARA_OFFSET : @(0),
//                                PARA_LIMIT : @(idList.count),
                                PARA_TYPE : @(feedListType),
                                PARA_OPUS_ID_LIST : ids,
                                PARA_IMAGE : @(1)
                               };
        
        GameNetworkOutput* output = [PPGameNetworkRequest trafficApiServerGetAndResponsePB:METHOD_GET_FEED_LIST parameters:para];
                
        NSArray *list = nil;
        NSInteger resultCode = output.resultCode;
        DataQueryResponse* response = output.pbResponse;
        if (resultCode == ERROR_SUCCESS && [response feedList]){
            PPDebug(@"<FeedService> getFeedListByIds finish, start to parse data.");
            resultCode = [response resultCode];
            NSArray *pbFeedList = [response feedList];
            list = [FeedManager parsePbFeedList:pbFeedList];
//            if ([list count] > 0) {
//                [[FeedManager defaultManager] cacheFeedDataQueryResponse:response forKey:[self cachedKeyForFeedListType:feedListType]];
//            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didGetFeedList:feedListType:resultCode:)]) {
                [delegate didGetFeedList:list feedListType:feedListType resultCode:resultCode];
            }
            
        });
        
        [subPool drain];
    });
}

- (void)getContestCommentFeedList:(NSString*)contestId
                           offset:(NSInteger)offset
                            limit:(NSInteger)limit
                         delegate:(id<FeedServiceDelegate>)delegate
{
    NSString *userId = [[UserManager defaultManager] userId];
    if (userId  == nil){
        // this is mainly for HOME display
        userId = [ConfigManager getSystemUserId];
    }
    
    LanguageType lang = UnknowType;
    lang = [[UserManager defaultManager] getLanguageType];
    
    //little gee force chinese opus --kira
    if ([GameApp forceChineseOpus]) {
        lang = ChineseType;
    }
    
    dispatch_queue_t getFeedListQueue = [self getQueue:GET_FEEDLIST_QUEUE];
    if (getFeedListQueue == NULL) {
        getFeedListQueue = workingQueue;
    }
    
    dispatch_async(getFeedListQueue, ^{
        
        // add by Benson
        NSAutoreleasePool *subPool = [[NSAutoreleasePool alloc] init];
        
        NSDictionary* para = @{ PARA_TYPE : @(FeedListTypeContestComment),
                                PARA_CONTESTID : contestId,
                                PARA_OFFSET : @(offset),
                                PARA_COUNT : @(limit)
                               };
        
        GameNetworkOutput* output = [PPGameNetworkRequest trafficApiServerGetAndResponsePB:METHOD_GET_FEED_LIST parameters:para];
        
        NSArray* list = nil;
        if (output.resultCode == ERROR_SUCCESS){
            NSArray *pbFeedList = [output.pbResponse feedList];
            list = [FeedManager parsePbFeedList:pbFeedList];
            if ([list count] != 0 && offset == 0) {
                [[FeedManager defaultManager] cacheFeedDataQueryResponse:output.pbResponse
                                                                  forKey:[self cachedKeyForFeedListType:FeedTypeContestComment]];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didGetFeedList:feedListType:resultCode:)]) {
                [delegate didGetFeedList:list
                            feedListType:FeedTypeContestComment
                              resultCode:output.resultCode];
            }            
        });
        
        [subPool drain];
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

        // add by Benson
        NSAutoreleasePool *subPool = [[NSAutoreleasePool alloc] init];
        
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
        
        [subPool drain];
    });
    
}

- (void)getUserFeedList:(NSString *)userId
                   type:(FeedListType)type
                 offset:(NSInteger)offset
                  limit:(NSInteger)limit
               delegate:(id<FeedServiceDelegate>)delegate
{
    dispatch_async(workingQueue, ^{
        
        // add by Benson
        NSAutoreleasePool *subPool = [[NSAutoreleasePool alloc] init];
        
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
            PPDebug(@"<FeedService> getUserFeedList type=%d finish, start to parse data.", type);
            
            @try{
                DataQueryResponse *response = [DataQueryResponse parseFromData:output.responseData];
                resultCode = [response resultCode];
                NSArray *pbFeedList = [response feedList];
                list = [FeedManager parsePbFeedList:pbFeedList];
            }
            @catch (NSException *exception) {
                PPDebug(@"<getUserFeedList> catch exception =%@", [exception description]);
                resultCode = ERROR_CLIENT_PARSE_DATA;
            }
            @finally {
            }
        }
        
        PPDebug(@"<FeedService> parse data finish, start display the views.");
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didGetFeedList:targetUser:type:resultCode:)]) {
                [delegate didGetFeedList:list targetUser:userId type:type resultCode:resultCode];
            }
        });
        
        [subPool drain];
    });
}

- (void)getUserFavoriteOpusList:(NSString *)userId
                         offset:(NSInteger)offset
                          limit:(NSInteger)limit
                       delegate:(id<FeedServiceDelegate>)delegate
{
    [self getUserFeedList:userId
                     type:FeedListTypeUserFavorite
                   offset:offset
                    limit:limit
                 delegate:delegate];
}

- (void)getUserFeedList:(NSString *)userId
                 offset:(NSInteger)offset 
                  limit:(NSInteger)limit 
               delegate:(id<FeedServiceDelegate>)delegate
{
    
    
    [self getUserFeedList:userId
                     type:FeedListTypeUserFeed
                   offset:offset
                    limit:limit
                 delegate:delegate];
    
//    dispatch_async(workingQueue, ^{
//
//        // add by Benson
//        NSAutoreleasePool *subPool = [[NSAutoreleasePool alloc] init];
//        
//        CommonNetworkOutput* output = [GameNetworkRequest 
//                                       getFeedListWithProtocolBuffer:TRAFFIC_SERVER_URL 
//                                       userId:userId 
//                                       feedListType:FeedListTypeUserFeed 
//                                       offset:offset 
//                                       limit:limit 
//                                       lang:UnknowType];
//        NSArray *list = nil;
//        NSInteger resultCode = output.resultCode;
//        if (resultCode == ERROR_SUCCESS){
//            PPDebug(@"<FeedService> getUserFeedList finish, start to parse data.");
//
//            @try{
//                DataQueryResponse *response = [DataQueryResponse parseFromData:output.responseData];
//                resultCode = [response resultCode];
//                NSArray *pbFeedList = [response feedList];
//                list = [FeedManager parsePbFeedList:pbFeedList];
//            }
//            @catch (NSException *exception) {
//                PPDebug(@"<getUserFeedList> catch exception =%@", [exception description]);
//                resultCode = ERROR_CLIENT_PARSE_DATA;
//            }
//            @finally {
//            }
//        }
//
//        PPDebug(@"<FeedService> parse data finish, start display the views.");
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (delegate && [delegate respondsToSelector:@selector(didGetFeedList:targetUser:type:resultCode:)]) {
//                [delegate didGetFeedList:list targetUser:userId type:FeedListTypeUserFeed resultCode:resultCode];
//            }
//        });
//        
//        [subPool drain];
//    });
}

- (void)getUserOpusList:(NSString *)userId
                 offset:(NSInteger)offset 
                  limit:(NSInteger)limit
                   type:(FeedListType)type
               delegate:(id<FeedServiceDelegate>)delegate
{
    dispatch_async(workingQueue, ^{
        
        // add by Benson
        NSAutoreleasePool *subPool = [[NSAutoreleasePool alloc] init];
        
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
//            [delegate showActivityWithText:NSLS(@"kParsingData")];
            @try{
                DataQueryResponse *response = [DataQueryResponse parseFromData:output.responseData];
                resultCode = [response resultCode];
                NSArray *pbFeedList = [response feedList];
                list = [FeedManager parsePbFeedList:pbFeedList];            
            }
            @catch (NSException *exception) {
                PPDebug(@"<getUserOpusList> catch exception =%@", [exception description]);
                resultCode = ERROR_CLIENT_PARSE_DATA;
            }
            @finally {
            }
        
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
        
        [subPool drain];
    });
}

- (void)getOpusCommentList:(NSString *)opusId 
                      type:(CommentType)type
                    offset:(NSInteger)offset 
                     limit:(NSInteger)limit 
                  delegate:(id<FeedServiceDelegate>)delegate
{

    // use operation queue to cancel pervious request
    NSString* queueId = [NSString stringWithFormat:@"%@_%d", GET_FEED_COMMENT_QUEUE, type];
    NSOperationQueue *queue = [self getOperationQueue:queueId];
    [queue cancelAllOperations];

    [queue addOperationWithBlock:^{
        
        // add by Benson
        NSAutoreleasePool *subPool = [[NSAutoreleasePool alloc] init];        
        
        CommonNetworkOutput* output = [GameNetworkRequest 
                                       getFeedCommentListWithProtocolBuffer:TRAFFIC_SERVER_URL
                                       opusId:opusId 
                                       type:type 
                                       offset:offset 
                                       limit:limit];
        NSArray *list = nil;
        NSInteger resultCode = output.resultCode;
        if (resultCode == ERROR_SUCCESS){
            @try{
                DataQueryResponse *response = [DataQueryResponse parseFromData:output.responseData];
                resultCode = [response resultCode];
                NSArray *pbFeedList = [response feedList];
                list = [FeedManager parsePbCommentFeedList:pbFeedList];
                PPDebug(@"<getOpusCommentList> result=%d, total %d comments", resultCode, [list count]);
            }
            @catch (NSException *exception) {
                PPDebug(@"<getOpusCommentList> catch exception =%@", [exception description]);
                resultCode = ERROR_CLIENT_PARSE_DATA;
            }
            @finally {
            }        
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didGetFeedCommentList:opusId:type:resultCode:offset:)]) {
                [delegate didGetFeedCommentList:list opusId:opusId type:type resultCode:resultCode offset:offset];
            }            
        });
        
        [subPool drain];
    }];

}

- (void)getMyCommentList:(NSInteger)offset 
                   limit:(NSInteger)limit 
                delegate:(id<FeedServiceDelegate>)delegate
{
    dispatch_async(workingQueue, ^{
        
        // add by Benson
        NSAutoreleasePool *subPool = [[NSAutoreleasePool alloc] init];        
        
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
            @try {
                DataQueryResponse *response = [DataQueryResponse parseFromData:output.responseData];
                resultCode = [response resultCode];
                NSArray *pbFeedList = [response feedList];
                list = [FeedManager parsePbCommentFeedList:pbFeedList];
            }
            @catch (NSException *exception) {
                PPDebug(@"<getMyCommentList> catch exception =%@", [exception description]);
                resultCode = ERROR_CLIENT_PARSE_DATA;
            }
            @finally {
            }

        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didGetMyCommentList:resultCode:)]) {
                [delegate didGetMyCommentList:list resultCode:resultCode];
            }            
        });
        
        [subPool drain];
    });
}




- (void)getFeedByFeedId:(NSString *)feedId
               delegate:(id<FeedServiceDelegate>)delegate
{
    
    NSOperationQueue *queue = [self getOperationQueue:GET_FEED_DETAIL_QUEUE];
    [queue cancelAllOperations];

//    __block DrawFeed *feed = nil;
    
    
    [queue addOperationWithBlock:^{
        NSInteger resultCode = 0;
        NSString* userId = [[UserManager defaultManager] userId];
        CommonNetworkOutput* output = [GameNetworkRequest
                                       getFeedWithProtocolBuffer:TRAFFIC_SERVER_URL
                                       userId:userId feedId:feedId];
        resultCode = [output resultCode];
        DrawFeed *feed = nil;
        
        if (output.resultCode == ERROR_SUCCESS && [output.responseData length] > 0) {
            
            @try{
                DataQueryResponse *response = [DataQueryResponse parseFromData:output.responseData];
                resultCode = [response resultCode];
                
                if (resultCode == ERROR_SUCCESS) {
                    NSArray *list = [response feedList];
                    PBFeed *pbFeed = nil;
                    pbFeed = ([list count] != 0) ? [list objectAtIndex:0] : nil;
                    
                    feed = (DrawFeed*)[FeedManager parsePbFeed:pbFeed];
                    if ([feed isKindOfClass:[DrawFeed class]]) {
                        
                    }else{
                        feed = nil;
                    }
                }
            }
            @catch (NSException *exception) {
                PPDebug(@"<getFeedByFeedId> catch exception =%@", [exception description]);
                resultCode = ERROR_CLIENT_PARSE_DATA;
            }
            @finally {}            

        }
        
        //send back to delegate
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didGetFeed:resultCode:fromCache:)]) {
                [delegate didGetFeed:feed
                          resultCode:resultCode
                           fromCache:NO];
            }
        });
        
    }];
}


- (void)getPBDrawByFeed:(DrawFeed *)feed
                handler:(LoadPBDrawResultHandler)handler
       downloadDelegate:(id)downloadDelegate
{
    FeedManager *manager = [FeedManager defaultManager];
    
    NSOperationQueue *queue = [self getOperationQueue:GET_PBDRAW_QUEUE];
    [queue cancelAllOperations];
    
    [queue addOperationWithBlock:^{
        
        NSAutoreleasePool *subPool = [[NSAutoreleasePool alloc] init];
        BOOL fromCache = NO;
        NSInteger resultCode = 0;
        NSData* data = nil;
        data = [manager loadPBDrawDataWithFeedId:feed.feedId];
        if (data) {
            fromCache = YES;
        }else{
            if ([[feed drawDataUrl] length] > 0){
                @try {
                    data = [[FeedDownloadService defaultService]
                                    downloadDrawDataFile:[feed drawDataUrl]
                                    fileName:[feed feedId]
                                    downloadProgressDelegate:downloadDelegate];
                }
                @catch (NSException *exception) {
                    PPDebug(@"<getPBDrawByFeed> catch exception =%@", [exception description]);
                    resultCode = ERROR_CLIENT_PARSE_DATA;
                }
                @finally {}
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (handler != NULL) {
                handler(resultCode, data, feed, fromCache);
            }
        });
        
        if (!fromCache) {
            [manager cachePBDrawData:data forFeedId:feed.feedId];
        }
        
        [subPool drain];
        
    }];

}


//- (void)getPBDrawByFeed:(DrawFeed *)feed
//               delegate:(id<FeedServiceDelegate>)delegate
//{
//    // new support in server
//    // add download feed draw data by data URL
//    
//    FeedManager *manager = [FeedManager defaultManager];
//    
//    NSOperationQueue *queue = [self getOperationQueue:GET_PBDRAW_QUEUE];
//    [queue cancelAllOperations];
//
//    [queue addOperationWithBlock:^{
//        
//        NSAutoreleasePool *subPool = [[NSAutoreleasePool alloc] init];      
//        BOOL fromCache = NO;
//        PBDraw *pbDraw = nil;
//        NSInteger resultCode = 0;
//
//        pbDraw = [manager loadPBDrawWithFeedId:feed.feedId];
//        if (pbDraw) {
//            fromCache = YES;
//        }else{
//            if ([[feed drawDataUrl] length] > 0){
//                @try {
//                    NSData* data = [[FeedDownloadService defaultService]
//                                    downloadDrawDataFile:[feed drawDataUrl]
//                                    fileName:[feed feedId]
//                                    downloadProgressDelegate:delegate
//                                    ];
//                    if (data != nil){
//                        pbDraw = [PBDraw parseFromData:data];
//                    }else{
//                        resultCode = ERROR_RESPONSE_NULL;
//                    }
//                }
//                @catch (NSException *exception) {
//                    PPDebug(@"<getPBDrawByFeed> catch exception =%@", [exception description]);
//                    resultCode = ERROR_CLIENT_PARSE_DATA;
//                }
//                @finally {}
//            }
//        }
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (delegate && [delegate respondsToSelector:@selector(didGetPBDraw:byDrawFeed:resultCode:fromCache:)]) {
//                [delegate didGetPBDraw:pbDraw byDrawFeed:feed resultCode:resultCode fromCache:fromCache];
//            }
//        });
//        
//        if (!fromCache) {
//            [manager cachePBDraw:pbDraw forFeedId:feed.feedId];
//        }
//        [subPool drain];
//     
//    }];
//}

- (void)getOpusCount:(NSString *)targetUid
            delegete:(id<FeedServiceDelegate>)delegate
{
    NSString* userId = [[UserManager defaultManager] userId];
    NSString* appId = [ConfigManager appId];
    
    dispatch_async(workingQueue, ^{
        
        CommonNetworkOutput* output = [GameNetworkRequest
                                       getOpusCount:TRAFFIC_SERVER_URL
                                       appId:appId
                                       userId:userId
                                       targetUid:targetUid];
        
        NSInteger count = 0;
        if (output.resultCode == 0) {
            count = [[output.jsonDataDict objectForKey:PARA_RET_COUNT] integerValue];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didGetUser:opusCount:resultCode:)]){
                [delegate didGetUser:userId opusCount:count resultCode:output.resultCode];
            }
        });
    });
}

- (void)commentOpus:(NSString *)opusId
             author:(NSString *)author 
            comment:(NSString *)comment          
        commentType:(CommentType)commentType 
          commentId:(NSString *)commentId 
     commentSummary:(NSString *)commentSummary
      commentUserId:(NSString *)commentUserId 
    commentNickName:(NSString *)commentNickName
          contestId:(NSString *)contestId
   forContestReport:(BOOL)forContestReport
           delegate:(id<FeedServiceDelegate>)delegate
{
    NSString* userId = [[UserManager defaultManager] userId];
    NSString* nick = [[UserManager defaultManager] nickName];
    NSString* gender = [[UserManager defaultManager] gender];
    NSString* avatar = [[UserManager defaultManager] avatarURL];
    NSString* appId = [ConfigManager appId];
    
    dispatch_async(workingQueue, ^{
        
        CommonNetworkOutput* output = nil;
        if (forContestReport){
            output = [GameNetworkRequest contestCommentOpus:TRAFFIC_SERVER_URL
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
                                     commentNickName:commentNickName
                                           contestId:contestId];

        }
        else{
            output = [GameNetworkRequest commentOpus:TRAFFIC_SERVER_URL
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
                                                          commentNickName:commentNickName
                                                                contestId:contestId];
        }
        
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

- (void)throwItem:(ItemType)itemType
           toOpus:(NSString *)opusId
           author:(NSString *)author
     awardBalance:(int)awardBalance
         awardExp:(int)awardExp
         delegate:(id<FeedServiceDelegate>)delegate
{
    
    PPDebug(@"<throwItem> item=%d, opusId=%@, author=%@", itemType, opusId, author);
    
    NSString* userId = [[UserManager defaultManager] userId];
    NSString* nick = [[UserManager defaultManager] nickName];
    NSString* gender = [[UserManager defaultManager] gender];
    NSString* avatar = [[UserManager defaultManager] avatarURL];
    NSString* appId = [ConfigManager appId];
    
    
    dispatch_async(workingQueue, ^{
        CommonNetworkOutput* output = [GameNetworkRequest throwItemToOpus:TRAFFIC_SERVER_URL appId:appId userId:userId nick:nick avatar:avatar gender:gender opusId:opusId opusCreatorUId:author itemType:itemType awardBalance:awardBalance awardExp:awardExp];
        
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

- (void)actionSaveOpus:(NSString *)opusId
            actionType:(int)actionType
            actionName:(NSString*)actionName
           resultBlock:(FeedActionResultBlock)resultBlock
{
    NSString* userId = [[UserManager defaultManager] userId];
    NSString* appId = [ConfigManager appId];
    
    dispatch_async(workingQueue, ^{
        CommonNetworkOutput* output = [GameNetworkRequest actionSaveOnOpus:TRAFFIC_SERVER_URL
                                                                     appId:appId
                                                                    userId:userId
                                                                actionType:actionType
                                                                actionName:actionName
                                                                    opusId:opusId];
        
        PPDebug(@"<actionSaveOpus> opusId=%@, action=%@, resultCode=%d",
                opusId, actionName, output.resultCode);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            EXECUTE_BLOCK(resultBlock, output.resultCode);
        });
    });
    
}

- (void)actionSaveOpus:(NSString *)opusId 
            actionName:(NSString*)actionName
{
    
    [self actionSaveOpus:opusId
              actionType:ACTION_TYPE_SAVE
              actionName:actionName
             resultBlock:nil];
    
//    NSString* userId = [[UserManager defaultManager] userId];
//    NSString* appId = [ConfigManager appId];    
//    
//    dispatch_async(workingQueue, ^{
//        CommonNetworkOutput* output = [GameNetworkRequest actionSaveOnOpus:TRAFFIC_SERVER_URL
//                                                                     appId:appId
//                                                                    userId:userId
//                                                                actionName:actionName
//                                                                    opusId:opusId];
//        
//        PPDebug(@"<actionSaveOpus> opusId=%@, action=%@, resultCode=%d",
//                opusId, actionName, output.resultCode);        
//    });
    
}

- (void)addOpusIntoFavorite:(NSString *)opusId
                resultBlock:(FeedActionResultBlock)resultBlock
{
    [self actionSaveOpus:opusId
              actionType:ACTION_TYPE_ADD_FAVORITE
              actionName:DB_FIELD_ACTION_SAVE_TIMES
             resultBlock:resultBlock];

}

- (void)removeOpusFromFavorite:(NSString *)opusId
                   resultBlock:(FeedActionResultBlock)resultBlock
{
    [self actionSaveOpus:opusId
              actionType:ACTION_TYPE_REMOVE_FAVORITE
              actionName:@""
             resultBlock:resultBlock];
    
}

- (void)recommendOpus:(NSString *)opusId
          resultBlock:(FeedActionResultBlock)resultBlock
{
    [self actionSaveOpus:opusId
              actionType:ACTION_TYPE_RECOMMEND_OPUS
              actionName:@""
             resultBlock:resultBlock];    
}

- (void)unRecommendOpus:(NSString *)opusId
          resultBlock:(FeedActionResultBlock)resultBlock
{
    [self actionSaveOpus:opusId
              actionType:ACTION_TYPE_UNRECOMMEND_OPUS
              actionName:@""
             resultBlock:resultBlock];
}

- (void)rejectOpusDrawToMe:(NSString *)opusId
               resultBlock:(FeedActionResultBlock)resultBlock
{
    [self actionSaveOpus:opusId
              actionType:ACTION_TYPE_REJECT_DRAW_TO_ME_OPUS
              actionName:@""
             resultBlock:resultBlock];
}

#define UPDATE_OPUS_QUEUE @"UPDATE_OPUS_QUEUE"

- (void)updateOpus:(NSString *)opusId image:(UIImage *)image
{
    [self updateOpus:opusId image:image description:nil resultHandler:nil];
}

- (void)updateOpus:(NSString *)opusId
             image:(UIImage *)image
       description:(NSString*)description
     resultHandler:(void(^)(int resultCode))resultHandler
{
//    NSString* userId = [[UserManager defaultManager] userId];
//    NSString* appId = [ConfigManager appId];
    
    NSData* imgData = nil;
    if (image) {
        imgData = [image data];
    }
    
    dispatch_queue_t updateOpusQueue = [self getQueue:UPDATE_OPUS_QUEUE];
    
    dispatch_async(updateOpusQueue, ^{
//        CommonNetworkOutput* output = [GameNetworkRequest updateOpus:TRAFFIC_SERVER_URL
//                                                               appId:appId
//                                                              userId:userId
//                                                              opusId:opusId
//                                                                data:nil
//                                                           imageData:imgData
//                                                        isCompressed:YES
//                                                         description:description];
//        if (output.resultCode == 0) {
//            PPDebug(@"<updateOpus> succ!");
//        }else{
//            PPDebug(@"<updateOpus> fail!");
//        }
//        dispatch_async(dispatch_get_main_queue(), ^{
//            EXECUTE_BLOCK(resultHandler, output.resultCode);
//        });
        
        NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:opusId, PARA_OPUS_ID, description, PARA_DESC, nil];
        CommonNetworkOutput* output = [PPGameNetworkRequest trafficApiServerPostAndResponseJSON:METHOD_UPDATE_OPUS parameters:params postData:imgData isReturnArray:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            EXECUTE_BLOCK(resultHandler, output.resultCode);
        });
        
    });
    
    
    
}

- (void)rejectOpusDrawToMe:(NSString *)opusId
              successBlock:(void (^)(void))successBlock
                 failBlock:(void (^)(void))failBlock
{
    NSString* userId = [[UserManager defaultManager] userId];
    NSString* appId = [ConfigManager appId];
    
    dispatch_queue_t updateOpusQueue = [self getQueue:UPDATE_OPUS_QUEUE];
    
    dispatch_async(updateOpusQueue, ^{
        CommonNetworkOutput* output = [GameNetworkRequest rejectOpusDrawToMe:TRAFFIC_SERVER_URL appId:appId userId:userId opusId:opusId type:FeedTypeDraw];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (output.resultCode == ERROR_SUCCESS) {
                PPDebug(@"<updateOpus> succ!");
                if (successBlock != NULL) successBlock();
            }else{
                PPDebug(@"<updateOpus> fail!");
                if (failBlock != NULL) failBlock();
            }
        });
    });
    
}

@end
