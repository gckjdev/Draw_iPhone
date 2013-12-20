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
#import "AccountService.h"
#import "TaskManager.h"
#import "AccountManager.h"
#import "UIImageUtil.h"
#import "CropAndFilterViewController.h"
#import "UIView+Pan.h"
#import "AudioFormatConverter.h"
#import "InputAlertView.h"
#import "PPConfigManager.h"
#import "ContestManager.h"

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
@property (assign, nonatomic) BOOL hasEdited;
@property (copy, nonatomic) NSString *mp3FilePath;
@property (retain, nonatomic) Contest *contest;


@end

@implementation SingController

- (void)dealloc{
    [_contest release];
    [_mp3FilePath release];
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
    [_lyricBgImageView release];
    [_descTextView release];
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

- (void)loadOpusDesignTime
{
    [self.singOpus loadOpusDesignTime];
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
        
        if ([opus.pbOpus.contestId length] != 0) {
            self.contest = [[ContestManager defaultManager] ongoingContestById:opus.pbOpus.contestId];
        }
    }
    
    return self;
}

- (id)initWithContest:(Contest *)contest{

    if (self = [super init]) {
        self.singOpus = (SingOpus *)[[[OpusService defaultService] draftOpusManager] createDraftWithName:[PPConfigManager getSingOpusDefaultName]];
        [self.singOpus setAsContestOpus:contest.contestId];
        self.contest = contest;
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
    
    self.descTextView.placeholder = NSLS(@"kDescPlaceholder");
    
    self.mp3FilePath =[NSTemporaryDirectory() stringByAppendingFormat:@"%@.mp3", @"temp"];
    
    // init title view
    [self initTitleView];

    // init opus image view
    [self initOpusImageView];
    
    // int lyric text view
    [self initLyricTextView];
    
    self.reviewButton.hidden = YES;
     
    _recordLimitTime = [PPConfigManager getRecordLimitTime];

    [self loadOpusDesignTime];
    
    if ([self.singOpus hasFileForPlay]) {
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
        self.lyricBgImageView.hidden = NO;

        bself.opusDescLabel.hidden = YES;
        bself.imageButton.hidden = YES;
        bself.opusImageView.hidden = YES;
        bself.reviewButton.hidden = NO;
        bself.reviewButton.selected = YES;
    }];
    
    [bself registerNotificationWithName:KEY_NOTIFICATION_SING_INFO_CHANGE usingBlock:^(NSNotification *note) {
        
        [((CommonTitleView*)[bself.view viewWithTag:TAG_TITLE_VIEW]) setTitle:bself.singOpus.name];
        
        [bself updateDescLabelInfo:bself.singOpus.pbOpus.desc];
        bself.lyricTextView.hidden = YES;
        self.lyricBgImageView.hidden = YES;
        bself.opusDescLabel.hidden = NO;
        bself.imageButton.hidden = NO;
        bself.opusImageView.hidden = NO;
        bself.hasEdited = YES;
    }];
}

- (void)initTitleView{
    
    CommonTitleView *titleView = [CommonTitleView createTitleView:self.view];
    [titleView setTitle:self.singOpus.name];
    [titleView setTarget:self];
    [titleView setBackButtonSelector:@selector(clickBackButton:)];
    [titleView setTitleLabelSelector:@selector(clickDescButton:)];
    titleView.tag = TAG_TITLE_VIEW;
    [self.view sendSubviewToBack:titleView];
}

- (void)initOpusDescLabel{
    
    PBLabelInfo *labelInfo = self.singOpus.pbOpus.descLabelInfo;    
    CGRect rect;
    if ([labelInfo hasFrame]) {
        rect = CGRectMake(labelInfo.frame.x,
                          labelInfo.frame.y,
                          labelInfo.frame.width,
                          labelInfo.frame.height);
    }else{
        rect = CGRectMake(self.opusImageView.frame.size.width * 0.1, self.opusImageView.frame.size.height * 0.5, 0, 0);
    }

    

    
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
    self.opusDescLabel.textOutlineWidth = (ISIPAD ? 4 : 2);

    // add label into opus image view
    [self.opusImageView addSubview:self.opusDescLabel];
    
    // enable user interaction
    self.opusImageView.userInteractionEnabled = YES;
    self.opusDescLabel.userInteractionEnabled = YES;
    
//    // add pan guesture
    UIPanGestureRecognizer *panGestureRecognizer = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestures:)] autorelease];
    panGestureRecognizer.delegate = self;
    [self.opusDescLabel addGestureRecognizer:panGestureRecognizer];
