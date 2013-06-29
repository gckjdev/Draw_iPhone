//
//  OpusManager.h
//  Draw
//
//  Created by 王 小涛 on 13-6-3.
//
//

#import <Foundation/Foundation.h>

@class Opus;
@class SingOpus;
@class PBOpus;
@class PBSong;
@class APLevelDB;

@interface OpusManager : NSObject

@property (nonatomic, retain) NSString* dbName;
@property (nonatomic, retain) APLevelDB* db;

- (id)initWithClass:(Class)class dbName:(NSString*)dbName;

// 获取单个作品
- (Opus*)opusWithOpusId:(NSString *)opusId;

// 保存作品
- (void)saveOpus:(Opus*)opus;

// 删除作品
- (void)deleteOpus:(NSString *)opusId;

// 查找作品
- (NSArray*)findAllOpusWithOffset:(int)offset limit:(int)limit;

// 删除所有作品
- (void)deleteAllOpus;

// 获得作品总数（本地）
- (int)allOpusCount;

// 获得待恢复的草稿总数
- (int)recoveryOpusCount;

// 创建唱歌草稿
- (SingOpus*)createDraftSingOpus:(PBSong*)song;
- (SingOpus*)createDraftSingOpusWithSelfDefineName:(NSString*)name;

+ (PBOpus *)createTestOpus;



@end
