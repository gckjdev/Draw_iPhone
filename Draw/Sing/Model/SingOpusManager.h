//
//  SingOpusManager.h
//  Draw
//
//  Created by 王 小涛 on 13-10-17.
//
//

#import "OpusManager.h"

@class SingOpus;

@interface SingOpusManager : OpusManager



// 创建唱歌草稿
//- (SingOpus*)createDraftSingOpus:(PBSong*)song;
- (Opus*)createDraftWithName:(NSString*)name;

@end
