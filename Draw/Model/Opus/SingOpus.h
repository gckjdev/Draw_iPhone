//
//  SingOpus.h
//  Draw
//
//  Created by 王 小涛 on 13-6-3.
//
//

@class Opus;

@interface SingOpus : Opus

- (void)setSong:(PBSong *)song;
- (void)setVoiceType:(PBVoiceType)voiceType;
- (void)setDuration:(float)duration;
- (void)setPitch:(float)pitch;

@end
