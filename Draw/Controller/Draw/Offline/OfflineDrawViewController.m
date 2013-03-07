//
//  DrawViewController.m
//  Draw
//
//  Created by gamy on 12-3-4.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "OfflineDrawViewController.h"
#import "DrawView.h"
#import "DrawColor.h"
#import "Word.h"
#import "LocaleUtils.h"
#import "AnimationManager.h"
#import "HJManagedImageV.h"
#import "PPApplication.h"
#import "RoomController.h"
#import "ShareImageManager.h"
#import "ColorView.h"
#import "UIButtonExt.h"
#import "HomeController.h"
#import "StableView.h"
#import "PPDebug.h"
#import "AccountManager.h"
#import "AccountService.h"
#import "PenView.h"
#import "WordManager.h"
#import "DrawUtils.h"
#import "DeviceDetection.h"
#import "ShoppingManager.h"
#import "DrawDataService.h"
#import "CommonMessageCenter.h"
#import "ShowFeedController.h"
#import "MyPaintManager.h"
#import "UserManager.h"
#import "DrawDataService.h"
#import "MyPaintManager.h"
#import "UIImageExt.h"
#import "ShareController.h"
#import "Contest.h"
#import "ContestController.h"
#import "GameNetworkConstants.h"
#import "ConfigManager.h"
#import "DrawToolPanel.h"
#import "DrawColorManager.h"
#import "VendingController.h"
#import "DrawRecoveryService.h"
#import "InputAlertView.h"
#import "AnalyticsManager.h"
#import "SelectHotWordController.h"
#import "MBProgressHUD.h"
#import "GameSNSService.h"
#import "PPSNSIntegerationService.h"
#import "ShareService.h"
#import "FileUtil.h"

@interface OfflineDrawViewController()
{
    DrawView *drawView;
    
    NSInteger penWidth;
    PenView *_willBuyPen;
    ShareImageManager *shareImageManager;
    MyPaint *_draft;
    
//    NSInteger _unDraftPaintCount;
//    time_t    _lastSaveTime;

    Word *_word;
    LanguageType languageType;
    TargetType targetType;
    
    NSString*_targetUid;
    
    DrawColor *_penColor;
    DrawColor *_eraserColor;

    CGFloat _alpha;
    
    Contest *_contest;
    
    BOOL _isAutoSave;
    
//    BOOL _userSaved;
    BOOL _isNewDraft;

    BOOL _commitAsNormal;
    
}

@property(nonatomic, retain)MyPaint *draft;
@property (retain, nonatomic) IBOutlet UILabel *wordLabel;
@property (retain, nonatomic) IBOutlet UIButton *draftButton;
@property (retain, nonatomic) IBOutlet UIButton *submitButton;

@property (retain, nonatomic) DrawColor* eraserColor;
@property (retain, nonatomic) DrawColor* penColor;
@property (retain, nonatomic) DrawToolPanel *drawToolPanel;
@property (retain, nonatomic) DrawColor *tempColor;
@property (retain, nonatomic) InputAlertView *inputAlert;
//@property (retain, nonatomic) TKProgressBarView *progressView;
@property (retain, nonatomic) MBProgressHUD *progressView;

@property (retain, nonatomic) NSString *tempImageFilePath;
@property (retain, nonatomic) NSSet *shareWeiboSet;

@property (assign, nonatomic) NSTimer* backupTimer;         // backup recovery timer

- (void)initDrawView;

- (void)saveDraft:(BOOL)showResult;
- (PBDraw *)pbDraw;

- (void)updateRecentColors;
@end


#define BUTTON_FONT_SIZE_ENGLISH (ISIPAD ? 25 : 12)

@implementation OfflineDrawViewController

@synthesize draft = _draft;
@synthesize wordLabel;
@synthesize word = _word;
@synthesize draftButton;
@synthesize delegate;
@synthesize targetUid = _targetUid;
@synthesize eraserColor = _eraserColor;
//@synthesize bgColor = _bgColor;
@synthesize contest = _contest;
@synthesize penColor = _penColor;
@synthesize startController = _startController;

#define PAPER_VIEW_TAG 20120403 


#pragma mark - Static Method

+ (OfflineDrawViewController *)startDrawWithContest:(Contest *)contest
                                     fromController:(UIViewController*)fromController
                                    startController:(UIViewController*)startController
                                           animated:(BOOL)animated
{
    OfflineDrawViewController *vc = [[OfflineDrawViewController alloc] initWithContest:contest];
    [fromController.navigationController pushViewController:vc animated:animated];
    vc.startController = startController;
    PPDebug(@"<startDrawWithContest>: contest id = %@",contest.contestId);
    return [vc autorelease];
}


+ (OfflineDrawViewController *)startDraw:(Word *)word
                          fromController:(UIViewController*)fromController
                         startController:(UIViewController*)startController
                               targetUid:(NSString *)targetUid
{
    LanguageType language = [[UserManager defaultManager] getLanguageType];
    OfflineDrawViewController *vc = [[OfflineDrawViewController alloc] initWithWord:word lang:language targetUid:targetUid];
    [fromController.navigationController pushViewController:vc animated:YES];
    vc.startController = startController;
    PPDebug(@"<StartDraw>: word = %@, targetUid = %@", word.text, targetUid);
    return [vc autorelease];
}

