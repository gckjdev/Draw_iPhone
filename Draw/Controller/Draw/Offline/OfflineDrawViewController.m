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
#import "DrawRecoveryService.h"
#import "InputAlertView.h"
#import "AnalyticsManager.h"
#import "SelectHotWordController.h"
#import "MBProgressHUD.h"
#import "GameSNSService.h"
#import "PPSNSIntegerationService.h"
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


#import "ToolCommand.h"
#import "StringUtil.h"
#import "MKBlockActionSheet.h"
#import "DrawToolUpPanel.h"
#import "DrawLayerPanel.h"

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
    [self stopRecovery];
    self.delegate = nil;
    _draft.drawActionList = nil;
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
    PPRelease(_copyPaintImage);
    PPRelease(_layerPanelPopView);
    PPRelease(_upPanelPopView);
    [_upPanelButton release];
    [_titleView release];
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
    [self.submitButton setTitle:NSLS(@"kSubmit") forState:UIControlStateNormal];
    [self.draftButton setTitle:NSLS(@"kSave") forState:UIControlStateNormal];
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
    
    if (targetType == TypeGraffiti || targetType == TypePhoto) {
        self.draftButton.hidden = YES;
        [self.upPanelButton setCenter:self.draftButton.center];
    }
    
}

#define STATUSBAR_HEIGHT 20.0

- (void)initDrawToolPanel
{
    self.drawToolPanel = [DrawToolPanel createViewWithDrawView:drawView];
    CGFloat x = self.view.center.x;
    CGFloat y = CGRectGetHeight([[UIScreen mainScreen] bounds]) - CGRectGetHeight(self.drawToolPanel.bounds) / 2.0 - STATUSBAR_HEIGHT;
    self.drawToolPanel.center = CGPointMake(x, y);
    [self.view addSubview:self.drawToolPanel];
    [self.drawToolPanel setPanelForOnline:NO];    
    [self.drawToolPanel setBackgroundColor:[UIColor clearColor]];
    self.drawToolPanel.delegate = self;
    [self.drawToolPanel bindController:self];
    
    self.drawToolUpPanel = [DrawToolUpPanel createViewWithDrawView:drawView];
    [self.drawToolUpPanel setCenter:CGPointMake(self.view.bounds.size.width-self.drawToolUpPanel.frame.size.width/2, -self.drawToolUpPanel.frame.size.height/2)];
    [self.view addSubview:self.drawToolUpPanel];

//    [self.drawToolUpPanel setPanelForOnline:NO];
    
    [self.drawToolUpPanel.titleLabel setText:([self.word.text length] > 0)?self.word.text:NSLS(@"kDefaultDrawWord")];

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

//- (NSString *)opusDesc
//{
//    if (_opusDesc == nil) {
//        return  self.inputAlert.contentText;
//    }
//    return _opusDesc;
//}

#pragma mark - Auto Recovery Service Methods

- (BOOL)supportRecovery
{
    if (targetType == TypeGraffiti || targetType == TypePhoto){
        return NO;
    }
    
    return YES;
}

- (void)updateDrawRecoveryService
{
    DrawRecoveryService *drs = [DrawRecoveryService defaultService];
    drs.canvasSize = drawView.bounds.size;
    drs.drawActionList = drawView.drawActionList;
    drs.targetUid = self.targetUid;
    drs.desc = self.opusDesc;
    drs.layers = [[[drawView layers] mutableCopy] autorelease];
}

- (void)initRecovery
{
    if (![self supportRecovery])
        return;
    
    DrawRecoveryService *drs = [DrawRecoveryService defaultService];
    drs.userId = [[UserManager defaultManager] userId];
    drs.nickName = [[UserManager defaultManager] nickName];
    drs.contestId = self.contest.contestId;
    drs.word = self.word;
    drs.language = languageType;
    drs.bgImageName = [NSString stringWithFormat:@"%@.png", [NSString GetUUID]];
    drs.bgImage = self.bgImage;
    [self updateDrawRecoveryService];    
    [drs start];
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
        [[DrawRecoveryService defaultService] backup];
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


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initDrawView];
    [self initDrawToolPanel];
    [self initWordLabel];
    [self initSubmitButton];
//    _unDraftPaintCount = 0;
//    _lastSaveTime = time(0);
    _isAutoSave = NO;               // set by Benson, disable this due to complicate multi-thread issue

    [self updateTargetFriend];

    [self initBgImage];
    
    [self initRecovery];
    self.view.backgroundColor = [shareImageManager drawBGColor];
    
    [self.titleView setTarget:self];
    [self.titleView setBackButtonSelector:@selector(clickBackButton:)];
    [self.titleView setLeftButtonImage:[shareImageManager drawBackImage]];
    [self.titleView setBgImage:nil];
    [self.titleView setBackgroundColor:[UIColor clearColor]];
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}


