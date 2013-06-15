//
//  VoiceChanger.m
//  Draw
//
//  Created by 王 小涛 on 13-6-14.
//
//

#import "VoiceChanger.h"
#include "DiracFxAudioPlayer.h"

#import "EAFRead.h"
#import "EAFWrite.h"
#include "DiracUtilities.h"

double gExecTimeTotal = 0.;

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*
 This is the callback function that supplies data from the input stream/file whenever needed.
 It should be implemented in your software by a routine that gets data from the input/buffers.
 The read requests are *always* consecutive, ie. the routine will never have to supply data out
 of order.
 */
long myReadData(float **chdata, long numFrames, void *userData)
{
	// The userData parameter can be used to pass information about the caller (for example, "self") to
	// the callback so it can manage its audio streams.
	if (!chdata)	return 0;
	
	VoiceChanger *Self = (VoiceChanger *)userData;
	if (!Self)	return 0;
	
	// we want to exclude the time it takes to read in the data from disk or memory, so we stop the clock until
	// we've read in the requested amount of data
	gExecTimeTotal += DiracClockTimeSeconds(); 		// ............................. stop timer ..........................................
    
	OSStatus err = [Self.reader readFloatsConsecutive:numFrames intoArray:chdata];
	
	DiracStartClock();								// ............................. start timer ..........................................
    
	return err;
	
}
//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


@interface VoiceChanger(){
    float percent;
}
@property (assign, nonatomic) double fileDuration;
@property (retain, nonatomic) NSURL *playURL;
@property (retain, nonatomic) DiracFxAudioPlayer *player;
@property (retain, nonatomic) NSTimer *timer;
@property (assign, nonatomic) id<VoiceProcessDelegate> progressDelegate;

@end

@implementation VoiceChanger
@synthesize reader = reader;

- (void)dealloc{
    
    [_playURL release];
    [_player release];
    [_timer release];
    [reader release];
    [writer release];
    [super dealloc];
}

- (void)prepareToPlay:(NSURL *)url{
    
    self.playURL = url;
    
    NSError *error = nil;
    self.player = [[[DiracFxAudioPlayer alloc] initWithContentsOfURL:_playURL channels:1 error:&error] autorelease];		// LE only supports 1 channel!
    [_player prepareToPlay];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [_player setDelegate:self];
    
    [self performSelector:@selector(setFileDuration) withObject:nil afterDelay:0.2];    
}

- (void)setFileDuration{
    
    self.fileDuration = _player.fileDuration;
    
    if ([_delegate respondsToSelector:@selector(voiceChanger:didGetFileDuration:)]) {
        [_delegate voiceChanger:self didGetFileDuration:_fileDuration];
    }
}

- (void)startPlayingWithDuration:(float)duration pitch:(float)pitch formant:(float)formant{
    
    if ([_player playing]) {
        PPDebug(@"Cannot call %s when playing", __FUNCTION__);
        return;
    }
    
    [_player changeDuration:duration];
    [_player changePitch:pitch];
    [_player changeFormant:formant];
    [_player play];
    
    // start timer
    [self startTimer:0.1];
    
    if ([_delegate respondsToSelector:@selector(voiceChanger:didChangePlayState:)]) {
        [_delegate voiceChanger:self didChangePlayState:VoiceChangerStatePlaying];
    }
}

- (void)changeDuration:(float)duration
                 pitch:(float)pitch
               formant:(float)formant{
    
    if ([_player playing]) {
        [_player changeDuration:duration];
        [_player changePitch:pitch];
        [_player changeFormant:formant];
    }
}

- (void)pausePlaying{
    
    if (![_player playing]) {
        return;
    }
    
    // kill timer
    [self killTimer];
    [_player pause];
    
    if ([_delegate respondsToSelector:@selector(voiceChanger:didChangePlayState:)]) {
        [_delegate voiceChanger:self didChangePlayState:VoiceChangerStatePaused];
    }
}

- (void)stopPlaying{
    
    if (![_player playing]) {
        return;
    }
    
    [self killTimer];
    [_player stop];
    
    if ([_delegate respondsToSelector:@selector(voiceChanger:didChangePlayState:)]) {
        [_delegate voiceChanger:self didChangePlayState:VoiceChangerStateStopped];
    }
}