- (void)dealloc
{
    [self stopRecovery];

    self.delegate = nil;
    _draft.drawActionList = nil;
    _draft.drawBg = nil;
    PPRelease(_shareWeiboSet);
    PPRelease(_tempImageFilePath);
    PPRelease(_progressView);
    PPRelease(_drawToolPanel);
    PPRelease(wordLabel);
    PPRelease(drawView);
    PPRelease(_word);
    PPRelease(_targetUid);
    PPRelease(_penColor);
    PPRelease(_eraserColor);
    PPRelease(_draft);
    PPRelease(_contest);
    PPRelease(draftButton);
    PPRelease(_submitButton);
    PPRelease(_tempColor);
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Construction
#define ERASER_WIDTH ([DeviceDetection isIPAD] ? 15 * 2 : 15)
#define PEN_WIDTH ([DeviceDetection isIPAD] ? 2 * 2 : 2)

- (id)initWithWord:(Word *)word lang:(LanguageType)lang{
    self = [super init];
    if (self) {
        self.word = word;
        languageType = lang;
        shareImageManager = [ShareImageManager defaultManager];
    }
    return self;
}

- (id)initWithContest:(Contest *)contest
{
 
    self = [super init];
    if (self) {
        self.contest = contest;
        self.word = [Word wordWithText:NSLS(@"kContestOpus") level:WordLeveLMedium score:0];
        shareImageManager = [ShareImageManager defaultManager];
        languageType = [[UserManager defaultManager] getLanguageType];
        shareImageManager = [ShareImageManager defaultManager];
        targetType = TypeContest;
    }
    return self;
    
}

- (id)initWithDraft:(MyPaint *)draft
{
    self = [super init];
    if (self) {
        self.draft = draft;
        if (draft.drawWordData != nil){
            self.word = [Word wordFromData:draft.drawWordData];
        }
        else{
            self.word = [Word wordWithText:draft.drawWord level:draft.level.intValue];
        }
        shareImageManager = [ShareImageManager defaultManager];
        languageType = draft.language.intValue;
        if ([draft.targetUserId length] != 0) {
            self.targetUid = [NSString stringWithFormat:@"%@",draft.targetUserId];    
        }
        if ([draft.contestId length] != 0) {
            self.contest = [[[Contest alloc] init] autorelease];
            [self.contest setContestId:draft.contestId];
            [self.contest setCanSubmitCount:1];
        }
        
        PPDebug(@"draft word = %@", [self.word description]);
    }
    return self;
}

- (id)initWithWord:(Word *)word
              lang:(LanguageType)lang 
        targetUid:(NSString *)targetUid
{
    self = [super init];
    if (self) {
        self.word = word;
        languageType = lang;
        shareImageManager = [ShareImageManager defaultManager];
        self.targetUid = targetUid;
    }
    return self;
    
}


- (id)initWithTargetType:(TargetType)aTargetType delegate:(id<OfflineDrawDelegate>)aDelegate
{
    self = [super init];
    if (self) {
        targetType = aTargetType;
        delegate = aDelegate;
        shareImageManager = [ShareImageManager defaultManager];
    }
    return self;
}

#pragma mark - Update Data


- (void)initDrawView
{
    UIView *paperView = [self.view viewWithTag:PAPER_VIEW_TAG];
    CGRect frame = DRAW_VIEW_FRAME;
    drawView = [[DrawView alloc] initWithFrame:frame];
    drawView.strawDelegate = _drawToolPanel;
    [drawView setDrawEnabled:YES];
//    [drawView setRevocationSupported:YES];
    drawView.delegate = self;
    _isNewDraft = YES;
//    _userSaved = NO;
    self.eraserColor = [DrawColor whiteColor];
    if (self.draft) {
        [drawView showDraft:self.draft];
        self.draft.thumbImage = nil;
        [self synEraserColor];
    }
    [self.view insertSubview:drawView aboveSubview:paperView];
    self.penColor = [DrawColor blackColor];
    _alpha = 1.0;
}

- (void)initWordLabel
{
    if (targetType == TypeGraffiti) {
        self.wordLabel.hidden = YES;
    }else {
        self.wordLabel.hidden = NO;
        NSString *wordText = self.word.text;
        if (targetType == TypeContest) {
            wordText = NSLS(@"kContestOpus");
        }
        [self.wordLabel setText:wordText];
    }
}

- (void)initSubmitButton
{
    [self.submitButton setTitle:NSLS(@"kSubmit") forState:UIControlStateNormal];
    [self.draftButton setTitle:NSLS(@"kSave") forState:UIControlStateNormal];
    if (![LocaleUtils isChinese]) {
        UIFont *font = [UIFont boldSystemFontOfSize:BUTTON_FONT_SIZE_ENGLISH];
        [self.submitButton.titleLabel setFont:font];
        [self.draftButton.titleLabel setFont:font];
    }
    
    if (targetType == TypeGraffiti) {
        self.draftButton.hidden = YES;
    }
}

#define STATUSBAR_HEIGHT 20.0

- (void)initDrawToolPanel
{
    self.drawToolPanel = [DrawToolPanel createViewWithdelegate:self];
    CGFloat x = self.view.center.x;
    CGFloat y = CGRectGetHeight([[UIScreen mainScreen] bounds]) - CGRectGetHeight(self.drawToolPanel.bounds) / 2.0 - STATUSBAR_HEIGHT;
    self.drawToolPanel.center = CGPointMake(x, y);
    [self.drawToolPanel setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.drawToolPanel];
    [self.drawToolPanel setPanelForOnline:NO];
}

#pragma mark - Auto Recovery Service Methods

- (BOOL)supportRecovery
{
    if (targetType == TypeGraffiti){
        return NO;
    }
    
    return YES;
}

- (void)initRecovery
{
    if (![self supportRecovery])
        return;
    
    [[DrawRecoveryService defaultService] start:_targetUid
                                      contestId:_contest.contestId
                                         userId:[[UserManager defaultManager] userId]
                                       nickName:[[UserManager defaultManager] nickName]
                                           word:_word
                                       language:languageType];    
}

- (void)stopRecovery
{
    if (![self supportRecovery])
        return;

    [self stopBackupTimer];
    [[DrawRecoveryService defaultService] stop];
}

- (void)backup:(id)timer
{
    if (![self supportRecovery])
        return;
    
    [[DrawRecoveryService defaultService] handleTimer:drawView.drawActionList];
}

- (void)startBackupTimer
{
    if (![self supportRecovery])
        return;
    
    if (_backupTimer != nil){
        [self stopBackupTimer];
    }
    
    _backupTimer = [NSTimer scheduledTimerWithTimeInterval:[[DrawRecoveryService defaultService] backupInterval]
                                                    target:self
                                                  selector:@selector(backup:)
                                                  userInfo:nil
                                                   repeats:YES];
}

- (void)stopBackupTimer
{
    if (![self supportRecovery])
        return;
    
    if (_backupTimer != nil){
        [_backupTimer invalidate];
        _backupTimer = nil;
    }
}

#pragma mark - View lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initDrawToolPanel];
    [self initDrawView];
    [self initWordLabel];
    [self initSubmitButton];
//    _unDraftPaintCount = 0;
//    _lastSaveTime = time(0);
    _isAutoSave = NO;               // set by Benson, disable this due to complicate multi-thread issue


    [self initRecovery];    
}