#define ESCAPE_DEDUT_COIN 1
#define DIALOG_TAG_CLEAN_DRAW 201204081
#define DIALOG_TAG_ESCAPE 201204082
#define DIALOG_TAG_SAVETIP 201204083
#define DIALOG_TAG_SUBMIT 201206071
#define DIALOG_TAG_CHANGE_BACK 201207281
#define DIALOG_TAG_COMMIT_OPUS 201208111
#define DIALOG_TAG_COMMIT_AS_NORMAL_OPUS 201302231
//#define DIALOG_TAG_COMPOSE_DIALOG 201302250


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
    else if(dialog.tag == DIALOG_TAG_COMMIT_AS_NORMAL_OPUS)
    {
        [self showInputAlertViewWithSubject:YES];
    }
    else if(dialog.tag == DIALOG_TAG_SUBMIT){

        [[DrawDataService defaultService] savePaintWithPBDraw:[self createPBDraw]
                                                        image:drawView.createImage
                                                     delegate:self];
        
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
//    else if (dialog.tag == DIALOG_TAG_COMPOSE_DIALOG){
//        
//        InputAlertView *v = (InputAlertView *)infoView;
//        [self commitOpus:v.titleInputField.text desc:v.contentInputView.text share:v.shareSet];
//    }
}

