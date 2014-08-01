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
#import "SelectOpusClassViewController.h"
#import "SPUserResizableView.h"
#import "CopyView.h"
#import "Tutorial.pb.h"
#import "PBTutorial+Extend.h"
#import "TutorialCoreManager.h"
#import "UserTutorialService.h"
#import "UserTutorialManager.h"
#import "OpenCVUtils.h"
#import "ImageSimilarityEngine.h"
#import "PBTutorial+Extend.h"
#import "ResultShareAlertPageViewController.h"
#import "TipsPageViewController.h"

@interface OfflineDrawViewController()
{
    DrawView *drawView;                     // 绘画视图
    ShareImageManager *shareImageManager;
    
    TargetType targetType;                  // 绘画作品目的
    
    BOOL _isNewDraft;                       // draft是否是全新草稿，还是从草稿箱加载的
    BOOL _hasNewStroke;                     // 当前是否新绘制的笔画没有保存，默认为否，增加一笔后为是，保存后重置为否
    BOOL _commitAsNormal;                   // 比赛作品转为普通作品提交

    int  _currentHelpIndex;
}

@property(nonatomic, retain) MyPaint *draft;                                // 草稿

@property (retain, nonatomic) IBOutlet UILabel *wordLabel;

// 顶部工具栏按钮
@property (retain, nonatomic) IBOutlet UIButton *draftButton;
@property (retain, nonatomic) IBOutlet UIButton *submitButton;
@property (retain, nonatomic) IBOutlet UIButton *upPanelButton;
@property (retain, nonatomic) IBOutlet UIButton *layerButton;
@property (retain, nonatomic) IBOutlet UIButton *helpButton;

// 工具栏点击弹出控制面板和视图
@property (retain, nonatomic) DrawToolPanel *drawToolPanel;
@property (retain, nonatomic) DrawToolUpPanel *drawToolUpPanel;
@property (retain, nonatomic) CMPopTipView *layerPanelPopView;
@property (retain, nonatomic) CMPopTipView *upPanelPopView;

// 微博分享，图片和路径
@property (retain, nonatomic) NSString *tempImageFilePath;
@property (retain, nonatomic) NSSet *shareWeiboSet;

// 自动备份定时器
@property (assign, nonatomic) NSTimer* backupTimer;         // backup recovery timer

//// 对话框
//@property (retain, nonatomic) CommonDialog* currentDialog;

// 临摹框
@property (retain, nonatomic) CopyView *copyView;
@property (retain, nonatomic) PBUserStage_Builder *userStageBuilder;
@property (retain, nonatomic) PBUserTutorial_Builder *userTutorialBuilder;
@property (retain, nonatomic) PBTutorial *tutorial;
@property (retain, nonatomic) PBStage *stage;

@end


#define BUTTON_FONT_SIZE_ENGLISH (ISIPAD ? 25 : 12)

@implementation OfflineDrawViewController

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
                                          photo:nil
                                       animated:YES];
}

+ (OfflineDrawViewController *)startDraw:(Word *)word
                          fromController:(UIViewController*)fromController
                         startController:(UIViewController*)startController
                               targetUid:(NSString *)targetUid
                                animated:(BOOL)animated
{
    return [OfflineDrawViewController startDraw:word
                                 fromController:fromController
                                startController:startController
                                      targetUid:targetUid
                                          photo:nil
                                       animated:animated];
}

+ (OfflineDrawViewController *)startDraw:(Word *)word
                          fromController:(UIViewController*)fromController
                         startController:(UIViewController*)startController
                               targetUid:(NSString *)targetUid
                                   photo:(UIImage *)photo
{
    return [self startDraw:word
            fromController:fromController
           startController:startController
                 targetUid:targetUid
                     photo:photo
                  animated:YES];
}

+ (OfflineDrawViewController *)startDraw:(Word *)word
                          fromController:(UIViewController*)fromController
                         startController:(UIViewController*)startController
                               targetUid:(NSString *)targetUid
                                   photo:(UIImage *)photo
                                animated:(BOOL)animated
{
    OfflineDrawViewController *vc = [[OfflineDrawViewController alloc] initWithTargetType:TypeDraw
                                                                                 delegate:nil
                                                                          startController:startController
                                                                                  Contest:nil
                                                                             targetUserId:targetUid
                                                                                  bgImage:photo];
    
    [fromController.navigationController pushViewController:vc animated:animated];
    vc.startController = startController;
    PPDebug(@"<StartDraw>: word = %@, targetUid = %@", word.text, targetUid);
    return [vc autorelease];
}

- (void)setDraftTutorialInfo:(PBUserStage*)userStage targetType:(int)type
{
    if (userStage == nil)
        return;
    
    [self.draft setTutorialId:userStage.tutorialId];
    [self.draft setStageId:userStage.stageId];
    [self.draft setStageIndex:@(userStage.stageIndex)];
    [self.draft setChapterIndex:@(userStage.currentChapterIndex)];
    [self.draft setIsForLearn:@(YES)];
    [self.draft setTargetType:@(type)];
    [self.draft setDrawWord:self.stage.name];
    [self.draft setStageName:self.stage.name];
    
    NSString* opusIdForLearn = [userStage getCurrentChapterOpusId];
    [self.draft setChapterOpusId:opusIdForLearn];
}

+ (OfflineDrawViewController*)practice:(UIViewController*)startController
                             userStage:(PBUserStage*)userStage
                          userTutorial:(PBUserTutorial*)userTutorial
{
    int targetType = TypePracticeDraw;
    PBTutorial* tutorial = [[TutorialCoreManager defaultManager] findTutorialByTutorialId:userStage.tutorialId];
    PBStage* stage = [tutorial getStageByIndex:userStage.stageIndex];
    
//    NSString* bgImagePath = [[UserTutorialService defaultService] getBgImagePath:userStage.tutorialId stage:stage];
//    UIImage* bgImage = [[[UIImage alloc] initWithContentsOfFile:bgImagePath] autorelease];

    UIImage* bgImage = [[UserTutorialService defaultService] getBgImage:userStage stage:stage type:targetType];
    
    NSString* draftId = userStage.practiceLocalOpusId;
    MyPaint* draft = [[MyPaintManager defaultManager] findDraftById:draftId];
    
    OfflineDrawViewController *vc = nil;
    if (draft){
        // load from draft
        vc = [[OfflineDrawViewController alloc] initWithDraft:draft startController:startController];
        
        vc.tutorial = tutorial;
        vc.stage = stage;
        
    }
    else{
        vc = [[OfflineDrawViewController alloc] initWithTargetType:targetType
                                                         delegate:nil
                                                  startController:startController
                                                          Contest:nil
                                                     targetUserId:nil
                                                          bgImage:bgImage];

        vc.tutorial = tutorial;
        vc.stage = stage;

        // set draft tutorial info
        [vc setDraftTutorialInfo:userStage targetType:targetType];
    }

    if (userStage){
        vc.userStageBuilder = [PBUserStage builderWithPrototype:userStage];
        [vc.userStageBuilder setPracticeLocalOpusId:vc.draft.draftId];
    }
    
    if (userTutorial){
        vc.userTutorialBuilder = [PBUserTutorial builderWithPrototype:userTutorial];
    }
    
    [startController.navigationController pushViewController:vc animated:YES];
    PPDebug(@"<StartDraw>: practice");
    return [vc autorelease];
}

