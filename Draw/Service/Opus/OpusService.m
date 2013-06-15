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

@implementation OpusService

SYNTHESIZE_SINGLETON_FOR_CLASS(OpusService);

- (Opus*)createDraftOpus
{
    return nil;
}

- (void)submitOpus:(Opus*)opusMeta
             image:(UIImage *)image
          opusData:(NSData *)opusData
       opusManager:(OpusManager*)opusManager
  progressDelegate:(id)progressDelegate
          delegate:(id<OpusServiceDelegate>)delegate

{    
//    if ([opusData length] == 0 || opusMeta == nil){
//        if ([delegate respondsToSelector:@selector(didSubmitOpus:opus:)]){
//            [delegate didSubmitOpus:ERROR_CLIENT_REQUEST_NULL opus:nil];
//        }
//        return;
//    }
    
    dispatch_async(workingQueue, ^{
        
        NSDictionary *para = @{PARA_USERID : [[UserManager defaultManager] userId],
                               PARA_APPID : [ConfigManager appId],
                               };
        
        NSDictionary *imageDataDict = nil;
        if (image != nil){
            imageDataDict = @{PARA_OPUS_IMAGE_DATA : [image data]};
        }
        
        NSMutableDictionary *postDataDict = [NSMutableDictionary dictionary];
        NSData* opusMetaData = [opusMeta data];
        if (opusMetaData) {
            [postDataDict setObject:opusMetaData forKey:PARA_OPUS_META_DATA];
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

            if (output.resultCode == ERROR_SUCCESS && pbOpus != nil){
                
                // save opus as normal opus locally
                Opus* newOpus = [Opus opusWithPBOpus:pbOpus];
                [newOpus setStorageType:PBOpusStoreTypeNormalOpus];
                [opusManager saveOpus:newOpus];
                
                // delete current draft opus
                [opusManager deleteOpus:[opusMeta opusKey]];
            }
            
            if ([delegate respondsToSelector:@selector(didSubmitOpus:opus:)]) {
                Opus *opus = [Opus opusWithPBOpus:pbOpus];
                [delegate didSubmitOpus:output.resultCode opus:opus];
            }
        });
    });
}


@end