//    [self.opusDescLabel addPanToMoveFeature];
    
//    // add tap guesture
    UITapGestureRecognizer *tapGestureRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestures:)] autorelease];
    tapGestureRecognizer.delegate = self;
    [self.opusDescLabel addGestureRecognizer:tapGestureRecognizer];
}

#define TAG_IMAGE_HOLDER_VIEW 201324
- (void)initOpusImageView{
    
    [self.opusImageView.layer setCornerRadius:(ISIPAD ? 75 : 35)];
    [self.opusImageView.layer setMasksToBounds:YES];
    [self.opusImageView.layer setBorderWidth:(ISIPAD ? 8 : 4)];
    [self.opusImageView.layer setBorderColor:[COLOR_RED CGColor]];
    
    [self.opusImageView updateWidth:self.singOpus.pbOpus.canvasSize.width];
    [self.opusImageView updateHeight:self.singOpus.pbOpus.canvasSize.height];
    PPDebug(@"size = %@", NSStringFromCGSize(self.opusImageView.frame.size));
    
    self.image = [UIImage imageWithContentsOfFile:[_singOpus localImageURLString]];
    if (self.image !=nil ) {
        [self.opusImageView setImage:self.image];
    }else{
        [self addHolderView];
    }
    
    UIButton *button = [[[UIButton alloc] initWithFrame:self.opusImageView.bounds] autorelease];
    [button addTarget:self action:@selector(clickImageButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.opusImageView addSubview:button];
    
    // init opus desc label
    [self initOpusDescLabel];
}

- (UIImageView *)addHolderView{
    
//    CGFloat width = ISIPAD ? 146*2.18 : 146;
//    UIImageView *iv = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, width)] autorelease];
//    iv.image = [UIImage imageNamed:@"sing_image@2x.png"];
    
    CGRect rect = CGRectMake(0, 0, (ISIPAD ? 360:170), (ISIPAD ? 360:170));
    UIImageView *iv = [[[UIImageView alloc] initWithFrame:rect] autorelease];
    iv.image = [UIImage imageNamed:@"unloadbg2@2x.png"];
    [iv.layer setCornerRadius:(ISIPAD ? 75 : 35)];
    [iv.layer setMasksToBounds:YES];
    
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
    
    
    [self.lyricBgImageView.layer setCornerRadius:(ISIPAD ? 75 : 35)];
    [self.lyricBgImageView.layer setMasksToBounds:YES];
    [self.lyricBgImageView.layer setBorderWidth:(ISIPAD ? 8 : 4)];
    [self.lyricBgImageView.layer setBorderColor:[COLOR_RED CGColor]];
    self.lyricBgImageView.hidden = YES;

    
    [self.lyricTextView addTapGuestureWithTarget:self selector:@selector(showImageAndDesc)];
}

- (IBAction)showImageAndDesc{
    
    self.lyricTextView.hidden = YES;
    self.lyricBgImageView.hidden = YES;
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
    
    if (paramSender.state == UIGestureRecognizerStateChanged) {
        
        [paramSender.view.layer setBorderWidth:(ISIPAD ? 4 : 2)];
        [paramSender.view.layer setBorderColor:[COLOR_GRAY CGColor]];
        
        CGPoint translatePoint = [paramSender translationInView:paramSender.view.superview];
        CGPoint center = paramSender.view.center;
        center.x += translatePoint.x;
        center.y += translatePoint.y;
        
        if (center.x < 0
            || center.y < 0
            || center.x > CGRectGetWidth(paramSender.view.superview.frame)
            || center.y > CGRectGetHeight(paramSender.view.superview.frame)) {
            return;
        }
        
        paramSender.view.center = center;
        [paramSender setTranslation:CGPointMake(0, 0) inView:paramSender.view.superview];
        

    }
    
    
    if (paramSender.state == UIGestureRecognizerStateEnded) {
        [paramSender.view.layer setBorderWidth:0];
        [paramSender.view.layer setBorderColor:[[UIColor clearColor] CGColor]];
        [self saveDescLabelInfo];
    }
}

- (void) handleTapGestures:(UIPanGestureRecognizer*)paramSender{
    
    MKBlockActionSheet *sheet = [[[MKBlockActionSheet alloc] initWithTitle:NSLS(@"kOption") delegate:nil cancelButtonTitle:NSLS(@"kCancel") destructiveButtonTitle:nil otherButtonTitles:NSLS(@"kWhiteTextBlackStroke"), NSLS(@"kBlackTextWhiteStroke"), NSLS(@"kEditDesc"),nil] autorelease];
    
    sheet.actionBlock = ^(NSInteger buttonIndex){
        
        if (buttonIndex == 0) {
            self.opusDescLabel.textColor = [[DrawColor whiteColor] color];
            self.opusDescLabel.textOutlineColor = [[DrawColor blackColor] color];
            [self saveDescLabelInfo];
        }else if (buttonIndex == 1){
            self.opusDescLabel.textColor = [[DrawColor blackColor] color];
            self.opusDescLabel.textOutlineColor = [[DrawColor whiteColor] color];
            [self saveDescLabelInfo];
        }else if (buttonIndex == 2){
            
            [self clickDescButton:nil];
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
    [self setLyricBgImageView:nil];
    [self setDescTextView:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)recorder:(VoiceRecorder *)recorder didChangeRecordState:(VoiceRecorderState)recordState{
    
    // prepare to play
    if (recordState == VoiceRecorderStateStopped) {
        
        [self prepareToPlay];
        [self setState:StateReadyPlay];
    }
}

- (void)recorder:(VoiceRecorder *)recorder recordTime:(CGFloat)recordTime{
//    NSTimeInterval leftTime =  recorder.duration -  recordTime;
    NSTimeInterval leftTime = recordTime;
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
    
    PPDebug(@"record url = %@", _recorder.recordURL.path);
    [_recorder startToRecordForDutaion:_recordLimitTime];
    
    // accumulate design time
    [_singOpus.designTime start];
}

- (void)stopRecord{
    // stop record
    _hasEdited = YES;
    [_recorder stopRecording];
    
    // pause design time
    [_singOpus.designTime pause];
}

- (void)prepareToPlay{
    if (_player == nil) {
        VoiceChanger* vc = [[VoiceChanger alloc] init];
        self.player = vc;
        [vc release];
    }
    
    _player.delegate = self;
    [_player prepareToPlay:[self playURL]];
    [_player changeDuration:_singOpus.pbOpus.sing.duration
                      pitch:_singOpus.pbOpus.sing.pitch
                    formant:_singOpus.pbOpus.sing.formant];
}

- (void)play{
    
    PPDebug(@"play url = %@", _player.playURL.absoluteString);
    
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

- (IBAction)clickChangeVoiceButton:(UIButton *)button {
    
    if (self.popTipView == nil) {
        VoiceTypeSelectView *v = [VoiceTypeSelectView createWithVoiceType:_singOpus.pbOpus.sing.voiceType];
        v.delegate = self;
        self.popTipView = [[[CMPopTipView alloc] initWithCustomView:v needBubblePath:NO] autorelease];
        [self.popTipView setBackgroundColor:COLOR_ORANGE];
        self.popTipView.cornerRadius = (ISIPAD ? 8 : 4);
        self.popTipView.pointerSize = (ISIPAD ? 12 : 6);
    }
    
    [self.popTipView presentPointingAtView:button inView:self.view animated:YES];
}

- (void)didSelectVoiceType:(PBVoiceType)voiceType{
    
    [self.popTipView dismissAnimated:YES];
    [self seekToBegin];
    if (self.singOpus.pbOpus.sing.voiceType != voiceType) {
        _hasEdited = YES;
        [self changeVoiceType:voiceType];
        
        // play directly
        [self prepareToPlay];
        [self setState:StatePlaying];
        [self play];
    }
}

- (void)seekToBegin{
    [_player setCurrentTime:0];
    [self updateUITime:@(_fileDuration)];
}

- (IBAction)clickImageButton:(id)sender {
    if (_picker == nil) {
        self.picker = [[[ChangeAvatar alloc] init] autorelease];
        _picker.autoRoundRect = NO;
        _picker.userOriginalImage = YES;
    }
    
    [_picker showSelectionView:self];
}

- (void)didImageSelected:(UIImage*)image{

    [self showImageEditor:image];
//    [self performSelector:@selector(showImageEditor:) withObject:image afterDelay:0.7];
}

- (void)showImageEditor:(UIImage *)image{
    
    CropAndFilterViewController *vc = [[CropAndFilterViewController alloc] init];
    vc.delegate = self;
    vc.image = image;
    
    [self presentViewController:vc animated:YES completion:NULL];
    [vc release];
}

- (void)cropViewController:(CropAndFilterViewController *)controller didFinishCroppingImage:(UIImage *)image{
    
    [controller dismissViewControllerAnimated:YES completion:NULL];
    
    if (image != nil) {
        PPDebug(@"image selected, image size = %@", NSStringFromCGSize(image.size));
        
        _hasEdited = YES;
        self.image = image;
        self.opusImageView.image = image;
        [self removeHolderView];
        self.opusImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
        
        NSData *data = [self.image data];
        NSString *path = self.singOpus.localImageURLString;
        [data writeToFile:path atomically:YES];
        
        [pool drain];
    }
}

- (void)cropViewControllerDidCancel:(CropAndFilterViewController *)controller{
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)clickBackButton:(id)sender {

    if (_hasEdited) {
        CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kQuitGameAlertTitle") message:NSLS(@"kQuitDrawAlertMessage") style:CommonDialogStyleDoubleButtonWithCross];
        [dialog showInView:self.view];
        
        [dialog.oKButton setTitle:NSLS(@"kSave") forState:UIControlStateNormal];
        [dialog.cancelButton setTitle:NSLS(@"kDonotSave") forState:UIControlStateNormal];
        
        [dialog setClickOkBlock:^(id infoView){
            [self clickSaveButton:nil];
            [self quitDirectly];
        }];
        
        [dialog setClickCancelBlock:^(id infoView){
            [self quitDirectly];
        }];
    }else{
        [self quitDirectly];
    }
}

- (void)quitDirectly{
    
    [self stopRecord];
    [self pausePlay];
    _recorder.delegate = nil;
    _player.delegate = nil;
    _processor.delegate = nil;
    [self unregisterNotificationWithName:KEY_NOTIFICATION_SELECT_SONG];
    [self unregisterNotificationWithName:KEY_NOTIFICATION_SING_INFO_CHANGE];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickSaveButton:(id)sender {
        
    [_singOpus pauseAndSaveDesignTime];
    
    if ([[UserService defaultService] checkAndAskLogin:self.view] == YES){
        return;
    }
    
    [self showActivityWithText:NSLS(@"kSaving")];
    
    // generate thumb image.
    UIImage *thumbImage = [self.opusImageView createSnapShotWithScale:0.5];
    [thumbImage saveImageToFile:[self.singOpus localThumbImageURLString]];
    
    // save opus.
    [[[OpusService defaultService] draftOpusManager] saveOpus:_singOpus];
    [self hideActivity];
    [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kSaved") delayTime:1.5];
    _hasEdited = NO;
}

- (void)showInputAlertView
{

    NSString *subject = self.singOpus.pbOpus.name;
    NSString *content = self.singOpus.pbOpus.desc;
    
    __block typeof(self) bself = self;

    [InputAlert showWithSubjectWithoutSNS:subject
                                  content:content
                                   inView:self.view
                                    block:^(BOOL confirm, NSString *subject, NSString *content, NSSet *shareSet) {
        
        if (confirm) {
            [bself.singOpus setName:subject];
            [bself.singOpus setDesc:content];
            [[NSNotificationCenter defaultCenter] postNotificationName:KEY_NOTIFICATION_SING_INFO_CHANGE object:nil];
            [bself deductCoinsAndSubmitOpus];
        }
    }];
}

- (IBAction)clickSubmitButton:(id)sender {
    
    [_singOpus pauseAndSaveDesignTime];
    
    if ([[UserService defaultService] checkAndAskLogin:self.view] == YES){
        return;
    }
        
    if (_fileDuration < [PPConfigManager getRecordLimitMinTime]) {
        NSString *msg = [NSString stringWithFormat:NSLS(@"kRecordTimeTooShort"), [PPConfigManager getRecordLimitMinTime]];
        POSTMSG2(msg, 3);
        return;
    }
    
    if (self.image == nil) {
        CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kGifTips") message:NSLS(@"kAskForSelectPhoto") style:CommonDialogStyleDoubleButton];
        [dialog showInView:self.view];
        
        [dialog setClickOkBlock:^(id view){
           
            [self clickImageButton:nil];
        }];
        
        return;
    }
    
    if (self.contest != nil) {
        [self commitContestOpus];
    }else{
        [self showInputAlertView]; 
    }
}

- (void)commitContestOpus{
    
    if ([self.contest commitCountEnough]) {
        NSString *title = [NSString stringWithFormat:NSLS(@"kContestCommitEnoughCommitAsNormal"),_contest.canSubmitCount];
        [self alertCommitContestOpusAsNormalOpus:title];
        return;
    }
    else if([self.contest canSubmit] == NO){
        [self alertCommitContestOpusAsNormalOpus:NSLS(@"kContestSubmitEndSubmitNormal")];
        return;
    }
    else if (![self.contest canUserJoined:[[UserManager defaultManager] userId]]) {
        [self alertCommitContestOpusAsNormalOpus:NSLS(@"kContestNotForUserSubmitNormal")];
        return;
    }
    else if([self.contest isPassed]){
        [self alertCommitContestOpusAsNormalOpus:NSLS(@"kContestEnd")];
        return;
    }
    [self showInputAlertView];
}

- (void)alertCommitContestOpusAsNormalOpus:(NSString *)message
{
    //TODO alert: Submit as the normal opus
    
    [self.singOpus setAsNormalOpus];
    
    
    __block typeof(self) bself = self;
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kTips")
                                                       message:message
                                                         style:CommonDialogStyleDoubleButton];
    [dialog showInView:self.view];
    [dialog setClickOkBlock:^(id infoView){
        [bself showInputAlertView];
    }];
}


- (void)deductCoinsAndSubmitOpus{
    
    if (_fileDuration > 30) {
        int count = _fileDuration / 30;
        int coins = count * [PPConfigManager getRecordDeductCoinsPer30Sec];
        int balance = [[AccountManager defaultManager] getBalanceWithCurrency:PBGameCurrencyCoin];
        
        if (coins > 0){
            if (balance < coins) {
                NSString *msg = [NSString stringWithFormat:NSLS(@"kCoinsNotEnoughForSubmit"), coins, balance];
                POSTMSG2(msg, 3);
                return;
            }

            NSString *msg = [NSString stringWithFormat:NSLS(@"kRecordSubmitHint"), (int)_fileDuration, coins, balance];
            CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kHint") message:msg style:CommonDialogStyleDoubleButton];
            [dialog setClickOkBlock:^(id infoView){
                [self deductCoins:coins];
                [self handleAndSubmitOpus];
            }];
            [dialog showInView:self.view];
        }
        else{
            [self handleAndSubmitOpus];
        }
        
    }else{
        [self handleAndSubmitOpus];
    }
}

- (void)handleAndSubmitOpus{
    
    BOOL isM4A = [[[self recordURL] pathExtension] isEqualToString:@"m4a"];
    if (isM4A){
        // 支持1.0/1.1的m4a文件
        PPDebug(@"record file is M4A file, submit native file directly");
        [_singOpus setVoiceType:PBVoiceTypeVoiceTypeOrigin]; // for origin
        [self uploadSingFile:[[self recordURL] path]];
        return;
    }
    
    
    // 用户如果选择原声，则不需要经过声音处理步骤，直接上传。
    if (_singOpus.pbOpus.sing.voiceType == PBVoiceTypeVoiceTypeOrigin) {
        
        [self convertWavFile:[[self recordURL] path]
                   toMp3File:self.mp3FilePath];

    }else{
        
        NSURL *inUrl = [self recordURL];
        NSURL *outUrl = [self finalOpusURL];
        
        if (_processor == nil) {
            self.processor = [[[VoiceProcessor alloc] init] autorelease];
            _processor.delegate = self;
        }
                
        [_processor processVoice:inUrl
                          outURL:outUrl
                        duration:_singOpus.pbOpus.sing.duration
                           pitch:_singOpus.pbOpus.sing.pitch
                         formant:_singOpus.pbOpus.sing.formant];
        
        [self showProgressViewWithMessage:NSLS(@"kSending")];
    }
}

- (void)processor:(VoiceProcessor *)processor progress:(float)progress{
    PPDebug(@"progress = %f", progress);
    
    NSString* progressText = [NSString stringWithFormat:NSLS(@"kChangeVoiceDataProgress"), progress*100];
    [self showProgressViewWithMessage:progressText progress:progress];
}

- (void)processor:(VoiceProcessor *)processor doneWithOutURL:(NSURL*)outURL resultCode:(int)resultCode{
    
    if (resultCode == 0){
        // 变声转换成功，再转成MP3文件
        [self convertWavFile:outURL.path toMp3File:self.mp3FilePath];
    }
    else{
        [self hideActivity];
        [self hideProgressView];
        NSString *msg = [NSString stringWithFormat:NSLS(@"kChangeVoiceTypeFail"), [_singOpus getCurrentVoiceTypeName]];
        POSTMSG2(msg, 2.5);
    }
}

- (void)convertWavFile:(NSString *)inputFilePath
             toMp3File:(NSString *)outputFilePath{
    
    [self showActivityWithText:NSLS(@"kCompressingData")];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [AudioFormatConverter convertWavToMp3WithInputFile:inputFilePath
                                                outputFile:outputFilePath];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideActivity];
            [self convertWavFileToMp3FileDone];
        });
    });
}

- (void)convertWavFileToMp3FileDone
{
    [self uploadSingFile:self.mp3FilePath];
}

- (void)uploadSingFile:(NSString*)filePath
{
    
    NSData *singData = [NSData dataWithContentsOfFile:filePath];
    PPDebug(@"record file path is %@", filePath);
    PPDebug(@"record file data length = %d", [singData length]);
    
    if ([singData length] <= 28) {
        NSString *msg = [NSString stringWithFormat:NSLS(@"kChangeVoiceTypeFail"), [_singOpus getCurrentVoiceTypeName]];
        [self hideProgressView];
        POSTMSG2(msg, 2.5);
        return;
    }
    
    [self uploadSingOpus:singData dataType:[filePath pathExtension]];
}

- (void)uploadSingOpus:(NSData *)singData dataType:(NSString*)dataType
{
    
    if ([singData length] <= 0) {
        POSTMSG(@"kNoRecordDataForSubmit");
        return;
    }
    
    [self setProgress:0];
    [[OpusService defaultService] submitOpus:_singOpus
                                       image:_image
                                    opusData:singData
                                    dataType:dataType
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
        
        [[TaskManager defaultManager] completeTask:PBTaskIdTypeTaskCreateOpus
                                           isAward:NO
                                        clearBadge:YES];
        
        if ([self.singOpus.pbOpus.contestId length] > 0) {
            [self.contest incCommitCount];
        }    
    }else{
        POSTMSG(NSLS(@"kSubmitFailure"));
    }
}

- (IBAction)clickReviewButton:(UIButton *)button {

    self.lyricTextView.hidden = !self.lyricTextView.hidden;
    self.lyricBgImageView.hidden = !self.lyricBgImageView.hidden;
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
    
    PPDebug(@"<didGetFileDuration> file duration=%f, recorder duration=%f", fileDuration, _recorder.recordDuration);
    
    if (fileDuration <= 0.0001f){
        if (_recorder.recordDuration > 0.00001f){
            // maybe because user disable microphone in iOS7
            [VoiceRecorder detectRecordPermission];
        }
    }
    else{
        _fileDuration = fileDuration + 0.5;
    }
    
    [_singOpus setVoiceDuration:_fileDuration];
    
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

- (void)deductCoins:(int)coins{
    
    if (coins <= 0) {
        return;
    }
    
    [[AccountService defaultService] deductCoin:coins source:DeductRecrod];
}

@end
