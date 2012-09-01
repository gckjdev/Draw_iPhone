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
#import "PickColorView.h"
#import "PickEraserView.h"
#import "PickPenView.h"
#import "ShoppingManager.h"
#import "DrawDataService.h"
#import "CommonMessageCenter.h"
#import "FeedController.h"
#import "SelectWordController.h"
#import "FeedDetailController.h"
#import "MyPaintManager.h"
#import "UserManager.h"
#import "DrawDataService.h"
#import "MyPaintManager.h"
#import "UIImageExt.h"
#import "ShareController.h"

@interface OfflineDrawViewController()
{
    DrawView *drawView;
    PickColorView *pickColorView;
    PickColorView *pickBGColorView;
    PickEraserView *pickEraserView;
    PickPenView *pickPenView;
    
    NSInteger penWidth;
    NSInteger eraserWidth;
    PenView *_willBuyPen;
    ShareImageManager *shareImageManager;
    MyPaint *_draft;
    
    NSInteger _unDraftPaintCount;
//    NSTimer *_draftTimer;

}

@property(nonatomic, retain)MyPaint *draft;

- (void)initEraser;
- (void)initPens;
- (void)initDrawView;

/*
- (void)restartDraftTimer;
- (void)stopDraftTimer;
- (void)handleDraftTimer:(NSTimer *)theTimer;
*/
- (void)saveDraft;
@end


@implementation OfflineDrawViewController

@synthesize draft = _draft;
@synthesize submitButton;
@synthesize eraserButton;
@synthesize wordButton;
@synthesize cleanButton;
@synthesize penButton;
@synthesize colorButton;
@synthesize word = _word;
@synthesize titleLabel;
@synthesize draftButton;
@synthesize delegate;
@synthesize targetUid = _targetUid;
@synthesize eraserColor = _eraserColor;
@synthesize bgColor = _bgColor;

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


- (void)dealloc
{
    PPRelease(eraserButton);
    PPRelease(wordButton);
    PPRelease(cleanButton);
    PPRelease(penButton);
    PPRelease(colorButton);
    PPRelease(pickColorView);
    PPRelease(drawView);
    PPRelease(pickEraserView);
    PPRelease(pickPenView);
    PPRelease(_word);
    PPRelease(_targetUid);
    PPRelease(titleLabel);
    PPRelease(submitButton);
    PPRelease(_bgColor);
    PPRelease(_eraserColor);
    PPRelease(pickBGColorView);
    PPRelease(_draft);
    //    [autoReleasePool drain];
    //    autoReleasePool = nil;
    
    [draftButton release];
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
        //        autoReleasePool = [[NSAutoreleasePool alloc] init];
        self.word = word;
        languageType = lang;
        shareImageManager = [ShareImageManager defaultManager];
    }
    return self;
}

