//
//  SingOpus.h
//  Draw
//
//  Created by 王 小涛 on 13-6-3.
//
//

#import "Opus.h"

#define SING_FILE_EXTENSION         @"m4a"

@interface SingOpus : Opus

- (void)setSong:(PBSong *)song;
- (void)setVoiceType:(PBVoiceType)voiceType;
- (void)setDuration:(float)duration;
- (void)setPitch:(float)pitch;
- (void)setFormant:(float)formant;

- (NSURL*)localNativeDataURL;
- (void)setLocalNativeDataUrl:(NSString*)extension;

@end
