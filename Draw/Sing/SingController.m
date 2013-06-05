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
#import "SingService.h"
#import "SongManager.h"

#define GREEN_COLOR [UIColor colorWithRed:99/255.0 green:186/255.0 blue:152/255.0 alpha:1]
#define WHITE_COLOR [UIColor whiteColor]

enum{
    StateReadyRecord = 0,
    StateRecording = 1,
    StateReadyPlay = 2,
    StatePlaying = 3
};

@interface SingController (){
    int _recordLimitTime;
    NSTimeInterval _recordDuration;
    NSTimeInterval _playTimerInterval;
    NSTimeInterval _recordTimerInterval;
    
    int _state;
    CGFloat _duration;
    CGFloat _pitch;
}
@property (retain, nonatomic) PBSong *song;
@property (retain, nonatomic) NSURL *recordURL;
@property (retain, nonatomic) NSURL *playURL;
@property (retain, nonatomic) AVAudioRecorder *recorder;
@property (retain, nonatomic) DiracFxAudioPlayer *player;
@property (retain, nonatomic) UIButton *selectedButton;
@property (copy, nonatomic) NSString *desc;
@property (copy, nonatomic) UIImage *image;
@property (retain, nonatomic) ChangeAvatar *picker;

@end

@implementation SingController

- (void)dealloc{
    [_picker release];
    [_image release];
    [_desc release];
    [_selectedButton release];
    [_song release];
    [_recordURL release];
    [_recorder release];
    [_player release];
    [_playURL release];
    [_micImageView release];
    [_timeLabel release];
    [_playImageView release];
    [_pauseImageView release];
    [_rerecordButton release];
    [_addTimeButton release];
    [_saveButton release];
    [_submitButton release];
    [_rerecordButtonBg release];
    [_addTimeButtonBg release];
    [_saveButtonBg release];
    [_submitButtonBg release];
    [_songNameLabel release];
    [_songAuthorLabel release];
    [_lyricTextView release];
    [_originButton release];
    [_tagButton release];
    [super dealloc];
}

