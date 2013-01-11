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
#import "SelectWordController.h"
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
#import "SelectHotWordController.h"
#import "DrawToolPanel.h"
#import "DrawColorManager.h"
#import "VendingController.h"
#import "FontButton.h"


@interface OfflineDrawViewController()
{
    DrawView *drawView;
    
    NSInteger penWidth;
    PenView *_willBuyPen;
    ShareImageManager *shareImageManager;
    MyPaint *_draft;
    
    NSInteger _unDraftPaintCount;

    Word *_word;
    LanguageType languageType;
    TargetType targetType;
    
    NSString*_targetUid;
    
    DrawColor *_penColor;
    DrawColor *_eraserColor;

    CGFloat _alpha;
    
    Contest *_contest;
    
    BOOL _isAutoSave;
    
    BOOL _userSaved;
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
@property (retain, nonatomic) NSString *desc;


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

#define PAPER_VIEW_TAG 20120403 


#pragma mark - Static Method

+ (void)startDraw:(Word *)word fromController:(UIViewController*)fromController
{
    LanguageType language = [[UserManager defaultManager] getLanguageType];
    OfflineDrawViewController *vc = [[OfflineDrawViewController alloc] initWithWord:word lang:language];
    [fromController.navigationController pushViewController:vc animated:YES];   
    [vc release];
    

}

+ (void)startDraw:(Word *)word 
   fromController:(UIViewController*)fromController 
        targetUid:(NSString *)targetUid
{
    LanguageType language = [[UserManager defaultManager] getLanguageType];
    OfflineDrawViewController *vc = [[OfflineDrawViewController alloc] initWithWord:word lang:language targetUid:targetUid];
    [fromController.navigationController pushViewController:vc animated:YES];   
    [vc release];
    
    PPDebug(@"<StartDraw>: word = %@, targetUid = %@", word.text, targetUid);
    
}


+ (void)startDrawWithContest:(Contest *)contest   
              fromController:(UIViewController*)fromController
                    animated:(BOOL)animated
{
    OfflineDrawViewController *odc = [[OfflineDrawViewController alloc] initWithContest:contest];
    [fromController.navigationController pushViewController:odc animated:animated];   
    [odc release];
    
    PPDebug(@"<startDrawWithContest>: contest id = %@",contest.contestId);

}

- (void)dealloc
{

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
    PPRelease(_desc);
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
        self.word = [Word wordWithText:NSLS(@"kContestOpus") level:WordLeveLMedium];
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
        self.word = [Word wordWithText:draft.drawWord level:draft.level.intValue];
        shareImageManager = [ShareImageManager defaultManager];
        languageType = draft.language.intValue;
        if ([draft.targetUserId length] != 0) {
            self.targetUid = [NSString stringWithFormat:@"%@",draft.targetUserId];    
        }
        if ([draft.contestId length] != 0) {
            self.contest = [[[Contest alloc] init] autorelease];
            [self.contest setContestId:draft.contestId];
        }
        
        PPDebug(@"draft word lelve = %@, language = %@", draft.level,draft.language);
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
    
    
    
    [drawView setDrawEnabled:YES];
    [drawView setRevocationSupported:YES];
    drawView.delegate = self;
    _isNewDraft = YES;
    _userSaved = NO;
    if (self.draft) {
        [drawView showDraft:self.draft];
        self.draft.thumbImage = nil;
        _userSaved = YES;
    }
    [self.view insertSubview:drawView aboveSubview:paperView];
    self.eraserColor = [DrawColor whiteColor];
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


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initDrawView];
    [self initWordLabel];
    [self initSubmitButton];
    _unDraftPaintCount = 0;
    _isAutoSave = NO;               // set by Benson, disable this due to complicate multi-thread issue
    [self initDrawToolPanel];

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
    [super viewDidDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.drawToolPanel updateView];
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
//
//- (void)didPickedPickView:(PickView *)pickView penView:(PenView *)penView
//{
//    if (penView) {
//        _willBuyPen = nil;
//        if ([penView isDefaultPen] || [[AccountService defaultService]hasEnoughItemAmount:penView.penType amount:1]) {
//            [self.penButton setPenType:penView.penType];
//            [drawView setPenType:penView.penType];       
//            [PenView savePenType:penView.penType];
//        }else{
//            AccountService *service = [AccountService defaultService];
//            if (![service hasEnoughCoins:penView.price]) {
//                NSString *message = [NSString stringWithFormat:NSLS(@"kCoinsNotEnoughTips"), penView.price];
//                CommonDialog *noMoneyDialog = [CommonDialog createDialogWithTitle:NSLS(@"kCoinsNotEnoughTitle") message:message style:CommonDialogStyleSingleButton delegate:self];
//                noMoneyDialog.tag = NO_COIN_TAG;
//                [noMoneyDialog showInView:self.view];
//            }else{
//                NSString *message = [NSString stringWithFormat:NSLS(@"kBuyPenDialogMessage"),penView.price];
//                CommonDialog *buyConfirmDialog = [CommonDialog createDialogWithTitle:NSLS(@"kBuyPenDialogTitle") message:message style:CommonDialogStyleDoubleButton delegate:self];
//                buyConfirmDialog.tag = BUY_CONFIRM_TAG;
//                [buyConfirmDialog showInView:self.view];
//                _willBuyPen = penView;
//            }
//
//        }
//    }
//    [self disMissAllPickViews:YES];
//}

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
    UIViewController *superController = [self superContestController];
    
