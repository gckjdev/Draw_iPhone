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

/*

+ (OfflineDrawViewController *)startDraw:(Word *)word fromController:(UIViewController*)fromController
{
    LanguageType language = [[UserManager defaultManager] getLanguageType];
    OfflineDrawViewController *vc = [[OfflineDrawViewController alloc] initWithWord:word lang:language];
    [fromController.navigationController pushViewController:vc animated:YES];
    return [vc autorelease];
}

+ (OfflineDrawViewController *)startDraw:(Word *)word 
   fromController:(UIViewController*)fromController 
        targetUid:(NSString *)targetUid
{
    LanguageType language = [[UserManager defaultManager] getLanguageType];
    OfflineDrawViewController *vc = [[OfflineDrawViewController alloc] initWithWord:word lang:language targetUid:targetUid];
    [fromController.navigationController pushViewController:vc animated:YES];
    PPDebug(@"<StartDraw>: word = %@, targetUid = %@", word.text, targetUid);
    return [vc autorelease];
}

*/
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


#define DEFAULT_COLOR_NUMBER 5

#pragma mark - Update Data

enum{
    YELLOW_COLOR = 0,
    RED_COLOR = 1,  
    BLUE_COLOR,
    BLACK_COLOR,
    COLOR_COUNT
};

- (DrawColor *)randColor
{
    srand(time(0)+ self.hash);
    NSInteger rand = random() % COLOR_COUNT;
    switch (rand) {
        case RED_COLOR:
            return [DrawColor redColor];
        case BLUE_COLOR:
            return [DrawColor blueColor];
        case YELLOW_COLOR:
            return [DrawColor yellowColor];
        case BLACK_COLOR:
        default:
            return [DrawColor blackColor];            
    }
}