- (id)initWithDraft:(MyPaint *)draft
{
    self = [super init];
    if (self) {
        self.draft = draft;
        self.word = [Word wordWithText:draft.drawWord level:draft.level];
        shareImageManager = [ShareImageManager defaultManager];
        languageType = draft.language;
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

#define PICK_ERASER_VIEW_TAG 2012053101
#define PICK_PEN_VIEW_TAG 2012053102
#define PICK_COLOR_VIEW_TAG 2012053103
#define PICK_BGCOLOR_VIEW_TAG 2012008041

#define DEFAULT_COLOR_NUMBER 5
- (void)initPickView
{

//init pick pen view    
    pickPenView = [[PickPenView alloc] initWithFrame:PICK_PEN_VIEW];        
    [pickPenView setDelegate:self];

//init pick eraser view    
    pickEraserView = [[PickEraserView alloc] initWithFrame:PICK_ERASER_VIEW];
    [pickEraserView setDelegate:self];
    pickEraserView.tag = PICK_ERASER_VIEW_TAG;
    
//init pick color view
    pickColorView = [[PickColorView alloc] initWithFrame:PICK_COLOR_VIEW type:PickColorViewTypePen];
    pickColorView.delegate = self;
    pickColorView.tag = PICK_COLOR_VIEW_TAG;
 
//init pick bg color View    
    pickBGColorView = [[PickColorView alloc] initWithFrame:PICK_BACKGROUND_COLOR_VIEW type:PickColorViewTypeBackground];
    pickBGColorView.delegate = self;
    pickBGColorView.tag = PICK_BGCOLOR_VIEW_TAG;
    [pickBGColorView setColorViews:[pickColorView colorViews]];
    
}




#pragma mark - Update Data

enum{
    BLACK_COLOR = 0,
    RED_COLOR = 1,  
    BLUE_COLOR,
    YELLOW_COLOR,
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



- (void)initEraser
{
    eraserWidth = ERASER_WIDTH;
}
- (void)initPens
{
    if (targetType == TypeGraffiti) {
        penButton.hidden = YES;
    }
        
    [self initPickView];
    DrawColor *randColor = [self randColor];
    [drawView setLineColor:randColor];
    [colorButton setDrawColor:randColor];
    [penButton setPenType:[PenView lastPenType]];
    [drawView setLineWidth:pickColorView.currentWidth];
    penWidth = pickColorView.currentWidth;
}

- (void)initDrawView
{
    UIView *paperView = [self.view viewWithTag:PAPER_VIEW_TAG];
    drawView = [[DrawView alloc] initWithFrame:DRAW_VIEW_FRAME];   
    [drawView setDrawEnabled:YES];
    drawView.delegate = self;
    if (self.draft) {
        NSArray* drawActionList = [NSKeyedUnarchiver unarchiveObjectWithData:self.draft.data];
        [drawView setDrawActionList:[NSMutableArray arrayWithArray:drawActionList]];
    }
    [self.view insertSubview:drawView aboveSubview:paperView];
    self.bgColor = self.eraserColor = [DrawColor whiteColor];
}

- (void)initWordLabel
{
    if (targetType == TypeGraffiti) {
        self.wordButton.hidden = YES;
    }else {
        self.wordButton.hidden = NO;
        NSString *wordText = self.word.text;
        //= [NSString stringWithFormat:NSLS(@"kDrawWord"),self.word.text];
        [self.wordButton setTitle:wordText forState:UIControlStateNormal];
    }
}

- (void)initTitleLabel
{
    if (targetType == TypeGraffiti) {
        [self.titleLabel setText:NSLS(@"kGraffiti")]; 
    }else {
        [self.titleLabel setText:NSLS(@"kDrawing")]; 
    }
}

- (void)initSubmitButton
{
    [self.submitButton setTitle:NSLS(@"kSubmit") forState:UIControlStateNormal];
    [self.submitButton setBackgroundImage:[shareImageManager orangeImage] forState:UIControlStateNormal];
}

- (void)initDraftButton
{
    if (targetType == TypeGraffiti) {
        self.draftButton.hidden = YES;
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initTitleLabel];
    [self initDrawView];
    [self initEraser];
    [self initPens];
    [self initWordLabel];
    [self initSubmitButton];
    [self initDraftButton];
    pickEraserView.hidden = NO;
    [self.view bringSubviewToFront:pickEraserView];
    _unDraftPaintCount = 0;
//    [self restartDraftTimer];
}



- (void)viewDidUnload
{
    drawView.delegate = nil;
    
    [self setWord:nil];
    [self setEraserButton:nil];
    [self setWordButton:nil];
    [self setCleanButton:nil];
    [self setPenButton:nil];
    [self setColorButton:nil];
    [self setTitleLabel:nil];
    [self setSubmitButton:nil];
    [self setDraftButton:nil];
    [super viewDidUnload];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    //save the recent draw color
    if ([pickColorView.colorViews count] > DEFAULT_COLOR_NUMBER) {
        NSMutableArray *array = [NSMutableArray array];
        NSInteger count = MIN([pickColorView.colorViews count], DEFAULT_COLOR_NUMBER * 3-1);
        for (int i = DEFAULT_COLOR_NUMBER; i < count; ++ i) {
            ColorView *view = [pickColorView.colorViews objectAtIndex:i];
            [array addObject:view.drawColor];
        }
        [DrawColor setRecentColorList:array];
    }
    
}

#define ESCAPE_DEDUT_COIN 1
#define DIALOG_TAG_CLEAN_DRAW 201204081
#define DIALOG_TAG_ESCAPE 201204082
#define DIALOG_TAG_SUBMIT 201206071
#define DIALOG_TAG_CHANGE_BACK 201207281
#define DIALOG_TAG_COMMIT_OPUS 201208111


- (void)disMissAllPickViews:(BOOL)animated
{
    [pickPenView dismissAnimated:animated];
    [pickEraserView dismissAnimated:animated];
    [pickColorView dismissAnimated:animated];
    [pickBGColorView dismissAnimated:animated];
}


#pragma mark - Pick view delegate
- (void)didPickedPickView:(PickView *)pickView colorView:(ColorView *)colorView
{
    if (pickView == pickColorView) {
        [drawView setLineColor:colorView.drawColor];
        [drawView setLineWidth:penWidth];
        [colorButton setDrawColor:colorView.drawColor];
        [pickColorView updatePickColorView:colorView];
    }else if(pickView == pickBGColorView)
    {
        self.bgColor = colorView.drawColor;
        //show tips.
        CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kChangeBackgroundTitle") message:NSLS(@"kChangeBackgroundMessage") style:CommonDialogStyleDoubleButton delegate:self];
        dialog.tag = DIALOG_TAG_CHANGE_BACK;
        [dialog showInView:self.view];
        
        [pickBGColorView updatePickColorView:colorView];
    }
    [self disMissAllPickViews:YES];
}

- (void)didPickedColorView:(ColorView *)colorView
{
    if (!pickColorView.dismiss) {
        [self didPickedPickView:pickColorView colorView:colorView];        
        [drawView setLineColor:colorView.drawColor];
        [drawView setLineWidth:penWidth];
        [colorButton setDrawColor:colorView.drawColor];
        [pickColorView updatePickColorView:colorView];
    }else if(!pickBGColorView.dismiss)
    {
        [self didPickedPickView:pickBGColorView colorView:colorView];        
        [pickBGColorView updatePickColorView:colorView];
    }

    [self disMissAllPickViews:YES];
}


- (void)didPickedPickView:(PickView *)pickView lineWidth:(NSInteger)width
{
    if (pickView.tag == PICK_COLOR_VIEW_TAG) {
        [drawView setLineWidth:width];
        penWidth = width;   
    }else if(pickView.tag == PICK_ERASER_VIEW_TAG)
    {
        [drawView setLineWidth:width];
        eraserWidth = width;
    }
    [self disMissAllPickViews:YES];
}
- (void)didPickedMoreColor
{
    ColorShopView *colorShop = [ColorShopView colorShopViewWithFrame:self.view.bounds];
    colorShop.delegate = self;
    [colorShop showInView:self.view animated:YES];    
}

#define NO_COIN_TAG 201204271
#define BUY_CONFIRM_TAG 201204272

- (void)didPickedPickView:(PickView *)pickView penView:(PenView *)penView
{
    if (penView) {
        _willBuyPen = nil;
        if ([penView isDefaultPen] || [[AccountService defaultService]hasEnoughItemAmount:penView.penType amount:1]) {
            [self.penButton setPenType:penView.penType];
            [drawView setPenType:penView.penType];       
            [PenView savePenType:penView.penType];
        }else{
            AccountService *service = [AccountService defaultService];
            if (![service hasEnoughCoins:penView.price]) {
                NSString *message = [NSString stringWithFormat:NSLS(@"kCoinsNotEnoughTips"), penView.price];
                CommonDialog *noMoneyDialog = [CommonDialog createDialogWithTitle:NSLS(@"kCoinsNotEnoughTitle") message:message style:CommonDialogStyleSingleButton delegate:self];
                noMoneyDialog.tag = NO_COIN_TAG;
                [noMoneyDialog showInView:self.view];
            }else{
                NSString *message = [NSString stringWithFormat:NSLS(@"kBuyPenDialogMessage"),penView.price];
                CommonDialog *buyConfirmDialog = [CommonDialog createDialogWithTitle:NSLS(@"kBuyPenDialogTitle") message:message style:CommonDialogStyleDoubleButton delegate:self];
                buyConfirmDialog.tag = BUY_CONFIRM_TAG;
                [buyConfirmDialog showInView:self.view];
                _willBuyPen = penView;
            }

        }
    }
    [self disMissAllPickViews:YES];
}

#pragma mark - Common Dialog Delegate


- (FeedDetailController *)superFeedDetailController
{
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[FeedDetailController class]]) {
            return (FeedDetailController *)controller;
        }
    }
    return nil;
}


