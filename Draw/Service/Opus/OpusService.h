//
//  OpusService.h
//  Draw
//
//  Created by 王 小涛 on 13-6-3.
//
//

#import "CommonService.h"
#import "Sing.pb.h"
#import "OpusManager.h"
#import "GameNetworkConstants.h"

@protocol OpusServiceDelegate <NSObject>

- (void)didSubmitOpus:(int)resultCode opus:(Opus *)opus;

@end

@interface OpusService : CommonService

+ (id)defaultService;

- (Opus*)createDraftOpus;

- (void)submitOpus:(Opus*)opusMeta
             image:(UIImage *)image
          opusData:(NSData *)opusData
       opusManager:(OpusManager*)opusManager
  progressDelegate:(id)progressDelegate
          delegate:(id<OpusServiceDelegate>)delegate;

@end