- (void)viewDidUnload
{
    drawView.delegate = nil;
    
    [self setWord:nil];
    [self setWordLabel:nil];
    [self setSubmitButton:nil];
    [self setDraftButton:nil];
    [super viewDidUnload];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self stopBackupTimer];
    [super viewDidDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.drawToolPanel updateView];
    [self startBackupTimer];
}

#define ESCAPE_DEDUT_COIN 1
#define DIALOG_TAG_CLEAN_DRAW 201204081
#define DIALOG_TAG_ESCAPE 201204082
#define DIALOG_TAG_SAVETIP 201204083
#define DIALOG_TAG_SUBMIT 201206071
#define DIALOG_TAG_CHANGE_BACK 201207281
#define DIALOG_TAG_COMMIT_OPUS 201208111
#define DIALOG_TAG_COMMIT_AS_NORMAL_OPUS 201302231



#define NO_COIN_TAG 201204271
#define BUY_CONFIRM_TAG 201204272


#pragma mark - Common Dialog Delegate


- (ShowFeedController *)superShowFeedController
{
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[ShowFeedController class]]) {
            return (ShowFeedController *)controller;
        }
    }
    return nil;
}


- (ShareController *)superShareController
{
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[ShareController class]]) {
            return (ShareController *)controller;
        }
    }
    return nil;
}

- (ContestController *)superContestController
{
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[ContestController class]]) {
            return (ContestController *)controller;
        }
    }
    return nil;
}


