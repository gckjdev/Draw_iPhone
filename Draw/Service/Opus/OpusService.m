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
#import "PPConfigManager.h"
#import "UserManager.h"
#import "GameMessage.pb.h"
#import "UIImageExt.h"
#import "SynthesizeSingleton.h"
#import "PPGameNetworkRequest.h"
//#import "SingOpus.h"
#import "StringUtil.h"
#import "OpusDownloadService.h"
#import "FileUtil.h"
#import "DrawDataService.h"
#import "Opus.h"
#import "OpusManagerFactory.h"

#define MY_OPUS_DB     @"my_opus.db"
#define FAVORITE_DB    @"favorite.db"
#define DRAFT_DB       @"draft.db"

#define GET_FEED_DETAIL_QUEUE   @"GET_FEED_DETAIL_QUEUE"
#define GET_OPUS_DATA_QUEUE     @"GET_OPUS_DATA_QUEUE"
#define GET_FEED_COMMENT_QUEUE  @"GET_FEED_COMMENT_QUEUE"

@interface OpusService()

@end

@implementation OpusService

SYNTHESIZE_SINGLETON_FOR_CLASS(OpusService);

- (void)dealloc
{
    [_draftOpusManager release];
    [_favoriteOpusManager release];
    [_myOpusManager release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    
    NSString *opusClassName = [GameApp opusClassName];    
    self.myOpusManager = [OpusManagerFactory createWithOpusClassName:opusClassName dbName:MY_OPUS_DB];
    self.favoriteOpusManager = [OpusManagerFactory createWithOpusClassName:opusClassName dbName:FAVORITE_DB];
    self.draftOpusManager = [OpusManagerFactory createWithOpusClassName:opusClassName dbName:DRAFT_DB];

    return self;
}


- (Opus*)createDraftOpus
{
    return nil;
}

- (void)submitOpus:(Opus*)draftOpus
             image:(UIImage *)image
          opusData:(NSData *)opusData
      targetUserId:(NSString *)targetUserId
  progressDelegate:(id)progressDelegate
          delegate:(id<OpusServiceDelegate>)delegate
{
    __block OpusManager *myOpusManager = _myOpusManager;
    __block OpusManager *draftOpusManager = _draftOpusManager;
        
    dispatch_async(workingQueue, ^{
        
        NSDictionary *para = nil;
        if (targetUserId == nil) {
            para = @{PARA_USERID : [[UserManager defaultManager] userId],
                        PARA_APPID : [PPConfigManager appId],
                     PARA_UPLOAD_DATA_TYPE : [draftOpus dataType]
                                   };
        }else{
            
            para = @{PARA_USERID : [[UserManager defaultManager] userId],
                     PARA_APPID : [PPConfigManager appId],
            PARA_UPLOAD_DATA_TYPE : [draftOpus dataType],
                     PARA_TO_USERID : targetUserId
                                   };
        }

        
        NSDictionary *imageDataDict = nil;
        if (image != nil){
            imageDataDict = @{PARA_OPUS_IMAGE_DATA : [image data]};
        }
        
        NSMutableDictionary *postDataDict = [NSMutableDictionary dictionary];
        
        NSData* draftOpusData = [draftOpus uploadData];
        
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

        
        int resultCode = output.resultCode;
        PBOpus *pbOpus = nil;
        
        if (resultCode == ERROR_SUCCESS){
            resultCode = output.pbResponse.resultCode;
            pbOpus = output.pbResponse.opus;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{

            Opus* newOpus = nil;
            if (resultCode == ERROR_SUCCESS && pbOpus != nil){
                
                // save opus as normal opus locally
                newOpus = [Opus opusWithPBOpus:pbOpus storeType:PBOpusStoreTypeSubmitOpus];
                [myOpusManager saveOpus:newOpus];
                
                // delete current draft opus
                [draftOpusManager deleteOpus:[draftOpus opusKey]];
            }
            
            if ([delegate respondsToSelector:@selector(didSubmitOpus:opus:)]) {
                [delegate didSubmitOpus:resultCode opus:(newOpus != nil) ? newOpus : draftOpus];
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
    NSString *opusId = opus.pbOpus.opusId;
    NSString *authorId = opus.pbOpus.author.userId;
    
    [[DrawDataService defaultService] guessDraw:words
                                         opusId:opusId
                                 opusCreatorUid:authorId
                                      isCorrect:NO
                                          score:3
                                       category:opus.pbOpus.category
                                       delegate:delegate];
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

- (void)getOpusWithOpusId:(NSString *)opusId
                 delegate:(id<OpusServiceDelegate>)delegate{
    
    dispatch_async(workingQueue, ^{
        
        NSDictionary *para = @{PARA_USERID : [[UserManager defaultManager] userId],
                               PARA_APPID : [PPConfigManager appId],
                               PARA_OPUS_ID : opusId
                               };
        
        GameNetworkOutput* output = [PPGameNetworkRequest trafficApiServerGetAndResponsePB:METHOD_GET_OPUS parameters:para];
        int resultCode = output.resultCode;
        PBOpus *pbOpus = nil;
        
        if (resultCode == ERROR_SUCCESS){
            resultCode = output.pbResponse.resultCode;
            pbOpus = output.pbResponse.opus;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            Opus* opus = nil;
            if (resultCode == ERROR_SUCCESS && pbOpus != nil){
                opus = [Opus opusWithPBOpus:pbOpus];
            }
            
            if ([delegate respondsToSelector:@selector(didGetOpus:opus:)]) {
                [delegate didGetOpus:resultCode opus:opus];
            }
        });
    });
}

@end