//
//  SingOpus.h
//  Draw
//
//  Created by 王 小涛 on 13-6-3.
//
//

#import "Opus.h"

#define SING_FILE_EXTENSION         @"m4a"
#define SING_IMAGE_EXTENSION        @"png"

@interface SingOpus : Opus

- (void)setSong:(PBSong *)song;
- (void)setVoiceType:(PBVoiceType)voiceType;

- (NSURL*)localNativeDataURL;
- (void)setLocalNativeDataUrl:(NSString*)extension;
- (void)setLocalImageDataUrl:(NSString*)extension;

@end