- (void)didClickCancel:(CommonDialog *)dialog
{
    if(dialog.tag == DIALOG_TAG_SUBMIT){

        // Save Image Locally
        [[DrawDataService defaultService] savePaintWithPBDraw:[self createPBDraw]
                                                        image:drawView.createImage
                                                     delegate:self];
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
    if ([[ToolCommandManager defaultManager] isPaletteShowing]) {
        [self.drawToolPanel updateRecentColorViewWithColor:aDrawView.drawInfo.penColor updateModel:YES];
    }
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
    
    [[DrawRecoveryService defaultService] handleNewPaintDrawed:view.drawActionList];

    return;
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
//    [self.inputAlert setCanClickCommitButton:YES];
    if (resultCode == 0) {
//        [self.inputAlert dismiss:NO];
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
                                          info:nil];

    PBDraw *pbDraw = [PBDraw parseFromData:data];
    data = nil;
    
    
    return pbDraw;
}



- (NSData *)newDrawDataSnapshot
{

    NSData* data = [DrawAction pbNoCompressDrawDataCFromDrawActionList:drawView.drawActionList
                                                                  size:drawView.bounds.size
                                                              opusDesc:self.opusDesc
                                                            drawToUser:nil
                                                       bgImageFileName:_bgImageName
                                                                layers:[[drawView.layers mutableCopy] autorelease]];
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
    if (targetType == TypeGraffiti || targetType == TypePhoto) {
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
                [self.draft setIsRecovery:[NSNumber numberWithBool:NO]];
                [self.draft setOpusDesc:self.opusDesc];
                result = [pManager updateDraft:self.draft
                                         image:image
                                      drawData:data];
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
    [self.layerPanelPopView dismissAnimated:YES];
    [self.upPanelPopView dismissAnimated:YES];
    if ([[UserService defaultService] checkAndAskLogin:self.view] == YES){
        return;
    }
    
    [self showActivityWithText:NSLS(@"kSaving")];
    [self performSelector:@selector(saveDraftAndShowResult) withObject:nil afterDelay:0.01];
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
    [self.progressView setLabelText:progressText];
    
    [self.progressView setProgress:progress];        
}

- (void)shareViaSNS:(SnsType)type imagePath:(NSString*)imagePath
{

    PPSNSCommonService* snsService = [[PPSNSIntegerationService defaultService] snsServiceByType:type];
    
    NSString* snsOfficialNick = [GameSNSService snsOfficialNick:type];
    NSString* text = nil;
    
    if ([[self getOpusComment] length] > 0){
        text = [NSString stringWithFormat:NSLS(@"kShareMyOpusWithDescriptionText"), [self getOpusComment], snsOfficialNick, self.word.text, [ConfigManager getSNSShareSubject], [ConfigManager getAppItuneLink]];
    }
    else{
        text = [NSString stringWithFormat:NSLS(@"kShareMyOpusWithoutDescriptionText"), snsOfficialNick, self.word.text, [ConfigManager getSNSShareSubject], [ConfigManager getAppItuneLink]];
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
        
        // follow weibo if NOT followed
        if ([GameSNSService hasFollowOfficialWeibo:snsService] == NO){
            [snsService followUser:[snsService officialWeiboId]
                         userId:[snsService officialWeiboId]
                   successBlock:^(NSDictionary *userInfo) {
                       PPDebug(@"follow official weibo success");
                       [GameSNSService updateFollowOfficialWeibo:snsService];
                   } failureBlock:^(NSError *error) {
                       PPDebug(@"follow weibo but error=%@", [error description]);
                   }];
        }
        
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
    return self.opusDesc;
}


- (void)commitOpus:(NSString *)opusName desc:(NSString *)desc share:(NSSet *)share
{
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
    
    
    [[DrawDataService defaultService] createOfflineDraw:drawView.drawActionList
                                                  image:image
                                               drawWord:self.word
                                               language:languageType
                                              targetUid:self.targetUid
                                              contestId:contestId
                                                   desc:text//@"元芳，你怎么看？"
                                                   size:drawView.bounds.size
                                                 layers:[[drawView.layers mutableCopy] autorelease]
                                                   info:nil
                                               delegate:self];

}

- (void)showInputAlertViewWithSubject:(BOOL)hasSubject
{
    InputAlertView *v = nil;
    if ([GameApp forceChineseOpus] && [[UserManager defaultManager] getLanguageType] == ChineseType) {
        BOOL hasSNS = ([LocaleUtils isChina] || [[UserManager defaultManager] hasBindQQWeibo] || [[UserManager defaultManager] hasBindSinaWeibo]);
        
        ComposeInputDialogType type = 0;
        if (hasSubject == YES && hasSNS == YES) {
            type = ComposeInputDialogTypeTitleAndContentWithSNS;
            [v.titleInputField becomeFirstResponder];
            v = [InputAlertView createWithType:type];

        }else if (hasSubject == YES && hasSNS == NO){
            type = ComposeInputDialogTypeTitleAndContent;
            [v.titleInputField becomeFirstResponder];
            v = [InputAlertView createWithType:type];

        }else if (hasSubject == NO && hasSNS == YES){
            type = ComposeInputDialogTypeContentWithSNS;
            [v.contentInputView becomeFirstResponder];
            v = [InputAlertView createWithType:type];

        }else{
            type = ComposeInputDialogTypeContent;
            [v.contentInputView becomeFirstResponder];
            v = [InputAlertView createWithType:type];
        }
        
    } else {
        v = [InputAlertView createWithType:ComposeInputDialogTypeContentWithSNS];
        [v.contentInputView becomeFirstResponder];
    }
    
    [v.titleInputField setText:self.word.text];
    [v.contentInputView setText:self.opusDesc];
    
    
    if ([[UserManager defaultManager] getLanguageType] == EnglishType) {
        [v setMaxTitleLength:[ConfigManager maxDrawEnglishTitleLen]];
    }else{
        [v setMaxTitleLength:[ConfigManager maxDrawChineseTitleLen]];
    }
    
    [v setMaxContentLength:[ConfigManager getMaxLengthOfDrawDesc]];

    
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kAddOpusDesc") customView:v style:CommonDialogStyleDoubleButton];
    
    [dialog showInView:self.view];
    
    [dialog setClickOkBlock:^(id infoView){
        
        if (hasSubject && [v.titleInputField.text length] <= 0) {            
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kOpusNameInvaild") delayTime:1.5];
        }else if (hasSubject
                  && [GameApp forceChineseOpus]
                  && [[UserManager defaultManager] getLanguageType] == ChineseType
                  && !NSStringIsValidChinese(v.titleInputField.text)){
            
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kOnlyChineseTitleAllowed") delayTime:2];            
            
        }else{
            [self commitOpus:v.titleInputField.text desc:v.contentInputView.text share:v.shareSet];
        }
    }];
}

- (IBAction)clickSubmitButton:(id)sender {
    [self.layerPanelPopView dismissAnimated:YES];
    [self.upPanelPopView dismissAnimated:YES];
    if ([[UserService defaultService] checkAndAskLogin:self.view] == YES){
        return;
    }    

    [self stopRecovery];

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
            if ([self.contest commitCountEnough]) {
                NSString *title = [NSString stringWithFormat:NSLS(@"kContestCommitEnoughCommitAsNormal"),_contest.canSubmitCount];
                [self alertCommitContestOpusAsNormalOpus:title];
                return;
            }else if([self.contest isPassed]){
                [self alertCommitContestOpusAsNormalOpus:NSLS(@"kContestEnd")];
                return;
            }
            [self showInputAlertViewWithSubject:NO];
        } else {
            [self showInputAlertViewWithSubject:YES];
        }
        
    }
}

- (IBAction)clickUpPanel:(id)sender
{
    [self.layerPanelPopView dismissAnimated:YES];
    
    if (self.upPanelPopView) {
        [self.upPanelPopView dismissAnimated:YES];
    }else{
        self.upPanelPopView = [[[CMPopTipView alloc] initWithCustomView:self.drawToolUpPanel] autorelease];
        [self.upPanelPopView setBackgroundColor:COLOR_YELLOW];
        if ([[self.word text] length] != 0) {
            [self.drawToolUpPanel.titleLabel setText:self.word.text];
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
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    // Modal
    [browser setCanSave:NO];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:nc animated:YES];
    [browser release];
    [nc release];
}


#pragma mark - mwPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return 1;
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (self.copyPaintImage) {
        return [MWPhoto photoWithImage:self.copyPaintImage];
    }
    return nil;
    
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
@end