- (void)diracPlayerDidFinishPlaying:(DiracAudioPlayerBase *)player successfully:(BOOL)flag{
    
    NSLog(@"diracPlayerDidFinishPlaying : %@", flag ? @"YES" : @"NO");
    
    // kill timer
    [self killTimer];
    
    if ([_delegate respondsToSelector:@selector(voiceChanger:didChangePlayState:)]) {
        VoiceChangerState state = flag ? VoiceChangerStateEnded : VoiceChangerStateError;
        [_delegate voiceChanger:self didChangePlayState:state];
    }
}


- (void)startTimer:(double)interval{
    // start timer
    if ([_delegate respondsToSelector:@selector(voiceChanger:playTime:fileDuration:)]) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(timeout) userInfo:nil repeats:YES];
    }
}

- (void)killTimer{
    // kill timer
    [_timer invalidate];
    self.timer = nil;
}

- (void)timeout{
    if ([_player playing]) {
        PPDebug(@"play currentTime = %f", _player.currentTime);
        if ([_delegate respondsToSelector:@selector(voiceChanger:playTime:fileDuration:)]) {
            [_delegate voiceChanger:self playTime:_player.currentTime fileDuration:_fileDuration];
        }
    }
}

-(void)playOnMainThread:(id)param
{
    
    if ([_progressDelegate respondsToSelector:@selector(processDone)]) {
        
        [_progressDelegate processDone];
    }
}

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-(void)updateBarOnMainThread:(id)param{
    
    if ([_progressDelegate respondsToSelector:@selector(setProgress:)]) {
        
        [_progressDelegate setProgress:(percent/100.f)];
    }
}


//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#define KEY_INURL @"inURL"
#define KEY_OUTURL @"outURL"
#define KEY_DURATION @"duration"
#define KEY_PITCH @"pitch"
#define KEY_FORMANT @"formant"

-(void)processThread:(id)param
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    
    NSDictionary *dic  = (NSDictionary *)param;
    NSURL *inUrl = [dic objectForKey:KEY_INURL];
    NSURL *outUrl = [dic objectForKey:KEY_OUTURL];
    float time = [[dic objectForKey:KEY_DURATION] floatValue];
    float pitch = [[dic objectForKey:KEY_PITCH] floatValue];
    float formant = [[dic objectForKey:KEY_FORMANT] floatValue];
    
	long numChannels = 1;		// DIRAC LE allows mono only
	float sampleRate = 44100.;
    
	// open input file
	[reader openFileForRead:inUrl sr:sampleRate channels:numChannels];
	
	// create output file (overwrite if exists)
	[writer openFileForWrite:outUrl sr:sampleRate channels:numChannels wordLength:16 type:kAudioFileAIFFType];
	
	// DIRAC parameters
	// Here we set our time an pitch manipulation values