- (id)initWithSong:(PBSong *)song{
    if (self = [super init]) {
        self.song = song;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    self.selectedButton = _originButton;
    
    _duration = 1;
    _pitch = 1;
    
    self.songNameLabel.text = _song.name;
    self.songAuthorLabel.text = _song.author;
    self.lyricTextView.text = _song.lyric;
    
    _recordLimitTime = 30;
    _recordTimerInterval = 0.5;
    _playTimerInterval = 0.1;
    self.recordURL = [FileUtil fileURLInAppDocument:@"record.m4a"];
    
    [self prepareToRecord:_recordURL];
    
    [_player changeDuration:1];
    [_player changePitch:1];
    
    [self setState:StateReadyRecord];
}

- (BOOL)shouldAutorotate{
    return NO;
}

- (void)viewDidUnload {
    [self setMicImageView:nil];
    [self setTimeLabel:nil];
    [self setPlayImageView:nil];
    [self setPauseImageView:nil];
    [self setRerecordButton:nil];
    [self setAddTimeButton:nil];
    [self setSaveButton:nil];
    [self setSubmitButton:nil];
    [self setRerecordButtonBg:nil];
    [self setAddTimeButtonBg:nil];
    [self setSaveButtonBg:nil];
    [self setSubmitButtonBg:nil];
    [self setSongNameLabel:nil];
    [self setSongAuthorLabel:nil];
    [self setLyricTextView:nil];
    [self setOriginButton:nil];
    [self setTagButton:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setSelectedButton:(UIButton *)selectedButton{
    
    [_selectedButton setTitleColor:GREEN_COLOR forState:UIControlStateNormal];
    [_selectedButton release];
    
    _selectedButton = [selectedButton retain];
    [_selectedButton setTitleColor:WHITE_COLOR forState:UIControlStateNormal];
    
    [self.tagButton updateCenterX:_selectedButton.center.x];
}

- (void)timeout{
    if (_recorder.recording) {
        PPDebug(@"record currentTime = %f", _recorder.currentTime);
        _recordDuration = _recorder.currentTime;
        NSTimeInterval leftTime =  _recordLimitTime -  _recordDuration;
        [self updateUITime:leftTime];
    }
    
    if ([_player playing]) {
        NSTimeInterval leftTime = _player.fileDuration - _player.currentTime + 0.5;
        PPDebug(@"play leftTime = %f", leftTime);
        [self updateUITime:(leftTime)];
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
    [self prepareToRecord:_recordURL];
    [self setState:StateReadyRecord];
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
    [_player changeDuration:_duration];
    [_player changePitch:_pitch];
    
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
    
    [self setState:StateReadyPlay];
}

- (void)diracPlayerDidFinishPlaying:(DiracAudioPlayerBase *)player successfully:(BOOL)flag{
    
    NSLog(@"diracPlayerDidFinishPlaying : %@", flag ? @"YES" : @"NO");

    
    // kill timer
    [timer invalidate];
    self.timer = nil;
    
    // prepare to play
    [self prepareToPlay:_playURL];
    
    [self updateUITime:(_recordDuration+0.5)];
    [self setState:StateReadyPlay];
}

- (void) mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (IBAction)clickControlButton:(id)sender {
    switch (_state) {
        case StateReadyRecord:
            [self updateUITime:_recordLimitTime];
            [self setState:StateRecording];
            [self record];
            break;
            
        case StateRecording:
            [self updateUITime:(_recordDuration+0.5)];
            [self setState:StateReadyPlay];
            [self stopRecord];
            break;
            
        case StateReadyPlay:
            [self setState:StatePlaying];
            [self play];
            break;
            
        case StatePlaying:
            [self setState:StateReadyPlay];
            [self pausePlay];
            break;
            
        default:
            break;
    }
    
}

- (void)setState:(int)state{
    _state = state;
    
    switch (state) {
        case StateReadyRecord:
            [self uiReadyRecord];
            break;
            
        case StateRecording:
            [self uiRecording];
            break;
            
        case StateReadyPlay:
            [self uiReadyPlay];
            break;
            
        case StatePlaying:
            [self uiPlaying];
            break;
            
        default:
            break;
    }
}

- (void)uiReadyRecord{
    self.micImageView.hidden = NO;
    self.timeLabel.hidden = YES;
    self.playImageView.hidden = YES;
    self.pauseImageView.hidden = YES;
    
    self.rerecordButton.hidden = YES;
    self.rerecordButtonBg.hidden = YES;

    self.addTimeButton.hidden = NO;
    self.addTimeButtonBg.hidden = NO;

    self.saveButton.hidden = YES;
    self.saveButtonBg.hidden = YES;

    self.submitButton.hidden = YES;
    self.submitButtonBg.hidden = YES;

}

- (void)uiRecording{
    self.micImageView.hidden = YES;
    self.timeLabel.hidden = NO;
    self.playImageView.hidden = YES;
    self.pauseImageView.hidden = YES;
    
    self.rerecordButton.hidden = YES;
    self.rerecordButtonBg.hidden = YES;

    self.addTimeButton.hidden = YES;
    self.addTimeButtonBg.hidden = YES;

    self.saveButton.hidden = YES;
    self.saveButtonBg.hidden = YES;

    self.submitButton.hidden = YES;
    self.submitButtonBg.hidden = YES;

}

- (void)uiReadyPlay{
    self.micImageView.hidden = YES;
    self.timeLabel.hidden = NO;
    self.playImageView.hidden = NO;
    self.pauseImageView.hidden = YES;
    
    self.rerecordButton.hidden = NO;
    self.rerecordButtonBg.hidden = NO;

    self.addTimeButton.hidden = NO;
    self.addTimeButtonBg.hidden = NO;

    self.saveButton.hidden = NO;
    self.saveButtonBg.hidden = NO;

    self.submitButton.hidden = NO;
    self.submitButtonBg.hidden = NO;

}

- (void)uiPlaying{
    self.micImageView.hidden = YES;
    self.timeLabel.hidden = NO;
    self.playImageView.hidden = YES;
    self.pauseImageView.hidden = NO;
    
    self.rerecordButton.hidden = YES;
    self.rerecordButtonBg.hidden = YES;
    
    self.addTimeButton.hidden = YES;
    self.addTimeButtonBg.hidden = YES;
    
    self.saveButton.hidden = YES;
    self.saveButtonBg.hidden = YES;
    
    self.submitButton.hidden = YES;
    self.submitButtonBg.hidden = YES;
}

- (void)updateUITime:(int)time{

    if (time < 0 || time > 999) {
        return;
    }
    
    int min = time / 60;
    int sec = time % 60;
    
    self.timeLabel.text = [NSString stringWithFormat:@"%02d:%02d", min, sec];

//    if (time < 99) {
//        self.timeLabel.text = [NSString stringWithFormat:@"%02d", time];
//    }else{
//        self.timeLabel.text = [NSString stringWithFormat:@"%03d", time];
//    }
}

- (void)changeDuration:(CGFloat)duration pitch:(CGFloat)pitch{
    _duration = duration;
    _pitch = pitch;
    
    if ([_player playing]) {
        [_player changeDuration:duration];
        [_player changePitch:pitch];
    }
}

- (IBAction)clickOriginButton:(id)sender {
    self.selectedButton = (UIButton *)sender;
    [self changeDuration:1 pitch:1];
}

- (IBAction)clickTomCatButton:(id)sender {
    self.selectedButton = (UIButton *)sender;
    [self changeDuration:0.5 pitch:1.f/0.5];
}

- (IBAction)clickDuckButton:(id)sender {
    self.selectedButton = (UIButton *)sender;

}

- (IBAction)clickMaleButton:(id)sender {
    self.selectedButton = (UIButton *)sender;

    [self changeDuration:1 pitch:1.2];

}

- (IBAction)clickChildButton:(id)sender {
    self.selectedButton = (UIButton *)sender;

}

- (IBAction)clickFemaleButton:(id)sender {
    self.selectedButton = (UIButton *)sender;
    [self changeDuration:1 pitch:0.8];
}

- (IBAction)clickDescButton:(id)sender {
    InputDialog *dialog = [InputDialog dialogWith:@"kInputDesc" delegate:self];
    [self.view addSubview:dialog];
}

- (void)didClickOk:(InputDialog *)dialog targetText:(NSString *)targetText{
    
    self.desc = targetText;
    [dialog removeFromSuperview];
}

- (void)didClickCancel:(InputDialog *)dialog{
    
    [dialog removeFromSuperview];
}

- (IBAction)clickImageButton:(id)sender {
    if (_picker == nil) {
        self.picker = [[[ChangeAvatar alloc] init] autorelease];
    }
    
    [_picker showSelectionView:self];
}

- (void)didImageSelected:(UIImage*)image{
    self.image = image;
}

- (IBAction)clickBackButton:(id)sender {
    [timer invalidate];
    self.timer = nil;
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickSubmitButton:(id)sender {
    NSString *path = _recordURL.path;
    PPDebug(@"path is %@", path);
    
    NSData *singData = [NSData dataWithContentsOfFile:path];
    if (singData == nil) {
        return;
    }
    
    [[SingService defaultService] submitFeed:1
                                        word:nil
                                        desc:nil
                                    toUserId:nil
                                  toUserNick:nil
                                   contestId:nil
                                        song:nil
                                    singData:singData
                                   imageData:nil
                                   voiceType:1
                                    duration:1
                                       pitch:1
                            progressDelegate:self];
}


@end
