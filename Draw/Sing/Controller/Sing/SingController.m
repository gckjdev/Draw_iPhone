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
#import "UserManager.h"
#import "UITextView+WebCache.h"
#import "SingImageManager.h"
#import "CommonDialog.h"
#import "CommonTitleView.h"
#import "UIImageView+WebCache.h"
#import "UIViewUtils.h"
//#import "NameAndDescEditView.h"
#import "UILabel+Extend.h"
#import "VoiceTypeSelectView.h"
#import "ImagePlayer.h"
#import "StorageManager.h"
#import "UIImageExt.h"
#import "SingInfoEditController.h"
#import "MKBlockActionSheet.h"
#import "CMPopTipView.h"
#import "SongSearchController.h"
#import "PPConfigManager.h"

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
    BOOL _isDraft;
}
@property (retain, nonatomic) SingOpus *singOpus;
@property (retain, nonatomic) VoiceRecorder *recorder;
@property (retain, nonatomic) VoiceChanger *player;
@property (retain, nonatomic) VoiceProcessor *processor;
@property (copy, nonatomic) UIImage *image;
@property (retain, nonatomic) ChangeAvatar *picker;
@property (retain, nonatomic) CMPopTipView *popTipView;

@end

@implementation SingController

- (void)dealloc{
    [_picker release];
    [_image release];
    [_singOpus release];
    [_recorder release];
    [_player release];
    [_processor release];
    [_popTipView release];
    
    [_micImageView release];
    [_timeLabel release];
    [_playImageView release];
    [_pauseImageView release];
    [_rerecordButton release];
    [_saveButton release];
    [_opusImageView release];
    [_opusDescLabel release];
    
    [_lyricTextView release];
    [_voiceButton release];
    [_searchSongButton release];
    [_descButton release];
    [_submitButton release];
    [_imageButton release];
    [_reviewButton release];
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

//- (id)initWithSong:(PBSong *)song{
//    if (self = [super init]) {
//        self.singOpus = [[[OpusService defaultService] singDraftOpusManager] createDraftSingOpus:song];
//        _newOpus = YES;
//    }
//    
//    return self;
//}

//- (id)initWithName:(NSString *)name{
//    if (self = [super init]) {
//        self.singOpus = [[[OpusService defaultService] singDraftOpusManager] createDraftSingOpusWithSelfDefineName:name];
//        _newOpus = YES;
//    }
//    
//    return self;
//}

- (id)init{
    
    if (self = [super init]) {
        self.singOpus = (SingOpus *)[[[OpusService defaultService] draftOpusManager] createDraftWithName:@"小吉话话"];
    }

    return self;
}

- (id)initWithOpus:(SingOpus *)opus{
    if (self = [super init]) {
        self.singOpus = opus;
        _isDraft = YES;
    }
    
    return self;
}

#define TAG_TITLE_VIEW 201311061604
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // init title view
    CommonTitleView *titleView = [CommonTitleView createTitleView:self.view];
    [titleView setTitle:self.singOpus.name];
    [titleView setTarget:self];
    [titleView setBackButtonSelector:@selector(clickBackButton:)];
    titleView.tag = TAG_TITLE_VIEW;
    [self.view sendSubviewToBack:titleView];
//    [titleView setRightButtonTitle:NSLS(@"kSubmit")];
//    [titleView setRightButtonSelector:@selector(clickSubmitButton:)];
    
    self.reviewButton.hidden = YES;
    
    
    [self.opusImageView.layer setCornerRadius:35];
    [self.opusImageView.layer setMasksToBounds:YES];

    self.image = [UIImage imageWithContentsOfFile:_singOpus.pbOpus.localImageUrl];
    if (self.image !=nil ) {
        [self.opusImageView setImage:self.image];
        [self.imageButton setImage:nil forState:UIControlStateNormal];
    }
    
//    [self.opusImageView addTapGuestureWithTarget:self selector:@selector(clickImageButton:)];
    [ShareImageManager setFXLabelStyle:self.opusDescLabel];
    self.opusDescLabel.text = self.singOpus.pbOpus.desc;
    
    self.lyricTextView.editable = NO;
    self.lyricTextView.text = self.singOpus.pbOpus.sing.song.lyric;
    self.lyricTextView.hidden = YES;
    self.lyricTextView.textColor = COLOR_BROWN;
    
    _recordLimitTime = [PPConfigManager getRecordLimitTime];

    if (_isDraft) {
        [self prepareToPlay];
        [self setState:StateReadyPlay];
    }else{
        [self prepareToRecord];
        [self setState:StateReadyRecord];
    }
    
    __block typeof (self) bself = self;
    [bself registerNotificationWithName:KEY_NOTIFICATION_SELECT_SONG usingBlock:^(NSNotification *note) {
        
        [((CommonTitleView*)[bself.view viewWithTag:TAG_TITLE_VIEW]) setTitle:bself.singOpus.name];
        bself.lyricTextView.text = bself.singOpus.pbOpus.sing.song.lyric;
        bself.lyricTextView.hidden = NO;
        bself.opusDescLabel.hidden = YES;
        bself.imageButton.hidden = YES;
        bself.opusImageView.hidden = YES;
        bself.reviewButton.hidden = NO;
    }];
    
    [bself registerNotificationWithName:KEY_NOTIFICATION_SING_INFO_CHANGE usingBlock:^(NSNotification *note) {
        
        [((CommonTitleView*)[bself.view viewWithTag:TAG_TITLE_VIEW]) setTitle:bself.singOpus.name];
        bself.opusDescLabel.text = bself.singOpus.pbOpus.desc;
        bself.lyricTextView.hidden = YES;
        bself.opusDescLabel.hidden = NO;
        bself.imageButton.hidden = NO;
        bself.opusImageView.hidden = NO;
    }];
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
    [self setSaveButton:nil];
    [self setOpusImageView:nil];
    [self setOpusDescLabel:nil];
    [self setLyricTextView:nil];
    [self setVoiceButton:nil];
    [self setSearchSongButton:nil];
    [self setDescButton:nil];
    [self setSubmitButton:nil];
    [self setImageButton:nil];
    [self setReviewButton:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kGifTips") message:NSLS(@"kRerecordWarnning") style:CommonDialogStyleDoubleButton];
    
    [dialog showInView:self.view];
    
    [dialog setClickOkBlock:^(id view){
        [self reset];
        [self prepareToRecord];
        [self setState:StateReadyRecord];
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
            [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
            break;
            
        case StateRecording:
            [self setState:StateReadyPlay];
            [self stopRecord];
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
            break;
            
        case StateReadyPlay:
            [self setState:StatePlaying];
            [self play];
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
            break;
            
        case StatePlaying:
            [self setState:StateReadyPlay];
            [self pausePlay];
            [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
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
    self.saveButton.hidden = YES;
    self.searchSongButton.hidden = NO;
    self.voiceButton.hidden = YES;
    self.descButton.hidden = NO;
    self.submitButton.hidden = YES;
    
    [self updateUITime:@(_recordLimitTime)];
}

- (void)uiRecording{
    self.micImageView.hidden = YES;
    self.timeLabel.hidden = NO;
    self.playImageView.hidden = YES;
    self.pauseImageView.hidden = YES;
    
    self.rerecordButton.hidden = YES;
    self.saveButton.hidden = YES;
    self.searchSongButton.hidden = YES;
    self.voiceButton.hidden = YES;
    self.descButton.hidden = YES;
    self.submitButton.hidden = YES;
    
    
    [self updateUITime:@(_recordLimitTime)];
}

- (void)uiReadyPlay{
    self.micImageView.hidden = YES;
    self.timeLabel.hidden = NO;
    self.playImageView.hidden = NO;
    self.pauseImageView.hidden = YES;
    
    self.rerecordButton.hidden = NO;
    self.saveButton.hidden = NO;
    self.searchSongButton.hidden = NO;
    self.voiceButton.hidden = NO;
    self.descButton.hidden = NO;
    self.submitButton.hidden = NO;
}

- (void)uiPlaying{
    self.micImageView.hidden = YES;
    self.timeLabel.hidden = NO;
    self.playImageView.hidden = YES;
    self.pauseImageView.hidden = NO;
    
    self.rerecordButton.hidden = YES;
    self.saveButton.hidden = YES;
    self.searchSongButton.hidden = YES;
    self.voiceButton.hidden = YES;
    self.descButton.hidden = YES;
    self.submitButton.hidden = YES;
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

- (IBAction)clickDescButton:(id)sender {

    PPDebug(@"clickDescButton");
    
    SingInfoEditController *vc = [[[SingInfoEditController alloc] initWithOpus:self.singOpus] autorelease];
    [self presentViewController:vc animated:YES completion:NULL];
}

- (IBAction)clickAddTimeButton:(id)sender {
    
    [[UserManager defaultManager] setSingLimitTime:(_recordLimitTime + 15)];
    _recordLimitTime = [[[UserManager defaultManager] pbUser] singRecordLimit];
}

- (IBAction)clickChangeVoiceButton:(UIButton *)button {
    
    if (self.popTipView == nil) {
        VoiceTypeSelectView *v = [VoiceTypeSelectView createWithVoiceType:_singOpus.pbOpus.sing.voiceType];
        v.delegate = self;
        self.popTipView = [[[CMPopTipView alloc] initWithCustomView:v needBubblePath:NO] autorelease];
        [self.popTipView setBackgroundColor:COLOR_ORANGE];
        self.popTipView.cornerRadius = 4;
        self.popTipView.pointerSize = 6;
    }
    
    [self.popTipView presentPointingAtView:button inView:self.view animated:YES];
}

- (void)didSelectVoiceType:(PBVoiceType)voiceType{
    
    [self changeVoiceType:voiceType];
    [self.popTipView dismissAnimated:YES];
}

- (IBAction)clickImageButton:(id)sender {
    if (_picker == nil) {
        self.picker = [[[ChangeAvatar alloc] init] autorelease];
        _picker.autoRoundRect = NO;
    }
    
    [_picker showSelectionView:self];
}

- (void)didImageSelected:(UIImage*)image{
    
    if (image != nil) {
        PPDebug(@"image size = %@", NSStringFromCGSize(image.size));
        if (image.size.width != image.size.height) {
            POSTMSG2(NSLS(@"kImageMustBeSquare"), 2);
            return;
        }
        
        self.image = image;
        self.opusImageView.image = image;
        self.opusImageView.contentMode = UIViewContentModeScaleAspectFit;
        NSData *data = [self.image data];
        NSString *path = self.singOpus.pbOpus.localImageUrl;
        [data writeToFile:path atomically:YES];
        
        [self.imageButton setImage:nil forState:UIControlStateNormal];
    }
}

- (IBAction)clickBackButton:(id)sender {

    [self stopRecord];
    [self pausePlay];
    _recorder.delegate = nil;
    _player.delegate = nil;
    _processor.delegate = nil;
    [self unregisterNotificationWithName:KEY_NOTIFICATION_SELECT_SONG];
    [self unregisterNotificationWithName:KEY_NOTIFICATION_SING_INFO_CHANGE];

    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)clickSaveButton:(id)sender {
    [self showActivityWithText:NSLS(@"kSaving")];
    [_singOpus setIsRecovery:YES];
    [[[OpusService defaultService] draftOpusManager] saveOpus:_singOpus];
    [self hideActivity];
    [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kSaved") delayTime:1.5];
}

- (IBAction)clickSubmitButton:(id)sender {
    
    if (self.image == nil) {
        CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kGifTips") message:NSLS(@"kAskForSelectPhoto") style:CommonDialogStyleDoubleButton];
        [dialog showInView:self.view];
        
        [dialog setClickOkBlock:^(id view){
           
            [self clickImageButton:self.imageButton];
        }];
        
        return;
    }
    
    // 用户如果选择原声，则不需要经过声音处理步骤，直接上传。
    if (_singOpus.pbOpus.sing.voiceType == PBVoiceTypeVoiceTypeOrigin) {
        
        NSString *path = [self recordURL].path;
        PPDebug(@"path is %@", path);

        NSData *singData = [NSData dataWithContentsOfFile:path];
        if (singData == nil) {
            return;
        }

        [self setProgress:0];
        [[OpusService defaultService] submitOpus:_singOpus
                                           image:_image
                                        opusData:singData
                                progressDelegate:self
                                        delegate:self];
    }else{
        
        NSURL *inUrl = [self recordURL];
        NSURL *outUrl = [self finalOpusURL];
        
        if (_processor == nil) {
            self.processor = [[[VoiceProcessor alloc] init] autorelease];
            _processor.delegate = self;
        }
        
        [_processor processVoice:inUrl outURL:outUrl duration:_singOpus.pbOpus.sing.duration pitch:_singOpus.pbOpus.sing.pitch formant:_singOpus.pbOpus.sing.formant];
        
        [self showProgressViewWithMessage:NSLS(@"kSending")];
    }
}

- (void)processor:(VoiceProcessor *)processor progress:(float)progress{
    PPDebug(@"progress = %f", progress);
    
    NSString* progressText = [NSString stringWithFormat:NSLS(@"kHandlingDataProgress"), progress*100];
    [self showProgressViewWithMessage:progressText progress:progress];
}

- (void)processor:(VoiceProcessor *)processor doneWithOutURL:(NSURL*)outURL{
    
    NSString *path = outURL.path;
    PPDebug(@"path is %@", path);
    
    NSData *singData = [NSData dataWithContentsOfFile:path];
    if (singData == nil) {
        return;
    }
    
    [self setProgress:0];
    [[OpusService defaultService] submitOpus:_singOpus
                                       image:_image
                                    opusData:singData
                            progressDelegate:self
                                    delegate:self];
}

- (void)setProgress:(float)progress{
    
    NSString* progressText = [NSString stringWithFormat:NSLS(@"kSendingProgress"), progress*100];
    [self showProgressViewWithMessage:progressText progress:progress];
}

- (void)didSubmitOpus:(int)resultCode opus:(Opus *)opus{
    
    [self hideProgressView];

    if (resultCode == ERROR_SUCCESS) {
        POSTMSG(NSLS(@"kSubmitSuccTitle"));
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        POSTMSG(NSLS(@"kSubmitFailure"));
    }
}

- (IBAction)clickReviewButton:(UIButton *)button {

    self.lyricTextView.hidden = !self.lyricTextView.hidden;
    self.opusDescLabel.hidden = !self.opusDescLabel.hidden;
    self.imageButton.hidden = !self.imageButton.hidden;
    self.opusImageView.hidden = !self.opusImageView.hidden;
    button.selected = !button.selected;
}

- (IBAction)clickSearchSongButton:(id)sender {
    
    SongSearchController *vc = [[[SongSearchController alloc] initWithSingOpus:self.singOpus] autorelease];
    [self presentViewController:vc animated:YES completion:NULL];
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