+ (OfflineDrawViewController*)conquer:(UIViewController*)startController
                            userStage:(PBUserStage*)userStage
                         userTutorial:(PBUserTutorial*)userTutorial
{
    int targetType = TypeConquerDraw;

    PBTutorial* tutorial = [[TutorialCoreManager defaultManager] findTutorialByTutorialId:userStage.tutorialId];
    PBStage* stage = [tutorial getStageByIndex:userStage.stageIndex];
    
//    NSString* bgImagePath = [[UserTutorialService defaultService] getBgImagePath:userStage.tutorialId stage:stage];
//    UIImage* bgImage = [[[UIImage alloc] initWithContentsOfFile:bgImagePath] autorelease];
    
    UIImage* bgImage = [[UserTutorialService defaultService] getBgImage:userStage stage:stage type:targetType];
    
    NSString* draftId = userStage.conquerLocalOpusId;
    MyPaint* draft = [[MyPaintManager defaultManager] findDraftById:draftId];
    
    OfflineDrawViewController *vc = nil;
    if (draft){
        // load from draft
        vc = [[OfflineDrawViewController alloc] initWithDraft:draft startController:startController];
        
        vc.tutorial = tutorial;
        vc.stage = stage;
        
    }
    else{
        vc = [[OfflineDrawViewController alloc] initWithTargetType:targetType
                                                          delegate:nil
                                                   startController:startController
                                                           Contest:nil
                                                      targetUserId:nil
                                                           bgImage:bgImage];
        
        vc.tutorial = tutorial;
        vc.stage = stage;
        
        // set draft tutorial info
        [vc setDraftTutorialInfo:userStage targetType:targetType];
    }
    
    if (userStage){
        vc.userStageBuilder = [PBUserStage builderWithPrototype:userStage];
        [vc.userStageBuilder setConquerLocalOpusId:vc.draft.draftId];
    }
    
    if (userTutorial){
        vc.userTutorialBuilder = [PBUserTutorial builderWithPrototype:userTutorial];
    }
    
    [startController.navigationController pushViewController:vc animated:YES];
    PPDebug(@"<StartDraw>: conquer");
    return [vc autorelease];
}

