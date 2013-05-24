//
//  SingController.m
//  Chat
//
//  Created by 王 小涛 on 13-5-10.
//  Copyright (c) 2013年 王 小涛. All rights reserved.
//



#import "SingController.h"
#import "StringUtil.h"
#import "DiracFxAudioPlayer.h"
#import "FileUtil.h"
#import "UIViewUtils.h"

@interface SingController (){
    int _recordLimitTime;
    NSTimeInterval _recordDuration;
    NSTimeInterval _playTimerInterval;
    NSTimeInterval _recordTimerInterval;

    UIButton *_selectedButton;
    
    BOOL mUseVarispeed;
}
@property (retain, nonatomic) NSURL *recordURL;
@property (retain, nonatomic) NSURL *playURL;
@property (retain, nonatomic) AVAudioRecorder *recorder;
@property (retain, nonatomic) DiracFxAudioPlayer *player;
@property (retain, nonatomic) RecordAndPlayControl *control;

@end

@implementation SingController

- (void)dealloc{
    [_control release];
    [_recordURL release];
    [_recorder release];
    [_player release];
    [_RecordAndPlayHolderView release];
    [_durationSlider release];
    [_pitchSlider release];
    [_durationLabel release];
    [_pitchLabel release];
    [_progressSlider release];
    [_playURL release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _recordLimitTime = 30;
    _recordTimerInterval = 1;
    _playTimerInterval = 0.1;
    self.recordURL = [FileUtil fileURLInAppDocument:@"record.m4a"];
    
    [self prepareToRecord:_recordURL];
    
    self.control = [[[RecordAndPlayControl alloc] init] autorelease];
    _control.delegate = self;
    [self updateControl:StateReadyRecord];
    
    [self setDuration:1];
    [self setPitch:1];
    
    self.progressSlider.value = 0;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
//    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);

}

- (BOOL)shouldAutorotate{
    return NO;
}

- (void)updateControl:(StateRecordAndPlay)state{
    
    [_control setState:state];
    [_control showInView:_RecordAndPlayHolderView];
    
    switch (state) {
        case StateReadyRecord:
            [_control updateViewWithInfo:[NSDictionary dictionaryWithObject:@(_recordLimitTime) forKey:@(KeyRecordLimited)]];
            break;
            
        case StateRecording:
            [_control updateViewWithInfo:[NSDictionary dictionaryWithObjectsAndKeys:@(_recordLimitTime), @(KeyRecordLeftTime), nil]];
            break;
            
        case StateReadyPaly:            
        case StatePlaying:
            _recordDuration = _player.fileDuration;
            [_control updateViewWithInfo:[NSDictionary dictionaryWithObjectsAndKeys:@(_recordDuration), @(KeyRecordDuration), nil]];

            break;
            
        default:
            break;
    }
}

- (void)updateFileDuration{
    _recordDuration = _player.fileDuration;
    [_control updateViewWithInfo:[NSDictionary dictionaryWithObjectsAndKeys:@(_recordDuration), @(KeyRecordDuration), nil]];
}

- (void)viewDidUnload {

    [self setRecordAndPlayHolderView:nil];
    [self setDurationSlider:nil];
    [self setPitchSlider:nil];
    [self setDurationLabel:nil];
    [self setPitchLabel:nil];
    [self setProgressSlider:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)timeout{
//    PPDebug(@"_recorder.recording = %@", _recorder.recording ? @"YES": @"NO");
//    PPDebug(@"_recorder.currentTime = %d", _recorder.currentTime);
    
    if (_recorder.recording && _recorder.currentTime != 0) {
        _recordDuration = _recorder.currentTime;
        NSLog(@"_recordDuration = %f", _recordDuration);
        NSTimeInterval leftTime =  _recordLimitTime - _recordDuration;
        [_control updateViewWithInfo:[NSDictionary dictionaryWithObjectsAndKeys:@(leftTime), @(KeyRecordLeftTime), nil]];
    }
    
    if ([_player playing]) {
        self.progressSlider.value = _player.currentTime / _player.fileDuration;
    }
}

- (void)didClickControl:(RecordAndPlayControl *)control{
    switch (control.state) {
        case StateReadyRecord:
            [self updateControl:StateRecording];
            [self record];
            break;
            
        case StateRecording:
            [self updateControl:StateReadyPaly];
            [self stopRecord];
            break;
            
        case StateReadyPaly:
            [self updateControl:StatePlaying];
            [self play];
            break;
            
        case StatePlaying:
            [self updateControl:StateReadyPaly];
            [self pausePlay];
            break;
            
        default:
            break;
    }
}

- (void)reset{
    _recorder.delegate = nil;
    _player.delegate = nil;
    [self stopRecord];
    [self stopPlay];
}

- (IBAction)clickRerecordButton:(id)sender {
    [self reset];
    [self updateControl:StateReadyRecord];

    [self prepareToRecord:_recordURL];
}

- (IBAction)clickIPodButton:(id)sender {
    MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeMusic];
	
	[picker setDelegate: self];
	[picker setAllowsPickingMultipleItems: NO];
	picker.prompt = @"Choose song";
	[self presentModalViewController: picker animated: YES];
	[picker release];
}

- (void)prepareToRecord:(NSURL *)url{
        
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    // For demo purpose, we skip the error handling. In real app, don’t forget to include proper error handling.
    self.recorder = [[[AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:NULL] autorelease];
    [_recorder prepareToRecord];

    // Setup audio session
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    // start recording
    _recorder.delegate = self;
}

- (void)record {
    [_recorder recordForDuration:_recordLimitTime];
    
    // start timer
    self.timer = [NSTimer scheduledTimerWithTimeInterval:_recordTimerInterval target:self selector:@selector(timeout) userInfo:nil repeats:YES];
    _recordDuration = 0;
}

- (void)stopRecord{
    // kill timer
    [timer invalidate];
    self.timer = nil;
    
    // stop record
    [_recorder stop];
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}

- (void)prepareToPlay:(NSURL*)url{
    
    NSError *error = nil;
    self.player = [[[DiracFxAudioPlayer alloc] initWithContentsOfURL:url channels:1 error:&error] autorelease];		// LE only supports 1 channel!
    [_player prepareToPlay];

    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [_player setDelegate:self];
}

- (void)play{
    [_player play];

    // start timer
    self.timer = [NSTimer scheduledTimerWithTimeInterval:_playTimerInterval target:self selector:@selector(timeout) userInfo:nil repeats:YES];
}

- (void)pausePlay{
    // kill timer
    [timer invalidate];
    self.timer = nil;
    
    [_player pause];
}

- (void)stopPlay{
    // kill timer
    [timer invalidate];
    self.timer = nil;

    [_player stop];
}

/* audioRecorderDidFinishRecording:successfully: is called when a recording has been finished or stopped. This method is NOT called if the recorder is stopped due to an interruption. */
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    
    // kill timer
    [timer invalidate];
    self.timer = nil;
    
    // prepare to play
    self.playURL = _recordURL;
    [self prepareToPlay:_playURL];
    [self updateControl:StateReadyPaly];
    [self performSelector:@selector(updateFileDuration) withObject:nil afterDelay:0.8];
}

- (void)diracPlayerDidFinishPlaying:(DiracAudioPlayerBase *)player successfully:(BOOL)flag{
    
    NSLog(@"diracPlayerDidFinishPlaying : %@", flag ? @"YES" : @"NO");

    _progressSlider.value = 1.0;
    
    // kill timer
    [timer invalidate];
    self.timer = nil;
    
    [self updateControl:StateReadyPaly];

    // prepare to play
    [self prepareToPlay:_playURL];
}

- (IBAction)clickMaleButton:(id)sender {
    _selectedButton.selected = NO;
    _selectedButton = (UIButton *)sender;
    _selectedButton.selected = YES;
    
    [self setDuration:1.0];
    
    float pitch = 1.f/1.2;
    [self setPitch:pitch];
}

- (IBAction)clickTomCatButton:(id)sender {
    _selectedButton.selected = NO;
    _selectedButton = (UIButton *)sender;
    _selectedButton.selected = YES;
    
    float duration = 0.5;
    [self setDuration:duration];

    float pitch = 1.f/duration;
    [self setPitch:pitch];
}

- (IBAction)clickFemaleButton:(id)sender {
    
    _selectedButton.selected = NO;
    _selectedButton = (UIButton *)sender;
    _selectedButton.selected = YES;
    
    [self setDuration:1.0];
    
    float pitch = 1.f/0.8;
    [self setPitch:pitch];
}

- (IBAction)clickOriginButton:(id)sender {
    _selectedButton.selected = NO;
    _selectedButton = (UIButton *)sender;
    _selectedButton.selected = YES;
    
    [self setDuration:1.0];
    [self setPitch:1.0];
}


-(IBAction)uiDurationSliderMoved:(UISlider *)sender;
{
    [self setDuration:sender.value];

	if (mUseVarispeed) {
		float pitch = 1.f/sender.value;
        [self setPitch:pitch];
	}
}
// ---------------------------------------------------------------------------------------------------------------------------------------------

-(IBAction)uiPitchSliderMoved:(UISlider *)sender;
{
    float pitch= powf(2.f, (int)sender.value / 12.f);
	[self setPitch:pitch];
}

-(IBAction)uiVarispeedSwitchTapped:(UISwitch *)sender;
{
	if (sender.on) {
		mUseVarispeed = YES;
		_pitchSlider.enabled=NO;
        
		float pitch = 1.f/_durationSlider.value;
        [self setPitch:pitch];

	} else {
		mUseVarispeed = NO;
		_pitchSlider.enabled=YES;
	}
}

- (void)setPitch:(float)pitch{
    [_player changePitch:pitch];
    _pitchLabel.text = [NSString stringWithFormat:@"%0.1f", pitch];
    _pitchSlider.value = (int)12.f*log2f(pitch);
}

- (void)setDuration:(float)duration{
    [_player changeDuration:duration];
    _durationLabel.text = [NSString stringWithFormat:@"%0.1f", duration];
    _durationSlider.value = duration;
}


// ---------------------------------------------------------------------------------------------------------------------------------------------

- (void) mediaPicker:(MPMediaPickerController *)mediaPicker
   didPickMediaItems:(MPMediaItemCollection *)collection
{
    [self reset];

    MPMediaItem *mediaItem = [collection.items objectAtIndex:0];
	self.playURL = [mediaItem valueForProperty:MPMediaItemPropertyAssetURL];
        
    [self dismissViewControllerAnimated:YES completion:nil];
    
	[self prepareToPlay:_playURL];
    [self updateControl:StateReadyPaly];
    [self performSelector:@selector(updateFileDuration) withObject:nil afterDelay:0.8];

    _progressSlider.value = 0;    
}

// ---------------------------------------------------------------------------------------------------------------------------------------------

- (void) mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

// ---------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)progressSliderValueChanged:(id)sender {
    if ([_recorder isRecording]) {
        return;
    }
    
    float persent = ((UISlider *)sender).value;
    float currentTime = persent * _player.fileDuration;
    
    NSLog(@"persent is : %f", persent);
    NSLog(@"current time is : %f", currentTime);
    NSLog(@"fileDuration is : %f", _player.fileDuration);
    
    float delta = persent - 1.0;
    if (ABS(delta) < 0.00001) {
        [self updateControl:StateReadyPaly];
        [_player setCurrentTime:0];
        return;
    }else{
        [_player setCurrentTime:(persent * _player.fileDuration)];
    }
    
    if (_control.state == StatePlaying) {
        [self play];
    }
}

- (IBAction)progressSliderTouchDown:(id)sender {
    if ([_recorder isRecording]) {
        return;
    }
    [self pausePlay];
}

- (IBAction)clickSubmitButton:(id)sender {
    NSString *path = _recordURL.path;
    PPDebug(@"path is %@", path);
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (data == nil) {
        return;
    }
    
    
}


@end
