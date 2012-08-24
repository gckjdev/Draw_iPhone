//
//  DrawViewController.m
//  Draw
//
//  Created by gamy on 12-3-4.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "OnlineDrawViewController.h"
#import "DrawView.h"
#import "DrawGameService.h"
#import "DrawColor.h"
#import "GameMessage.pb.h"
#import "Word.h"
#import "GameSessionUser.h"
#import "GameSession.h"
#import "LocaleUtils.h"
#import "AnimationManager.h"
#import "ResultController.h"
#import "HJManagedImageV.h"
#import "PPApplication.h"
#import "RoomController.h"
#import "OnlineGuessDrawController.h"
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
#import "GameTurn.h"
#import "DrawUtils.h"
#import "DeviceDetection.h"
#import "CommonMessageCenter.h"
#import "PickColorView.h"
#import "PickEraserView.h"
#import "PickPenView.h"
#import "ShoppingManager.h"
#import "FriendRoomController.h"
#import "GameConstants.h"
#import "ItemService.h"

@implementation OnlineDrawViewController

@synthesize eraserButton;
@synthesize wordButton;
@synthesize cleanButton;
@synthesize penButton;
@synthesize colorButton;
@synthesize gameCompleteMessage = _gameCompleteMessage;
@synthesize eraserColor = _eraserColor;
@synthesize bgColor = _bgColor;


#define PAPER_VIEW_TAG 20120403 


#pragma mark - Static Method
+ (void)startDraw:(Word *)word fromController:(UIViewController*)fromController
{
    LanguageType language = [[UserManager defaultManager] getLanguageType];
    OnlineDrawViewController *vc = [[OnlineDrawViewController alloc] initWithWord:word lang:language];
    [[DrawGameService defaultService] startDraw:word.text level:word.level language:language];
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
    PPRelease(_gameCompleteMessage);

    //    [autoReleasePool drain];
    //    autoReleasePool = nil;
    
    
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



#pragma mark - Timer

- (void)handleTimer:(NSTimer *)theTimer
{
    PPDebug(@"<OnlineDrawViewController> handle timer");
    --retainCount;
    if (retainCount <= 0) {
        [self resetTimer];
        retainCount = 0;
    }
    [self updateClockButton];
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
    [self.view insertSubview:drawView aboveSubview:paperView];
    self.eraserColor = self.bgColor = [DrawColor whiteColor];
}

- (void)initWordLabel
{
    NSString *wordText = self.word.text;
    //= [NSString stringWithFormat:NSLS(@"kDrawWord"),self.word.text];
    [self.wordButton setTitle:wordText forState:UIControlStateNormal];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    drawGameService.drawDelegate = self;
    [self initDrawView];
    [self initEraser];
    [self initPens];
    [self initWordLabel];
    [self startTimer];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.gameCompleteMessage != nil) {
        [self didGameTurnComplete:self.gameCompleteMessage];
        self.gameCompleteMessage = nil;
    }
}




- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
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

- (void)viewDidUnload
{
    drawView.delegate = nil;
    
    [self setWord:nil];
    [self setEraserButton:nil];
    [self setWordButton:nil];
    [self setClockButton:nil];
    [self setCleanButton:nil];
    [self setPenButton:nil];
    [self setPopupButton:nil];
    [self setTurnNumberButton:nil];
    [self setColorButton:nil];
    [super viewDidUnload];
}



#pragma mark - Draw Game Service Delegate

- (void)didBroken
{
    PPDebug(@"<DrawViewController>:didBroken");
    [self cleanData];
    [HomeController returnRoom:self];
}


#pragma mark - Observer Method/Game Process
- (void)didGameTurnComplete:(GameMessage *)message
{
    self.gameCompleteMessage = message;
    if (_gameCompleted == NO && _gameCanCompleted) {
        _gameCompleted = YES;
        PPDebug(@"DrawViewController:<didGameTurnComplete>");
        UIImage *image = [drawView createImage];
        NSInteger gainCoin = [[message notification] turnGainCoins];
        
        NSString* drawUserId = [[[drawGameService session] currentTurn] lastPlayUserId];
        NSString* drawUserNickName = [[drawGameService session] getNickNameByUserId:drawUserId];    
        [self cleanData];
        ResultController *rc = [[ResultController alloc] initWithImage:image
                                                            drawUserId:drawUserId
                                                      drawUserNickName:drawUserNickName
                                                              wordText:self.word.text                             
                                                                 score:gainCoin                                                         
                                                               correct:NO
                                                             isMyPaint:YES
                                                        drawActionList:drawView.drawActionList];
        [self.navigationController pushViewController:rc animated:YES];
        [rc release];        
    }else{
        PPDebug(@"DrawViewController unhandle <didGameTurnComplete>");
    }

}

