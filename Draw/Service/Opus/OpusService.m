//
//  OpusService.m
//  Draw
//
//  Created by 王 小涛 on 13-6-3.
//
//

#import "OpusService.h"
#import "GameNetworkRequest.h"
#import "CommonNetworkClient.h"
#import "ConfigManager.h"
#import "UserManager.h"
#import "GameMessage.pb.h"
#import "UIImageExt.h"
#import "SynthesizeSingleton.h"
#import "PPGameNetworkRequest.h"
#import "SingOpus.h"
#import "StringUtil.h"
#import "OpusDownloadService.h"
#import "FileUtil.h"

#define SING_MY_OPUS_DB     @"sing_my_opus.db"
#define SING_FAVORITE_DB    @"sing_favorite.db"
#define SING_DRAFT_DB       @"sing_draft.db"

#define GET_FEED_DETAIL_QUEUE   @"GET_FEED_DETAIL_QUEUE"
#define GET_OPUS_DATA_QUEUE        @"GET_OPUS_DATA_QUEUE"
#define GET_FEED_COMMENT_QUEUE  @"GET_FEED_COMMENT_QUEUE"

@interface OpusService()


@end

@implementation OpusService

SYNTHESIZE_SINGLETON_FOR_CLASS(OpusService);

- (void)dealloc
{
    [_singDraftOpusManager release];
    [_singLocalFavoriteOpusManager release];
    [_singLocalMyOpusManager release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    _singLocalMyOpusManager = [[OpusManager alloc] initWithClass:[SingOpus class] dbName:SING_MY_OPUS_DB];
    _singLocalFavoriteOpusManager = [[OpusManager alloc] initWithClass:[SingOpus class] dbName:SING_FAVORITE_DB];
    _singDraftOpusManager = [[OpusManager alloc] initWithClass:[SingOpus class] dbName:SING_DRAFT_DB];
    return self;
}


- (Opus*)createDraftOpus
{
    return nil;
}

- (void)submitOpus:(Opus*)draftOpus
             image:(UIImage *)image
          opusData:(NSData *)opusData
  opusDraftManager:(OpusManager*)opusDraftManager
       opusManager:(OpusManager*)opusManager
  progressDelegate:(id)progressDelegate
          delegate:(id<OpusServiceDelegate>)delegate

{    
//    if ([opusData length] == 0 || draftOpus == nil){
//        if ([delegate respondsToSelector:@selector(didSubmitOpus:opus:)]){
//            [delegate didSubmitOpus:ERROR_CLIENT_REQUEST_NULL opus:nil];
//        }
//        return;
//    }
    
    dispatch_async(workingQueue, ^{
        
        NSDictionary *para = @{PARA_USERID : [[UserManager defaultManager] userId],
                               PARA_APPID : [ConfigManager appId],
                               PARA_UPLOAD_DATA_TYPE : [draftOpus dataType]
                               };
        
        NSDictionary *imageDataDict = nil;
        if (image != nil){
            imageDataDict = @{PARA_OPUS_IMAGE_DATA : [image data]};
        }
        
        NSMutableDictionary *postDataDict = [NSMutableDictionary dictionary];
        NSData* draftOpusData = [draftOpus data];
        if (draftOpusData) {
            [postDataDict setObject:draftOpusData forKey:PARA_OPUS_META_DATA];
        }
        
        if (opusData) {
            [postDataDict setObject:opusData forKey:PARA_OPUS_DATA];
        }
        
        GameNetworkOutput* output = [PPGameNetworkRequest trafficApiServerUploadAndResponsePB:METHOD_SUBMIT_OPUS
                                                                                   parameters:para
                                                                                imageDataDict:imageDataDict
                                                                                 postDataDict:postDataDict
                                                                             progressDelegate:progressDelegate];

        
        
        PBOpus *pbOpus = nil;
        if (output.resultCode == ERROR_SUCCESS){
            pbOpus = output.pbResponse.opus;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{

            Opus* newOpus = nil;
            if (output.resultCode == ERROR_SUCCESS && pbOpus != nil){
                
                // save opus as normal opus locally
                newOpus = [Opus opusWithPBOpus:pbOpus storeType:PBOpusStoreTypeSubmitOpus];
                [opusManager saveOpus:newOpus];
                
                // delete current draft opus
                [opusDraftManager deleteOpus:[draftOpus opusKey]];
            }
            
            if ([delegate respondsToSelector:@selector(didSubmitOpus:opus:)]) {
                [delegate didSubmitOpus:output.resultCode opus:(newOpus != nil) ? newOpus : draftOpus];
            }
        });
    });
}

- (void)submitGuessWords:(NSArray *)words
                    opus:(Opus *)opus
               isCorrect:(BOOL)isCorrect
                   score:(int)score
                delegate:(id)delegate{
    
    if ([words count] == 0) {
        return;
    }
    
    
    
}

- (void)getOpusDataFile:(Opus*)opus
       progressDelegate:(id)progressDelegate
               delegate:(id<OpusServiceDelegate>)delegate{
        
    NSOperationQueue *queue = [self getOperationQueue:GET_OPUS_DATA_QUEUE];
    [queue cancelAllOperations];
    
    [queue addOperationWithBlock:^{
        
        NSAutoreleasePool *subPool = [[NSAutoreleasePool alloc] init];
        NSInteger resultCode = 0;
        NSString *dataUrl = opus.pbOpus.dataUrl;
        
        NSString *destDir = [[FileUtil getAppCacheDir] stringByAppendingPathComponent:@"opusdata"];
                
        NSString *destPath = nil;
        @try {
            destPath = [[OpusDownloadService defaultService] downloadFileSynchronous:dataUrl destDir:destDir progressDelegate:progressDelegate];
        }
        @catch (NSException *exception) {
            PPDebug(@"<getPBDrawByFeed> catch exception =%@", [exception description]);
            resultCode = ERROR_CLIENT_PARSE_DATA;
        }
        @finally {
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([delegate respondsToSelector:@selector(didGetOpusFile:path:opus:)]) {
                [delegate didGetOpusFile:resultCode path:destPath opus:opus];
            }
        });
        
        [subPool drain];
    }];
}


@end