- (FeedController *)superFeedController
{
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[FeedController class]]) {
            return (FeedController *)controller;
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


- (void)quit
{
    UIViewController *superController = [self superFeedDetailController];
    if (superController == nil) {
        superController = [self superFeedController];
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
    if (dialog.tag == DIALOG_TAG_CLEAN_DRAW) {
        [drawView addCleanAction];
        self.bgColor = self.eraserColor = [DrawColor whiteColor];
    }else if(dialog.tag == DIALOG_TAG_COMMIT_OPUS)
    {
        [self showActivityWithText:NSLS(@"kSending")];
        self.submitButton.userInteractionEnabled = NO;
        UIImage *image = [drawView createImage];
        if ([DeviceDetection isIPAD]) {
            image = [image imageByScalingAndCroppingForSize:DRAW_VIEW_FRAME_IPHONE.size];
        }            
        [[DrawDataService defaultService] createOfflineDraw:drawView.drawActionList 
                                                      image:image 
                                                   drawWord:self.word 
                                                   language:languageType 
                                                  targetUid:self.targetUid 
                                                   delegate:self];

    }
    else if (dialog.tag == DIALOG_TAG_ESCAPE ){
        [self saveDraft];
        [self quit];
    }else if(dialog.tag == BUY_CONFIRM_TAG){
        [[AccountService defaultService] buyItem:_willBuyPen.penType itemCount:1 itemCoins:_willBuyPen.price];
        [self.penButton setPenType:_willBuyPen.penType];
        [_willBuyPen setAlpha:1];
        [drawView setPenType:_willBuyPen.penType];   
        [PenView savePenType:_willBuyPen.penType];
        [pickPenView updatePenViews];
    }else if(dialog.tag == DIALOG_TAG_CHANGE_BACK)
    {
        DrawAction *action = [DrawAction 
                              changeBackgroundActionWithColor:self.bgColor];
        [drawView addAction:action];
        self.eraserColor = self.bgColor;
        if (drawView.penType == Eraser) {
            drawView.lineColor = self.eraserColor;
        }
                
    }
    else if(dialog.tag == DIALOG_TAG_SUBMIT){
        // Save Image Locally        
        [[DrawDataService defaultService] saveActionList:drawView.drawActionList 
                                                  userId:[[UserManager defaultManager] userId] 
                                                nickName:[[UserManager defaultManager] nickName]
                                               isMyPaint:YES    
                                                    word:[_word text]
                                                   image:[drawView createImage]
                                                delegate:self];

        
        UIViewController *superController = [self superFeedDetailController];
        if (superController == nil) {
            superController = [self superFeedDetailController];
        }
        
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
    }
}

- (void)clickBack:(CommonDialog *)dialog
{
    if(dialog.tag == DIALOG_TAG_SUBMIT){
        
        // Save Image Locally        
        [[DrawDataService defaultService] saveActionList:drawView.drawActionList 
                                                  userId:[[UserManager defaultManager] userId] 
                                                nickName:[[UserManager defaultManager] nickName]
                                               isMyPaint:YES    
                                                    word:[_word text]
                                                   image:[drawView createImage]
                                                delegate:self];
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
    [self disMissAllPickViews:YES];
}

#define DRAFT_PAINT_COUNT 10

- (void)didDrawedPaint:(Paint *)paint
{
    ++ _unDraftPaintCount;
    if (_unDraftPaintCount >= DRAFT_PAINT_COUNT) {
        [self saveDraft];        
        _unDraftPaintCount = 0;
    }
}

- (void)didCreateDraw:(int)resultCode
{
    [self hideActivity];
    self.submitButton.userInteractionEnabled = YES;
    if (resultCode == 0) {
        CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kSubmitSuccTitle") message:NSLS(@"kSubmitSuccMsg") style:CommonDialogStyleDoubleButton delegate:self];
        dialog.tag = DIALOG_TAG_SUBMIT;
        [dialog showInView:self.view];
        
        [[LevelService defaultService] addExp:OFFLINE_DRAW_EXP delegate:self];
        if (self.draft) {
            [[MyPaintManager defaultManager] deleteMyPaint:self.draft];
            self.draft = nil;
        }
        
    }else{
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kSubmitFailure") delayTime:1 isSuccessful:NO];
    }
}




#pragma makr - Draft
/*
- (void)restartDraftTimer
{
    [self stopDraftTimer];
    _draftTimer = [NSTimer scheduledTimerWithTimeInterval:DRAFT_TIMER_INTERVAL
                                                   target:self
                                                 selector:@selector(handleDraftTimer:)
                                                 userInfo:nil 
                                                  repeats:YES];
}
- (void)stopDraftTimer
{
    if (_draftTimer && [_draftTimer isValid]) {
        [_draftTimer invalidate];
    }
    _draftTimer = nil;
}
- (void)handleDraftTimer:(NSTimer *)theTimer
{
    [self saveDraft];
}

 */
- (void)saveDraft
{
    PPDebug(@"<OfflineDrawViewController> start to save draft.");
    if (self.draft) {
        //delete the old draft.
        [[MyPaintManager defaultManager] deleteMyPaint:self.draft];
    }    
    UIImage *image = [drawView createImage];
    self.draft = [[MyPaintManager defaultManager] createDraft:image data:drawView.drawActionList language:languageType drawWord:self.word.text level:self.word.level];    
}

#pragma mark - Actions

- (IBAction)clickDraftButton:(id)sender {
    
    [self saveDraft];
    [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kSaveSucc") delayTime:1.5 isSuccessful:YES];
}

- (IBAction)clickRevokeButton:(id)sender {
    if ([drawView canRevoke]) {
        [drawView revoke];
    }
}

- (IBAction)changeBackground:(id)sender {
    BOOL show = pickBGColorView.dismiss;
    [self disMissAllPickViews:YES];
    if (show) {
        [pickBGColorView updatePickColorView];
        [pickBGColorView popupAtView:(UIButton *)sender inView:self.view animated:YES];
    }    
}


- (IBAction)clickRedraw:(id)sender {

    [self disMissAllPickViews:YES];
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kCleanDrawTitle") message:NSLS(@"kCleanDrawMessage") style:CommonDialogStyleDoubleButton delegate:self];
    dialog.tag = DIALOG_TAG_CLEAN_DRAW;
    [dialog showInView:self.view];
}

- (IBAction)clickEraserButton:(id)sender {
    BOOL show = pickEraserView.dismiss;
    [self disMissAllPickViews:YES];
    if (show) {
        [pickEraserView popupAtView:sender inView:self.view animated:YES];        
    }

    [drawView setPenType:Eraser];
    [drawView setLineColor:self.eraserColor];
    [drawView setLineWidth:eraserWidth];
}

- (IBAction)clickPenButton:(id)sender {
    BOOL show = pickPenView.dismiss;
    [self disMissAllPickViews:YES];
    if (show) {
        [pickPenView popupAtView:sender inView:self.view animated:YES];
    }
    
    [drawView setPenType:penButton.penType];
    [drawView setLineColor:colorButton.drawColor];
    [drawView setLineWidth:penWidth];
}

- (IBAction)clickColorButton:(id)sender {
    BOOL show = pickColorView.dismiss;
    [self disMissAllPickViews:YES];
    if (show) {
        [pickColorView updatePickColorView];
        [pickColorView popupAtView:(UIButton *)sender inView:self.view animated:YES];
    }    
    
    [drawView setLineColor:colorButton.drawColor];
    [drawView setLineWidth:penWidth];
    [drawView setPenType:penButton.penType];
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
    
    NSArray *drawActionList = drawView.drawActionList;

    if (targetType == TypeGraffiti) {
        if (delegate && [delegate respondsToSelector:@selector(didClickSubmit:)]) {
            [delegate didClickSubmit:drawActionList];
        }
    }else {
        
        CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kCommitOpusTitle") message:NSLS(@"kCommitOpusMessage") style:CommonDialogStyleDoubleButton delegate:self];
        [dialog showInView:self.view];
        dialog.tag = DIALOG_TAG_COMMIT_OPUS;
        
    }
}
- (void)clickBackButton:(id)sender
{
    if (targetType == TypeGraffiti) {
        if (delegate && [delegate respondsToSelector:@selector(didClickBack)]) {
            [delegate didClickBack];
        }
    }else {
        CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kQuitDrawAlertTitle") message:NSLS(@"kQuitDrawAlertMessage") style:CommonDialogStyleDoubleButton delegate:self];
        dialog.tag = DIALOG_TAG_ESCAPE;
        [dialog showInView:self.view];
    }
}

#pragma mark - level service delegate
- (void)levelUp:(int)level
{
//    [[CommonMessageCenter defaultCenter] postMessageWithText:[NSString stringWithFormat:NSLS(@"kUpgradeMsg"),level] delayTime:1.5 isHappy:YES];
}


@end
