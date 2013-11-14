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
#import "UIImageUtil.h"
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
#import "DrawColor.h"
#import "DrawUtils.h"


#define GREEN_COLOR [UIColor colorWithRed:99/255.0 green:186/255.0 blue:152/255.0 alpha:1]
#define WHITE_COLOR [UIColor whiteColor]

enum{
    StateReadyRecord = 0,
    StateRecording = 1,
    StateReadyPlay = 2,
    StatePlaying = 3
};

@interface SingController ()<UIGestureRecognizerDelegate>{
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

- (id)init{
    
    if (self = [super init]) {
        self.singOpus = (SingOpus *)[[[OpusService defaultService] draftOpusManager] createDraftWithName:[PPConfigManager getSingOpusDefaultName]];
        [self.singOpus setTargetUser:nil];
    }

    return self;
}

- (id)initWithTargetUser:(PBGameUser *)targetUser{
    
    if (self = [super init]) {
        self.singOpus = (SingOpus *)[[[OpusService defaultService] draftOpusManager] createDraftWithName:[PPConfigManager getSingOpusDefaultName]];
        [self.singOpus setTargetUser:targetUser];
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
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    PPDebug(@"image view frame = %@", NSStringFromCGRect(self.opusImageView.frame));
    PPDebug(@"label view frame = %@", NSStringFromCGRect(self.opusDescLabel.frame));
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setCanDragBack:NO];
    
    // init title view
    [self initTitleView];

    // init opus image view
    [self initOpusImageView];
    
    // int lyric text view
    [self initLyricTextView];
    
    self.reviewButton.hidden = YES;
     
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
        
        [bself updateDescLabelInfo:bself.singOpus.pbOpus.desc];
        bself.lyricTextView.hidden = YES;
        bself.opusDescLabel.hidden = NO;
        bself.imageButton.hidden = NO;
        bself.opusImageView.hidden = NO;
    }];
}

- (void)initTitleView{
    
    CommonTitleView *titleView = [CommonTitleView createTitleView:self.view];
    [titleView setTitle:self.singOpus.name];
    [titleView setTarget:self];
    [titleView setBackButtonSelector:@selector(clickBackButton:)];
    titleView.tag = TAG_TITLE_VIEW;
    [self.view sendSubviewToBack:titleView];
}

- (void)initOpusDescLabel{
    
    PBLabelInfo *labelInfo = self.singOpus.pbOpus.descLabelInfo;
    
    CGRect rect = CGRectMake(labelInfo.frame.x,
                             labelInfo.frame.y,
                             labelInfo.frame.width,
                             labelInfo.frame.height);
    
    self.opusDescLabel = [[[StrokeLabel alloc] initWithFrame:rect] autorelease];
    self.opusDescLabel.numberOfLines = 0;
    self.opusDescLabel.text = self.singOpus.pbOpus.desc;
    self.opusDescLabel.textAlignment = NSTextAlignmentCenter;
    self.opusDescLabel.backgroundColor = [UIColor clearColor];
    
    
    // set text color
    UIColor *textColor =  [[DrawColor colorWithBetterCompressColor:labelInfo.textColor] color];
    self.opusDescLabel.textColor = textColor;
    
    // set text font
    self.opusDescLabel.font = [UIFont systemFontOfSize:labelInfo.textFont];
    
    
    // set text stroke color
    UIColor *textStrokeColor = [[DrawColor colorWithBetterCompressColor:labelInfo.textStrokeColor] color];
    self.opusDescLabel.textOutlineColor = textStrokeColor;
    
    // set stroke width
    self.opusDescLabel.textOutlineWidth = (ISIPAD ? 2 : 1);

    // add label into opus image view
    [self.opusImageView addSubview:self.opusDescLabel];
    
    // enable user interaction
    self.opusImageView.userInteractionEnabled = YES;
    self.opusDescLabel.userInteractionEnabled = YES;
    
    // add pan guesture
    UIPanGestureRecognizer *panGestureRecognizer = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestures:)] autorelease];
    panGestureRecognizer.delegate = self;
    [self.opusDescLabel addGestureRecognizer:panGestureRecognizer];
    
    // add tap guesture
    UITapGestureRecognizer *tapGestureRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestures:)] autorelease];
    tapGestureRecognizer.delegate = self;
    [self.opusDescLabel addGestureRecognizer:tapGestureRecognizer];
}

