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
#import "ASIHTTPRequest.h"
#import "FileUtil.h"
#import "SSZipArchive.h"

static FeedService *_staticFeedService = nil;
@implementation FeedService

+ (FeedService *)defaultService
{
    if (_staticFeedService == nil) {
        [FeedService initPaths];
        _staticFeedService = [[FeedService alloc] init];
    }
    return _staticFeedService;
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
                 offset:(NSInteger)offset 
                  limit:(NSInteger)limit 
               delegate:(PPViewController<FeedServiceDelegate> *)delegate
{
//    [delegate showActivityWithText:NSLS(@"kParsingData")];
    dispatch_async(workingQueue, ^{

        // add by Benson
        NSAutoreleasePool *subPool = [[NSAutoreleasePool alloc] init];
        
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
                [delegate didGetFeedList:list targetUser:userId type:FeedListTypeUserFeed resultCode:resultCode];
            }
        });
        
        [subPool drain];
    });
}

- (void)getUserOpusList:(NSString *)userId
                 offset:(NSInteger)offset 
                  limit:(NSInteger)limit
                   type:(FeedListType)type
               delegate:(PPViewController<FeedServiceDelegate> *)delegate
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
                      type:(int)type
                    offset:(NSInteger)offset 
                     limit:(NSInteger)limit 
                  delegate:(id<FeedServiceDelegate>)delegate
{
    dispatch_async(workingQueue, ^{
        
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
    });

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

#define FEED_DATA_NAME_IN_ZIP   @"data"          // IMPORTANT, YOU MUST ALIGN THIS WITH SERVER

+ (void)initPaths
{
    [FileUtil createDir:[FeedService getDownloadTopPath]];
    [FileUtil createDir:[FeedService getDownloadTempTopPath]];
    [FileUtil createDir:[FeedService getDownloadZipTopPath]];
}

+ (NSString*)getDownloadTopPath
{
    NSString* dir = [[FileUtil getAppCacheDir] stringByAppendingPathComponent:[FeedManager getFeedCacheDir]];
    return dir;
}

+ (NSString*)getDownloadTempTopPath
{
    NSString* dir = [[[FileUtil getAppCacheDir]
                     stringByAppendingPathComponent:[FeedManager getFeedCacheDir]]
                     stringByAppendingPathComponent:@"/download_temp/"];
    return dir;
}

+ (NSString*)getDownloadZipTopPath
{
    NSString* dir = [[[FileUtil getAppCacheDir]
                      stringByAppendingPathComponent:[FeedManager getFeedCacheDir]]
                     stringByAppendingPathComponent:@"/zip/"];
    return dir;
}

+ (NSString*)getFileUpdateDownloadZipPath:(NSString*)name
{
    return [[FeedService getDownloadZipTopPath] stringByAppendingPathComponent:name];
}

+ (NSString*)getFileUpdateDownloadPath:(NSString*)name
{
    return [[FeedService getDownloadTopPath]
            stringByAppendingPathComponent:[name stringByAppendingString:@"_zip"]];
}

+ (NSString*)getFileFinalPath:(NSString*)name
{
    return [[FeedService getDownloadTopPath]
            stringByAppendingPathComponent:name];
}

+ (NSString*)getFileUpdateDownloadTempPath:(NSString*)name
{
    return [[FeedService getDownloadTempTopPath] stringByAppendingPathComponent:name];
}

- (NSData*)unzipFile:(NSString *)zipFilePath unzipFilePath:(NSString*)unzipFilePath // moveToFilePath:(NSString*)moveToFilePath
{    
    PPDebug(@"<unzipFile> start unzip %@", zipFilePath);
    if ([SSZipArchive unzipFileAtPath:zipFilePath
                        toDestination:unzipFilePath
                            overwrite:YES
                             password:nil
                                error:nil]) {
        PPDebug(@"<unzipFile> unzip %@ successfully", [zipFilePath lastPathComponent]);
    } else {
        PPDebug(@"<unzipFile> unzip %@ fail", [zipFilePath lastPathComponent]);
        return nil;
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // delete files after it's unzip
        [FileUtil removeFile:zipFilePath];
    });
    
    NSString* dataFile = [unzipFilePath stringByAppendingPathComponent:FEED_DATA_NAME_IN_ZIP];
    NSData* data = [NSData dataWithContentsOfFile:dataFile];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // delete file after it's read
        [FileUtil removeFile:dataFile];
        
        // delete unzip file folder
        [FileUtil removeFile:unzipFilePath];
    });
    
    return data;
    
    /*
    NSFileManager* fileManager = [[NSFileManager alloc] init];
    
    // remove file before move
    if ([fileManager fileExistsAtPath:moveToFilePath]){
        [fileManager removeItemAtPath:moveToFilePath error:nil];
    }
    
    // move file
    NSString* fileToBeMoved = [unzipFilePath stringByAppendingPathComponent:FEED_DATA_NAME_IN_ZIP];    
    NSError* error = nil;
    BOOL result = [fileManager moveItemAtPath:fileToBeMoved toPath:moveToFilePath error:&error];
    if (result){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // delete files after it's unzip
            [FileUtil removeFile:unzipFilePath];
        });
    }
    
    [fileManager release];
    */
}

