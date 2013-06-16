//
//  Opus.h
//  Draw
//
//  Created by 王 小涛 on 13-6-3.
//
//

#import <Foundation/Foundation.h>
#import "Opus.pb.h"
#import "BuriSerialization.h"

//typedef enum _OpusCategory{
//    OpusCategoryDraw = 1,
//    OpusCategorySing = 2,
//    OpusCategoryAskPs = 3,
//    OpusCategoryAskPsOpus = 4
//}OpusCategory;

@interface Opus : NSObject <BuriSupport>

@property (nonatomic, retain) PBOpus_Builder* pbOpusBuilder;

+ (Opus*)opusWithCategory:(PBOpusCategoryType)category;
+ (Opus*)opusWithPBOpus:(PBOpus *)pbOpus;
- (NSString*)opusKey;

- (void)setType:(PBOpusType)type;
- (void)setName:(NSString *)name;  
- (void)setDesc:(NSString *)desc;
- (void)setTargetUser:(PBGameUser *)user;

- (PBOpus *)pbOpus;
- (NSData *)data;

- (void)setCategory:(int)value;
- (void)setLanguage:(int)value;
- (void)setOpusId:(NSString *)value;
- (void)setDeviceName:(NSString *)value;
- (void)setAppId:(NSString *)value;
- (void)setAuthor:(PBGameUser *)user;
- (void)setStorageType:(int)value;
- (void)setCreateDate:(int)value;
- (void)setDeviceType:(int)value;

- (NSURL*)localDataURL;
+ (NSString*)localDataDir;
- (void)setLocalDataUrl:(NSString*)extension;

- (NSString*)dataType;

@end