- (void)initDrawView
{
    UIView *paperView = [self.view viewWithTag:PAPER_VIEW_TAG];
    drawView = [[DrawView alloc] initWithFrame:DRAW_VIEW_FRAME];
    drawView.strawDelegate = _drawToolPanel;
//    [drawView setTouchActionType:TouchActionTypeGetColor];
    
    [drawView setDrawEnabled:YES];
//    [drawView setRevocationSupported:YES];
    drawView.delegate = self;
    _isNewDraft = YES;
//    _userSaved = NO;
    self.eraserColor = [DrawColor whiteColor];
    if (self.draft) {
        [drawView showDraft:self.draft];
        self.draft.thumbImage = nil;
        NSInteger count = [self.draft.drawActionList count];
        //find the last clean action or change back action
        for (NSInteger i = count - 1; i >= 0; -- i) {
            DrawAction *action = [self.draft.drawActionList objectAtIndex:i];
            if ([action isCleanAction]) {
                break;
            }else if([action isChangeBackAction]){
                self.eraserColor = [DrawColor colorWithColor:[action.paint color]];
                [self.eraserColor setAlpha:1.0];
            }
        }
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
//    UIViewController *superController = _startController;
    
//    if (superController == nil) {
//        superController = [self superShowFeedController];
//    }
//    if (superController == nil) {
//        superController = [self superShareController];
//    }
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

//        UIViewController *superController = [self superShowFeedController];
        
        //if come from feed detail controller
        if (_startController != nil) {
            [self.navigationController popToViewController:_startController animated:NO];
            SelectHotWordController *sc = nil;
            if ([_targetUid length] == 0) {
                sc = [[[SelectHotWordController alloc] init] autorelease];
            }else{
                sc = [[SelectHotWordController alloc] initWithTargetUid:self.targetUid];
            }
            sc.superController = self.startController;
            [_startController.navigationController pushViewController:sc animated:NO];
//            [superController.navigationController pushViewController:sc animated:NO];
//            [sc release];
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


- (void)didStartedTouch:(Paint *)paint
{
    [self.drawToolPanel dismissAllPopTipViews];
    [self updateRecentColors];
    _isNewDraft = NO;
}

#define DRAFT_PAINT_COUNT           [ConfigManager drawAutoSavePaintInterval]
#define DRAFT_PAINT_TIME_INTERVAL   [ConfigManager drawAutoSavePaintTimeInterval]

- (void)didDrawedPaint:(Paint *)paint
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

- (void)didCreateDraw:(int)resultCode
{
    [self hideActivity];
    self.submitButton.userInteractionEnabled = YES;
    [self.inputAlert setCanClickCommitButton:YES];
    if (resultCode == 0) {
        [self.inputAlert dismiss:NO];
        CommonDialog *dialog = nil;
        if (self.contest) {
            self.contest.opusCount ++;
            if (![self.contest joined]) {
                self.contest.participantCount ++;
            }
            [self.contest incCommitCount];
            
            if ([self.contest commitCountEnough]) {
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
        
    }else if(resultCode == ERROR_CONTEST_END){
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kContestEnd") delayTime:1.5 isSuccessful:NO];
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
                      language:languageType];
    return pbDraw;
}

- (PBNoCompressDrawData *)drawDataSnapshot
{
    NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:drawView.drawActionList];
    PBNoCompressDrawData* data = [DrawAction drawActionListToPBNoCompressDrawData:temp];
    PPRelease(temp);
    return data;
}

- (void)saveDraft:(BOOL)showResult
{
    if (targetType == TypeGraffiti) {
        return;
    }
    PPDebug(@"<OfflineDrawViewController> start to save draft. show result = %d",showResult);
//    _unDraftPaintCount = 0;
//    _lastSaveTime = 0;
    _isNewDraft = YES;
    UIImage *image = [drawView createImage];    
    
    __block BOOL result = NO;

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

- (void)commitOpus:(NSNumber *)share
{
    
    [self showActivityWithText:NSLS(@"kSending")];
    self.submitButton.userInteractionEnabled = NO;
    [self.inputAlert setCanClickCommitButton:NO];
    UIImage *image = [drawView createImage];
    NSString *text = self.inputAlert.contentText;
    [[DrawDataService defaultService] createOfflineDraw:drawView.drawActionList
                                                  image:image
                                               drawWord:self.word
                                               language:languageType
                                              targetUid:self.targetUid
                                              contestId:_contest.contestId
                                                   desc:text//@"元芳，你怎么看？"
                                               delegate:self];
    if ([share boolValue]) {
        //TODO share draw to SNS
        PPDebug(@"share draw to SNS");
    }
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
        if(self.contest && [self.contest commitCountEnough]){
            NSString *title = [NSString stringWithFormat:NSLS(@"kContestSummitCountEnough"),_contest.canSubmitCount];
            [[CommonMessageCenter defaultCenter] postMessageWithText:title
                                                           delayTime:1.5
                                                             isHappy:NO];
            return;

        }
        if (self.inputAlert == nil) {
            self.inputAlert = [InputAlertView inputAlertViewWith:NSLS(@"kAddOpusDesc") content:nil target:self commitSeletor:@selector(commitOpus:) cancelSeletor:NULL];
        }
        [self.inputAlert showInView:self.view animated:YES];
    
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
                [self.drawToolPanel updateView];
                break;
            case Pen:
            case Pencil:
            case IcePen:
            case Quill:
            case WaterPen:
            {
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
}

- (void)drawToolPanel:(DrawToolPanel *)toolPanel didClickUndoButton:(UIButton *)button
{
    if ([drawView canRevoke]) {
        _isNewDraft = NO;
        
        [self showActivityWithText:NSLS(@"kRevoking")];
        [self performSelector:@selector(performRevoke) withObject:nil afterDelay:0.1f];
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
    drawView.touchActionType = TouchActionTypeDraw;
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
    drawView.touchActionType = TouchActionTypeDraw;
    if (bought) {
        PPDebug(@"<didSelectPen> pen type = %d",penType);
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
    drawView.touchActionType = TouchActionTypeDraw;
    drawView.lineWidth = width;
    PPDebug(@"<didSelectWidth> width = %f",width);
}
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didSelectColor:(DrawColor *)color
{
    drawView.touchActionType = TouchActionTypeDraw;
    self.tempColor = color;
    self.penColor = color;
    [drawView setLineColor:[DrawColor colorWithColor:color]];
    [drawView.lineColor setAlpha:_alpha];
}
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didSelectAlpha:(CGFloat)alpha
{
    drawView.touchActionType = TouchActionTypeDraw;
    _alpha = alpha;
    if (drawView.lineColor != self.eraserColor) {
        DrawColor *color = [DrawColor colorWithColor:drawView.lineColor];
        color.alpha = alpha;
        drawView.lineColor = color;
    }
}

- (void)drawToolPanel:(DrawToolPanel *)toolPanel startToBuyItem:(ItemType)type
{
//    VendingController *vend = [VendingController instance];
//    [self.navigationController pushViewController:vend animated:YES];
    [CommonItemInfoView showItem:[Item itemWithType:type amount:1] infoInView:self canBuyAgain:YES];
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