- (void)dealloc
{
    [UIApplication sharedApplication].idleTimerDisabled = NO; // disable lock screen while in drawing
    [self stopRecovery];
    
    PPRelease(_userStageBuilder);
    PPRelease(_userTutorialBuilder);
    PPRelease(_tutorial);
    PPRelease(_stage);
    
    self.delegate = nil;
    _draft.drawActionList = nil;
    PPRelease(_copyView);
    PPRelease(_selectedClassList);
    PPRelease(_submitOpusFinalImage);
    PPRelease(_submitOpusDrawData);
    PPRelease(_shareWeiboSet);
    
    PPRelease(_tempImageFilePath);
    PPRelease(_drawToolPanel);
    PPRelease(_drawToolUpPanel);
    PPRelease(_wordLabel);
    PPRelease(drawView);
    PPRelease(_draft);
    PPRelease(_contest);
    PPRelease(_draftButton);
    PPRelease(_submitButton);
    PPRelease(_bgImage);
    PPRelease(_bgImageName);
//    PPRelease(_currentDialog);
    PPRelease(_layerPanelPopView);
    PPRelease(_upPanelPopView);
    PPRelease(_designTime);
    PPRelease(_helpButton);
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

- (id)initWithTargetType:(TargetType)aTargetType
                delegate:(id<OfflineDrawDelegate>)aDelegate
         startController:(UIViewController*)startController
                 Contest:(Contest*)contest
            targetUserId:(NSString*)targetUserId
                 bgImage:(UIImage*)bgImage
{
    self = [super init];
    if (self){
        
        // background image for draw
        if (bgImage) {
            self.bgImage = bgImage;
            self.bgImageName = [NSString stringWithFormat:@"%@.png", [NSString GetUUID]];
        }
        
        // create an empty draft
        MyPaintManager *pManager = [MyPaintManager defaultManager];
        UserManager *userManager = [UserManager defaultManager];
        self.draft = [pManager createDraft:nil
                               drawData:nil
                              targetUid:targetUserId
                              contestId:contest.contestId
                                 userId:[userManager userId]
                               nickName:[userManager nickName]
                                   word:[Word wordWithText:@"" level:WordLeveLMedium]
                               language:ChineseType
                                bgImage:_bgImage
                                bgImageName:_bgImageName];
        
        // for delete flag so that it will not show while crash
        [self.draft setDeleteFlag:@(YES)];
        
        self.startController = startController;
        self.delegate = aDelegate;
        self.contest = contest;
        targetType = aTargetType;
        _isNewDraft = YES;
                        
        shareImageManager = [ShareImageManager defaultManager];
    }
    return self;
}

- (id)initWithContest:(Contest *)contest
{
    return [self initWithTargetType:TypeContest
                           delegate:nil
                    startController:nil
                            Contest:contest
                       targetUserId:nil
                            bgImage:nil];
}
 
- (id)initWithDraft:(MyPaint *)draft
    startController:(UIViewController*)startController
{
    self = [super init];
    if (self) {
        self.draft = draft;
        
        // background image for draw
        if (self.draft.bgImageName) {
            self.bgImage = self.draft.bgImage;
            self.bgImageName = self.draft.bgImageName;
        }
        
        self.startController = startController;
        self.delegate = nil;

        targetType = [self.draft getTargetType];
        _isNewDraft = NO;

        if ([draft.contestId length] != 0) {
            self.contest = [[ContestManager defaultManager] ongoingContestById:draft.contestId];
        }
        
        shareImageManager = [ShareImageManager defaultManager];
        
        PPDebug(@"<loadDraft> draft=%@", [_draft description]);
    }
    return self;
}

- (id)initWithTargetType:(TargetType)aTargetType
                delegate:(id<OfflineDrawDelegate>)aDelegate
         startController:(UIViewController*)startController;
{
    return [self initWithTargetType:aTargetType
                           delegate:aDelegate
                    startController:startController
                            Contest:nil
                       targetUserId:nil
                            bgImage:nil];
}


- (void)initDrawView
{
    
    drawView = [[DrawView alloc] initWithFrame:[CanvasRect defaultRect]
                                        layers:[DrawLayer defaultLayersWithFrame:[CanvasRect defaultRect]]];

    [drawView setDrawEnabled:YES];
    drawView.delegate = self;
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
    int initTime = (self.draft == nil) ? 0 : [self.draft.opusSpendTime intValue];
    self.designTime = [[[OpusDesignTime alloc] initWithTime:initTime] autorelease];
    [self.designTime start];

    NSString* opusId = self.draft.chapterOpusId;
    
    if ([self isLearnType]){
        self.copyView = [CopyView createCopyView:self
                                       superView:holder
                                         atPoint:drawView.frame.origin
                                          opusId:opusId
                                       userStage:[self buildUserStage]
                                           stage:self.stage];
    }
}

- (void)setCopyViewInfo
{
    // copy is created in initDrawView, here is just to set the info of copy view
    if ([self isLearnType]){
        [_copyView disableMenu];
    }
    else{
        [_copyView enableMenu];
    }
}

- (NSString*)opusDesc
{
    return self.draft.opusDesc;
}

- (NSString*)opusSubject
{
    NSString *wordText = self.draft.drawWord;
    if (targetType == TypeContest && [wordText length] == 0) {
        wordText = NSLS(@"kContestOpus");
    }
    
    if (wordText == nil){
        return @"";
    }
    
    return wordText;
}

- (Word*)opusWord
{
    return [Word wordWithText:[self opusSubject] level:WordLeveLMedium];
}

// 草稿是否设置过一些信息
- (BOOL)hasSetOpusInfo
{
    return ([self.draft.opusDesc length] > 0) || ([self.draft.drawWord length] > 0) || ([self.draft.targetUserId length] > 0);
}

- (void)initWordLabel
{
    if (targetType == TypeGraffiti || targetType == TypePhoto) {
        self.wordLabel.hidden = YES;
    }else {
        self.wordLabel.hidden = NO;
        
        NSString *wordText = self.draft.drawWord;
        if (targetType == TypeContest && [wordText length] == 0) {
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
    
    if ([self isLearnType]){
        self.draftButton.hidden = YES;
        self.upPanelButton.hidden = YES;
        [self.layerButton setCenter:self.draftButton.center];
        [self.helpButton setCenter:self.upPanelButton.center];
    }
    else{
        [self.helpButton setHidden:YES];
    }
    
    [self updateSubmitButtonForPracticeDraw];
    
    // update title view by buttons
    if ([self isLearnType]){
        CGPoint center = self.titleView.titleLabel.center;
        center.x -= (self.helpButton.frame.size.width*2)/2;
        [self.titleView.titleLabel setCenter:center];
    }
}

- (void)updateSubmitButtonForPracticeDraw
{
    if (targetType != TypePracticeDraw){
        return;
    }
    
    if ([self.stage.chapterList count] <= 1){
        // only one chapter, no "next" button
        return;
    }
    
    int lastChapterIndex = [self.stage.chapterList count] - 1;
    if (self.userStageBuilder.currentChapterIndex >= lastChapterIndex){
        // it's last chapter, use submit button
        [self.submitButton setImage:[shareImageManager drawCommit] forState:UIControlStateNormal];
    }
    else{
        [self.submitButton setImage:[shareImageManager drawNext] forState:UIControlStateNormal];
    }
}

// 是否是绘画作品模式（聊天涂鸦、论坛涂鸦都不属于该模式）
- (BOOL)isBriefStyle
{
    return (targetType == TypeGraffiti || targetType == TypePhoto);
}

// 是否是学画画的闯关或者修炼
- (BOOL)isLearnType
{
    return (targetType == TypePracticeDraw || targetType == TypeConquerDraw);
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
    [self.draft setOpusDesc:opusDesc];
    if ([self supportRecovery]) {
        [[DrawRecoveryService defaultService] setDesc:opusDesc];
    }
}

- (void)setOpusSubject:(NSString *)opusSubject
{
    [self.draft setDrawWord:opusSubject];
}

- (void)setOpusWord:(NSString*)word desc:(NSString *)opusDesc
{
    [self.draft setDrawWord:word];
    [self.draft setOpusDesc:opusDesc];
}

#pragma mark - Auto Recovery Service Methods

- (BOOL)supportRecovery
{
    return (targetType == TypeDraw || targetType == TypeContest);
}

- (void)updateDrawRecoveryService
{
    DrawRecoveryService *drs = [DrawRecoveryService defaultService];
    drs.canvasSize = drawView.bounds.size;
    drs.drawActionList = drawView.drawActionList;
    drs.targetUid = self.draft.targetUserId;
    drs.desc = self.draft.opusDesc;
    drs.word = [self opusWord]; // self.word;
    drs.bgImage = self.bgImage;
    drs.layers = [[[drawView layers] mutableCopy] autorelease];
}

// 初始化备份服务
- (void)initRecovery
{
    if (![self supportRecovery])
        return;
    
    DrawRecoveryService *drs = [DrawRecoveryService defaultService];

    [drs start:drawView.drawActionList
     targetUid:self.draft.targetUserId
          word:[self opusWord]
          desc:self.draft.opusDesc
    canvasSize:drawView.bounds.size
   bgImageName:[NSString stringWithFormat:@"%@.png", [NSString GetUUID]]
       bgImage:self.bgImage
     contestId:self.contest.contestId
       strokes:[self.draft.totalStrokes intValue]
     spendTime:[self.draft.opusSpendTime intValue]
  completeDate:time(0)
        layers:[drawView layers]];
}

// 停止自动备份
- (void)stopRecovery
{
    if (![self supportRecovery])
        return;

    [self stopBackupTimer];
    [[DrawRecoveryService defaultService] stop];
}

// 执行备份操作
- (void)backup:(id)timer
{
    if (![self supportRecovery])
        return;
    
    [self updateDrawRecoveryService];
    if ([[DrawRecoveryService defaultService] needBackup]) {
        [[DrawRecoveryService defaultService] backup:drawView.drawActionList
                                           targetUid:self.draft.targetUserId
                                                word:[self opusWord]
                                                desc:self.draft.opusDesc
                                          canvasSize:drawView.bounds.size
                                         bgImageName:nil
                                             bgImage:self.bgImage
                                           contestId:self.contest.contestId
                                             strokes:[self.draft.totalStrokes longValue]
                                           spendTime:[self.draft.opusSpendTime intValue]
                                        completeDate:time(0)
                                              layers:[drawView layers]];
    }
}

// 开始备份定时器
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

// 停止备份定时器
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

// 获取用户好友数据的delegate回调方法
- (void)didGetUserInfo:(MyFriend *)user resultCode:(NSInteger)resultCode
{
    if (resultCode == 0 && user) {
        [self.drawToolUpPanel updateDrawToUser:user];
    }
}

// 根据“画给好友”ID获取用户数据
- (void)updateTargetFriend
{
    if ([self.draft.targetUserId length] > 0) {
        [[UserService defaultService] getUserSimpleInfoByUserId:self.draft.targetUserId delegate:self];
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

- (void)initTitleView
{
    [self.titleView setTarget:self];
    [self.titleView setBackButtonSelector:@selector(clickBackButton:)];
    [self.titleView setLeftButtonImage:[shareImageManager drawBackImage]];
    [self.titleView setBgImage:nil];
    [self.titleView setBackgroundColor:[UIColor clearColor]];
    
    if (self.userStageBuilder && [self isLearnType]){
        
        // set title
        [self.titleView.titleLabel setTextColor:COLOR_BROWN];
        NSString* title = nil;
        if (targetType == TypeConquerDraw){
            title = NSLS(@"kConquer");
        }
        else{
            title = NSLS(@"kPractice");

            if ([self.stage hasMoreThanOneChapter]){
                title = [title stringByAppendingFormat:@" (%d/%d)",
                         self.userStageBuilder.currentChapterIndex+1,
                         [self.stage.chapterList count]];
            }
        }
        
//        NSString* stageName = self.stage.name;
//        title = [title stringByAppendingFormat:@" - %@", stageName];
        
        
        [self.titleView setTitle:title];
    }
}


- (void)viewDidLoad
{
    // 禁止自动锁屏
    [UIApplication sharedApplication].idleTimerDisabled = YES; // disable lock screen while in drawing
    
    // 设置当前用户作画模式（用于能否使用道具判别）
    [[UserManager defaultManager] setIsLearning:[self isLearnType]];
    
    [super viewDidLoad];
    [self registerUIApplicationNotification];

    // set default draw word
    if ([self.draft.drawWord length] == 0) {
        self.draft.drawWord = [PPConfigManager defaultDrawWord];   // NSLS(@"kDefaultDrawWord")];
    }
    
    [self initDrawView];
    [self initDrawToolPanel];
    [self initWordLabel];
    [self initTitleView];
    [self initSubmitButton];
    [self setCopyViewInfo];

    [self updateTargetFriend];

    [self initBgImage];
    [self initPageBG];

    [self initRecovery];
    [self setCanDragBack:NO];
    
    // TODO update submit/next button status for learn draw (practice only)
    
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
    
    [self setHelpButton:nil];
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
    [self setCanDragBack:NO];
    [self startBackupTimer];
}

- (void)registerUIApplicationNotification
{
    [self registerNotificationWithName:UIApplicationDidEnterBackgroundNotification usingBlock:^(NSNotification *note) {

        if ([self isLearnType]){
            [self saveDraft:NO];
        }
        
        [self.designTime pause];
    }];
    
    [self registerNotificationWithName:UIApplicationWillEnterForegroundNotification usingBlock:^(NSNotification *note) {
        [self.designTime resume];
    }];
}

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

- (void)deleteTempImageFile
{
    if (self.tempImageFilePath){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [FileUtil removeFile:self.tempImageFilePath];
        });
        
        self.tempImageFilePath = nil;
    }
}

- (void)actionsBeforeQuit
{
    [self deleteEmptyDraft];
    [self unregisterAllNotifications];
    [self stopRecovery];
//    [self deleteTempImageFile];
    
    // save draft before quit
    [[MyPaintManager defaultManager] save];
}

// 退出方法，所有退出必须调用本方法以保证正常释放
- (void)quit
{
    [self actionsBeforeQuit];
    
    if (_startController) {
        [self.navigationController popToViewController:_startController animated:YES];
    }else {
        [HomeController returnRoom:self];
    }
}

- (void)drawAnotherOpusForContest
{
    ContestController *contestController =  [self superContestController];
    
    // quit to contest controller
    [self.navigationController popToViewController:contestController
                                          animated:NO];
    
    // re-enter
    [contestController enterDrawControllerWithContest:self.contest
                                             animated:NO];
}

- (void)drawAnotherOpus
{
    [self actionsBeforeQuit];
    if (_startController != nil) {
        
        [_startController retain];
        [self.navigationController popToViewController:_startController animated:NO];
        [OfflineDrawViewController startDraw:nil
                              fromController:_startController
                             startController:_startController
                                   targetUid:nil
                                    animated:NO];
        
        [_startController release];

    }else{

        [self.navigationController popToRootViewControllerAnimated:NO];
        [OfflineDrawViewController startDraw:nil
                              fromController:nil
                             startController:nil
                                   targetUid:nil
                                    animated:NO];
    }
}

/*
- (void)didClickOk:(CommonDialog *)dialog infoView:(id)infoView
{
    if (dialog.tag == DIALOG_TAG_ESCAPE ){
//        [self quit];
    }
    else if (dialog.tag == DIALOG_TAG_SAVETIP)
    {
//        [self saveDraft:NO];
//        [self quit];
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
            if ([self.draft.targetUserId length] == 0) {
                sc = [[[SelectHotWordController alloc] init] autorelease];
            }else{
                sc = [[[SelectHotWordController alloc] initWithTargetUid:self.draft.targetUserId] autorelease];
            }
            sc.superController = self.startController;
            [_startController.navigationController pushViewController:sc animated:NO];
        }else{
            //if come from home controller
            if ([self.draft.targetUserId length] == 0) {
                [HomeController startOfflineDrawFrom:self];
            }else{
                [HomeController startOfflineDrawFrom:self uid:self.draft.targetUserId];
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
 */


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
    [_layerPanelPopView dismissAnimated:YES];
    [_upPanelPopView dismissAnimated:YES];

    [[ToolCommandManager defaultManager] hideAllPopTipViews];
    [_layerPanelPopView dismissAnimated:YES];
    [_upPanelPopView dismissAnimated:YES];

    _hasNewStroke = YES;
    
//    _isNewDraft = NO;

}

- (void)drawView:(DrawView *)view didFinishDrawAction:(DrawAction *)action
{
    // add back auto save for future recovery
    if (![self supportRecovery]){
        return;
    }
    
    [[DrawRecoveryService defaultService] handleNewPaintDrawed:view.drawActionList
                                                   targetUid:self.draft.targetUserId
                                                        word:[self opusWord]
                                                        desc:self.draft.opusDesc
                                                  canvasSize:drawView.bounds.size
                                                 bgImageName:nil
                                                     bgImage:self.bgImage
                                                   contestId:self.contest.contestId
                                                     strokes:[self.draft.totalStrokes longValue]
                                                   spendTime:[self.draft.opusSpendTime intValue]
                                                completeDate:time(0)
                                                      layers:[drawView layers]];
    
    return;
}

- (void)alertCommitContestOpusAsNormalOpus:(NSString *)message
{
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kTips")
                                         message:message
                                           style:CommonDialogStyleDoubleButton];
    _commitAsNormal = YES;
    [dialog setClickOkBlock:^(id infoView){
        [self showInputAlertView];
    }];
    
    [dialog showInView:self.view];
}

- (void)didCreateLearnDraw:(int)resultCode
                    opusId:(NSString *)opusId
                 userStage:(PBUserStage*)userStage
              userTutorial:(PBUserTutorial*)userTutorial
{
    [self hideActivity];
    [self hideProgressView];
    self.submitButton.userInteractionEnabled = YES;
    
    if (resultCode == 0){
        
        if (userStage){
            self.userStageBuilder = [PBUserStage builderWithPrototype:userStage];
        }
        
        if (userTutorial){
            self.userTutorialBuilder = [PBUserTutorial builderWithPrototype:userTutorial];
        }
        
        [self showResultOptionForConquer];
    }
    else{
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kSubmitFailure") delayTime:1.5 isSuccessful:NO];
    }
}

- (void)didCreateDraw:(int)resultCode opusId:(NSString *)opusId
{
    [self hideActivity];
    [self hideProgressView];
    
    self.submitButton.userInteractionEnabled = YES;
    if (resultCode == 0) {
                
        
        // stop recovery while the opus is commit successfully
        [self stopRecovery];

        // save as normal opus in draft box
        BOOL result = [[DrawDataService defaultService] savePaintWithPBDrawData:self.submitOpusDrawData
                                                                          image:self.submitOpusFinalImage
                                                                           word:self.draft.drawWord
                                                                         opusId:opusId];
        
        if (result) {
            POSTMSG(NSLS(@"kSaveOpusOK"));
            if (self.draft) {
                [[MyPaintManager defaultManager] deleteMyPaint:self.draft];
                self.draft = nil;
            }
            
            self.selectedClassList = nil;
            
        }else{
            POSTMSG(NSLS(@"kSaveImageFail"));
        }
        
        [[TaskManager defaultManager] completeTask:PBTaskIdTypeTaskCreateOpus
                                           isAward:NO
                                        clearBadge:YES];
        
        // clean data
        self.submitOpusFinalImage = nil;
        self.submitOpusDrawData = nil;
        
        [[LevelService defaultService] addExp:OFFLINE_DRAW_EXP delegate:self];
        [self shareToWeibo:opusId];
        
        CommonDialog *dialog = nil;
        if (self.contest) {
            if (!_commitAsNormal) {
                // 增加比赛提交作品次数
                [self.contest incCommitCount];
            }
            
            if ([self.contest commitCountEnough] || _commitAsNormal) {
                // 已经达到比赛提交最大作品数目，提示后退出
                dialog = [CommonDialog createDialogWithTitle:NSLS(@"kSubmitSuccTitle") 
                                                     message:NSLS(@"kContestSubmitSuccQuitMsg") 
                                                       style:CommonDialogStyleSingleButton 
                                                    delegate:nil];
                
                [dialog setClickOkBlock:^(id infoView){
                    [self quit];
                }];
                
            }else{
                NSString *title = [NSString stringWithFormat:NSLS(@"kContestSubmitSuccMsg"),
                                   self.contest.retainCommitChance];
                
                dialog = [CommonDialog createDialogWithTitle:NSLS(@"kSubmitSuccTitle") 
                                                     message:title 
                                                       style:CommonDialogStyleDoubleButton 
                                                    delegate:nil];
                
                [dialog setClickOkBlock:^(id infoView){
                    [self drawAnotherOpusForContest];
                }];
                
                [dialog setClickCancelBlock:^(id infoView){
                    [self quit];
                }];
            }
            
//            dialog.tag = DIALOG_TAG_SUBMIT;
            [dialog showInView:self.view];

        }else{
            dialog = [CommonDialog createDialogWithTitle:NSLS(@"kSubmitSuccTitle")
                                                 message:NSLS(@"kSubmitSuccMsg") 
                                                   style:CommonDialogStyleDoubleButton 
                                                delegate:nil];
             
//            dialog.tag = DIALOG_TAG_SUBMIT;
            [dialog setClickOkBlock:^(id infoView){
                [self drawAnotherOpus];
            }];
            
            [dialog setClickCancelBlock:^(id infoView){
                [self quit];
            }];
            
            [dialog showInView:self.view];
        }
        

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
                                      drawWord:[self opusWord]
                                      language:ChineseType
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
                                                              opusDesc:self.draft.opusDesc
                                                            drawToUser:nil
                                                       bgImageFileName:_bgImageName
                                                                layers:copyLayers
                                                               strokes:&strokes
                                                             spendTime:_designTime.totalTime
                                                          completeDate:time(0)];
    [copyLayers release];
    
    // set stroke in draft for usage
    [self.draft setTotalStrokes:@(strokes)];
    
    return data;
}


- (void)setTargetUid:(NSString *)targetUid
{
    [self.draft setTargetUserId:targetUid];
    if ([self supportRecovery]){
        [[DrawRecoveryService defaultService] setTargetUid:targetUid];
    }
}

// 删除空草稿
- (void)deleteEmptyDraft
{
    if (self.draft && [self isEmptyNewDraft]){
        MyPaintManager *pManager = [MyPaintManager defaultManager];
        [pManager deleteMyPaint:self.draft];
        self.draft = nil;
    }
}

- (PBUserStage*)buildUserStage
{
    PBUserStage* userStage = [self.userStageBuilder build];
    if (userStage){
        self.userStageBuilder = [PBUserStage builderWithPrototype:userStage];
    }
    
    return userStage;
}

- (PBUserTutorial*)buildUserTutorial
{
    PBUserTutorial* ut = [self.userTutorialBuilder build];
    if (ut){
        self.userTutorialBuilder = [PBUserTutorial builderWithPrototype:ut];
    }
    
    return ut;
}

- (void)saveDraft:(BOOL)showResult
{
    if ([self isBriefStyle]) {
        PPDebug(@"<saveDraft＞ but no need, return directly");
        return;
    }
    
    BOOL isBlank = ([drawView.drawActionList count] == 0);
    if (isBlank && targetType != TypePhoto && [self isLearnType] == NO) {
        CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kBlankDrawTitle") message:NSLS(@"kBlankDraftMessage") style:CommonDialogStyleSingleButton];
        [dialog showInView:self.view];
        return;
    }
    
    PPDebug(@"<OfflineDrawViewController> start to save draft. show result = %d",showResult);
//    _isNewDraft = YES;

    _hasNewStroke = NO;
    
    NSAutoreleasePool *subPool = [[NSAutoreleasePool alloc] init];
    UIImage *image = [drawView createImage];
    
    BOOL result = NO;

    // pause design calculation
    [self.designTime pause];
    
    @try {
        MyPaintManager *pManager = [MyPaintManager defaultManager];
        if (self.draft) {
            
            // clear delete flag
            [self.draft setDeleteFlag:@(NO)];

            PPDebug(@"<saveDraft> save draft");
            NSData* data = [self newDrawDataSnapshot];
            if ([data length] == 0){
                result = NO;
            }
            else{
                result = YES;
                [self.draft setIsRecovery:@(NO)];
                [self.draft setOpusSpendTime:@(_designTime.totalTime)];
                [self.draft setOpusCompleteDate:[NSDate date]];
                
                result = [pManager updateDraft:self.draft
                                         image:image
                                      drawData:data
                                     forceSave:YES];
                
                PPDebug(@"<saveDraft> draft=%@", [_draft description]);
            }
            
            if ([self isLearnType]){
                [[UserTutorialManager defaultManager] updateUserStage:[self buildUserStage]];
            }
            
        }else{
            PPDebug(@"<saveDraft> but draft is nil");
            
            // 以下代码理论上已经不可能执行了，因为所有初始化时候一定会创建一个草稿，暂时保留
            /*
            PPDebug(@"<saveDraft> create core data draft");
            NSData* data = [self newDrawDataSnapshot];
            if ([data length] == 0){
                result = NO;
            }
            else{
                UserManager *userManager = [UserManager defaultManager];
                self.draft = [pManager createDraft:image
                                          drawData:data
                                         targetUid:self.draft.targetUserId
                                         contestId:self.contest.contestId
                                            userId:[userManager userId]
                                          nickName:[userManager nickName]
                                              word:[self opusWord]
                                          language:ChineseType
                                           bgImage:_bgImage
                                       bgImageName:_bgImageName];

                if (self.draft) {
                    result = YES;
                }else{
                    result = NO;
                }

                [self.draft setOpusSpendTime:@(_designTime.totalTime)];
                [self.draft setOpusCompleteDate:[NSDate date]];
            }
            */
                        
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
}

- (void)shareViaSNS:(SnsType)type imagePath:(NSString*)imagePath opusId:(NSString*)opusId
{    
    NSString* text = [ShareAction createShareText:[self opusSubject]
                                             desc:[self getOpusComment]
                                       opusUserId:[[UserManager defaultManager] userId]
                                       userGender:[[UserManager defaultManager] isUserMale]
                                          snsType:type
                                           opusId:opusId];
    
    if (imagePath != nil) {
        
        [[GameSNSService defaultService] publishWeiboAtBackground:type
                                                             text:text
                                                    imageFilePath:imagePath
                                                       awardCoins:[PPConfigManager getCreateOpusWeiboReward]
                                                   successMessage:NSLS(@"kSentWeiboSucc")
                                                   failureMessage:NSLS(@"kSentWeiboFailure")];
        
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

- (void)writeTempFile:(UIImage*)image hasWaterMark:(BOOL)hasWaterMark
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    self.tempImageFilePath = [[ShareService defaultService] synthesisImageWithImage:image
                                                                      waterMarkText:(hasWaterMark ? [PPConfigManager getShareImageWaterMark] : @"")];
    [pool drain];
}

- (void)shareToWeibo:(NSString*)opusId
{
    for (NSNumber *value in self.shareWeiboSet) {
        [self shareViaSNS:[value integerValue] imagePath:self.tempImageFilePath opusId:opusId];
    }
    
    self.shareWeiboSet = nil;
}

- (NSString*)getOpusComment
{
    return self.draft.opusDesc;
}


- (void)commitOpus:(NSString *)opusName desc:(NSString *)desc share:(NSSet *)share classList:(NSArray*)classList
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

    NSString *text = self.draft.opusDesc;
    
    if (opusName != nil) {
        [self.draft setDrawWord:opusName];
    }
    
    NSString *contestId = (_commitAsNormal ? nil : _contest.contestId);
    
    self.submitOpusFinalImage = image;
    
    [self.designTime pause];
    
    MyPaint* draft = self.draft;
    if (draft == nil){
        draft = [[DrawRecoveryService defaultService] currentPaint]; // use this to carry data
    }
    
    [draft setOpusSpendTime:@(_designTime.totalTime)];
    [draft setOpusCompleteDate:[NSDate date]];
    [draft setSelectedClassList:self.selectedClassList];
    
    self.submitOpusDrawData = [[DrawDataService defaultService] createOfflineDraw:drawView.drawActionList
                                                  image:image
                                               drawWord:[self opusWord]
                                               language:ChineseType
                                              targetUid:self.draft.targetUserId
                                              contestId:contestId
                                                   desc:text
                                                   size:drawView.bounds.size
                                                 layers:[[drawView.layers mutableCopy] autorelease]
                                                  draft:draft
                                              userStage:nil
                                           userTutorial:nil
                                               delegate:self];
    
    if (self.submitOpusDrawData == nil){
        self.submitOpusFinalImage = nil;
    }
    
    [self.designTime resume];
}




- (void)showInputAlertView
{
    NSString *subject = [self opusSubject];
    NSString *content = self.draft.opusDesc;
    [InputAlert showWithSubject:subject
                        content:content
                         inView:self.view
                          block:^(BOOL confirm, NSString *subject, NSString *content, NSSet *shareSet) {
       
        if (confirm) {
            
            [self setOpusWord:subject desc:content];

            // TODO need to disable for release
//            [self commitOpus:subject desc:content share:shareSet classList:nil];
            
            // show set opus class
            [SelectOpusClassViewController showInViewController:self
                                                   selectedTags:self.selectedClassList
                                              arrayForSelection:nil
                                                       callback:^(int resultCode, NSArray *selectedArray, NSArray *arrayForSelection) {

                                                           self.selectedClassList = selectedArray;
                                                           [self commitOpus:subject desc:content share:shareSet classList:selectedArray];

                                                       }];
            
        }else{
            [self setOpusWord:subject desc:content];
        }
    }];
}

- (NSString*)writeImageToFile:(UIImage*)sourceImage filePath:(NSString*)fileName
{
    NSString* path = [NSString stringWithFormat:@"%@/%@.jpg", NSTemporaryDirectory(), fileName];
    PPDebug(@"<writeImageToFile> path=%@", path);
    UIImage* image = sourceImage;
    BOOL result=[[image data] writeToFile:path atomically:YES];
    if (result) {
        return path;
    }
    return nil;
}

- (int)scoreSourceImage:(UIImage*)source destImage:(UIImage*)dest
{
    return 0;
}

- (BOOL)isPassPractice:(int)score
{
    return [[UserTutorialManager defaultManager] isPass:score];
}

- (BOOL)isPassConquer:(int)score
{
    return [[UserTutorialManager defaultManager] isPass:score];
}


- (NSInteger) strokeLimitWithMinStrokeNum:(NSInteger)minStrokeNum
                              MinPointNum:(NSInteger)minPointNum;
{
    //  提交按钮的预处理
    NSInteger effetiveAction = 0;

    for(DrawAction *da in drawView.drawActionList)
    {
        if ([da isPaintAction]){
            PaintAction *pa=da;
            if((pa.paint.color.red!=1.0 || pa.paint.color.green!=1.0
                            || pa.paint.color.blue!=1.0)
                    && [pa pointCount] > minPointNum)
                effetiveAction++;
        }
        if ([da isChangeBGAction]) {
            ChangeBackAction *cba=da;
            if(cba.color.red==1.0 && cba.color.green==1.0 && cba.color.blue==1.0)
                effetiveAction=0;
            else
                effetiveAction++;
        }
        if ([da isShapeAction]) {
            ShapeAction *sa=da;
            if (sa.shape.color.red == 1.0 && sa.shape.color.green == 1.0
                && sa.shape.color.blue == 1.0);
            else
                effetiveAction++;
            }
    }

    if(effetiveAction<minStrokeNum){
        return (minStrokeNum - effetiveAction);
        PPDebug(@"too few strokes!");
    }
    else
        return 0;
}


- (BOOL)isGotoNextChapter
{
    if (targetType != TypePracticeDraw){
        return NO;
    }
    
    if ([self.stage.chapterList count] <= 1){
        // only one chapter, no "next" button
        return NO;
    }
    
    int lastChapterIndex = [self.stage.chapterList count] - 1;
    if (self.userStageBuilder.currentChapterIndex >= lastChapterIndex){
        // it's last chapter, use submit button
        return NO;
    }
    else{
        return YES;
    }
}

- (void)gotoNextChapter
{
    int nextChapterIndex = self.userStageBuilder.currentChapterIndex + 1;
    
    // update user stage (currentChapterIndex) and save user tutorial
    [self.userStageBuilder setCurrentChapterIndex:nextChapterIndex];
    
    // save into DB
    PBUserTutorial* newUT = [[UserTutorialManager defaultManager] updateUserStage:[self buildUserStage]];
    if (newUT == nil){
        return;
    }
    
    // update user tutorial builder
    self.userTutorialBuilder = [PBUserTutorial builderWithPrototype:newUT];
    
    // reset tips index
    _currentHelpIndex = 0;
    
    // update copy view
    [_copyView loadData:[self buildUserStage] stage:self.stage];
    
    // update button image
    [self updateSubmitButtonForPracticeDraw];
    
    // TODO post a message?
}

- (void)handleSubmitForLearnDraw
{
    //  笔画数预处理
    NSInteger minus =
    [self strokeLimitWithMinStrokeNum:[PPConfigManager getMinStrokeNum]
                          MinPointNum:[PPConfigManager getMinPointNum]];

    if ([self isGotoNextChapter]){
        [self gotoNextChapter];
        return;
    }
    
    self.submitOpusDrawData = nil;
    self.submitOpusFinalImage = nil;
    
    UIImage *image = [drawView createImage];
    if(image == nil){
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kImageNull") delayTime:1.5 isHappy:NO];
        return;
    }
    
    // 如果下面代码有推出，记得这里配合处理... userInteractionEnabled=YES
    self.submitButton.userInteractionEnabled = NO;
    
    // create temp image file for weibo sharing
    [self writeTempFile:image hasWaterMark:NO];
    self.submitOpusFinalImage = image;
    
    // save last conquer opus image
    [[UserTutorialService defaultService] saveTutorialImage:[self buildUserStage]
                                                      image:self.submitOpusFinalImage
                                                       type:targetType];
    
    [self.designTime pause];
    
    MyPaint* draft = self.draft;
    [draft setOpusSpendTime:@(_designTime.totalTime)];
    [draft setOpusCompleteDate:[NSDate date]];
    [draft setSelectedClassList:self.selectedClassList];
    
    UIImage* imageForCompare = [_copyView imageForCompare];
    
    // 评分
    NSString* sourcePath = [self writeImageToFile:imageForCompare filePath:self.draft.draftId];
    NSString* destPath = self.tempImageFilePath;
    
    //从关卡传入difficulty，stage.scoreEngine,区分一般画和简笔画;从预处理传入minus
    //TODO
    int score = [ImageSimilarityEngine scoreSrcPath:sourcePath
                                           destPath:destPath
                                         difficulty:_stage.difficulty
                                              minus:minus
                                               type:_stage.scoreEngine];
    
    [self.draft setScore:@(score)];
    [self.draft setScoreDate:[NSDate date]];
    
    [self saveDraft:NO];
    
//    NSData *drawData = [DrawAction buildPBDrawData:[[UserManager defaultManager] userId]
//                                              nick:[[UserManager defaultManager] nickName]
//                                            avatar:[[UserManager defaultManager] avatarURL]
//                                    drawActionList:drawView.drawActionList
//                                          drawWord:[self opusWord]
//                                          language:ChineseType
//                                              size:drawView.bounds.size
//                                      isCompressed:NO
//                                            layers:[[drawView.layers mutableCopy] autorelease]
//                                             draft:draft];
//    
//    self.submitOpusDrawData = drawData;
//    PPDebug(@"<handleSubmitForPractice> create draw data length=%d", [drawData length]);
//    
//    if (self.submitOpusDrawData == nil){
//        // clear image if create data failure
//        self.submitOpusFinalImage = nil;
//    }

    if (targetType == TypeConquerDraw){
        [self showProgressViewWithMessage:NSLS(@"kSending")];
        self.submitOpusDrawData = [[DrawDataService defaultService] createOfflineDraw:drawView.drawActionList
                                                                                image:image
                                                                             drawWord:[self opusWord]
                                                                             language:ChineseType
                                                                            targetUid:nil
                                                                            contestId:nil
                                                                                 desc:self.draft.opusDesc
                                                                                 size:drawView.bounds.size
                                                                               layers:[[drawView.layers mutableCopy] autorelease]
                                                                                draft:draft
                                                                            userStage:[self buildUserStage]
                                                                         userTutorial:[self buildUserTutorial]
                                                                             delegate:self];
    }
    else{
        self.submitButton.userInteractionEnabled = YES;
    }
    
    if (self.submitOpusDrawData == nil){
        self.submitOpusFinalImage = nil;
    }
    
    [self.designTime resume];
    
    if (targetType == TypePracticeDraw){
        [self showResultOptionForPractice];
    }
    

    
}

- (void)showResultOptionForConquer
{
    PBUserStage* userStage = [self buildUserStage];
    int score = [self.draft.score intValue];
    
    // invoke show result view here, pass user stage, image as parameter
    
    [ResultShareAlertPageViewController show:self
                                       image:self.submitOpusFinalImage
                                   userStage:[self buildUserStage]
                                       score:score
                                   nextBlock:^{
                                       
                                       PPDebug(@"next Block");
                                       [self tryConquerNext];
                                       
                                   } retryBlock:^{
                                       
                                       [self conquerAgain];
                                       
                                   } backBlock:^{
                                       
                                       [self quit];
                                   }];
     return;
    
    
    
    // the following code is just used for reference.
    
    // 根据评分结果跳转
    int defeatPercent = [userStage defeatPercent];
    if ([self isPassPractice:score]){
        
        BOOL isTutorialComplete = [[UserTutorialManager defaultManager] isLastStage:[self buildUserStage]];
        if (isTutorialComplete){
            // 及格，最后一关
            NSString* message = [NSString stringWithFormat:NSLS(@"kConquerPassWithComplete"), score, defeatPercent];
            CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"kConquerResult")
                                                               message:message
                                                                 style:CommonDialogStyleSingleButton];
            
            [dialog setClickOkBlock:^(id view){
                [self quit];
            }];
            
            [dialog showInView:self.view];
            return;
        }
        
        // 及格，提示闯下一关
        NSString* message = [NSString stringWithFormat:NSLS(@"kConquerPass"), score, defeatPercent];
        CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"kConquerResult")
                                                           message:message
                                                             style:CommonDialogStyleDoubleButton];
        
        [dialog.oKButton setTitle:NSLS(@"kTryConquerNext") forState:UIControlStateNormal];
        [dialog.cancelButton setTitle:NSLS(@"Back") forState:UIControlStateNormal];
        
        [dialog setClickCancelBlock:^(id view){
            [self quit];
        }];
        
        [dialog setClickOkBlock:^(id view){
            [self tryConquerNext];
        }];
        
        [dialog showInView:self.view];
    }
    else{
        // 闯关失败，建议再来一次
        NSString* message = [NSString stringWithFormat:NSLS(@"kConquerFail"), score, defeatPercent];
        CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"kConquerResult")
                                                           message:message
                                                             style:CommonDialogStyleDoubleButton];
        
        [dialog.oKButton setTitle:NSLS(@"kConquerAgain") forState:UIControlStateNormal];
        [dialog.cancelButton setTitle:NSLS(@"Back") forState:UIControlStateNormal];
        
        [dialog setClickCancelBlock:^(id view){
            [self quit];
        }];
        
        [dialog setClickOkBlock:^(id view){
            [self conquerAgain];
        }];
        
        [dialog showInView:self.view];
    }
}

