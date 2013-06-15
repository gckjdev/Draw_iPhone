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
#import "SongManager.h"
#import "OpusManager.h"
#import "MKBlockAlertView.h"
#import "UIButton+WebCache.h"

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
    double _fileDuration;
    
    int _state;
    BOOL _newOpus;
}
@property (retain, nonatomic) SingOpus *singOpus;
@property (copy, nonatomic) NSURL *recordURL;
@property (copy, nonatomic) NSURL *playURL;
@property (retain, nonatomic) VoiceRecorder *recorder;
@property (retain, nonatomic) VoiceChanger *player;
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
    [_singOpus release];
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
    [_songNameLabel release];
    [_songNameLabel1 release];
    [_songAuthorLabel1 release];
    [_songAuthorLabel1 release];
    [_lyricTextView release];
    [_originButton release];
    [_tagButton release];
    [_tomCatButton release];
    [_maleButton release];
    [_duckButton release];
    [_femaleButton release];
    [_childButton release];
    [_opusMainView release];
    [_opusReview release];
    [_opusImageButton release];
    [super dealloc];
}

- (id)initWithSong:(PBSong *)song{
    if (self = [super init]) {
        self.singOpus = [Opus opusWithCategory:OpusCategorySing];
        [_singOpus setType:PBOpusTypeSing];
        [_singOpus setSong:song];
        [_singOpus setVoiceType:PBVoiceTypeVoiceTypeOrigin];
        [_singOpus setDuration:1];
        [_singOpus setPitch:1];
        _newOpus = YES;
    }
    
    return self;
}

- (id)initWithOpus:(SingOpus *)opus{
    if (self = [super init]) {
        self.singOpus = opus;
        _newOpus = NO;
    }
    
    return self;
}