#define TAG_IMAGE_HOLDER_VIEW 201324
- (void)initOpusImageView{
    
    [self.opusImageView.layer setCornerRadius:35];
    [self.opusImageView.layer setMasksToBounds:YES];
    
    [self.opusImageView updateWidth:self.singOpus.pbOpus.canvasSize.width];
    [self.opusImageView updateHeight:self.singOpus.pbOpus.canvasSize.height];
    PPDebug(@"size = %@", NSStringFromCGSize(self.opusImageView.frame.size));
    
    self.image = [UIImage imageWithContentsOfFile:_singOpus.pbOpus.localImageUrl];
    if (self.image !=nil ) {
        [self.opusImageView setImage:self.image];
    }else{
        [self addHolderView];
    }
    
    // init opus desc label
    [self initOpusDescLabel];
}

- (UIImageView *)addHolderView{
    
    CGFloat width = ISIPAD ? 146*2.18 : 146;
    UIImageView *iv = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, width)] autorelease];
    iv.image = [UIImage imageNamed:@"sing_image@2x.png"];
    iv.tag = TAG_IMAGE_HOLDER_VIEW;
    
    [self.opusImageView addSubview:iv];
    
    [iv updateCenterX:self.opusImageView.bounds.size.width/2];
    [iv updateCenterY:self.opusImageView.bounds.size.height/2];
    
    return iv;
}

- (void)removeHolderView{
    [[self.opusImageView viewWithTag:TAG_IMAGE_HOLDER_VIEW] removeFromSuperview];
}


- (void)initLyricTextView{
    
    self.lyricTextView.editable = NO;
    self.lyricTextView.text = self.singOpus.pbOpus.sing.song.lyric;
    self.lyricTextView.hidden = YES;
    self.lyricTextView.textColor = COLOR_BROWN;
    
    
    [self.lyricTextView addTapGuestureWithTarget:self selector:@selector(showImageAndDesc)];
}

- (IBAction)showImageAndDesc{
    
    self.lyricTextView.hidden = YES;
    self.opusDescLabel.hidden = NO;
    self.imageButton.hidden = NO;
    self.opusImageView.hidden = NO;
    self.reviewButton.selected = NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    return YES;
}

// 拖拽手势处理事件
- (void) handlePanGestures:(UIPanGestureRecognizer*)paramSender{
    
    if (paramSender.state != UIGestureRecognizerStateEnded && paramSender.state != UIGestureRecognizerStateFailed){
        
        // 获取手指在屏幕中的坐标
        CGPoint location = [paramSender locationInView:paramSender.view.superview];
        
        if (location.x < 0 || location.x > paramSender.view.superview.bounds.size.width) {
            return;
        }
        
        if (location.y < 0 || location.y > paramSender.view.superview.bounds.size.height) {
            return;
        }
        
        paramSender.view.center = location;// 重新设置视图的位置
        
    }else if (paramSender.state == UIGestureRecognizerStateEnded){
    
        [self saveDescLabelInfo];
    }
}

- (void) handleTapGestures:(UIPanGestureRecognizer*)paramSender{
    
    MKBlockActionSheet *sheet = [[[MKBlockActionSheet alloc] initWithTitle:NSLS(@"kOption") delegate:nil cancelButtonTitle:NSLS(@"kCancel") destructiveButtonTitle:nil otherButtonTitles:NSLS(@"kWhiteTextBlackStroke"), NSLS(@"kBlackTextWhiteStroke"), nil] autorelease];
    
    sheet.actionBlock = ^(NSInteger buttonIndex){
        
        if (buttonIndex == 0) {
            self.opusDescLabel.textColor = [[DrawColor whiteColor] color];
            self.opusDescLabel.textOutlineColor = [[DrawColor blackColor] color];
            [self saveDescLabelInfo];
        }else if (buttonIndex == 1){
            self.opusDescLabel.textColor = [[DrawColor blackColor] color];
            self.opusDescLabel.textOutlineColor = [[DrawColor whiteColor] color];
            [self saveDescLabelInfo];
        }
    };
    
    [sheet showInView:self.view];
}
    