- (void)showResultOptionForPractice
{
    int score = [self.draft.score intValue];
    
    // 根据评分结果跳转
    if ([[UserTutorialManager defaultManager] isPass:score]){
        // 修炼及格，提示闯关
        NSString* message = [NSString stringWithFormat:NSLS(@"kPracticePass"), score];
        CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"kPracticeResult")
                                                           message:message
                                                             style:CommonDialogStyleDoubleButton];
        
        [dialog.oKButton setTitle:NSLS(@"kTryConquer") forState:UIControlStateNormal];
        [dialog.cancelButton setTitle:NSLS(@"Back") forState:UIControlStateNormal];
        
        [dialog setClickCancelBlock:^(id view){
            [self quit];
        }];
        
        [dialog setClickOkBlock:^(id view){
            [self tryConquer];
        }];
        
        [dialog showInView:self.view];
    }
    else{
        // 修炼不及格，建议再来一次
        NSString* message = [NSString stringWithFormat:NSLS(@"kPracticeFail"), score];
        CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"kPracticeResult")
                                                           message:message
                                                             style:CommonDialogStyleDoubleButton];
        
        [dialog.oKButton setTitle:NSLS(@"kPracticeAgain") forState:UIControlStateNormal];
        [dialog.cancelButton setTitle:NSLS(@"Back") forState:UIControlStateNormal];
        
        [dialog setClickCancelBlock:^(id view){
            [self quit];
        }];
        
        [dialog setClickOkBlock:^(id view){
            [self practiceAgain];
        }];
        
        [dialog showInView:self.view];
    }
}

