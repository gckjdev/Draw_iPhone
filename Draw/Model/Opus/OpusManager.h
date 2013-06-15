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


+ (PBOpus *)createTestOpus;
- (SingOpus*)createDraftSingOpus:(PBSong*)song;

@end