- (void)quit
{
    if (_startController) {
        [self.navigationController popToViewController:_startController animated:YES];
    }else {
        [HomeController returnRoom:self];
    }
}
- (void)clickOk:(CommonDialog *)dialog
{
    if (dialog.tag == DIALOG_TAG_ESCAPE ){
        [self quit];
    }
    else if (dialog.tag == DIALOG_TAG_SAVETIP)
    {
        [self saveDraft:NO];
        [self quit];
    }
    else if(dialog.tag == BUY_CONFIRM_TAG){
        [[AccountService defaultService] buyItem:_willBuyPen.penType itemCount:1 itemCoins:_willBuyPen.price];
        [_willBuyPen setAlpha:1];
        [drawView setPenType:_willBuyPen.penType];   
        [PenView savePenType:_willBuyPen.penType];
    }else if(dialog.tag == DIALOG_TAG_COMMIT_AS_NORMAL_OPUS)
    {
        [self showInputAlertView];
        //TODO click input Alert ok button
//        [self.inputAlert clickConfirm];
    }
    else if(dialog.tag == DIALOG_TAG_SUBMIT){
        
        
        // Save Image Locally        
        [[DrawDataService defaultService] savePaintWithPBDraw:self.pbDraw image:drawView.createImage delegate:self];

        if (self.contest) {
            
            if (dialog.style == CommonDialogStyleSingleButton) {
                [self quit];
                return;
            }
            
            //draw another opus for contest
            ContestController *contestController =  [self superContestController];
            [self.navigationController popToViewController:contestController 
                                                  animated:NO];
            [contestController enterDrawControllerWithContest:self.contest 
                                                     animated:NO];
            return;
        }
        //if come from feed detail controller
        if (_startController != nil) {
            [self.navigationController popToViewController:_startController animated:NO];
            SelectHotWordController *sc = nil;
            if ([_targetUid length] == 0) {
                sc = [[[SelectHotWordController alloc] init] autorelease];
            }else{
                sc = [[[SelectHotWordController alloc] initWithTargetUid:self.targetUid] autorelease];
            }
            sc.superController = self.startController;
            [_startController.navigationController pushViewController:sc animated:NO];
        }else{
            //if come from home controller
            if ([_targetUid length] == 0) {
                [HomeController startOfflineDrawFrom:self];    
            }else{
                [HomeController startOfflineDrawFrom:self uid:self.targetUid];
            }
        }
        if (self.draft) {
            [[MyPaintManager defaultManager] deleteMyPaint:self.draft];
            self.draft = nil;
        }
    }
}

- (void)clickBack:(CommonDialog *)dialog
{
    if(dialog.tag == DIALOG_TAG_SUBMIT){

        // Save Image Locally
        [[DrawDataService defaultService] savePaintWithPBDraw:self.pbDraw image:drawView.createImage delegate:self];
        [self quit];
    }
    else if (dialog.tag == DIALOG_TAG_SAVETIP)
    {
        [self quit];
    }
}


- (void)didSaveOpus:(BOOL)succ
{
    if (succ) {
        [self popupMessage:NSLS(@"kSaveOpusOK") title:nil];
    }else{
        [self popupMessage:NSLS(@"kSaveImageFail") title:nil];
    }
}

- (void)drawView:(DrawView *)drawView didStartTouchWithAction:(DrawAction *)action
{
    [self.drawToolPanel dismissAllPopTipViews];
    [self updateRecentColors];
    if (action) {
        _isNewDraft = NO;
    }
}

#define DRAFT_PAINT_COUNT           [ConfigManager drawAutoSavePaintInterval]
#define DRAFT_PAINT_TIME_INTERVAL   [ConfigManager drawAutoSavePaintTimeInterval]

- (void)drawView:(DrawView *)drawView didFinishDrawAction:(DrawAction *)action
{
    // add back auto save for future recovery
    if (![self supportRecovery]){
        return;
    }
    
    [[DrawRecoveryService defaultService] handleNewPaintDrawed:drawView.drawActionList];

    /*
    time_t nowTime = time(0);
    if (_unDraftPaintCount >= DRAFT_PAINT_COUNT ||
        (_unDraftPaintCount > 0 && ((nowTime - _lastSaveTime) >= DRAFT_PAINT_TIME_INTERVAL) )) {
        [[DrawRecoveryService defaultService] backup:drawView.drawActionList];
        _unDraftPaintCount = 0;
        _lastSaveTime = nowTime;
    }
    else{
        _unDraftPaintCount ++;
    }
    */
    return;
    
    // old implementation, reserved, to be deleted
    
    /*
    if (targetType == TypeGraffiti || !_isAutoSave) {
        return;
    }
    
    ++ _unDraftPaintCount;
    if (_unDraftPaintCount >= DRAFT_PAINT_COUNT) {
        PPDebug(@"<didDrawedPaint> start to auto save...");
        [self saveDraft:NO];
    }
    */
}

- (void)alertCommitContestOpusAsNormalOpus:(NSString *)message
{
    //TODO alert: Submit as the normal opus
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kTips")
                                         message:message
                                           style:CommonDialogStyleDoubleButton
                                        delegate:self];
    dialog.tag =  DIALOG_TAG_COMMIT_AS_NORMAL_OPUS;
    [dialog showInView:self.view];
    _commitAsNormal = YES;
    
}

