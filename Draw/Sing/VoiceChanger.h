//
//  VoiceChanger.h
//  Draw
//
//  Created by 王 小涛 on 13-6-14.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    VoiceChangerStateStopped,
    VoiceChangerStatePlaying,
    VoiceChangerStatePaused,
    VoiceChangerStateEnded,
    VoiceChangerStateError
} VoiceChangerState;

@class VoiceChanger;
@class EAFRead;
@class EAFWrite;

@protocol VoiceProcessDelegate <NSObject>

@optional

- (void)setProgress:(float)process;
- (void)processDone:(NSURL *)outURL;

@end

@protocol VoiceChangerDelegate <NSObject>

@optional

- (void)voiceChanger:(VoiceChanger *)voiceChanger didGetFileDuration:(double)fileDuration;
- (void)voiceChanger:(VoiceChanger *)voiceChanger didChangePlayState:(VoiceChangerState)playState;
- (void)voiceChanger:(VoiceChanger *)voiceChanger
            playTime:(CGFloat)playTime
        fileDuration:(double)fileDuration;

@end

@interface VoiceChanger : NSObject{
    EAFRead *reader;
	EAFWrite *writer;
}

@property (readonly, retain, nonatomic) NSURL *playURL;
@property (assign, nonatomic) id<VoiceChangerDelegate> delegate;
@property (assign, nonatomic) id<VoiceProcessDelegate> progressDelegate;
@property (readonly) EAFRead *reader;

- (void)prepareToPlay:(NSURL *)url;

- (void)startPlayingWithDuration:(float)duration
                           pitch:(float)pitch
                         formant:(float)formant;

- (void)changeDuration:(float)duration
                 pitch:(float)pitch
               formant:(float)formant;

- (void)pausePlaying;
- (void)stopPlaying;

- (void)processVoice:(NSURL *)inURL
              outURL:(NSURL *)outURL
            duration:(float)duration
               pitch:(float)pitch
             formant:(float)formant;

@end