- (void)conquerAgain
{
    // 再来一次
    [self.draft setDeleteFlag:@(YES)]; // delete current draft
    [self.userStageBuilder setConquerLocalOpusId:nil];              // TODO clear local opus Id
    PBUserStage* userStage = [self buildUserStage];
    PBUserTutorial* userTutorial = [self buildUserTutorial];
    
    [self actionsBeforeQuit];
    [self.navigationController popViewControllerAnimated:NO];
    
    [[UserTutorialService defaultService] enterConquerDraw:self.startController
                                              userTutorial:userTutorial
                                                   stageId:userStage.stageId
                                                stageIndex:userStage.stageIndex];
    
//    [OfflineDrawViewController conquer:self.startController userStage:userStage userTutorial:userTutorial];
}

// 闯关模式下，尝试下一关
- (void)tryConquerNext
{
    [self.draft setDeleteFlag:@(YES)]; // delete current draft
    
    PBUserStage* userStage = [self buildUserStage];
    
    PBUserTutorial* userTutorial = [self buildUserTutorial];
    
    PBStage* nextStage = [self.tutorial nextStage:userStage.stageIndex];
    if (nextStage == nil){
        // no next stage, end.
        return;
    }
    
    [self actionsBeforeQuit];
    [self.navigationController popViewControllerAnimated:NO];
    
    [[UserTutorialService defaultService] enterConquerDraw:self.startController
                                              userTutorial:userTutorial
                                                   stageId:nextStage.stageId
                                                stageIndex:userStage.stageIndex + 1];
}