- (void)didCreateDraw:(int)resultCode
{
    [self hideActivity];
    [self hideProgressView];
    
    self.submitButton.userInteractionEnabled = YES;
    [self.inputAlert setCanClickCommitButton:YES];
    if (resultCode == 0) {
        [self.inputAlert dismiss:NO];
        CommonDialog *dialog = nil;
        if (self.contest) {
            if (!_commitAsNormal) {
                self.contest.opusCount ++;
                if (![self.contest joined]) {
                    self.contest.participantCount ++;
                }
                [self.contest incCommitCount];
            }
            
            if ([self.contest commitCountEnough] || _commitAsNormal) {
                dialog = [CommonDialog createDialogWithTitle:NSLS(@"kSubmitSuccTitle") 
                                                     message:NSLS(@"kContestSubmitSuccQuitMsg") 
                                                       style:CommonDialogStyleSingleButton 
                                                    delegate:self];
            }else{
                NSString *title = [NSString stringWithFormat:NSLS(@"kContestSubmitSuccMsg"),
                                   self.contest.retainCommitChance];
                
                dialog = [CommonDialog createDialogWithTitle:NSLS(@"kSubmitSuccTitle") 
                                                     message:title 
                                                       style:CommonDialogStyleDoubleButton 
                                                    delegate:self];
            }
        }else{
            dialog = [CommonDialog createDialogWithTitle:NSLS(@"kSubmitSuccTitle")
                                                 message:NSLS(@"kSubmitSuccMsg") 
                                                   style:CommonDialogStyleDoubleButton 
                                                delegate:self];
        }
        
        dialog.tag = DIALOG_TAG_SUBMIT;
        [dialog showInView:self.view];
        
        [[LevelService defaultService] addExp:OFFLINE_DRAW_EXP delegate:self];
        if (self.draft) {
            [[MyPaintManager defaultManager] deleteMyPaint:self.draft];
            self.draft = nil;
        }
        
        // share weibo after submit opus success
        [self shareToWeibo];

    }else if(resultCode == ERROR_CONTEST_END){
//        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kContestEnd") delayTime:1.5 isSuccessful:NO];
        [self alertCommitContestOpusAsNormalOpus:NSLS(@"kContestEnd")];
    }else{
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kSubmitFailure") delayTime:1.5 isSuccessful:NO];
    }

    
}




#pragma mark - Draft

- (PBDraw *)pbDraw
{
    UserManager *userManager = [UserManager defaultManager];
    PBDraw *pbDraw = [[DrawDataService defaultService]
                      buildPBDraw:[userManager userId]
                      nick:[userManager nickName]
                      avatar:[userManager avatarURL]
                      drawActionList:drawView.drawActionList
                      drawWord:self.word
                      language:languageType
                      drawBg:drawView.drawBg
                      size:drawView.frame.size
                      isCompressed:YES];
    return pbDraw;
}

- (PBNoCompressDrawData *)drawDataSnapshot
{
//    NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:drawView.drawActionList];
    PBNoCompressDrawData* data = [DrawAction drawActionListToPBNoCompressDrawData:drawView.drawActionList pbdrawBg:drawView.drawBg size:drawView.frame.size];
//    PPRelease(temp);
    return data;
}

- (void)saveDraft:(BOOL)showResult
{
    if (targetType == TypeGraffiti) {
        return;
    }
    PPDebug(@"<OfflineDrawViewController> start to save draft. show result = %d",showResult);
    _isNewDraft = YES;

    NSAutoreleasePool *subPool = [[NSAutoreleasePool alloc] init];
    UIImage *image = [drawView createImage];
    
    BOOL result = NO;
    
    @try {
        MyPaintManager *pManager = [MyPaintManager defaultManager];
        if (self.draft) {
            result = YES;
            PPDebug(@"<saveDraft> save draft");
            [self.draft setIsRecovery:[NSNumber numberWithBool:NO]];
            
            result = [pManager updateDraft:self.draft
                                     image:image
                      pbNoCompressDrawData:[self drawDataSnapshot]];
        }else{
            PPDebug(@"<saveDraft> create core data draft");
            UserManager *userManager = [UserManager defaultManager];
            self.draft = [pManager createDraft:image
                          pbNoCompressDrawData:[self drawDataSnapshot]
                                     targetUid:_targetUid
                                     contestId:self.contest.contestId
                                        userId:[userManager userId]
                                      nickName:[userManager nickName]
                                          word:_word
                                      language:languageType];

            
            if (self.draft) {
                result = YES;
            }else{
                result = NO;
            }
        }
        if (showResult) {
            NSString *message = result ? NSLS(@"kSaveSucc") :  NSLS(@"kSaveFail");
            [[CommonMessageCenter defaultCenter] postMessageWithText:message delayTime:1.5 isSuccessful:result];
            
        }

    }
    @catch (NSException *exception) {
        NSLog(@"saveDraft: Caught %@: %@", [exception name], [exception reason]);
    }
    @finally {
        
    }
    
    [subPool drain];        
}

#pragma mark - Actions
- (void)synEraserColor
{
    self.eraserColor = drawView.bgColor;
    if (drawView.penType == Eraser) {
        drawView.lineColor = self.eraserColor;
    }
}

- (void)performSaveDraft
{
    [self saveDraft:YES];
    [self hideActivity];
}

- (void)saveDraftAndShowResult
{
    [self showActivityWithText:NSLS(@"kSaving")];
    [self performSelector:@selector(performSaveDraft) withObject:nil afterDelay:0.1f];
}

