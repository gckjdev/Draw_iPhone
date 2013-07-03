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

typedef enum{
    
//    FeedListTypeUnknow = 0,
//    FeedListTypeMy = 1,
//    FeedListTypeAll = 2,
//    FeedListTypeHot = 3,
//    FeedListTypeUserFeed = 4,
//    FeedListTypeUserOpus = 5,
//    FeedListTypeLatest = 6,
//    
//    //add 2012.9.21
//    FeedListTypeDrawToMe = 7,
//    FeedListTypeComment = 8,
//    FeedListTypeHistoryRank = 9,
//    FeedListTypeTopPlayer = 10,
//    
//    FeedListTypeRecommend = 11,
//    FeedListTypeTimelineOpus = 12,
//    FeedListTypeTimelineGuess = 13,
//    
//    FeedListTypeUserFavorite = 100,
    
    OpusListTypeWeek = 3,
    OpusListTypeLastest = 6,
    OpusListTypeYear = 9,
    OpusListTypeRecommend = 11
    
}OpusListType;

@protocol OpusServiceDelegate <NSObject>

@optional
- (void)didSubmitOpus:(int)resultCode
                 opus:(Opus *)opus;

- (void)didGetOpusFile:(int)resultCode
                  path:(NSString *)path
                  opus:(Opus *)opus;

- (void)didGetOpus:(int)resultCode
              opus:(PBOpus *)opus;

- (void)didGetOpusList:(int)resultCode
                  list:(NSArray *)list;

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

- (void)getOpusDataFile:(Opus*)opus
       progressDelegate:(id)progressDelegate
               delegate:(id<OpusServiceDelegate>)delegate;

- (void)getOpusWithOpusId:(NSString *)opusId
                 delegate:(id<OpusServiceDelegate>)delegate;

- (void)getOpusList:(OpusListType)opusListType
             offset:(NSInteger)offset
              limit:(NSInteger)limit
           delegate:(id<OpusServiceDelegate>)delegate;

@end

