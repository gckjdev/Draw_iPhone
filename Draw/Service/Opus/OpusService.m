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

@implementation OpusService

SYNTHESIZE_SINGLETON_FOR_CLASS(OpusService);

- (Opus*)createDraftOpus
{
    return nil;
}

- (void)submitOpus:(Opus*)opusMeta
             image:(UIImage *)image
          opusData:(NSData *)opusData
  progressDelegate:(id)progressDelegate
          delegate:(id<OpusServiceDelegate>)delegate{
    
    if ([opusData length] == 0 || opusMeta == nil){
        
        if ([delegate respondsToSelector:@selector(didSubmitOpus:opus:)]){
            [delegate didSubmitOpus:ERROR_CLIENT_REQUEST_NULL opus:nil];
        }
        return;
    }
    
    dispatch_async(workingQueue, ^{
        
        CommonNetworkOutput *output = [GameNetworkRequest submitOpus:TRAFFIC_SERVER_URL
                                                               appId:[ConfigManager appId]
                                                              userId:[[UserManager defaultManager] userId]
                                                        opusMetaData:[[opusMeta pbOpus] data]
                                                           imageData:[image data]
                                                            opusData:opusData
                                                    progressDelegate:progressDelegate];
        
        NSInteger resultCode = output.resultCode;
        PBOpus *pbOpus = nil;
        if (resultCode == ERROR_SUCCESS){
            @try{
                DataQueryResponse *response = [DataQueryResponse parseFromData:output.responseData];
                resultCode = [response resultCode];
                pbOpus = [response opus];
                
                // TODO
                
            }
            @catch (NSException *exception) {
                PPDebug(@"<%s> catch exception =%@", __FUNCTION__, [exception description]);
                resultCode = ERROR_CLIENT_PARSE_DATA;
            }
            @finally {
                
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{

            if (resultCode == 0 && pbOpus != nil){
                
                // save opus as normal opus locally
                Opus* newOpus = [Opus opusWithPBOpus:pbOpus];
                [[OpusManager defaultManager] saveOpus:newOpus];
                
                // delete current draft opus
                [[OpusManager defaultManager] deleteOpus:[opusMeta opusKey]];
            }
            
            if ([delegate respondsToSelector:@selector(didSubmitOpus:opus:)]) {
                Opus *opus = [Opus opusWithPBOpus:pbOpus];
                [delegate didSubmitOpus:resultCode opus:opus];
            }
        });
    });
}


@end