- (IBAction)clickDraftButton:(id)sender {
    [self showActivityWithText:NSLS(@"kSaving")];
    [self performSelector:@selector(saveDraftAndShowResult) withObject:nil afterDelay:0.01];
    [[AnalyticsManager sharedAnalyticsManager] reportDrawClick:DRAW_CLICK_DRAFT];
}


- (NSMutableArray *)compressActionList:(NSArray *)drawActionList
{
    return  [DrawAction scaleActionList:drawActionList
                                 xScale:1.0 / IPAD_WIDTH_SCALE
                                 yScale:1.0 / IPAD_HEIGHT_SCALE];
}

// TODO move to common
- (void)showProgressView
{
    if (self.progressView == nil){
        self.progressView = [[[MBProgressHUD alloc] initWithView:self.view] autorelease];
    }
    
    [self.progressView setProgress:0.0];
    [self.progressView setMode:MBProgressHUDModeDeterminate];
    [self.progressView setLabelText:NSLS(@"kSending")];
    
    [self.view addSubview:_progressView];
    [self.progressView show:YES];
}

- (void)hideProgressView
{
    [self.progressView hide:YES];
    self.progressView = nil;
}

- (void)setProgress:(CGFloat)progress
{
    PPDebug(@"opus upload progress=%f", progress);

    if (progress == 1.0f){
        // make this because after uploading data, it takes server sometime to process
        progress = 0.99;
    }
    
    NSString* progressText = [NSString stringWithFormat:NSLS(@"kSendingProgress"), progress*100];
    [self.progressView setLabelText:progressText];
    
    [self.progressView setProgress:progress];        
}

- (void)shareViaSNS:(SnsType)type imagePath:(NSString*)imagePath
{

    PPSNSCommonService* snsService = [[PPSNSIntegerationService defaultService] snsServiceByType:type];
    
    NSString* snsOfficialNick = [GameSNSService snsOfficialNick:type];
    NSString* text = nil;
    
    if ([[self getOpusComment] length] > 0){
        text = [NSString stringWithFormat:NSLS(@"kShareMeTextWithComment"), [self getOpusComment], snsOfficialNick, self.word.text];
    }
    else{
        text = [NSString stringWithFormat:NSLS(@"kShareMeText"), snsOfficialNick, self.word.text];
    }
    
    if (imagePath != nil) {
        [snsService publishWeibo:text imageFilePath:imagePath successBlock:^(NSDictionary *userInfo) {
            
            PPDebug(@"%@ publish weibo succ", [snsService snsName]);
//            dispatch_async(dispatch_get_main_queue(), ^{
                int earnCoins = [[AccountService defaultService] rewardForShareWeibo];
                if (earnCoins > 0){
//                    NSString* msg = [NSString stringWithFormat:NSLS(@"kPublishWeiboSuccAndEarnCoins"), earnCoins];
//                    [self popupMessage:msg title:nil];
                }
//            });
            
        } failureBlock:^(NSError *error) {
            PPDebug(@"%@ publish weibo failure", [snsService snsName]);
        }];
    }
    
    return;
    
}

- (void)writeTempFile:(UIImage*)image
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    self.tempImageFilePath = [[ShareService defaultService] synthesisImageWithImage:image
                                                                      waterMarkText:[ConfigManager getShareImageWaterMark]];
    [pool drain];
}

- (void)shareToWeibo
{
    for (NSNumber *value in self.shareWeiboSet) {
        [self shareViaSNS:[value integerValue] imagePath:self.tempImageFilePath];
    }
    
    self.shareWeiboSet = nil;
}

- (NSString*)getOpusComment
{
    return self.inputAlert.contentText;
}

- (void)commitOpus:(NSSet *)share
{
    
//    [self showActivityWithText:NSLS(@"kSending")];
    
    [self showProgressView];
    
    self.submitButton.userInteractionEnabled = NO;
    [self.inputAlert setCanClickCommitButton:NO];
    UIImage *image = [drawView createImage];

    // create temp file for weibo sharing
    [self writeTempFile:image];
    [self setShareWeiboSet:share];    

    NSString *text = self.inputAlert.contentText;
    
    NSString *contestId = (_commitAsNormal ? nil : _contest.contestId);
    
    [[DrawDataService defaultService] createOfflineDraw:drawView.drawActionList
                                                  image:image
                                               drawWord:self.word
                                               language:languageType
                                              targetUid:self.targetUid
                                              contestId:contestId
                                                   desc:text//@"元芳，你怎么看？"
                                                 drawBg:drawView.drawBg
                                                   size:drawView.frame.size
                                               delegate:self];

    

}

- (void)showInputAlertView
{
    if (self.inputAlert == nil) {
        self.inputAlert = [InputAlertView inputAlertViewWith:NSLS(@"kAddOpusDesc") content:nil target:self commitSeletor:@selector(commitOpus:) cancelSeletor:NULL];
    }
    [self.inputAlert showInView:self.view animated:YES];
}