- (void)saveDescLabelInfo{
    
    CGRect rect = self.opusDescLabel.frame;
    
    DrawColor *color = [[[DrawColor alloc] initWithColor:self.opusDescLabel.textColor] autorelease];
    NSUInteger textColor = [DrawUtils compressDrawColor8:color];
    
    color = [[[DrawColor alloc] initWithColor:self.opusDescLabel.textOutlineColor] autorelease];
    NSUInteger textStrokeColor = [DrawUtils compressDrawColor8:color];
    
    float fontSize = [[self.opusDescLabel font] pointSize];
    
    [self.singOpus setLabelInfoWithFrame:rect
                               textColor:textColor
                                textFont:fontSize
                                   style:0
                         textStrokeColor:textStrokeColor];
}


- (void)updateDescLabelInfo:(NSString *)desc{

    // adjust new size of desc label
    CGSize size = CGSizeMake(self.opusImageView.frame.size.width * 0.8, self.opusImageView.frame.size.height);
    self.opusDescLabel.text = desc;
    [self.opusDescLabel wrapTextWithConstrainedSize:size];
    [self.opusDescLabel updateWidth:self.opusImageView.frame.size.width * 0.8];
    
    // center desc label
    [self.opusDescLabel updateCenterX:self.opusImageView.frame.size.width/2];
    [self.opusDescLabel updateCenterY:self.opusImageView.frame.size.height/2];
    
    // save label info
    [self saveDescLabelInfo];
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

#define CENTER_X1_SEARCH_SONG_BUTTON (ISIPAD ? 66 : 30)
#define CENTER_X2_SEARCH_SONG_BUTTON (ISIPAD ? 121 : 55)

#define CENTER_X1_DESC_BUTTON (ISIPAD ? 627 : 288)
#define CENTER_X2_DESC_BUTTON (ISIPAD ? 572 : 263)


- (void)uiReadyRecord{
    self.micImageView.hidden = NO;
    self.timeLabel.hidden = YES;
    self.playImageView.hidden = YES;
    self.pauseImageView.hidden = YES;
    
    [UIView animateWithDuration:0.5 animations:^{
        
        self.rerecordButton.alpha = 0;
        self.voiceButton.alpha = 0;
        self.searchSongButton.alpha = 1;
        self.descButton.alpha = 1;
        
        [self.searchSongButton updateCenterX:CENTER_X2_SEARCH_SONG_BUTTON];
        [self.descButton updateCenterX:CENTER_X2_DESC_BUTTON];
    } completion:^(BOOL finished) {
        
        self.rerecordButton.hidden = YES;
        self.voiceButton.hidden = YES;
        self.searchSongButton.hidden = NO;
        self.descButton.hidden = NO;
    }];
    
    
    self.saveButton.hidden = YES;
    self.submitButton.hidden = YES;
    
    [self updateUITime:@(_recordLimitTime)];
}

- (void)uiRecording{
    self.micImageView.hidden = YES;
    self.timeLabel.hidden = NO;
    self.playImageView.hidden = YES;
    self.pauseImageView.hidden = YES;
    
    [UIView animateWithDuration:0.5 animations:^{
        
        self.rerecordButton.alpha = 0;
        self.voiceButton.alpha = 0;
        self.searchSongButton.alpha = 0;
        self.descButton.alpha = 0;
        
        [self.searchSongButton updateCenterX:CENTER_X1_SEARCH_SONG_BUTTON];
        [self.descButton updateCenterX:CENTER_X1_DESC_BUTTON];
    } completion:^(BOOL finished) {
        
        self.rerecordButton.hidden = YES;
        self.searchSongButton.hidden = YES;
        self.voiceButton.hidden = YES;
        self.descButton.hidden = YES;
    }];
    
    self.saveButton.hidden = YES;
    self.submitButton.hidden = YES;

    [self updateUITime:@(_recordLimitTime)];
}

- (void)uiReadyPlay{
    self.micImageView.hidden = YES;
    self.timeLabel.hidden = NO;
    self.playImageView.hidden = NO;
    self.pauseImageView.hidden = YES;
    

    
    [UIView animateWithDuration:0.5 animations:^{
        
        self.rerecordButton.alpha = 1;
        self.voiceButton.alpha = 1;
        self.searchSongButton.alpha = 1;
        self.descButton.alpha = 1;
        
        [self.searchSongButton updateCenterX:CENTER_X1_SEARCH_SONG_BUTTON];
        [self.descButton updateCenterX:CENTER_X1_DESC_BUTTON];
    } completion:^(BOOL finished) {
        
        self.rerecordButton.hidden = NO;
        self.searchSongButton.hidden = NO;
        self.voiceButton.hidden = NO;
        self.descButton.hidden = NO;
    }];
    
    self.saveButton.hidden = NO;
    self.submitButton.hidden = NO;
}

- (void)uiPlaying{
    self.micImageView.hidden = YES;
    self.timeLabel.hidden = NO;
    self.playImageView.hidden = YES;
    self.pauseImageView.hidden = NO;

    
    [UIView animateWithDuration:0.5 animations:^{
        
        self.rerecordButton.alpha = 0;
        self.voiceButton.alpha = 0;
        self.searchSongButton.alpha = 0;
        self.descButton.alpha = 0;
        
        [self.searchSongButton updateCenterX:CENTER_X1_SEARCH_SONG_BUTTON];
        [self.descButton updateCenterX:CENTER_X1_DESC_BUTTON];
    } completion:^(BOOL finished) {
        
        self.rerecordButton.hidden = YES;
        self.searchSongButton.hidden = YES;
        self.voiceButton.hidden = YES;
        self.descButton.hidden = YES;
    }];
    
    self.saveButton.hidden = YES;
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
//        if (image.size.width != image.size.height) {
//            POSTMSG2(NSLS(@"kImageMustBeSquare"), 2);
//            return;
//        }
        
        self.image = image;
        self.opusImageView.image = image;
        [self removeHolderView];
        self.opusImageView.contentMode = UIViewContentModeScaleAspectFit;
        NSData *data = [self.image data];
        NSString *path = self.singOpus.pbOpus.localImageUrl;
        [data writeToFile:path atomically:YES];
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
    
    // generate thumb image.
    UIImage *thumbImage = [self.opusImageView createSnapShotWithScale:0.5];
    [thumbImage saveImageToFile:self.singOpus.pbOpus.localThumbImageUrl];
//    [[thumbImage data] writeToFile:self.singOpus.pbOpus.localThumbImageUrl atomically:YES];
    
    // save opus.
    [[[OpusService defaultService] draftOpusManager] saveOpus:_singOpus];
    [self hideActivity];
    [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kSaved") delayTime:1.5];
}

- (IBAction)clickSubmitButton:(id)sender {
    
    if (self.image == nil) {
        CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kGifTips") message:NSLS(@"kAskForSelectPhoto") style:CommonDialogStyleDoubleButton];
        [dialog showInView:self.view];
        
        [dialog setClickOkBlock:^(id view){
           
            [self clickImageButton:nil];
        }];
        
        return;
    }
    
    // 用户如果选择原声，则不需要经过声音处理步骤，直接上传。
    if (_singOpus.pbOpus.sing.voiceType == PBVoiceTypeVoiceTypeOrigin) {
        
        NSString *path = [self recordURL].path;
        PPDebug(@"path is %@", path);

        NSData *singData = [NSData dataWithContentsOfFile:path];
        
        [self uploadSingOpus:singData];
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
    [self uploadSingOpus:singData];
}

- (void)uploadSingOpus:(NSData *)singData{
    
    if (singData == nil) {
        POSTMSG(@"没有录音数据，上传失败");
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