    if (superController == nil) {
        superController = [self superShowFeedController];
    }
    if (superController == nil) {
        superController = [self superShareController];
    }
    if (superController) {
        [self.navigationController popToViewController:superController animated:YES];
    }else {
        [HomeController returnRoom:self];
    }
}
- (void)clickOk:(CommonDialog *)dialog
{
    if(dialog.tag == DIALOG_TAG_COMMIT_OPUS)
    {
        [self showActivityWithText:NSLS(@"kSending")];
        self.submitButton.userInteractionEnabled = NO;
        UIImage *image = [drawView createImage];
        [[DrawDataService defaultService] createOfflineDraw:drawView.drawActionList 
                                                      image:image 
                                                   drawWord:self.word 
                                                   language:languageType 
                                                  targetUid:self.targetUid 
                                                  contestId:_contest.contestId
                                                       desc:_desc//@"元芳，你怎么看？"
                                                   delegate:self];

    }
    else if (dialog.tag == DIALOG_TAG_ESCAPE ){
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

        UIViewController *superController = [self superShowFeedController];
        
        //if come from feed detail controller
        if (superController) {
            [self.navigationController popToViewController:superController animated:NO];
            SelectWordController *sc = nil;
            if ([_targetUid length] == 0) {
                sc = [[SelectWordController alloc] initWithType:OfflineDraw];                
            }else{
                sc = [[SelectWordController alloc] initWithTargetUid:self.targetUid];
            }
            [superController.navigationController pushViewController:sc animated:NO];
            [sc release];
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
        if (!_userSaved) {
            [[MyPaintManager defaultManager] deleteMyPaint:self.draft];
        }
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

#define DRAFT_PAINT_COUNT [ConfigManager drawAutoSavePaintInterval]

- (void)didDrawedPaint:(Paint *)paint
{
    if (targetType == TypeGraffiti || !_isAutoSave) {
        return;
    }
    
    ++ _unDraftPaintCount;
    if (_unDraftPaintCount >= DRAFT_PAINT_COUNT) {
        PPDebug(@"<didDrawedPaint> start to auto save...");
        [self saveDraft:NO];
    }
}

- (void)didCreateDraw:(int)resultCode
{
    [self hideActivity];
    self.submitButton.userInteractionEnabled = YES;
    if (resultCode == 0) {
        CommonDialog *dialog = nil;
        if (self.contest) {
            self.contest.opusCount ++;
            if (![self.contest joined]) {
                self.contest.participantCount ++;
            }
            [self.contest incCommitCount];
            
            if ([self.contest commintCountEnough]) {
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
    _unDraftPaintCount = 0;
    _isNewDraft = YES;
    UIImage *image = [drawView createImage];    
    
    __block BOOL result = NO;

    @try {
        MyPaintManager *pManager = [MyPaintManager defaultManager];
        if (self.draft) {
            result = YES;
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            PPDebug(@"<saveDraft> save draft");
            result = [pManager updateDraft:self.draft
                                     image:image
                      pbNoCompressDrawData:[self drawDataSnapshot]];
//            });
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

- (void)saveDraftAndShowResult
{
    [self saveDraft:YES];
    [self hideActivity];
}

- (IBAction)clickDraftButton:(id)sender {
    _userSaved = YES;
    [self showActivityWithText:NSLS(@"kSaving")];
    [self performSelector:@selector(saveDraftAndShowResult) withObject:nil afterDelay:0.01];
}


- (NSMutableArray *)compressActionList:(NSArray *)drawActionList
{
    return  [DrawAction scaleActionList:drawActionList xScale:1.0 / IPAD_WIDTH_SCALE yScale:1.0 / IPAD_HEIGHT_SCALE];
}

- (IBAction)clickSubmitButton:(id)sender {
    
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
        
        CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kCommitOpusTitle") message:NSLS(@"kCommitOpusMessage") style:CommonDialogStyleDoubleButton delegate:self];
        [dialog showInView:self.view];
        dialog.tag = DIALOG_TAG_COMMIT_OPUS;
        
    }
}


- (void)alertExit
{
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:nil message:nil style:CommonDialogStyleDoubleButton delegate:self];
    
    if (_isNewDraft || [drawView.drawActionList count] == 0 || !_isAutoSave) {
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
    if ([drawView canRedo]) {
        [drawView redo];
        _isNewDraft = NO;
    }
}
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didClickUndoButton:(UIButton *)button
{
    if ([drawView canRevoke]) {
        _isNewDraft = NO;
        [drawView revoke];
    }
}
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didClickEraserButton:(UIButton *)button
{
    [drawView setLineColor:self.eraserColor];
    [drawView setPenType:Eraser];
}
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didClickPaintBucket:(UIButton *)button
{
    _isNewDraft = NO;
    self.penColor.alpha = 1.0;
    [drawView addChangeBackAction:self.penColor];
    self.eraserColor = self.penColor;
    self.penColor = drawView.lineColor = [DrawColor blackColor];
    [toolPanel setColor:self.penColor];
    [drawView.lineColor setAlpha:_alpha];
    [self updateRecentColors];
    [_drawToolPanel updateRecentColorViewWithColor:[DrawColor blackColor]];
}
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didSelectPen:(ItemType)penType
               bought:(BOOL)bought
{
    if (bought) {
        PPDebug(@"<didSelectPen> pen type = %d",penType);
        drawView.penType = penType;
    }else{
        [CommonItemInfoView showItem:[Item itemWithType:penType amount:1] infoInView:self canBuyAgain:!bought];
    }
}
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didSelectWidth:(CGFloat)width
{
    drawView.lineWidth = width;
    PPDebug(@"<didSelectWidth> width = %f",width);
}
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didSelectColor:(DrawColor *)color
{
    self.tempColor = color;
    self.penColor = color;
    [drawView setLineColor:[DrawColor colorWithColor:color]];
    [drawView.lineColor setAlpha:_alpha];
}
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didSelectAlpha:(CGFloat)alpha
{
    _alpha = alpha;
    DrawColor *color = [DrawColor colorWithColor:drawView.lineColor];
    color.alpha = alpha;
    drawView.lineColor = color;
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

@end