- (IBAction)clickSubmitButton:(id)sender {

    [self stopRecovery];

    BOOL isBlank = [DrawAction isDrawActionListBlank:drawView.drawActionList];
    
    if (isBlank) {
        CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kBlankDrawTitle") message:NSLS(@"kBlankDrawMessage") style:CommonDialogStyleSingleButton delegate:nil];
        [dialog showInView:self.view];
        return;
    }
    
    if (targetType == TypeGraffiti) {
        if (delegate && [delegate respondsToSelector:@selector(didController:submitActionList:drawImage:)]) {
            UIImage *image = [drawView createImage];
            [delegate didController:self submitActionList:drawView.drawActionList drawImage:image];
        }
    }else {
        if(self.contest){
            if ([self.contest commitCountEnough]) {
                NSString *title = [NSString stringWithFormat:NSLS(@"kContestCommitEnoughCommitAsNormal"),_contest.canSubmitCount];
                [self alertCommitContestOpusAsNormalOpus:title];
                return;
            }else if([self.contest isPassed]){
                [self alertCommitContestOpusAsNormalOpus:NSLS(@"kContestEnd")];
                return;
            }
        }
        [self showInputAlertView];
    }
}


- (void)alertExit
{
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:nil message:nil style:CommonDialogStyleDoubleButton delegate:self];
    
    if (_isNewDraft || [drawView.drawActionList count] == 0 /*|| !_isAutoSave*/) {
        [dialog setTitle:NSLS(@"kQuitGameAlertTitle")];
        [dialog setMessage:NSLS(@"kQuitGameAlertMessage")];
        dialog.tag = DIALOG_TAG_ESCAPE;
    }else{
        [dialog setTitle:NSLS(@"kQuitDrawAlertTitle")];
        [dialog setMessage:NSLS(@"kQuitDrawAlertMessage")];
        [dialog.backButton setTitle:NSLS(@"kDonotSave") forState:UIControlStateNormal];
        [dialog.oKButton setTitle:NSLS(@"kSave") forState:UIControlStateNormal];

        dialog.tag = DIALOG_TAG_SAVETIP;
    }
    
    [dialog showInView:self.view];
}

- (void)clickBackButton:(id)sender
{
    if (targetType == TypeGraffiti) {
        if (delegate && [delegate respondsToSelector:@selector(didControllerClickBack:)]) {
            [delegate didControllerClickBack:self];
        }
    }else {
        [self alertExit];
//        CommonDialog *dialog = nil;
//        if ([drawView.drawActionList count] == 0 || !_isAutoSave) {
//            dialog = [CommonDialog createDialogWithTitle:NSLS(@"kQuitGameAlertTitle")
//                                                 message:NSLS(@"kQuitGameAlertMessage")
//                                                   style:CommonDialogStyleDoubleButton 
//                                                delegate:self];
//        }else{
//            dialog = [CommonDialog createDialogWithTitle:NSLS(@"kQuitDrawAlertTitle") 
//                                                 message:NSLS(@"kQuitDrawAlertMessage") 
//                                                   style:CommonDialogStyleDoubleButton 
//                                                delegate:self];
//        }
//        
//        dialog.tag = DIALOG_TAG_ESCAPE;
//        [dialog showInView:self.view];
    }
}

#pragma mark - level service delegate
- (void)levelUp:(int)level
{
//    [[CommonMessageCenter defaultCenter] postMessageWithText:[NSString stringWithFormat:NSLS(@"kUpgradeMsg"),level] delayTime:1.5 isHappy:YES];
}

#pragma mark - CommonItemInfoView Delegate

- (void)didBuyItem:(Item*)anItem
            result:(int)result
{
    if (result == 0) {
        switch (anItem.type) {
            case PaletteItem:
            case ColorAlphaItem:
            case ColorStrawItem:
                [self.drawToolPanel updateNeedBuyToolViews];
                [self.drawToolPanel userItem:anItem.type];
                break;
            case Pen:
            case Pencil:
            case IcePen:
            case Quill:
            case WaterPen:
            {
                drawView.touchActionType = TouchActionTypeDraw;
                [self.drawToolPanel setPenType:anItem.type];
                [drawView setPenType:anItem.type];
                break;
            }
            default:
                break;

        }
    }else
    {
        [self popupMessage:NSLS(@"kNotEnoughCoin") title:nil];
    }
}

#pragma mark - Draw Tool Panel Delegate

- (void)drawToolPanel:(DrawToolPanel *)toolPanel didClickRedoButton:(UIButton *)button
{
    BOOL canRedo = [drawView canRedo];
    if (canRedo) {
        [drawView redo];
        _isNewDraft = NO;
        [self synEraserColor];
    }
}
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didClickStrawButton:(UIButton *)button
{
    drawView.touchActionType = TouchActionTypeGetColor;
}

- (void)performRevoke
{
    [drawView revoke:^{
        [self hideActivity];
    }];
    [self synEraserColor];
}

