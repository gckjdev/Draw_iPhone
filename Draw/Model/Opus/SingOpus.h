//
//  SingOpus.h
//  Draw
//
//  Created by 王 小涛 on 13-6-3.
//
//

#import "Opus.h"

//#define SING_FILE_EXTENSION         @"m4a"
#define SING_FILE_EXTENSION         @"wav"
//#define SING_FILE_EXTENSION         @"mp3"

#define SING_UPLOAD_FILE_EXTENSION         @"mp3"

#define SING_IMAGE_EXTENSION        @"png"

@interface SingOpus : Opus

- (void)setSong:(PBSong *)song;
- (void)setVoiceType:(PBVoiceType)voiceType;

- (void)setLabelInfoWithFrame:(CGRect)frame
                    textColor:(NSUInteger)textColor
                     textFont:(float)textFont
                        style:(int)style
              textStrokeColor:(NSUInteger)textStrokeColor;

- (NSURL*)localNativeDataURL;
- (void)setLocalNativeDataUrl:(NSString*)extension;
- (void)setLocalImageDataUrl:(NSString*)extension;
- (void)setLocalThumbImageDataUrl:(NSString*)extension;
- (BOOL)hasFileForPlay;
- (NSString *)getCurrentVoiceTypeName;

@end