// call this method to download data
- (NSData*)downloadDrawDataFile:(NSString*)fileURL fileName:(NSString*)fileName
{
    if (fileURL == nil)
        return nil;

    NSURL* url = [NSURL URLWithString:fileURL];
    if (url == nil)
        return nil;
    
    NSString* zipFileName = [fileName stringByAppendingPathExtension:@"zip"];
    
    ASIHTTPRequest* downloadHttpRequest = [ASIHTTPRequest requestWithURL:url];
    
    downloadHttpRequest.delegate = self;
    [downloadHttpRequest setAllowCompressedResponse:YES];
//    [downloadHttpRequest setUsername:DEFAULT_HTTP_USER_NAME];
//    [downloadHttpRequest setPassword:DEFAULT_HTTP_PASSWORD];
    
    NSString* destPath = [FeedService getFileUpdateDownloadZipPath:zipFileName];
    [downloadHttpRequest setDownloadDestinationPath:destPath];
    
    NSString* tempPath = [FeedService getFileUpdateDownloadTempPath:zipFileName];
    [downloadHttpRequest setTemporaryFileDownloadPath:tempPath];
    
    [downloadHttpRequest setDownloadProgressDelegate:nil];
    [downloadHttpRequest setAllowResumeForFileDownloads:YES];
    
    PPDebug(@"<downloadDrawDataFile> URL=%@, Local Temp=%@, Store At=%@",
            url.absoluteString, tempPath, destPath);
    
    [downloadHttpRequest startSynchronous];

    if ([[NSFileManager defaultManager] fileExistsAtPath:destPath] == NO){
        PPDebug(@"<downloadDrawDataFile> failure, file not downloaded");
        return nil;
    }
    
    // unzip file
    NSString* unzipFilePath = [FeedService getFileUpdateDownloadPath:fileName];
    return [self unzipFile:destPath unzipFilePath:unzipFilePath]; //moveToFilePath:finalFilePath];
}

#define GET_FEED_DETAIL_QUEUE @"GET_FEED_DETAIL_QUEUE"
- (void)getFeedByFeedId:(NSString *)feedId
               delegate:(id<FeedServiceDelegate>)delegate
{
    
    FeedManager *manager = [FeedManager defaultManager];

    NSOperationQueue *queue = [self getOperationQueue:GET_FEED_DETAIL_QUEUE];
    [queue cancelAllOperations];

    [queue addOperationWithBlock:^{
        
        // add by Benson
        NSAutoreleasePool *subPool = [[NSAutoreleasePool alloc] init];        
        
        PBFeed *pbFeed = [manager loadPBFeedWithFeedId:feedId];
        DrawFeed *feed = nil;
        BOOL fromCache = NO;
        BOOL downloadFileResult = NO;

        NSInteger resultCode = 0;
        
        if (pbFeed != nil) {
            PPDebug(@"<getFeedByFeedId> load local data, feedId = %@",feedId);
            fromCache = YES;
            feed = (DrawFeed*)[FeedManager parsePbFeed:pbFeed];
        }
        else{
        //if local data is nil, load data from remote service

            PPDebug(@"<getFeedByFeedId> load remote data, feedId = %@",feedId);
            NSString* userId = [[UserManager defaultManager] userId];
            
            
            CommonNetworkOutput* output = [GameNetworkRequest
                                           getFeedWithProtocolBuffer:TRAFFIC_SERVER_URL
                                           userId:userId feedId:feedId];
            
            resultCode = [output resultCode];

            if (output.resultCode == ERROR_SUCCESS && [output.responseData length] > 0) {
                
                @try{
                    DataQueryResponse *response = [DataQueryResponse parseFromData:output.responseData];
                    resultCode = [response resultCode];
                    
                    if (resultCode == ERROR_SUCCESS) {
                        NSArray *list = [response feedList];
                        pbFeed = ([list count] != 0) ? [list objectAtIndex:0] : nil;
                        
                        // add download feed data file here
                        if ([[pbFeed drawDataUrl] length] > 0){
                            NSData* data = [self downloadDrawDataFile:[pbFeed drawDataUrl]
                                                                  fileName:[pbFeed feedId]];
                            
                            if (data != nil){
                                // create PBDraw from data and rewrite pbFeed
                                PBDraw* pbDraw = [PBDraw parseFromData:data];
                                pbFeed = [[[PBFeed builderWithPrototype:pbFeed] setDrawData:pbDraw] build];
                            }
                        }
                        
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
                @finally {
                }            
            }
        }
        //send back to delegate
        dispatch_async(dispatch_get_main_queue(), ^{
            [manager cachePBFeed:pbFeed];
            if (delegate && [delegate respondsToSelector:@selector(didGetFeed:resultCode:fromCache:)]) {
                [delegate didGetFeed:feed
                          resultCode:resultCode
                           fromCache:fromCache];
            }
        });
        
        [subPool drain];
    }];
}

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

#define UPDATE_OPUS_QUEUE @"UPDATE_OPUS_QUEUE"

- (void)updateOpus:(NSString *)opusId image:(UIImage *)image
{
    NSString* userId = [[UserManager defaultManager] userId];
    NSString* appId = [ConfigManager appId];
    
    dispatch_queue_t updateOpusQueue = [self getQueue:UPDATE_OPUS_QUEUE];
    
    dispatch_async(updateOpusQueue, ^{
        CommonNetworkOutput* output = [GameNetworkRequest updateOpus:TRAFFIC_SERVER_URL appId:appId userId:userId opusId:opusId data:nil imageData:[image data]];
        if (output.resultCode == 0) {
            PPDebug(@"<updateOpus> succ!");
        }else{
            PPDebug(@"<updateOpus> fail!");
        }
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
        if (output.resultCode == 0) {
            PPDebug(@"<updateOpus> succ!");
            successBlock();
        }else{
            PPDebug(@"<updateOpus> fail!");
            failBlock();
        }
    });
    
}

@end