- (void)initSelectedButton{
    switch (_singOpus.pbOpus.sing.voiceType) {
        case PBVoiceTypeVoiceTypeOrigin:
            self.selectedButton = _originButton;
            break;
            
        case PBVoiceTypeVoiceTypeTomCat:
            self.selectedButton = _tomCatButton;
            break;
        case PBVoiceTypeVoiceTypeDuck:
            self.selectedButton = _duckButton;
            break;
        case PBVoiceTypeVoiceTypeMale:
            self.selectedButton = _maleButton;
            break;
        case PBVoiceTypeVoiceTypeChild:
            self.selectedButton = _childButton;
            break;
        case PBVoiceTypeVoiceTypeFemale:
            self.selectedButton = _femaleButton;
            break;
            
        default:
            break;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    [self initSelectedButton];
    
    NSString *name = _singOpus.pbOpus.sing.song.name;
    NSString *author = _singOpus.pbOpus.sing.song.author;
    NSString *lyric = _singOpus.pbOpus.sing.song.lyric;
    NSString *image = _singOpus.pbOpus.image;
    
    self.songNameLabel.text = name;
    self.songAuthorLabel.text = author;
    self.songNameLabel1.text = name;
    self.songAuthorLabel1.text = author;
    self.lyricTextView.text = lyric;
    
    _recordLimitTime = 30;
    
    NSURL *url = [NSURL URLWithString:image];
    [_opusImageButton setImageWithURL:url placeholderImage:nil];
    
    NSString *recordPath = [NSString stringWithFormat:@"%@.m4a", _singOpus.pbOpus.opusId];
    self.recordURL = [FileUtil fileURLInAppDocument:recordPath];
    self.playURL = _recordURL;
    
    if (_newOpus) {
        [self prepareToRecord];
        [self setState:StateReadyRecord];
    }else{
        [self prepareToPlay];
        [self setState:StateReadyPlay];
    }
    
    [self showMainView];
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
    [self setSongNameLabel:nil];
    [self setSongNameLabel1:nil];
    [self setSongAuthorLabel:nil];
    [self setSongAuthorLabel1:nil];
    [self setLyricTextView:nil];
    [self setOriginButton:nil];
    [self setTagButton:nil];
    [self setTomCatButton:nil];
    [self setDuckButton:nil];
    [self setMaleButton:nil];
    [self setFemaleButton:nil];
    [self setChildButton:nil];
    [self setOpusMainView:nil];
    [self setOpusReview:nil];
    [self setOpusImageButton:nil];
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

- (void)recorder:(VoiceRecorder *)recorder didChangeRecordState:(VoiceRecorderState)recordState{
    
    // prepare to play
    if (recordState == VoiceRecorderStateStopped) {
        [self prepareToPlay];
        [self setState:StateReadyPlay];
    }
}

- (void)recorder:(VoiceRecorder *)recorder recordTime:(CGFloat)recordTime{
    NSTimeInterval leftTime =  recorder.duration -  recordTime;
    [self updateUITime:@(leftTime)];
}


- (void)reset{
    _recorder.delegate = nil;
    _player.delegate = nil;
    [self stopRecord];
    [self stopPlay];
}

- (IBAction)clickRerecordButton:(id)sender {

    __block typeof(self) bself = self;
    
    MKBlockAlertView *v = [[[MKBlockAlertView alloc] initWithTitle:NSLS(@"kGifTips") message:NSLS(@"kRerecordWarnning") delegate:nil cancelButtonTitle:NSLS(@"kCancel") otherButtonTitles:NSLS(@"kOk"), nil] autorelease];
    
    [v show];
    
    [v setActionBlock:^(NSInteger buttonIndex){
        if (buttonIndex == 1) {
            [bself reset];
            [bself prepareToRecord];
            [bself setState:StateReadyRecord];
        }
    }];
}

- (void)prepareToRecord{
    if (_recorder == nil) {
        self.recorder = [[[VoiceRecorder alloc] init] autorelease];
    }
    _recorder.delegate = self;
    [_recorder prepareToRecord:_recordURL];
}

- (void)record {
    [_recorder startToRecordForDutaion:_recordLimitTime];
}

- (void)stopRecord{
    // stop record
    [_recorder stopRecording];
}

- (void)prepareToPlay{
    if (_player == nil) {
        self.player = [[[VoiceChanger alloc] init] autorelease];
    }
    _player.delegate = self;
    [_player prepareToPlay:_playURL];
}

- (void)play{
    float duration = _singOpus.pbOpus.sing.duration;
    float pitch = _singOpus.pbOpus.sing.pitch;
    float formant = _singOpus.pbOpus.sing.formant;
    
    [_player startPlayingWithDuration:duration pitch:pitch formant:formant];
}

- (void)pausePlay{
    [_player pausePlaying];
}

- (void)stopPlay{
    [_player stopPlaying];
}

- (void)diracPlayerDidFinishPlaying:(DiracAudioPlayerBase *)player successfully:(BOOL)flag{
    
    NSLog(@"diracPlayerDidFinishPlaying : %@", flag ? @"YES" : @"NO");

    
    // kill timer
    [timer invalidate];
    self.timer = nil;
    
    // prepare to play
    
    [self updateUITime:@(_fileDuration)];
    [self prepareToPlay];
    [self setState:StateReadyPlay];
}

- (void) mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (IBAction)clickControlButton:(id)sender {
    switch (_state) {
        case StateReadyRecord:
            [self setState:StateRecording];
            [self record];
            break;
            
        case StateRecording:
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
    self.addTimeButton.hidden = NO;
    self.saveButton.hidden = YES;
    self.submitButton.hidden = NO;
    self.submitButton.enabled = NO;
    
    [self updateUITime:@(_recordLimitTime)];
}

- (void)uiRecording{
    self.micImageView.hidden = YES;
    self.timeLabel.hidden = NO;
    self.playImageView.hidden = YES;
    self.pauseImageView.hidden = YES;
    
    self.rerecordButton.hidden = YES;
    self.addTimeButton.hidden = YES;
    self.saveButton.hidden = YES;
    self.submitButton.hidden = YES;
    self.submitButton.enabled = YES;
    
    [self updateUITime:@(_recordLimitTime)];
}

- (void)uiReadyPlay{
    self.micImageView.hidden = YES;
    self.timeLabel.hidden = NO;
    self.playImageView.hidden = NO;
    self.pauseImageView.hidden = YES;
    
    self.rerecordButton.hidden = NO;
    self.addTimeButton.hidden = NO;
    self.saveButton.hidden = NO;
    self.submitButton.hidden = NO;
}

- (void)uiPlaying{
    self.micImageView.hidden = YES;
    self.timeLabel.hidden = NO;
    self.playImageView.hidden = YES;
    self.pauseImageView.hidden = NO;
    
    self.rerecordButton.hidden = YES;
    self.addTimeButton.hidden = YES;
    self.saveButton.hidden = YES;
    self.submitButton.hidden = YES;
    self.submitButton.enabled = YES;
}

- (void)updateUITime:(NSNumber *)time{

    if (time.intValue < 0 || time.intValue > 999) {
        return;
    }
    
    int min = time.intValue / 60;
    int sec = time.intValue % 60;
    
    self.timeLabel.text = [NSString stringWithFormat:@"%02d:%02d", min, sec];
}

- (void)changeVoiceType:(PBVoiceType)voiceType{
    
    [_singOpus setVoiceType:voiceType];
    
    switch (voiceType) {
        case PBVoiceTypeVoiceTypeOrigin:
            [self changeDuration:1 pitch:1 formant:1];
            break;
            
        case PBVoiceTypeVoiceTypeTomCat:
            [self changeDuration:0.5 pitch:1.f/0.5 formant:1];

            break;
            
        case PBVoiceTypeVoiceTypeDuck:
            [self changeDuration:0.5 pitch:1.f/0.5 formant:1];

            break;
            
        case PBVoiceTypeVoiceTypeMale:
            [self changeDuration:1 pitch:0.8 formant:0.5];
            break;
            
        case PBVoiceTypeVoiceTypeChild:
            [self changeDuration:0.5 pitch:1.f/0.5 formant:1];

            break;
            
        case PBVoiceTypeVoiceTypeFemale:
            [self changeDuration:1 pitch:1.2 formant:1];
            break;
            
        default:
            break;
    }
}

- (void)changeDuration:(CGFloat)duration pitch:(CGFloat)pitch formant:(CGFloat)formant{
    [_singOpus setDuration:duration];
    [_singOpus setPitch:pitch];
    [_singOpus setFormant:formant];

    [_player changeDuration:duration pitch:pitch formant:formant];
}

- (IBAction)clickOriginButton:(id)sender {
    self.selectedButton = (UIButton *)sender;
    [self changeVoiceType:PBVoiceTypeVoiceTypeOrigin];
}

- (IBAction)clickTomCatButton:(id)sender {
    self.selectedButton = (UIButton *)sender;
    [self changeVoiceType:PBVoiceTypeVoiceTypeTomCat];
}

- (IBAction)clickDuckButton:(id)sender {
    self.selectedButton = (UIButton *)sender;
    [self changeVoiceType:PBVoiceTypeVoiceTypeDuck];
}

- (IBAction)clickMaleButton:(id)sender {
    self.selectedButton = (UIButton *)sender;
    [self changeVoiceType:PBVoiceTypeVoiceTypeMale];
}

- (IBAction)clickChildButton:(id)sender {
    self.selectedButton = (UIButton *)sender;
    [self changeVoiceType:PBVoiceTypeVoiceTypeChild];
}

- (IBAction)clickFemaleButton:(id)sender {
    self.selectedButton = (UIButton *)sender;
    [self changeVoiceType:PBVoiceTypeVoiceTypeFemale];
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
//    self.image = image;
    
    [_opusImageButton setImage:image forState:UIControlStateNormal];
//    [_opusImageView setImageWithURL:url placeholderImage:nil];
}

- (IBAction)clickBackButton:(id)sender {

    [self stopRecord];
    [self pausePlay];
    _recorder.delegate = nil;
    _player.delegate = nil;
    _player.progressDelegate = nil;
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickSaveButton:(id)sender {
    [[OpusManager singOpusManager] saveOpus:_singOpus];
}

- (IBAction)clickSubmitButton:(id)sender {
    
//    NSString *path = _recordURL.path;
//    PPDebug(@"path is %@", path);
//    
//    NSData *singData = [NSData dataWithContentsOfFile:path];
//    if (singData == nil) {
//        return;
//    }
//    
//    [[OpusService defaultService] submitOpus:_singOpus
//                                       image:_image
//                                    opusData:singData
//                                 opusManager:[OpusManager singOpusManager]
//                            progressDelegate:nil
//                                    delegate:self];
    
    NSURL *inUrl = _recordURL.path;
	NSURL *outUrl = [FileUtil fileURLInAppDocument:@"out.aif"];
    
    _player.progressDelegate = self;
    [_player processVoice:inUrl outURL:outUrl duration:0.5 pitch:2 formant:1];
}

- (void)setProgress:(float)process{
    PPDebug(@"process = %f", process);
}

- (void)processDone:(NSURL *)outURL{
    
    NSString *path = outURL.path;
    PPDebug(@"path is %@", path);

    NSData *singData = [NSData dataWithContentsOfFile:path];
    if (singData == nil) {
        return;
    }

    [[OpusService defaultService] submitOpus:_singOpus
                                       image:_image
                                    opusData:singData
                                 opusManager:[OpusManager singOpusManager]
                            progressDelegate:nil
                                    delegate:self];
}

- (void)didSubmitOpus:(int)resultCode opus:(Opus *)opus{
    
    if (resultCode == ERROR_SUCCESS) {
        [self popupMessage:@"成功" title:nil];
    }else{
        [self popupMessage:@"失败" title:nil];
    }
}

- (IBAction)clickReviewButton:(id)sender {
    
    [self showReView];
    
}

- (IBAction)clickOpusImageButton:(id)sender {
    [self showMainView];
}

- (void)showMainView{
    self.opusMainView.hidden = NO;
    self.opusReview.hidden = YES;
}

- (void)showReView{
    self.opusMainView.hidden = YES;
    self.opusReview.hidden = NO;
}

- (void)voiceChanger:(VoiceChanger *)voiceChanger didGetFileDuration:(double)fileDuration{
    _fileDuration = fileDuration + 0.5;
    [self updateUITime:@(_fileDuration)];
}

- (void)voiceChanger:(VoiceChanger *)voiceChanger didChangePlayState:(VoiceChangerState)playState{
    
    switch (playState) {
        case VoiceChangerStateError:
            PPDebug(@"Something error happen!");
            break;
            
        case VoiceChangerStateEnded:
            [self updateUITime:@(_fileDuration)];
            [self prepareToPlay];
            [self setState:StateReadyPlay];
            break;
            
        default:
            break;
    }
}

- (void)voiceChanger:(VoiceChanger *)voiceChanger
            playTime:(CGFloat)playTime
        fileDuration:(double)fileDuration{
    
    NSTimeInterval leftTime = fileDuration - playTime;
    PPDebug(@"play currentTime = %f", playTime);
    PPDebug(@"play leftTime = %f", leftTime);
    [self updateUITime:@(leftTime)];
}

@end
