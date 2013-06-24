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

#define SING_MY_OPUS_DB     @"sing_my_opus.db"
#define SING_FAVORITE_DB    @"sing_favorite.db"
#define SING_DRAFT_DB       @"sing_draft.db"

@implementation OpusService

SYNTHESIZE_SINGLETON_FOR_CLASS(OpusService);

- (id)init
{
    self = [super init];
    _singLocalMyOpusManager = [[OpusManager alloc] initWithClass:[SingOpus class] dbName:SING_MY_OPUS_DB];
    _singLocalFavoriteOpusManager = [[OpusManager alloc] initWithClass:[SingOpus class] dbName:SING_FAVORITE_DB];
    _singDraftOpusManager = [[OpusManager alloc] initWithClass:[SingOpus class] dbName:SING_DRAFT_DB];
    return self;
}

- (void)dealloc
{
    [super dealloc];
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


@end