// 修炼模式下，尝试闯关
- (void)tryConquer
{
    [self.draft setDeleteFlag:@(YES)]; // delete current draft

    PBUserStage* userStage = [self buildUserStage];
    PBUserTutorial* userTutorial = [self buildUserTutorial];
    
    [self actionsBeforeQuit];
    [self.navigationController popViewControllerAnimated:NO];
    
    [[UserTutorialService defaultService] enterConquerDraw:self.startController
                                              userTutorial:userTutorial
                                                   stageId:userStage.stageId
                                                stageIndex:userStage.stageIndex];
}

// 修炼模式下，重新修炼
- (void)practiceAgain
{
    // 再来一次
    [self.draft setDeleteFlag:@(YES)]; // delete current draft
    [self.userStageBuilder setPracticeLocalOpusId:nil];            // TODO clear local opus Id
    PBUserStage* userStage = [self buildUserStage];
    PBUserTutorial* userTutorial = [self buildUserTutorial];

    // quit current
    [self actionsBeforeQuit];
    [self.navigationController popViewControllerAnimated:NO];
    
    // start new
    [[UserTutorialService defaultService] enterPracticeDraw:self.startController
                                               userTutorial:userTutorial
                                                    stageId:userStage.stageId
                                                 stageIndex:userStage.stageIndex];
    
//    [OfflineDrawViewController practice:self.startController userStage:userStage userTutorial:userTutorial];
}

