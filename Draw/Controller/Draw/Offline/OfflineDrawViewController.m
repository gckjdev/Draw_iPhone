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
#import "PPConfigManager.h"
#import "DrawToolPanel.h"
#import "DrawColorManager.h"
#import "DrawRecoveryService.h"
#import "InputAlertView.h"
#import "AnalyticsManager.h"
#import "SelectHotWordController.h"
#import "MBProgressHUD.h"
#import "GameSNSService.h"
#import "ShareService.h"
#import "FileUtil.h"
#import "BuyItemView.h"
#import "CustomInfoView.h"
#import "UserGameItemService.h"
#import "GameItemService.h"
#import "DrawHolderView.h"
#import "GameItemManager.h"
#import "CanvasRect.h"
#import "UserManager.h"
#import "ContestManager.h"
#import "UIImageUtil.h"

#import "ToolCommand.h"
#import "StringUtil.h"
#import "MKBlockActionSheet.h"
#import "DrawToolUpPanel.h"
#import "DrawLayerPanel.h"
#import "ImagePlayer.h"
#import "TaskManager.h"
#import "BBSActionSheet.h"

#import "OpusDesignTime.h"

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
@property (retain, nonatomic) IBOutlet UIButton *upPanelButton;
@property (retain, nonatomic) IBOutlet UIButton *layerButton;

@property (retain, nonatomic) DrawToolPanel *drawToolPanel;
@property (retain, nonatomic) DrawToolUpPanel *drawToolUpPanel;

@property (retain, nonatomic) NSString *tempImageFilePath;
@property (retain, nonatomic) NSSet *shareWeiboSet;

@property (assign, nonatomic) NSTimer* backupTimer;         // backup recovery timer

@property (retain, nonatomic) CommonDialog* currentDialog;
@property (retain, nonatomic) CMPopTipView *layerPanelPopView;
@property (retain, nonatomic) CMPopTipView *upPanelPopView;
//@property (assign, nonatomic) CGRect canvasRect;

- (void)initDrawView;

- (void)saveDraft:(BOOL)showResult;
- (PBDraw *)createPBDraw;

@end


#define BUTTON_FONT_SIZE_ENGLISH (ISIPAD ? 25 : 12)

@implementation OfflineDrawViewController

@synthesize draft = _draft;
@synthesize wordLabel;
@synthesize word = _word;
@synthesize draftButton;
@synthesize delegate;
@synthesize targetUid = _targetUid;
//@synthesize bgColor = _bgColor;
@synthesize contest = _contest;
@synthesize startController = _startController;
@synthesize opusDesc = _opusDesc;

//#define PAPER_VIEW_TAG 20120403 


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
    return [OfflineDrawViewController startDraw:word
                                 fromController:fromController
                                startController:startController
                                      targetUid:targetUid
                                          photo:nil];
}

+ (OfflineDrawViewController *)startDraw:(Word *)word
                          fromController:(UIViewController*)fromController
                         startController:(UIViewController*)startController
                               targetUid:(NSString *)targetUid
                                   photo:(UIImage *)photo
{
    LanguageType language = [[UserManager defaultManager] getLanguageType];
    OfflineDrawViewController *vc = [[OfflineDrawViewController alloc] initWithWord:word lang:language targetUid:targetUid photo:photo];
    [fromController.navigationController pushViewController:vc animated:YES];
    vc.startController = startController;
    PPDebug(@"<StartDraw>: word = %@, targetUid = %@", word.text, targetUid);
    return [vc autorelease];
}

- (void)dealloc
{
    [UIApplication sharedApplication].idleTimerDisabled = NO; // disable lock screen while in drawing
    
    [self stopRecovery];
    self.delegate = nil;
    _draft.drawActionList = nil;
//    PPRelease(_copyPaintImageURL);
    PPRelease(_submitOpusFinalImage);
    PPRelease(_submitOpusDrawData);
    PPRelease(_shareWeiboSet);
    PPRelease(_tempImageFilePath);
    PPRelease(_drawToolPanel);
    PPRelease(_drawToolUpPanel);
    PPRelease(wordLabel);
    PPRelease(drawView);
    PPRelease(_word);
    PPRelease(_targetUid);
    PPRelease(_draft);
    PPRelease(_contest);
    PPRelease(draftButton);
    PPRelease(_submitButton);
    PPRelease(_opusDesc);
    PPRelease(_bgImage);
    PPRelease(_bgImageName);
    PPRelease(_currentDialog);
//    PPRelease(_copyPaintImage);
    PPRelease(_layerPanelPopView);
    PPRelease(_upPanelPopView);
    PPRelease(_designTime);
    [_upPanelButton release];
    [_titleView release];
    [_layerButton release];
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
            
            self.contest = [[ContestManager defaultManager] ongoingContestById:draft.contestId];
        }
        self.opusDesc = draft.opusDesc;
        
        PPDebug(@"draft word = %@", [self.word description]);
    }
    return self;
}

- (id)initWithWord:(Word *)word
              lang:(LanguageType)lang
        targetUid:(NSString *)targetUid
{
    self = [self initWithWord:word lang:lang targetUid:targetUid photo:nil];
    return self;
}

