//
//  OpusManager.h
//  Draw
//
//  Created by 王 小涛 on 13-6-3.
//
//

#import <Foundation/Foundation.h>

@class Opus;
@class PBOpus;
@class APLevelDB;


/*
 Do not use this class directly, use it's subclass instead.
 */

@interface OpusManager : NSObject

- (id)initWihtDbName:(NSString *)dbName;


// left for subclass to implementation
- (Class)opusClass;

// 获取单个作品
- (Opus*)opusWithOpusId:(NSString *)opusId;

// 保存作品
- (void)saveOpus:(Opus*)opus;

// 删除作品
- (void)deleteOpus:(Opus *)opus;

// 查找作品
- (NSArray*)findAllOpusWithOffset:(int)offset limit:(int)limit;

// 删除所有作品
- (void)deleteAllOpus;

// 获得作品总数（本地）
- (int)allOpusCount;

// 获得待恢复的草稿总数
- (int)recoveryOpusCount;

// 创建作品草稿
- (Opus*)createDraftWithName:(NSString*)name;

+ (PBOpus *)createTestOpus;

// Call these methods in sub-class
- (void)setDraftOpusId:(Opus*)opus extension:(NSString*)fileNameExtension;
- (void)setCommonOpusInfo:(Opus*)opus;

@end
