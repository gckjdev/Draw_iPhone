//
//  Opus.h
//  Draw
//
//  Created by 王 小涛 on 13-6-3.
//
//

#import <Foundation/Foundation.h>
#import "Opus.pb.h"
#import "OpusDesignTime.h"

//typedef enum _OpusCategory{
//    OpusCategoryDraw = 1,
//    OpusCategorySing = 2,
//    OpusCategoryAskPs = 3,
//    OpusCategoryAskPsOpus = 4
//}OpusCategory;

#define ENCODE_OPUS_DATA        @"opusData"
#define ENCODE_OPUS_KEY         @"opusKey"
#define BURI_INDEX_STORE_TYPE   @"opusStoreType"

@interface Opus : NSObject

@property (nonatomic, retain) PBOpusBuilder* pbOpusBuilder;
@property (nonatomic, retain) OpusDesignTime* designTime;

+ (Opus*)opusWithCategory:(PBOpusCategoryType)category;
+ (Opus*)opusWithPBOpus:(PBOpus *)pbOpus storeType:(PBOpusStoreType)storeType;
+ (Opus*)opusWithPBOpus:(PBOpus *)pbOpus;

// don't change method name, used for Buri Index
- (NSString*)opusKey;
- (NSNumber*)opusStoreType;

- (void)setType:(PBOpusType)type;
- (void)setName:(NSString *)name;
- (void)setLocalImageUrl:(NSString *)image;
- (void)setLocalThumbImageUrl:(NSString *)image;

- (void)setDesc:(NSString *)desc;
- (void)setTargetUser:(PBGameUser *)user;
- (void)setAsContestOpus:(NSString *)contestId;
- (void)setAsNormalOpus;

- (void)setIsRecovery:(BOOL)value;
- (void)setCanvasSize:(CGSize)size;


- (PBOpus *)pbOpus;
- (NSData *)data;

- (void)setCategory:(int)value;
- (void)setLanguage:(int)value;
- (void)setOpusId:(NSString *)value;
- (void)setDeviceName:(NSString *)value;
- (void)setAppId:(NSString *)value;
- (void)setAuthor:(PBGameUser *)user;
- (void)setStorageType:(PBOpusStoreType)value;
- (void)setCreateDate:(int)value;
- (void)setDeviceType:(int)value;
- (void)setSpendTime:(int)value;

- (void)setAsDraft;
- (void)setAsSubmit;
- (void)setAsSaved;

- (NSString*)localURLString:(NSString*)urlString;
- (NSString*)localDataURLString;
- (NSString*)localImageURLString;
- (NSString*)localThumbImageURLString;

- (NSURL*)localDataURL;
- (NSURL*)localThumbImageURL;
- (NSURL*)localImageURL;
+ (NSString*)localDataDir;
- (void)setLocalDataUrl:(NSString*)extension;

- (void)setTags:(NSArray *)tags;

- (NSString*)dataType;


- (NSData *)uploadData;

//add by kira
- (BOOL)isMyOpus;
- (NSString*)name;
- (NSDate*)createDate;
- (int)spendTime;
- (void)replayInController:(UIViewController*)controller;

- (NSArray*)shareOptionsTitleArray;
- (void)handleShareOptionAtIndex:(int)index
                  fromController:(UIViewController*)controller;
- (void)enterEditFromController:(UIViewController*)controller;


- (NSString *)shareTextWithSNSType:(int)type;

- (BOOL)hasSameTagsToTags:(NSArray *)tags;


- (void)loadOpusDesignTime;
- (void)saveDesignTime;
- (void)pauseAndSaveDesignTime;

@end