//	float time      = 1;                 // 115% length
//    //	float pitch     = pow(2., 0./12.);     // pitch shift (0 semitones)
//    float pitch     = 1.2;     // pitch shift (0 semitones)
//    //	float formant   = pow(2., 0./12.);    // formant shift (0 semitones). Note formants are reciprocal to pitch in natural transposing
//    float formant   = 1.2;    // formant shift (0 semitones). Note formants are reciprocal to pitch in natural transposing
    
	
	// First we set up DIRAC to process numChannels of audio at 44.1kHz
	// N.b.: The fastest option is kDiracLambdaPreview / kDiracQualityPreview, best is kDiracLambda3, kDiracQualityBest
	// The probably best *default* option for general purpose signals is kDiracLambda3 / kDiracQualityGood
	void *dirac = DiracCreate(kDiracLambdaPreview, kDiracQualityPreview, numChannels, sampleRate, &myReadData, (void*)self);
	//	void *dirac = DiracCreate(kDiracLambda3, kDiracQualityBest, numChannels, sampleRate, &myReadData);
	if (!dirac) {
		printf("!! ERROR !!\n\n\tCould not create DIRAC instance\n\tCheck number of channels and sample rate!\n");
		printf("\n\tNote that the free DIRAC LE library supports only\n\tone channel per instance\n\n\n");
		exit(-1);
	}
	
	// Pass the values to our DIRAC instance
	DiracSetProperty(kDiracPropertyTimeFactor, time, dirac);
	DiracSetProperty(kDiracPropertyPitchFactor, pitch, dirac);
	DiracSetProperty(kDiracPropertyFormantFactor, formant, dirac);
	
	// upshifting pitch will be slower, so in this case we'll enable constant CPU pitch shifting
	if (pitch > 1.0)
		DiracSetProperty(kDiracPropertyUseConstantCpuPitchShift, 1, dirac);
    
	// Print our settings to the console
	DiracPrintSettings(dirac);
	
	NSLog(@"Running DIRAC version %s\nStarting processing", DiracVersion());
	
	// Get the number of frames from the file to display our simplistic progress bar
	SInt64 numf = [reader fileNumFrames];
	SInt64 outframes = 0;
	SInt64 newOutframe = numf*time;
	long lastPercent = -1;
    percent = 0;
	
	// This is an arbitrary number of frames per call. Change as you see fit
	long numFrames = 8192;
	
	// Allocate buffer for output
	float **audio = AllocateAudioBuffer(numChannels, numFrames);
    
	double bavg = 0;
	
	// MAIN PROCESSING LOOP STARTS HERE
	for(;;) {
		
		// Display ASCII style "progress bar"
		percent = 100.f*(double)outframes / (double)newOutframe;
		long ipercent = percent;
		if (lastPercent != percent) {
			[self performSelectorOnMainThread:@selector(updateBarOnMainThread:) withObject:self waitUntilDone:NO];
			printf("\rProgress: %3li%% [%-40s] ", ipercent, &"||||||||||||||||||||||||||||||||||||||||"[40 - ((ipercent>100)?40:(2*ipercent/5))] );
			lastPercent = ipercent;
			fflush(stdout);
		}
		
		DiracStartClock();								// ............................. start timer ..........................................
		
		// Call the DIRAC process function with current time and pitch settings
		// Returns: the number of frames in audio
		long ret = DiracProcess(audio, numFrames, dirac);
		bavg += (numFrames/sampleRate);
		gExecTimeTotal += DiracClockTimeSeconds();		// ............................. stop timer ..........................................
		
		printf("x realtime = %3.3f : 1 (DSP only), CPU load (peak, DSP+disk): %3.2f%%\n", bavg/gExecTimeTotal, DiracPeakCpuUsagePercent(dirac));
		
		// Process only as many frames as needed
		long framesToWrite = numFrames;
		unsigned long nextWrite = outframes + numFrames;
		if (nextWrite > newOutframe) framesToWrite = numFrames - nextWrite + newOutframe;
		if (framesToWrite < 0) framesToWrite = 0;
		
		// Write the data to the output file
		[writer writeFloats:framesToWrite fromArray:audio];
		
		// Increase our counter for the progress bar
		outframes += numFrames;
		
		// As soon as we've written enough frames we exit the main loop
		if (ret <= 0) break;
	}
	
	percent = 100;
	[self performSelectorOnMainThread:@selector(updateBarOnMainThread:) withObject:self waitUntilDone:NO];
    
	
	// Free buffer for output
	DeallocateAudioBuffer(audio, numChannels);
	
	// destroy DIRAC instance
	DiracDestroy( dirac );
	
	// Done!
	NSLog(@"\nDone!");
	
	[reader release];
	[writer release]; // important - flushes data to file
	
	// start playback on main thread
    
	[self performSelectorOnMainThread:@selector(playOnMainThread:) withObject:self waitUntilDone:NO];
	
	[pool release];
}

- (void)processVoice:(NSURL *)inURL
              outURL:(NSURL *)outURL
            duration:(float)duration
               pitch:(float)pitch
             formant:(float)formant
    progressDelegate:(id<VoiceProcessDelegate>)progressDelegate{
    
    self.progressDelegate = progressDelegate;
    
    if (reader == nil) {
        reader = [[EAFRead alloc] init];
    }
    
    if (writer == nil) {
        writer = [[EAFWrite alloc] init];
    }
    
    NSDictionary *dic = @{KEY_INURL: inURL,
                          KEY_OUTURL : outURL,
                          KEY_DURATION : @(duration),
                          KEY_PITCH : @(pitch),
                          KEY_FORMANT : @(formant),
                          };
    
	[NSThread detachNewThreadSelector:@selector(processThread:) toTarget:self withObject:dic];
}

@end
