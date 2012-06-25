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

@implementation OfflineDrawViewController

@synthesize submitButton;
@synthesize eraserButton;
@synthesize wordButton;
@synthesize cleanButton;
@synthesize penButton;
@synthesize colorButton;
@synthesize word = _word;
@synthesize titleLabel;
@synthesize delegate;

#define PAPER_VIEW_TAG 20120403 


#pragma mark - Static Method
+ (void)startDraw:(Word *)word fromController:(UIViewController*)fromController
{
    LanguageType language = [[UserManager defaultManager] getLanguageType];
    OfflineDrawViewController *vc = [[OfflineDrawViewController alloc] initWithWord:word lang:language];
    [fromController.navigationController pushViewController:vc animated:YES];   
    [vc release];
    
    PPDebug(@"<StartDraw>: word = %@, need reset Data", word.text);
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
    //    [autoReleasePool drain];
    //    autoReleasePool = nil;
    
    
    [titleLabel release];
    [submitButton release];
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
//    self = [super initWithNibName:nil bundle:nil];
    self = [super init];
    if (self) {
        //        autoReleasePool = [[NSAutoreleasePool alloc] init];
        self.word = word;
        languageType = lang;
        shareImageManager = [ShareImageManager defaultManager];
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
- (void)initPickView
{

    //init pick pen view

    pickPenView = [[PickPenView alloc] initWithFrame:PICK_PEN_VIEW];
    [pickPenView setImage:[shareImageManager penPopupImage]];
    [pickPenView setDelegate:self];
    NSMutableArray *penArray = [[NSMutableArray alloc] init];
    NSInteger price = [[ShoppingManager defaultManager] getPenPrice];
    for (int i = PenStartType; i < PenCount; ++ i) {
        PenView *pen = [PenView penViewWithType:i];
        pen.price = price;
        [penArray addObject:pen];
    }
    
    [penArray sortUsingComparator:^(id obj1,id obj2){
        PenView *pen1 = (PenView *)obj1;
        PenView *pen2 = (PenView *)obj2;
        BOOL hasBought1 = [pen1 isDefaultPen] || [[AccountService defaultService] hasEnoughItemAmount:pen1.penType amount:1];
        BOOL hasBought2 = [pen2 isDefaultPen] || [[AccountService defaultService] hasEnoughItemAmount:pen2.penType amount:1];
        NSInteger ret = hasBought2 - hasBought1;
        if (ret == 0) {
            return NSOrderedAscending;
        }
        return ret;
    }];
    
    [pickPenView setPens:penArray];
    [penArray release];
    [self.view addSubview:pickPenView];
    
    
    NSMutableArray *widthArray = [[NSMutableArray alloc] init];
    if ([DeviceDetection isIPAD]) {
        [widthArray addObject:[NSNumber numberWithInt:20 * 2]];
        [widthArray addObject:[NSNumber numberWithInt:15 * 2]];
        [widthArray addObject:[NSNumber numberWithInt:9 * 2]];
        [widthArray addObject:[NSNumber numberWithInt:2 * 2]];
    }else{
        [widthArray addObject:[NSNumber numberWithInt:20]];
        [widthArray addObject:[NSNumber numberWithInt:15]];
        [widthArray addObject:[NSNumber numberWithInt:9]];
        [widthArray addObject:[NSNumber numberWithInt:2]];        
    }
    

//init pick eraser view    
    pickEraserView = [[PickEraserView alloc] initWithFrame:PICK_ERASER_VIEW];
    [pickEraserView setImage:[shareImageManager eraserPopupImage]];
    [pickEraserView setDelegate:self];
    pickEraserView.tag = PICK_ERASER_VIEW_TAG;
    [self.view addSubview:pickEraserView];
    [pickEraserView setLineWidths:widthArray];
    
//init pick color view
    pickColorView = [[PickColorView alloc] initWithFrame:PICK_COLOR_VIEW];
    [pickColorView setImage:[shareImageManager toolPopupImage]];
    pickColorView.delegate = self;
    pickColorView.tag = PICK_COLOR_VIEW_TAG;
    [pickColorView setLineWidths:widthArray];
    [self.view addSubview:pickColorView];

    NSMutableArray *colorViewArray = [[NSMutableArray alloc] init];
    
    [colorViewArray addObject:[ColorView blackColorView]];
    [colorViewArray addObject:[ColorView redColorView]];
    [colorViewArray addObject:[ColorView yellowColorView]];
    [colorViewArray addObject:[ColorView blueColorView]];
    [colorViewArray addObject:[ColorView whiteColorView]];
    [pickColorView setColorViews:colorViewArray];
    [colorViewArray release];
    [widthArray release];
    
    [pickPenView setHidden:YES];
    [pickColorView setHidden:YES];
    [pickEraserView setHidden:YES];
    
}




#pragma mark - Update Data

enum{
    BLACK_COLOR = 0,
    RED_COLOR = 1,  
    BLUE_COLOR,
    ORANGE_COLOR,
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
        case ORANGE_COLOR:
            return [DrawColor orangeColor];
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
    [penButton setPenType:Pencil];
    [drawView setLineWidth:pickColorView.currentWidth];
    penWidth = pickColorView.currentWidth;
}

- (void)initDrawView
{
    
    UIView *paperView = [self.view viewWithTag:PAPER_VIEW_TAG];
    drawView = [[DrawView alloc] initWithFrame:DRAW_VEIW_FRAME];   
    [drawView setDrawEnabled:YES];
    drawView.delegate = self;
    [self.view insertSubview:drawView aboveSubview:paperView];
}

- (void)initWordLabel
{
    if (targetType == TypeGraffiti) {
        self.wordButton.hidden = YES;
    }else {
        self.wordButton.hidden = NO;
        NSString *wordText = [NSString stringWithFormat:NSLS(@"kDrawWord"),self.word.text];
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
    [super viewDidUnload];
}




#pragma mark - Pick view delegate
- (void)didPickedColorView:(ColorView *)colorView
{
    [drawView setLineColor:colorView.drawColor];
    [drawView setLineWidth:penWidth];
    [colorButton setDrawColor:colorView.drawColor];
    [pickColorView updatePickColorView:colorView];
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
}

#pragma mark - Common Dialog Delegate
#define ESCAPE_DEDUT_COIN 1
#define DIALOG_TAG_CLEAN_DRAW 201204081
#define DIALOG_TAG_ESCAPE 201204082
#define DIALOG_TAG_SUBMIT 201206071

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

- (void)quit
{
    UIViewController *superController = [self superFeedDetailController];
    if (superController == nil) {
        superController = [self superFeedController];
    }
    if (superController) {
        [self.navigationController popToViewController:superController animated:YES];
    }else{
        [HomeController returnRoom:self];
    }
}

- (void)clickOk:(CommonDialog *)dialog
{
    if (dialog.tag == DIALOG_TAG_CLEAN_DRAW) {
        [drawView addCleanAction];
        [pickColorView setHidden:YES];        
    }else if (dialog.tag == DIALOG_TAG_ESCAPE ){
        [self quit];
    }else if(dialog.tag == BUY_CONFIRM_TAG){
        [[AccountService defaultService] buyItem:_willBuyPen.penType itemCount:1 itemCoins:_willBuyPen.price];
        [self.penButton setPenType:_willBuyPen.penType];
        [drawView setPenType:_willBuyPen.penType];            
    }else if(dialog.tag == DIALOG_TAG_SUBMIT){
        UIViewController *superController = [self superFeedDetailController];
        if (superController == nil) {
            superController = [self superFeedController];
        }
        if (superController) {
            [self.navigationController popToViewController:superController animated:NO];
            SelectWordController *sc = [[SelectWordController alloc] initWithType:OfflineDraw];
            [superController.navigationController pushViewController:sc animated:NO];
            [sc release];
        }else{
            [HomeController startOfflineDrawFrom:self];
        }
    }
}

- (void)clickBack:(CommonDialog *)dialog
{
    if(dialog.tag == DIALOG_TAG_SUBMIT){
        [self quit];
    }
}





- (void)didStartedTouch:(Paint *)paint
{
    [pickColorView setHidden:YES];
    [pickEraserView setHidden:YES];
    [pickPenView setHidden:YES];
}

- (void)didCreateDraw:(int)resultCode
{
    [self hideActivity];
    if (resultCode == 0) {
        CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kSubmitSuccTitle") message:NSLS(@"kSubmitSuccMsg") style:CommonDialogStyleDoubleButton delegate:self];
        dialog.tag = DIALOG_TAG_SUBMIT;
        [dialog showInView:self.view];
        
        [[LevelService defaultService] addExp:OFFLINE_DRAW_EXP delegate:self];
        
    }else{
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kSubmitFailure") delayTime:1 isSuccessful:NO];
    }
}


#pragma mark - Actions

- (IBAction)clickRedraw:(id)sender {
    [pickColorView setHidden:YES animated:YES];
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kCleanDrawTitle") message:NSLS(@"kCleanDrawMessage") style:CommonDialogStyleDoubleButton delegate:self];
    dialog.tag = DIALOG_TAG_CLEAN_DRAW;
    [dialog showInView:self.view];
}

- (IBAction)clickEraserButton:(id)sender {
    [pickEraserView setHidden:!pickEraserView.hidden animated:YES];
    [drawView setPenType:Eraser];
    [drawView setLineColor:[DrawColor whiteColor]];
    [drawView setLineWidth:eraserWidth];
    [pickPenView setHidden:YES];
    [pickColorView setHidden:YES];
}

- (IBAction)clickPenButton:(id)sender {
    [pickPenView setHidden:!pickPenView.hidden animated:YES];
    [drawView setPenType:penButton.penType];
    [drawView setLineColor:colorButton.drawColor];
    [drawView setLineWidth:penWidth];
    [pickEraserView setHidden:YES];
    [pickColorView setHidden:YES];
}

- (IBAction)clickColorButton:(id)sender {
    [pickColorView setHidden:!pickColorView.hidden animated:YES];
    [drawView setLineColor:colorButton.drawColor];
    [drawView setLineWidth:penWidth];
    [drawView setPenType:penButton.penType];
    [pickPenView setHidden:YES];
    [pickEraserView setHidden:YES];
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
//    if ([DeviceDetection isIPAD]) {
//        drawActionList = [self compressActionList:drawView.drawActionList];
//    }

    if (targetType == TypeGraffiti) {
        if (delegate && [delegate respondsToSelector:@selector(didClickSubmit:)]) {
            [delegate didClickSubmit:drawActionList];
        }
    }else {
        [self showActivityWithText:NSLS(@"kSending")];
        [[DrawDataService defaultService] createOfflineDraw:drawActionList drawWord:self.word language:languageType delegate:self];
    }
}
- (void)clickBackButton:(id)sender
{
    if (targetType == TypeGraffiti) {
        if (delegate && [delegate respondsToSelector:@selector(didClickBack)]) {
            [delegate didClickBack];
        }
    }else {
        CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kQuitGameAlertTitle") message:NSLS(@"kQuitGameAlertMessage") style:CommonDialogStyleDoubleButton delegate:self];
        dialog.tag = DIALOG_TAG_ESCAPE;
        [dialog showInView:self.view];
    }
}

#pragma mark - level service delegate
- (void)levelUp:(int)level
{
    [[CommonMessageCenter defaultCenter] postMessageWithText:[NSString stringWithFormat:NSLS(@"kUpgradeMsg"),level] delayTime:1.5 isHappy:YES];
}


@end
