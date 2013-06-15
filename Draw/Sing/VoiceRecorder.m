//
//  VoiceRecorder.m
//  Draw
//
//  Created by 王 小涛 on 13-6-14.
//
//

#import "VoiceRecorder.h"

#define SAMPLE_RATE 44100.0
#define CHANNELS 2
#define FORMAT kAudioFormatMPEG4AAC

@interface VoiceRecorder()

@property (copy, nonatomic) NSURL *recordURL;
@property (retain, nonatomic) AVAudioRecorder *recorder;
@property (retain, nonatomic) NSTimer *timer;

@end

@implementation VoiceRecorder

- (void)dealloc{
    [_recordURL release];
    [_recorder release];

    [super dealloc];
}

- (void)prepareToRecord:(NSURL *)url{
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[[NSMutableDictionary alloc] init] autorelease];
    
    [recordSetting setValue:[NSNumber numberWithInt:FORMAT] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:SAMPLE_RATE] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt:CHANNELS] forKey:AVNumberOfChannelsKey];
    [recordSetting setValue:[NSNumber numberWithInt: AVAudioQualityHigh] forKey:AVSampleRateConverterAudioQualityKey];
    [recordSetting setValue:[NSNumber numberWithInt: AVAudioQualityMin] forKey:AVEncoderAudioQualityKey];
    
    // Initiate and prepare the recorder
    // For demo purpose, we skip the error handling. In real app, don’t forget to include proper error handling.
    self.recordURL = url;
    NSError **error = nil;
    self.recorder = [[[AVAudioRecorder alloc] initWithURL:_recordURL settings:recordSetting error:error] autorelease];
    if (error != nil) {
        PPDebug(@"Error in %s: %@", __FUNCTION__, (*error).description);
    }
    
    [_recorder prepareToRecord];
    
    // Setup audio session
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    // start recording
    _recorder.delegate = self;
}

- (void)startToRecordForDutaion:(double)duration{
    
    if ([_recorder isRecording]) {
        PPDebug(@"Cannot call %s when recording", __FUNCTION__);
        return;
    }
    
    _duration = duration;
    [_recorder recordForDuration:duration];
    [self startTimer:0.5];
    
    if ([_delegate respondsToSelector:@selector(recorder:didChangeRecordState:)]) {
        [_delegate recorder:self didChangeRecordState:VoiceRecorderStateRecording];
    }
}

- (void)stopRecording{
    
    if (![_recorder isRecording]) {
        return;
    }
    
    [self killTimer];
    
    // stop record
    [_recorder stop];
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
    
    if ([_delegate respondsToSelector:@selector(recorder:didChangeRecordState:)]) {
        [_delegate recorder:self didChangeRecordState:VoiceRecorderStateStopped];
    }
}

/* audioRecorderDidFinishRecording:successfully: is called when a recording has been finished or stopped. This method is NOT called if the recorder is stopped due to an interruption. */
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    
    [self killTimer];

    if ([_delegate respondsToSelector:@selector(recorder:didChangeRecordState:)]) {
        [_delegate recorder:self didChangeRecordState:VoiceRecorderStateEnded];
    }
}

/* if an error occurs while encoding it will be reported to the delegate. */
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error{
    
    [self killTimer];

    if ([_delegate respondsToSelector:@selector(recorder:didChangeRecordState:)]) {
        [_delegate recorder:self didChangeRecordState:VoiceRecorderStateError];
    }
}

- (void)startTimer:(double)interval{
    // start timer
    if ([_delegate respondsToSelector:@selector(recorder:recordTime:)]) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(timeout) userInfo:nil repeats:YES];
    }
}

- (void)killTimer{
    // kill timer
    [_timer invalidate];
    self.timer = nil;
}

- (void)timeout{
    if (_recorder.recording) {
        PPDebug(@"record currentTime = %f", _recorder.currentTime);
        if ([_delegate respondsToSelector:@selector(recorder:recordTime:)]) {
            [_delegate recorder:self recordTime:_recorder.currentTime];
        }
    }
}

@end