- (IBAction)clickNextChapterButton:(id)sender
{
    // for learn draw practice mode
    if (targetType != TypePracticeDraw){
        PPDebug(@"<clickNextChapterButton> NOT IN PRACTICE MODE!!!!!");
        return;
    }

    // next chapter
    PBUserStage* newUserStage = [[UserTutorialService defaultService] nextChapter:[self buildUserStage]];
    if (newUserStage == nil){
        // no new user stage, next failure!!!
        return;
    }

    // update user stage here
    self.userStageBuilder = [PBUserStage builderWithPrototype:newUserStage];
    
    // update copy view
    [_copyView loadData:[self buildUserStage] stage:self.stage];
    
    // TODO update submit/next button status
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
        if (_delegate && [_delegate respondsToSelector:@selector(didController:submitActionList:canvasSize:drawImage:)]) {
            UIImage *image = [drawView createImage];
            [_delegate didController:self
                   submitActionList:drawView.drawActionList
                         canvasSize:drawView.bounds.size
                          drawImage:image];
        }
    }else if (targetType == TypePhoto) {
        if ([_delegate respondsToSelector:@selector(didController:submitImage:)]) {
            UIImage *image = [drawView createImage];
            [_delegate didController:self submitImage:image];
        }
    }
    else if ([self isLearnType]){
        // 学画画闯关或者修炼
        [self handleSubmitForLearnDraw];
    }
    else {
        if(self.contest){
            [self commitContestOpus];
        } else {
            // change by Benson 2014-03-24
            // [self showSubmitActionList];  // disable again on 2014-06-10
            [self showInputAlertView];
        }
    }
}

