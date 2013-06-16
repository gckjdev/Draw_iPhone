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
@property (retain, nonatomic) VoiceRecorder *recorder;
@property (retain, nonatomic) VoiceChanger *player;
@property (retain, nonatomic) VoiceProcessor *processor;

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
    [_recorder release];
    [_player release];
    [_processor release];
    
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

- (NSURL*)recordURL
{
    return [_singOpus localNativeDataURL];
}

- (NSURL*)playURL
{
    return [_singOpus localNativeDataURL];
}

- (NSURL*)finalOpusURL
{
    return [_singOpus localDataURL];
}

- (id)initWithSong:(PBSong *)song{
    if (self = [super init]) {
        self.singOpus = [[OpusManager singOpusManager] createDraftSingOpus:song];      
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
    if (recordState == VoiceRecorderStateStopped || recordState == VoiceChangerStateEnded) {
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
    _processor.delegate = nil;
    [self stopRecord];
    [self stopPlay];
}

- (IBAction)clickRerecordButton:(id)sender {

    __block typeof(self) bself = self;
    
    MKBlockAlertView *v = [[[MKBlockAlertView alloc] initWithTitle:NSLS(@"kGifTips") message:NSLS(@"kRerecordWarnning") delegate:nil cancelButtonTitle:NSLS(@"kCancel") otherButtonTitles:NSLS(@"kOK"), nil] autorelease];
    
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
    [_recorder prepareToRecord:[self recordURL]];
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
    [_player prepareToPlay:[self playURL]];
    [_player changeDuration:_singOpus.pbOpus.sing.duration
                      pitch:_singOpus.pbOpus.sing.pitch
                    formant:_singOpus.pbOpus.sing.formant];
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

- (void)changeVoiceType:(PBVoiceType)type{
    [_singOpus setVoiceType:type];
    [_player changeDuration:_singOpus.pbOpus.sing.duration
                      pitch:_singOpus.pbOpus.sing.pitch
                    formant:_singOpus.pbOpus.sing.formant];
}

- (IBAction)clickVoiceTypeButton:(id)sender {
    self.selectedButton = (UIButton *)sender;
    [self changeVoiceType:self.selectedButton.tag];
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
    [_opusImageButton setImage:image forState:UIControlStateNormal];
}

- (IBAction)clickBackButton:(id)sender {

    [self stopRecord];
    [self pausePlay];
    _recorder.delegate = nil;
    _player.delegate = nil;
    _processor.delegate = nil;
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickSaveButton:(id)sender {
    [[OpusManager singOpusManager] saveOpus:_singOpus];
}

- (IBAction)clickSubmitButton:(id)sender {

    NSURL *inUrl = [self recordURL];
	NSURL *outUrl = [self finalOpusURL];

    if (_processor == nil) {
        self.processor = [[[VoiceProcessor alloc] init] autorelease];
        _processor.delegate = self;
    }
    
    [_processor processVoice:inUrl outURL:outUrl duration:_singOpus.pbOpus.sing.duration pitch:_singOpus.pbOpus.sing.pitch formant:_singOpus.pbOpus.sing.formant];
    
    
    [self showProgressViewWithMessage:NSLS(@"kSending")];
}

- (void)processor:(VoiceProcessor *)processor progress:(float)progress{
    PPDebug(@"progress = %f", progress);
    
    NSString* progressText = [NSString stringWithFormat:NSLS(@"kSendingProgress"), progress*100];
    [self.progressView setLabelText:progressText];
    
    [self.progressView setProgress:progress];
}

- (void)processor:(VoiceProcessor *)processor doneWithOutURL:(NSURL*)outURL{
    
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
    
    [self hideProgressView];

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