- (void)didUserQuitGame:(GameMessage *)message
{
    NSString *userId = [[message notification] quitUserId];
    [self popUpRunAwayMessage:userId];
    [self adjustPlayerAvatars:userId];
    if ([self userCount] <= 1) {
        //[self popupUnhappyMessage:NSLS(@"kAllUserQuit") title:nil]; 
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kAllUserQuit") delayTime:1 isHappy:NO]; 
    }
}

- (void)didReceiveRank:(NSNumber*)rank fromUserId:(NSString*)userId
{
    if (rank.integerValue == RANK_TOMATO) {
        PPDebug(@"%@ give you an tomato", userId);
        [self recieveTomato];
        
        // item award handling for online draw/guess
        [[ItemService defaultService] receiveItem:ItemTypeTomato];        
        
    }else{
        PPDebug(@"%@ give you a flower", userId);
        [self recieveFlower];
        
        // item award handling for online draw/guess
        [[ItemService defaultService] receiveItem:ItemTypeFlower];
    }
    
    
}

#define ESCAPE_DEDUT_COIN 1
#define DIALOG_TAG_CLEAN_DRAW 201204081
#define DIALOG_TAG_ESCAPE 201204082
#define DIALOG_TAG_CHANGE_BACK 201207281

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
- (void)clickOk:(CommonDialog *)dialog
{
    if (dialog.tag == DIALOG_TAG_CLEAN_DRAW) {
        [drawGameService cleanDraw];
        [drawView addCleanAction];
        [pickColorView setHidden:YES];        
    }else if (dialog.tag == DIALOG_TAG_ESCAPE && dialog.style == CommonDialogStyleDoubleButton && [[AccountManager defaultManager] hasEnoughBalance:1]) {
        [drawGameService quitGame];
        [HomeController returnRoom:self];
        [[AccountService defaultService] deductAccount:ESCAPE_DEDUT_COIN source:EscapeType];
        [self cleanData];
        [[LevelService defaultService] minusExp:NORMAL_EXP delegate:self];
    }else if(dialog.tag == BUY_CONFIRM_TAG){
        [[AccountService defaultService] buyItem:_willBuyPen.penType itemCount:1 itemCoins:_willBuyPen.price];
        [self.penButton setPenType:_willBuyPen.penType];
        [drawView setPenType:_willBuyPen.penType];        
        [PenView savePenType:_willBuyPen.penType];
        [_willBuyPen setAlpha:1];
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

}

- (void)clickBack:(CommonDialog *)dialog
{
    //    [dialog removeFromSuperview];
}


#pragma mark - Draw View Delegate

- (void)didDrawedPaint:(Paint *)paint
{
    
    NSInteger intColor  = [DrawUtils compressDrawColor:paint.color];    
    NSMutableArray *pointList = [[[NSMutableArray alloc] init] autorelease];
    CGPoint lastPoint = ILLEGAL_POINT;
    int i = 0;
    for (NSValue *pointValue in paint.pointList) {
        CGPoint point = [pointValue CGPointValue];
        if (i ++ == 0 || [DrawUtils distanceBetweenPoint:lastPoint point2:point] > 2) 
        {
            CGPoint tempPoint = point;
            if ([DeviceDetection isIPAD]) {
                tempPoint = CGPointMake(point.x / IPAD_WIDTH_SCALE, point.y / IPAD_HEIGHT_SCALE);
            }
            NSNumber *pointNumber = [NSNumber numberWithInt:[DrawUtils compressPoint:tempPoint]];
            [pointList addObject:pointNumber];
        }
        lastPoint = point;
    }
    CGFloat width = paint.width;
    if ([DeviceDetection isIPAD]) {
        width /= 2;
    }
    [[DrawGameService defaultService]sendDrawDataRequestWithPointList:pointList color:intColor width:width penType:paint.penType];
}

- (void)didStartedTouch:(Paint *)paint
{
    [self disMissAllPickViews:YES];
}


#pragma mark - Actions


- (IBAction)clickChangeRoomButton:(id)sender {
    [self disMissAllPickViews:YES];
    
    CommonDialogStyle style;
    NSString *message = nil;
    if ([[AccountManager defaultManager] hasEnoughBalance:ESCAPE_DEDUT_COIN]) {
        style = CommonDialogStyleDoubleButton;
        message =[NSString stringWithFormat:NSLS(@"kDedutCoinQuitGameAlertMessage"), 1];//deduct one coin when runaway ,the coin should configured by config manager, do it later ---kira
    }else{
        style = CommonDialogStyleSingleButton;
        message = NSLS(@"kNoCoinQuitGameAlertMessage");
    }
    
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kQuitGameAlertTitle") message:message style:style delegate:self];
    dialog.tag = DIALOG_TAG_ESCAPE;
    [dialog showInView:self.view];
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

- (IBAction)clickGroupChatButton:(id)sender {
    [super showGroupChatView];
}

#pragma mark - levelServiceDelegate
- (void)levelDown:(int)level
{
    
}
@end