- (id)initWithWord:(Word *)word
              lang:(LanguageType)lang
         targetUid:(NSString *)targetUid
             photo:(UIImage *)photo
{
    self = [super init];
    if (self) {
        self.word = word;
        languageType = lang;
        shareImageManager = [ShareImageManager defaultManager];
        self.targetUid = targetUid;
        
        if (photo) {
            self.bgImage = photo;
            self.bgImageName = [NSString stringWithFormat:@"%@.png", [NSString GetUUID]];
        }
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

- (void)initDrawView
{
    
    drawView = [[DrawView alloc] initWithFrame:[CanvasRect defaultRect]
                                        layers:[DrawLayer defaultLayersWithFrame:[CanvasRect defaultRect]]];

    [drawView setDrawEnabled:YES];
    drawView.delegate = self;
    _isNewDraft = YES;
    if (self.draft) {
        
        [self.draft drawActionList];
        if ([GameApp hasBGOffscreen]) {
            [self setDrawBGImage:self.draft.bgImage];
        }
        
        [drawView showDraft:self.draft];
        self.draft.paintImage = nil;
        self.draft.thumbImage = nil;
        self.opusDesc = self.draft.opusDesc;
    }
    DrawHolderView *holder = [DrawHolderView defaultDrawHolderViewWithContentView:drawView];
    [self.view insertSubview:holder aboveSubview:self.draftButton];
    PPDebug(@"DrawView Rect = %@",NSStringFromCGRect(drawView.frame));
    
    // set opus design time, the value is store in PBDraw data so need to get it after drawActionList is read
    int initTime = (self.draft == nil) ? 0 : self.draft.spendTime;
    self.designTime = [[OpusDesignTime alloc] initWithTime:initTime];
    [self.designTime start];
}

- (void)initWordLabel
{
    if (targetType == TypeGraffiti || targetType == TypePhoto) {
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
    if (![LocaleUtils isChinese]) {
        UIFont *font = [UIFont boldSystemFontOfSize:BUTTON_FONT_SIZE_ENGLISH];
        [self.submitButton.titleLabel setFont:font];
        [self.draftButton.titleLabel setFont:font];
    }
    
    if ([GameApp canSubmitDraw] == NO) {
        self.draftButton.frame = self.submitButton.frame;
        self.submitButton.hidden = YES;
        return;
    }
    
    if ([self isBriefStyle]) {
        self.draftButton.hidden = YES;
        self.layerButton.hidden = YES;
        [self.upPanelButton setCenter:self.draftButton.center];
    }
    
}

- (BOOL)isBriefStyle
{
    return (targetType == TypeGraffiti || targetType == TypePhoto);
}

#define STATUSBAR_HEIGHT 20.0

- (void)initDrawToolPanel
{
    self.drawToolPanel = [DrawToolPanel createViewWithDrawView:drawView];
    CGFloat x = self.view.center.x;
    CGFloat y = CGRectGetHeight([[UIScreen mainScreen] bounds]) - CGRectGetHeight(self.drawToolPanel.bounds) / 2.0 - STATUSBAR_HEIGHT + STATUSBAR_DELTA;
    self.drawToolPanel.center = CGPointMake(x, y);
    [self.view addSubview:self.drawToolPanel];
    [self.drawToolPanel setPanelForOnline:NO];    
    [self.drawToolPanel setBackgroundColor:[UIColor clearColor]];
    self.drawToolPanel.delegate = self;
    [self.drawToolPanel bindController:self];
    
    self.drawToolUpPanel = [DrawToolUpPanel createViewWithDrawView:drawView
                                                        briefStyle:[self isBriefStyle]];
    [drawView.dlManager setDelegate:self];
    [self.drawToolUpPanel bindController:self];
}


- (void)setOpusDesc:(NSString *)opusDesc
{
    if(_opusDesc != opusDesc){
        PPRelease(_opusDesc);
        _opusDesc = [opusDesc retain];
        if ([self supportRecovery]) {
            [[DrawRecoveryService defaultService] setDesc:opusDesc];
        }
    }
}

#pragma mark - Auto Recovery Service Methods

- (BOOL)supportRecovery
{
    return ![self isBriefStyle];
}

- (void)updateDrawRecoveryService
{
    DrawRecoveryService *drs = [DrawRecoveryService defaultService];
    drs.canvasSize = drawView.bounds.size;
    drs.drawActionList = drawView.drawActionList;
    drs.targetUid = self.targetUid;
    drs.desc = self.opusDesc;
    drs.word = self.word;
    drs.bgImage = self.bgImage;
    drs.layers = [[[drawView layers] mutableCopy] autorelease];
}

- (void)initRecovery
{
    if (![self supportRecovery])
        return;
    
    DrawRecoveryService *drs = [DrawRecoveryService defaultService];
//    drs.userId = [[UserManager defaultManager] userId];
//    drs.nickName = [[UserManager defaultManager] nickName];
//    drs.contestId = self.contest.contestId;
//    drs.word = self.word;
//    drs.language = languageType;
//    drs.bgImageName = [NSString stringWithFormat:@"%@.png", [NSString GetUUID]];
//    drs.bgImage = self.bgImage;
//    [self updateDrawRecoveryService];    

    [drs start:drawView.drawActionList
     targetUid:self.targetUid
          word:self.word
          desc:self.opusDesc
    canvasSize:drawView.bounds.size
   bgImageName:[NSString stringWithFormat:@"%@.png", [NSString GetUUID]]
       bgImage:self.bgImage
     contestId:self.contest.contestId
       strokes:self.draft.strokes
     spendTime:self.draft.spendTime
  completeDate:time(0)
        layers:[drawView layers]];
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
    
    [self updateDrawRecoveryService];
    if ([[DrawRecoveryService defaultService] needBackup]) {
        [[DrawRecoveryService defaultService] backup:drawView.drawActionList
                                           targetUid:self.targetUid
                                                word:self.word
                                                desc:self.opusDesc
                                          canvasSize:drawView.bounds.size
                                         bgImageName:nil
                                             bgImage:self.bgImage
                                           contestId:self.contest.contestId
                                             strokes:self.draft.strokes
                                           spendTime:self.draft.spendTime
                                        completeDate:time(0)
                                              layers:[drawView layers]];
    }
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

- (void)didGetUserInfo:(MyFriend *)user resultCode:(NSInteger)resultCode
{
    if (resultCode == 0 && user) {
        [self.drawToolUpPanel updateDrawToUser:user];
    }
}

- (void)updateTargetFriend
{
    if (self.targetUid) {
        [[UserService defaultService] getUserSimpleInfoByUserId:self.targetUid delegate:self];
    }
}

- (void)initBgImage
{
    if ([GameApp hasBGOffscreen] || targetType == TypePhoto) {
        if (self.draft == nil && _bgImage) {
            [self setDrawBGImage:_bgImage];
        } else {
            self.bgImageName = _draft.bgImageName;
            self.bgImage = _draft.bgImage;
        }
    }
}

- (void)initPageBG
{
    UIImage *image = [[UserManager defaultManager] drawBackground];
    if (image == nil) {
        image = [shareImageManager drawBGImage];        
    }
    [self setPageBGImage:image];
}


- (void)viewDidLoad
{
    [UIApplication sharedApplication].idleTimerDisabled = YES; // disable lock screen while in drawing
    
    [super viewDidLoad];
    [self registerUIApplicationNotification];

    // set default draw word
    if ([self.word.text length] == 0) {
        self.word = [Word cusWordWithText:[PPConfigManager defaultDrawWord]];   //@""]; // NSLS(@"kDefaultDrawWord")];
    }
    
    [self initDrawView];
    [self initDrawToolPanel];
    [self initWordLabel];
    [self initSubmitButton];

    _isAutoSave = NO;               // set by Benson, disable this due to complicate multi-thread issue

    [self updateTargetFriend];

    [self initBgImage];
    [self initPageBG];

    [self initRecovery];

    [self.titleView setTarget:self];
    [self.titleView setBackButtonSelector:@selector(clickBackButton:)];
    [self.titleView setLeftButtonImage:[shareImageManager drawBackImage]];
    [self.titleView setBgImage:nil];
    [self.titleView setBackgroundColor:[UIColor clearColor]];
    [self setCanDragBack:NO];
}


- (void)setDrawBGImage:(UIImage *)image
{
    CGRect rect = CGRectFromCGSize(image.size);
    [drawView changeRect:rect];
    [drawView setBGImage:image];
}


- (void)viewDidUnload
{
    drawView.delegate = nil;
    
    [self setWord:nil];
    [self setWordLabel:nil];
    [self setSubmitButton:nil];
    [self setDraftButton:nil];
    [self setUpPanelButton:nil];
    [self setTitleView:nil];
    [self setLayerButton:nil];
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
    [self startBackupTimer];
}

- (void)registerUIApplicationNotification
{
    [self registerNotificationWithName:UIApplicationDidEnterBackgroundNotification usingBlock:^(NSNotification *note) {
        [self.designTime pause];
    }];
    
    [self registerNotificationWithName:UIApplicationWillEnterForegroundNotification usingBlock:^(NSNotification *note) {
        [self.designTime resume];
    }];
}


#define ESCAPE_DEDUT_COIN 1
#define DIALOG_TAG_CLEAN_DRAW 201204081
#define DIALOG_TAG_ESCAPE 201204082
#define DIALOG_TAG_SAVETIP 201204083
#define DIALOG_TAG_SUBMIT 201206071
#define DIALOG_TAG_CHANGE_BACK 201207281
#define DIALOG_TAG_COMMIT_OPUS 201208111


#define NO_COIN_TAG 201204271


#pragma mark - Common Dialog Delegate



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
- (void)didClickOk:(CommonDialog *)dialog infoView:(id)infoView
{
    if (dialog.tag == DIALOG_TAG_ESCAPE ){
        [self quit];
    }
    else if (dialog.tag == DIALOG_TAG_SAVETIP)
    {
        [self saveDraft:NO];
        [self quit];
    }
    else if(dialog.tag == DIALOG_TAG_SUBMIT){

        if (self.contest) {
            
            // ask gamy later, why here use dialog style to decide logic
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
        
    }
}

- (void)didClickCancel:(CommonDialog *)dialog
{
    if (dialog.tag == DIALOG_TAG_SUBMIT || dialog.tag == DIALOG_TAG_SAVETIP){
        [self quit];
    }
}


- (void)didSaveOpus:(BOOL)succ
{
    if (succ) {
        POSTMSG(NSLS(@"kSaveOpusOK"));
    }else{
        POSTMSG(NSLS(@"kSaveImageFail"));
    }
    
    if (succ){
        if (self.draft) {
            [[MyPaintManager defaultManager] deleteMyPaint:self.draft];
            self.draft = nil;
        }
    }    
}

- (void)drawView:(DrawView *)aDrawView didStartTouchWithAction:(DrawAction *)action
{
    [self.layerPanelPopView dismissAnimated:YES];
    [self.upPanelPopView dismissAnimated:YES];

    [[ToolCommandManager defaultManager] hideAllPopTipViews];
    [self.layerPanelPopView dismissAnimated:YES];
    [self.upPanelPopView dismissAnimated:YES];    
    _isNewDraft = NO;

}

- (void)drawView:(DrawView *)view didFinishDrawAction:(DrawAction *)action
{
    // add back auto save for future recovery
    if (![self supportRecovery]){
        return;
    }
    
//    [[DrawRecoveryService defaultService] handleNewPaintDrawed:view.drawActionList];

    [[DrawRecoveryService defaultService] handleNewPaintDrawed:view.drawActionList
                                                   targetUid:self.targetUid
                                                        word:self.word
                                                        desc:self.opusDesc
                                                  canvasSize:drawView.bounds.size
                                                 bgImageName:nil
                                                     bgImage:self.bgImage
                                                   contestId:self.contest.contestId
                                                     strokes:self.draft.strokes
                                                   spendTime:self.draft.spendTime
                                                completeDate:time(0)
                                                      layers:[drawView layers]];
    
    return;
}

- (void)alertCommitContestOpusAsNormalOpus:(NSString *)message
{
    //TODO alert: Submit as the normal opus
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kTips")
                                         message:message
                                           style:CommonDialogStyleDoubleButton];
    [dialog showInView:self.view];
    _commitAsNormal = YES;
    
    [dialog setClickOkBlock:^(id infoView){
        [self showInputAlertView];
    }];
}

- (void)didCreateDraw:(int)resultCode
{
    [self hideActivity];
    [self hideProgressView];
    
    self.submitButton.userInteractionEnabled = YES;
    if (resultCode == 0) {
                
        
        // stop recovery while the opus is commit successfully
        [self stopRecovery];

        // save as normal opus in draft box
        BOOL result = [[DrawDataService defaultService]
                       savePaintWithPBDrawData:self.submitOpusDrawData                                                                          image:self.submitOpusFinalImage
                       word:self.word.text];
        
        if (result) {
            POSTMSG(NSLS(@"kSaveOpusOK"));
            if (self.draft) {
                [[MyPaintManager defaultManager] deleteMyPaint:self.draft];
                self.draft = nil;
            }
        }else{
            POSTMSG(NSLS(@"kSaveImageFail"));
        }
        
        [[TaskManager defaultManager] completeTask:PBTaskIdTypeTaskCreateOpus
                                           isAward:NO
                                        clearBadge:YES];
        
        // clean data
        self.submitOpusFinalImage = nil;
        self.submitOpusDrawData = nil;
        
        CommonDialog *dialog = nil;
        if (self.contest) {
            if (!_commitAsNormal) {
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

        [self shareToWeibo];

    }else if(resultCode == ERROR_CONTEST_END){
        [self alertCommitContestOpusAsNormalOpus:NSLS(@"kContestEnd")];
    }else{
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kSubmitFailure") delayTime:1.5 isSuccessful:NO];
    }

    
}




#pragma mark - Draft

- (PBDraw *)createPBDraw
{
    UserManager *userManager = [UserManager defaultManager];
    NSData *data = [DrawAction buildPBDrawData:[userManager userId]
                                          nick:[userManager nickName]
                                        avatar:[userManager avatarURL]
                                drawActionList:drawView.drawActionList
                                      drawWord:self.word
                                      language:languageType
                                          size:drawView.bounds.size
                                  isCompressed:NO
                                        layers:[[drawView.layers mutableCopy] autorelease]
                                          draft:self.draft];

    PBDraw *pbDraw = [PBDraw parseFromData:data];
    data = nil;
    
    
    return pbDraw;
}



- (NSData *)newDrawDataSnapshot
{
    NSArray* copyLayers = [drawView.layers mutableCopy];
    int64_t strokes = 0;
    NSData* data = [DrawAction pbNoCompressDrawDataCFromDrawActionList:drawView.drawActionList
                                                                  size:drawView.bounds.size
                                                              opusDesc:self.opusDesc
                                                            drawToUser:nil
                                                       bgImageFileName:_bgImageName
                                                                layers:copyLayers
                                                               strokes:&strokes
                                                             spendTime:_designTime.totalTime
                                                          completeDate:time(0)];
    [copyLayers release];
    
    // set stroke in draft for usage
    _totalStroke = strokes;
    
    return data;
}


- (void)setTargetUid:(NSString *)targetUid
{
    if(_targetUid != targetUid){
        PPRelease(_targetUid);
        _targetUid = [targetUid retain];
        if (self.draft) {
            [self.draft setTargetUserId:targetUid];
        }
        
        if ([self supportRecovery]){
            [[DrawRecoveryService defaultService] setTargetUid:targetUid];
        }
    }
}

- (void)saveDraft:(BOOL)showResult
{
    if ([self isBriefStyle]) {
        PPDebug(@"<saveDraft＞ but no need, return directly");
        return;
    }
    
    BOOL isBlank = ([drawView.drawActionList count] == 0);
    if (isBlank && targetType != TypePhoto) {
        CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kBlankDrawTitle") message:NSLS(@"kBlankDraftMessage") style:CommonDialogStyleSingleButton];
        [dialog showInView:self.view];
        return;
    }
    
    PPDebug(@"<OfflineDrawViewController> start to save draft. show result = %d",showResult);
    _isNewDraft = YES;

    NSAutoreleasePool *subPool = [[NSAutoreleasePool alloc] init];
    UIImage *image = [drawView createImage];
    
    BOOL result = NO;

    // pause design calculation
    [self.designTime pause];
    
    @try {
        MyPaintManager *pManager = [MyPaintManager defaultManager];
        if (self.draft) {
            PPDebug(@"<saveDraft> save draft");
            NSData* data = [self newDrawDataSnapshot];
            if ([data length] == 0){
                result = NO;
            }
            else{
                result = YES;
                [self.draft setIsRecovery:@(NO)];
                BOOL forceSave = NO;
                if (![[self.draft opusDesc] isEqualToString:self.opusDesc]) {
                    forceSave = YES;
                    [self.draft setOpusDesc:self.opusDesc];
                }
                if ((![[self.draft drawWord] isEqualToString:self.word.text])) {
                    forceSave = YES;
                    [self.draft setDrawWord:self.word.text];
                }

                [self.draft setStrokes:_totalStroke];
                [self.draft setSpendTime:_designTime.totalTime];
                [self.draft setCompleteDate:time(0)];
                
                result = [pManager updateDraft:self.draft
                                         image:image
                                      drawData:data
                                     forceSave:forceSave];
            }
        }else{
            PPDebug(@"<saveDraft> create core data draft");
            NSData* data = [self newDrawDataSnapshot];
            if ([data length] == 0){
                result = NO;
            }
            else{
                UserManager *userManager = [UserManager defaultManager];
                self.draft = [pManager createDraft:image
                                          drawData:data
                                         targetUid:_targetUid
                                         contestId:self.contest.contestId
                                            userId:[userManager userId]
                                          nickName:[userManager nickName]
                                              word:_word
                                          language:languageType
                                           bgImage:_bgImage
                                       bgImageName:_bgImageName];

                if (self.draft) {
                    result = YES;
                }else{
                    result = NO;
                }

                [self.draft setStrokes:_totalStroke];
                [self.draft setSpendTime:_designTime.totalTime];
                [self.draft setCompleteDate:time(0)];
                
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
    
    // restart calculation
    [self.designTime resume];
    
    [subPool drain];        
}

#pragma mark - Actions
- (void)performSaveDraft
{
    [self saveDraft:YES];
    [self hideActivity];
}

//- (void)saveDraftAndShowResult
//{
//    [self showActivityWithText:NSLS(@"kSaving")];
//    [self performSelector:@selector(performSaveDraft) withObject:nil afterDelay:0.1f];
//}

- (IBAction)clickDraftButton:(id)sender {
    [self.layerPanelPopView dismissAnimated:YES];
    [self.upPanelPopView dismissAnimated:YES];
    if ([[UserService defaultService] checkAndAskLogin:self.view] == YES){
        return;
    }
    
    [self showActivityWithText:NSLS(@"kSaving")];
    [self performSelector:@selector(performSaveDraft) withObject:nil afterDelay:0.01];
    [[AnalyticsManager sharedAnalyticsManager] reportDrawClick:DRAW_CLICK_DRAFT];
}

- (void)setProgress:(CGFloat)progress
{
    PPDebug(@"opus upload progress=%f", progress);

    if (progress == 1.0f){
        // make this because after uploading data, it takes server sometime to process
        progress = 0.99;
    }
    
    NSString* progressText = [NSString stringWithFormat:NSLS(@"kSendingProgress"), progress*100];
    [self showProgressViewWithMessage:progressText progress:progress];
    
//    [self.progressView setLabelText:progressText];
//    
//    [self.progressView setProgress:progress];        
}

- (void)shareViaSNS:(SnsType)type imagePath:(NSString*)imagePath
{    
    NSString* text = [ShareAction createShareText:self.word.text
                                             desc:[self getOpusComment]
                                       opusUserId:[[UserManager defaultManager] userId]
                                       userGender:[[UserManager defaultManager] isUserMale]
                                          snsType:type
                                           opusId:nil];
    
    if (imagePath != nil) {
        
        [[GameSNSService defaultService] publishWeiboAtBackground:type
                                                             text:text
                                                    imageFilePath:imagePath
                                                       awardCoins:[PPConfigManager getCreateOpusWeiboReward]
                                                   successMessage:NSLS(@"kSentWeiboSucc")
                                                   failureMessage:NSLS(@"kSentWeiboFailure")];
        
        
//        [snsService publishWeibo:text imageFilePath:imagePath successBlock:^(NSDictionary *userInfo) {
//            
//            PPDebug(@"%@ publish weibo succ", [snsService snsName]);
//                int earnCoins = [[AccountService defaultService] rewardForShareWeibo];
//                if (earnCoins > 0){
//
//            
//            
//        } failureBlock:^(NSError *error) {
//            PPDebug(@"%@ publish weibo failure", [snsService snsName]);
//        }];
        
//        // follow weibo if NOT followed
//        if ([GameSNSService hasFollowOfficialWeibo:snsService] == NO){
//            [snsService followUser:[snsService officialWeiboId]
//                         userId:[snsService officialWeiboId]
//                   successBlock:^(NSDictionary *userInfo) {
//                       PPDebug(@"follow official weibo success");
//                       [GameSNSService updateFollowOfficialWeibo:snsService];
//                   } failureBlock:^(NSError *error) {
//                       PPDebug(@"follow weibo but error=%@", [error description]);
//                   }];
//        }
        
    }
    
    return;
    
}

- (void)writeTempFile:(UIImage*)image
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    self.tempImageFilePath = [[ShareService defaultService] synthesisImageWithImage:image
                                                                      waterMarkText:[PPConfigManager getShareImageWaterMark]];
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
    return self.opusDesc;
}


- (void)commitOpus:(NSString *)opusName desc:(NSString *)desc share:(NSSet *)share
{
    self.submitOpusDrawData = nil;
    self.submitOpusFinalImage = nil;
    
    self.opusDesc = desc;
    
    UIImage *image = [drawView createImage];
    if(image == nil){
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kImageNull") delayTime:1.5 isHappy:NO];
        return;
    }
    
    [self showProgressViewWithMessage:NSLS(@"kSending")];
    
    self.submitButton.userInteractionEnabled = NO;

    // create temp file for weibo sharing
    [self writeTempFile:image];
    [self setShareWeiboSet:share];    

    NSString *text = self.opusDesc;
    
    if (opusName != nil) {
        [self.word setText:opusName];
    }
    
    NSString *contestId = (_commitAsNormal ? nil : _contest.contestId);
    
    if ([GameApp forceChineseOpus]) {
        languageType = ChineseType;
        
        if ([[UserManager defaultManager] getLanguageType] != ChineseType) {
            self.word = [Word cusWordWithText:@"画"];
            PPDebug(@"You are playing little gee in english, so auto create title");
        }
    }
    
    self.submitOpusFinalImage = image;
    
    [self.designTime pause];
    
    MyPaint* draft = self.draft;
    if (draft == nil){
        draft = [[DrawRecoveryService defaultService] currentPaint]; // use this to carry data
    }
    
    [draft setSpendTime:_designTime.totalTime];
    [draft setCompleteDate:time(0)];
    
    self.submitOpusDrawData = [[DrawDataService defaultService] createOfflineDraw:drawView.drawActionList
                                                  image:image
                                               drawWord:self.word
                                               language:languageType
                                              targetUid:self.targetUid
                                              contestId:contestId
                                                   desc:text                    //@"元芳，你怎么看？"
                                                   size:drawView.bounds.size
                                                 layers:[[drawView.layers mutableCopy] autorelease]
                                                  draft:draft
                                               delegate:self];
    
    if (self.submitOpusDrawData == nil){
        self.submitOpusFinalImage = nil;
    }
    
    [self.designTime resume];
}




- (void)showInputAlertView
{
    NSString *subject = self.word.text;
    NSString *content = self.opusDesc;
    [InputAlert showWithSubject:subject
                        content:content
                         inView:self.view
                          block:^(BOOL confirm, NSString *subject, NSString *content, NSSet *shareSet) {
       
        if (confirm) {
            [self commitOpus:subject desc:content share:shareSet];
        }else{
            self.word.text = subject;
            [self setOpusDesc:content];
        }
    }];
}

- (IBAction)clickSubmitButton:(id)sender {
    [self.layerPanelPopView dismissAnimated:YES];
    [self.upPanelPopView dismissAnimated:YES];
    if ([[UserService defaultService] checkAndAskLogin:self.view] == YES){
        return;
    }    
    
    BOOL isBlank = ([drawView.drawActionList count] == 0);
    
    if (isBlank && targetType != TypePhoto) {
        CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kBlankDrawTitle") message:NSLS(@"kBlankDrawMessage") style:CommonDialogStyleSingleButton];
        [dialog showInView:self.view];
        return;
    }
    
    if (targetType == TypeGraffiti) {
        if (delegate && [delegate respondsToSelector:@selector(didController:submitActionList:canvasSize:drawImage:)]) {
            UIImage *image = [drawView createImage];
            [delegate didController:self
                   submitActionList:drawView.drawActionList
                         canvasSize:drawView.bounds.size
                          drawImage:image];
        }
    }else if (targetType == TypePhoto) {
        if ([delegate respondsToSelector:@selector(didController:submitImage:)]) {
            UIImage *image = [drawView createImage];
            [delegate didController:self submitImage:image];
        }
    }else {
        if(self.contest){
            [self commitContestOpus];
        } else {
            // change by Benson 2014-03-24
            [self showSubmitActionList];
//            [self showInputAlertView];
        }
    }
}

- (void)submitSNS:(PPSNSType)snsType
{
    [self saveDraft:NO];
    
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    NSString* text = [NSString stringWithFormat:NSLS(@"kSubmitShareText"), self.draft.drawWord];
//    NSString* title = self.draft.drawWord;
    int award = [PPConfigManager getShareWeiboReward];
    
    UIImage *image = [drawView createImage];
    if(image == nil){
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kImageNull") delayTime:1.5 isHappy:NO];
        return;
    }
    // create temp file for weibo sharing
    [self writeTempFile:image];
    
//    POSTMSG2(NSLS(@"kSubmittingWeibo"), 2.5);
    
    [[GameSNSService defaultService] publishWeibo:snsType
                                             text:text
                                    imageFilePath:self.tempImageFilePath //[[MyPaintManager defaultManager] imagePathForPaint:self.draft]
                                           inView:self.view
                                       awardCoins:award
                                   successMessage:NSLS(@"kSubmitWeiboSuccAndNext")
                                   failureMessage:NSLS(@"kSubmitWeiboFailure")];
    
    [pool drain];
}

- (void)showSubmitActionList
{
    NSArray* titles = @[ NSLS(@"kPublishXiaoji"), NSLS(@"kPublishSina"), NSLS(@"kPublishTecent"), NSLS(@"kPublishWeixinFriend"), NSLS(@"kPublishWeixinTimeline"), NSLS(@"kCancel") ];
    BBSActionSheet *sheet = [[BBSActionSheet alloc] initWithTitles:titles callback:^(NSInteger index) {
        enum{
            SUBMIT_XIAOJI,
            SUBMIT_SINA,
            SUBMIT_TECENT,
            SUBMIT_WEIXIN_FRIEND,
            SUBMIT_WEIXIN_TIMELINE,
            SUBMIT_CANCEL
        };

        PPSNSType snsType;
        switch (index){
                
            case SUBMIT_WEIXIN_TIMELINE:
                snsType = TYPE_WEIXIN_TIMELINE;
                break;
            
            case SUBMIT_WEIXIN_FRIEND:
                snsType = TYPE_WEIXIN_SESSION;
                break;

            case SUBMIT_TECENT:
                snsType = TYPE_QQ;
                break;

            case SUBMIT_SINA:
                snsType = TYPE_SINA;
                break;
                
            case SUBMIT_CANCEL:
                return;
                
            case SUBMIT_XIAOJI:
            default:
                [self showInputAlertView];
                return;
        }

        [self submitSNS:snsType];
        
    }];
    [sheet showInView:self.view showAtPoint:self.view.center animated:YES];
    [sheet release];
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



- (IBAction)clickUpPanel:(id)sender
{
    [self.layerPanelPopView dismissAnimated:YES];
    
    if (self.upPanelPopView) {
        [self.upPanelPopView dismissAnimated:YES];
    }else{
        self.upPanelPopView = [[[CMPopTipView alloc] initWithCustomView:self.drawToolUpPanel] autorelease];
        [self.upPanelPopView setBackgroundColor:COLOR_YELLOW];
        self.upPanelPopView.cornerRadius = (ISIPAD ? 8 :4);        
        if ([[self.word text] length] != 0) {
            [self.drawToolUpPanel updateSubject:self.word.text];
        }
        [self.upPanelPopView presentPointingAtView:sender inView:self.view animated:YES];
        self.upPanelPopView.delegate = self;
    }
}

- (IBAction)clickLayerButton:(id)sender {
    [self.upPanelPopView dismissAnimated:YES];
    if (self.layerPanelPopView) {
        [self.layerPanelPopView dismissAnimated:YES];
    }else{
        DrawLayerPanel *layerPanel = [DrawLayerPanel drawLayerPanelWithDrawLayerManager:drawView.dlManager];
        self.layerPanelPopView = [[[CMPopTipView alloc] initWithCustomView:layerPanel] autorelease];
        [self.layerPanelPopView setBackgroundColor:COLOR_YELLOW];
        [self.layerPanelPopView presentPointingAtView:sender inView:self.view animated:YES];
        self.layerPanelPopView.cornerRadius = (ISIPAD ? 8 :4);
        self.layerPanelPopView.delegate = self;
    }
}


- (void)alertExit
{
    CommonDialog *dialog = nil;
    
    if (_isNewDraft || [drawView.drawActionList count] == 0) {
        dialog = [CommonDialog createDialogWithTitle:NSLS(@"kQuitGameAlertTitle") message:NSLS(@"kQuitGameAlertMessage") style:CommonDialogStyleDoubleButton delegate:self];
        dialog.tag = DIALOG_TAG_ESCAPE;
    }else{
        dialog = [CommonDialog createDialogWithTitle:NSLS(@"kQuitDrawAlertTitle") message:NSLS(@"kQuitDrawAlertMessage") style:CommonDialogStyleDoubleButtonWithCross delegate:self];
        [dialog.cancelButton setTitle:NSLS(@"kDonotSave") forState:UIControlStateNormal];
        [dialog.oKButton setTitle:NSLS(@"kSave") forState:UIControlStateNormal];
        dialog.tag = DIALOG_TAG_SAVETIP;
    }
    
    [dialog showInView:self.view];
}

- (void)clickBackButton:(id)sender
{
    [self.upPanelPopView dismissAnimated:YES];
    [self.layerPanelPopView dismissAnimated:YES];
    if ([[UserManager defaultManager] hasUser] == NO){
        [self quit];
        return;
    }    
    
    if (targetType == TypeGraffiti || targetType == TypePhoto) {
        if (delegate && [delegate respondsToSelector:@selector(didControllerClickBack:)]) {
            [delegate didControllerClickBack:self];
        }
    }else {
        [self alertExit];
    }
}

#pragma mark - level service delegate
- (void)levelUp:(int)level
{

}

- (void)showCopyPaint
{
    UIImage *image = [self getCopyPaintImage];
    [[ImagePlayer defaultPlayer] playWithImage:image displayActionButton:YES onViewController:self];
}

#pragma mark- Copy Paint Handling

+ (NSString*)getCopyPaintFileName
{
    NSString* COPY_PAINT_IMAGE_PATH = [FileUtil getFileFullPath:@"copy_paint.png"];
    return COPY_PAINT_IMAGE_PATH;
}

- (void)saveCopyPaintImage:(UIImage*)image
{
    if (image == nil)
        return;

    [image saveImageToFile:[OfflineDrawViewController getCopyPaintFileName]];
}

- (UIImage*)getCopyPaintImage
{
    UIImage* image = [UIImage imageWithContentsOfFile:[OfflineDrawViewController getCopyPaintFileName]];
    return image;
}

+ (UIImage*)getDefaultCopyPaintImage
{
    UIImage* image = [UIImage imageWithContentsOfFile:[OfflineDrawViewController getCopyPaintFileName]];
    return image;
}

#pragma mark- DrawLayerManager Delegate
- (void)layerManager:(DrawLayerManager *)manager
didChangeSelectedLayer:(DrawLayer *)selectedLayer
           lastLayer:(DrawLayer *)lastLayer
{
    if (selectedLayer) {
        PPDebug(@"<didChangeSelectedLayer> tag = %d, name = %@",selectedLayer.layerTag, selectedLayer.layerName);
        [self.drawToolPanel updateWithDrawInfo:selectedLayer.drawInfo];
    }
}

- (void)layerManager:(DrawLayerManager *)manager
            didLayer:(DrawLayer *)layer
    changeClipAction:(ClipAction *)action
{
    [self.drawToolPanel updateWithDrawInfo:layer.drawInfo];
}

#pragma mark- CMPopTipView Delegate
- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
    if (popTipView == self.layerPanelPopView) {
        self.layerPanelPopView = nil;
    }else if(self.upPanelPopView == popTipView){
        self.upPanelPopView = nil;
    }

    
}
- (void)popTipViewWasDismissedByCallingDismissAnimatedMethod:(CMPopTipView *)popTipView
{
    if (popTipView == self.layerPanelPopView) {
        self.layerPanelPopView = nil;
    }else if(self.upPanelPopView == popTipView){
        self.upPanelPopView = nil;
    }
}

#pragma mark- DrawToolPanel Delegate
- (void)drawToolPanel:(DrawToolPanel *)panel didClickTool:(UIButton *)toolButton
{
    [self.layerPanelPopView dismissAnimated:YES];
    [self.upPanelPopView dismissAnimated:YES];
}


#define PAGE_BG_TAG 12802101
- (void)setPageBGImage:(UIImage *)image
{
    UIImageView *iv = (id)[self.view viewWithTag:PAGE_BG_TAG];
    if (iv == nil) {
        iv = [[[UIImageView alloc] initWithFrame:self.view.bounds] autorelease];
        iv.autoresizingMask = (1<<6) -1;
        iv.tag = PAGE_BG_TAG;
        [self.view insertSubview:iv atIndex:0];
    }
    [iv setImage:image];
    if (image) {
        [self.view setBackgroundColor:[UIColor whiteColor]];
    }else{
        self.view.backgroundColor = [shareImageManager drawBGColor];        
    }
}
@end
