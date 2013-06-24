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
- (void)didDownloadOpusData:(int)resultCode opus:(Opus *)opus;

@end

@interface OpusService : CommonService

@property (nonatomic, retain) OpusManager* singDraftOpusManager;
@property (nonatomic, retain) OpusManager* singLocalFavoriteOpusManager;
@property (nonatomic, retain) OpusManager* singLocalMyOpusManager;

+ (id)defaultService;

- (Opus*)createDraftOpus;

- (void)submitOpus:(Opus*)draftOpus
             image:(UIImage *)image
          opusData:(NSData *)opusData
  opusDraftManager:(OpusManager*)opusDraftManager
       opusManager:(OpusManager*)opusManager
  progressDelegate:(id)progressDelegate
          delegate:(id<OpusServiceDelegate>)delegate;

- (void)submitGuessWords:(NSArray *)words
                    opus:(Opus *)opus
               isCorrect:(BOOL)isCorrect
                   score:(int)score
                delegate:(id)delegate;

- (void)downloadOpusData:(Opus*)opus
        progressDelegate:(id)progressDelegate
                delegate:(id<OpusServiceDelegate>)delegate;

@end