- (void)drawToolPanel:(DrawToolPanel *)toolPanel didClickUndoButton:(UIButton *)button
{
    if ([drawView canRevoke]) {
        _isNewDraft = NO;        
//        [self showActivityWithText:NSLS(@"kRevoking")];
        [self performSelector:@selector(performRevoke) withObject:nil afterDelay:0.1f];
    }else{
        [self popupUnhappyMessage:NSLS(@"kCannotRevoke") title:nil];
    }
}
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didClickEraserButton:(UIButton *)button
{
    drawView.touchActionType = TouchActionTypeDraw;
    [self.eraserColor setAlpha:1.0];
    [drawView setLineColor:self.eraserColor];
    [drawView setPenType:Eraser];
}
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didClickPaintBucket:(UIButton *)button
{
    if (drawView.touchActionType == TouchActionTypeGetColor) {
        drawView.touchActionType = TouchActionTypeDraw;
    }

    _isNewDraft = NO;

    self.eraserColor = [DrawColor colorWithColor:self.penColor];
    [self.eraserColor setAlpha:1.0];
    [drawView changeBackWithColor:self.eraserColor];
    
    self.penColor = [DrawColor blackColor];
    [toolPanel setColor:self.penColor];
    
    drawView.lineColor = [DrawColor blackColor];
    [drawView.lineColor setAlpha:_alpha];
    
    [self updateRecentColors];
    [_drawToolPanel updateRecentColorViewWithColor:[DrawColor blackColor]];
}
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didSelectPen:(ItemType)penType
               bought:(BOOL)bought
{
    if (bought) {
        PPDebug(@"<didSelectPen> pen type = %d",penType);
        drawView.touchActionType = TouchActionTypeDraw;
        drawView.penType = penType;
        //set draw color
        drawView.lineColor = [DrawColor colorWithColor:self.penColor];
        [drawView.lineColor setAlpha:_alpha];
    }else{
        [CommonItemInfoView showItem:[Item itemWithType:penType amount:1] infoInView:self canBuyAgain:!bought];
    }
}
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didSelectWidth:(CGFloat)width
{
    if (drawView.touchActionType == TouchActionTypeGetColor) {
        drawView.touchActionType = TouchActionTypeDraw;
    }
    drawView.lineWidth = width;
    PPDebug(@"<didSelectWidth> width = %f",width);
}
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didSelectColor:(DrawColor *)color
{
    if (drawView.touchActionType == TouchActionTypeGetColor) {
        drawView.touchActionType = TouchActionTypeDraw;
    }
    if (drawView.penType == Eraser) {
        drawView.penType = Pencil;
    }
    self.tempColor = color;
    self.penColor = color;
    [drawView setLineColor:[DrawColor colorWithColor:color]];
    [drawView.lineColor setAlpha:_alpha];
}
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didSelectAlpha:(CGFloat)alpha
{
    if (drawView.touchActionType == TouchActionTypeGetColor) {
        drawView.touchActionType = TouchActionTypeDraw;
    }
    _alpha = alpha;
    if (drawView.lineColor != self.eraserColor) {
        DrawColor *color = [DrawColor colorWithColor:drawView.lineColor];
        color.alpha = alpha;
        drawView.lineColor = color;
    }
    
    //chage scale... will be removed __By Gamy
//    drawView.scale = alpha * 5;
    
}

- (void)drawToolPanel:(DrawToolPanel *)toolPanel startToBuyItem:(ItemType)type
{
    [CommonItemInfoView showItem:[Item itemWithType:type amount:1] infoInView:self canBuyAgain:YES];
}

- (void)drawToolPanel:(DrawToolPanel *)toolPanel didSelectShapeType:(ShapeType)type
{
    drawView.touchActionType = TouchActionTypeShape;
    drawView.shapeType = type;
}

- (void)drawToolPanel:(DrawToolPanel *)toolPanel didSelectDrawBg:(PBDrawBg *)drawBg
{
    [drawView setDrawBg:drawBg];
    [[DrawRecoveryService defaultService] handleChangeDrawBg:drawBg];
    
}
#pragma mark - Recent Color

- (void)updateRecentColors
{
    if (_tempColor) {
        [[DrawColorManager sharedDrawColorManager] updateColorListWithColor:_tempColor];
        [_drawToolPanel updateRecentColorViewWithColor:_tempColor];
        self.tempColor = nil;
    }
}


#pragma mark -- super method

- (void)keyboardWillShowWithRect:(CGRect)keyboardRect
{
    if (!ISIPAD) {
        PPDebug(@"keyboardWillShowWithRect rect = %@", NSStringFromCGRect(keyboardRect));
        [self.inputAlert adjustWithKeyBoardRect:keyboardRect];        
    }
}

//- (void)keyboardWillHideWithRect:(CGRect)keyboardRect
//{
//    PPDebug(@"keyboardWillHideWithRect rect = %@", NSStringFromCGRect(keyboardRect));
//    [self.inputAlert adjustWithKeyBoardRect:CGRectZero];
//}

//- (void)keyboardDidShowWithRect:(CGRect)keyboardRect
//{
//}
//
//- (void)keyboardDidHideWithRect:(CGRect)keyboardRect
//{
//}



@end
