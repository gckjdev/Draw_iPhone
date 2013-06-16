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

@interface OpusManager : NSObject

+ (id)singOpusManager;
+ (id)drawOpusManager;
+ (id)askPsManager;

- (id)opusWithOpusId:(NSString *)opusId;
- (void)saveOpus:(Opus*)opus;
- (void)deleteOpus:(NSString *)opusId;

// 草稿作品
- (NSArray*)findAllDrafts;
- (NSArray*)findAllDraftsWithOffset:(int)offset limit:(int)limit;

// 已经提交的所有作品
- (NSArray*)findAllSubmitOpus;

// 保存到本地的所有作品
- (NSArray*)findAllSavedOpus;


+ (PBOpus *)createTestOpus;
- (SingOpus*)createDraftSingOpus:(PBSong*)song;

@end