- (void)submitSNS:(PPSNSType)snsType
{
    [self saveDraft:NO];
    
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    NSString* text = [NSString stringWithFormat:NSLS(@"kSubmitShareText"), self.draft.drawWord];
    int award = [PPConfigManager getShareWeiboReward];
    
    UIImage *image = [drawView createImage];
    if(image == nil){
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kImageNull") delayTime:1.5 isHappy:NO];
        return;
    }
    // create temp file for weibo sharing
    [self writeTempFile:image];
    
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


// 点击画画设置按钮
- (IBAction)clickUpPanel:(id)sender
{
    [self.layerPanelPopView dismissAnimated:YES];
    
    if (self.upPanelPopView) {
        [self.upPanelPopView dismissAnimated:YES];
    }else{
        self.upPanelPopView = [[[CMPopTipView alloc] initWithCustomView:self.drawToolUpPanel] autorelease];
        [self.upPanelPopView setBackgroundColor:COLOR_YELLOW];
        self.upPanelPopView.cornerRadius = (ISIPAD ? 8 :4);        
        if ([self.draft.drawWord length] != 0) {
            [self.drawToolUpPanel updateSubject:self.draft.drawWord];
        }
        [self.upPanelPopView presentPointingAtView:sender inView:self.view animated:YES];
        self.upPanelPopView.delegate = self;
    }
}

// 点击帮助按钮
- (IBAction)clickHelpButton:(id)sender
{
    NSMutableArray* allTips = [NSMutableArray array];
    int currentChapterTipsIndex = 0;
    for (int i=0; i<=_userStageBuilder.currentChapterIndex && i<[self.stage.chapterList count]; i++){
        NSArray* tipsPaths = [[UserTutorialService defaultService] getChapterTipsImagePath:_userStageBuilder.tutorialId
                                                                                     stage:self.stage
                                                                              chapterIndex:i];

        if (tipsPaths){
            if (i == _userStageBuilder.currentChapterIndex){
                currentChapterTipsIndex = [allTips count];
                [allTips addObjectsFromArray:tipsPaths];
            }
            else{
                [allTips addObjectsFromArray:tipsPaths];
            }
        }
    }
    
    if (_currentHelpIndex == 0){ // default
        _currentHelpIndex = currentChapterTipsIndex;
    }
    
    NSString* title = NSLS(@"kCopyViewHelp");
    
    if ([allTips count] > 0){
        [TipsPageViewController show:self
                               title:title
                      imagePathArray:allTips
                        defaultIndex:_currentHelpIndex
                         returnIndex:&_currentHelpIndex];
    }
    else{
        POSTMSG(NSLS(@"kNoTipsForChapter"));
    }
}


// 点击图层按钮
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

// 是否是新建草稿（而不是从已有草稿加载），并且当前没有任何笔画
- (BOOL)isEmptyNewDraft
{
    return (_isNewDraft && [drawView.drawActionList count] == 0);
}

// 退出询问
- (void)alertExit
{
    CommonDialog *dialog = nil;
    
    if ((_hasNewStroke == NO) || ([drawView.drawActionList count] == 0)) {
        // 没有画任何新笔画，或者画画内容为空，只询问是否退出
        dialog = [CommonDialog createDialogWithTitle:NSLS(@"kQuitGameAlertTitle")
                                             message:NSLS(@"kQuitGameAlertMessage")
                                               style:CommonDialogStyleDoubleButton
                                            delegate:nil];
//        dialog.tag = DIALOG_TAG_ESCAPE;
        [dialog setClickOkBlock:^(id infoView){
            [self quit];
        }];
        
    }
    else
    {
        // 询问是否保存后退出
        dialog = [CommonDialog createDialogWithTitle:NSLS(@"kQuitDrawAlertTitle") message:NSLS(@"kQuitDrawAlertMessage") style:CommonDialogStyleDoubleButtonWithCross delegate:self];
        [dialog.cancelButton setTitle:NSLS(@"kDonotSave") forState:UIControlStateNormal];
        [dialog.oKButton setTitle:NSLS(@"kSave") forState:UIControlStateNormal];
//        dialog.tag = DIALOG_TAG_SAVETIP;
        [dialog setClickOkBlock:^(id infoView){
            [self saveDraft:NO];
            [self quit];
        }];

        [dialog setClickCancelBlock:^(id infoView){
            [self quit];
        }];

    }
    
    [dialog showInView:self.view];
}

- (void)clickBackButton:(id)sender
{
    
    // 关闭弹窗
    [self.upPanelPopView dismissAnimated:YES];
    [self.layerPanelPopView dismissAnimated:YES];
    
    if ([[UserManager defaultManager] hasUser] == NO){
        // 没有注册过，直接退出
        [self quit];
        return;
    }    
    
    if ([self isLearnType]){
        [self saveDraft:NO];
        [self quit];
    }
    else if (targetType == TypeGraffiti || targetType == TypePhoto) {
        // 聊天涂鸦或者是在照片上画画，调用回调方法
        if (_delegate && [_delegate respondsToSelector:@selector(didControllerClickBack:)]) {
            [_delegate didControllerClickBack:self];
        }
    }else {
        // 正常画画，询问是否退出
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
