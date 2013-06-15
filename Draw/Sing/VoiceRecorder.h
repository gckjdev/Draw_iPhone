//
//  VoiceRecorder.h
//  Draw
//
//  Created by 王 小涛 on 13-6-14.
//
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef enum {
    VoiceRecorderStateStopped,
    VoiceRecorderStateRecording,
    VoiceRecorderStatePaused,
    VoiceRecorderStateEnded,
    VoiceRecorderStateError
} VoiceRecorderState;


@class VoiceRecorder;

@protocol VoiceRecorderDelegate <NSObject>

@optional

- (void)recorder:(VoiceRecorder *)recorder didChangeRecordState:(VoiceRecorderState)recordState;
- (void)recorder:(VoiceRecorder *)recorder recordTime:(CGFloat)recordTime;

@end

@interface VoiceRecorder : NSObject <AVAudioRecorderDelegate>
@property (readonly, copy, nonatomic) NSURL *recordURL;
@property (readonly, assign, nonatomic) double duration;
@property (assign, nonatomic) id<VoiceRecorderDelegate> delegate;

- (void)prepareToRecord:(NSURL *)url;
- (void)startToRecordForDutaion:(double)duration;
- (void)stopRecording;

@end
