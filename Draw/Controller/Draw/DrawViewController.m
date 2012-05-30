//
//  DrawViewController.m
//  Draw
//
//  Created by gamy on 12-3-4.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "DrawViewController.h"
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
#import "ShowDrawController.h"
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

#import "FriendRoomController.h"


@implementation DrawViewController

@synthesize eraserButton;
@synthesize wordButton;
@synthesize cleanButton;
@synthesize penButton;
@synthesize colorButton;

#define PAPER_VIEW_TAG 20120403


#pragma mark - Static Method
+ (void)startDraw:(Word *)word fromController:(UIViewController*)fromController
{
    LanguageType language = [[UserManager defaultManager] getLanguageType];
    DrawViewController *vc = [[DrawViewController alloc] initWithWord:word lang:language];
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
    PPRelease(pickColorView);
    PPRelease(drawView);
    
    //    [autoReleasePool drain];
    //    autoReleasePool = nil;
    
    [colorButton release];
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
    }
    return self;
}


- (void)initPickPenView
{
    pickColorView = [[PickColorView alloc] initWithFrame:PICK_PEN_VIEW];
    [pickColorView setImage:[shareImageManager toolPopupImage]];
    pickColorView.delegate = self;
    [self.view addSubview:pickColorView];
    NSMutableArray *widthArray = [[NSMutableArray alloc] init];
    NSMutableArray *colorViewArray = [[NSMutableArray alloc] init];
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
    
    [pickColorView setLineWidths:widthArray];
    [widthArray release];
    
    [colorViewArray addObject:[ColorView blackColorView]];
    [colorViewArray addObject:[ColorView redColorView]];
    [colorViewArray addObject:[ColorView greenColorView]];
    [colorViewArray addObject:[ColorView blueColorView]];
    [colorViewArray addObject:[ColorView yellowColorView]];
//    [colorViewArray addObject:[ColorView orangeColorView]];
//    [colorViewArray addObject:[ColorView pinkColorView]];
//    [colorViewArray addObject:[ColorView brownColorView]];
//    [colorViewArray addObject:[ColorView skyColorView]];
    //    [colorViewArray addObject:[ColorView whiteColorView]];
    
    [pickColorView setColorViews:colorViewArray];
    [colorViewArray release];
}

#pragma mark - Timer

- (void)handleTimer:(NSTimer *)theTimer
{
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
    GREEN_COLOR,
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
        case GREEN_COLOR:
            return [DrawColor greenColor];
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
    [self initPickPenView];
    DrawColor *randColor = [self randColor];
    [drawView setLineColor:randColor];
    [colorButton setDrawColor:randColor];
    //    [penButton setPenColor:randColor];
    [penButton setPenType:2];
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
    NSString *wordText = [NSString stringWithFormat:NSLS(@"kDrawWord"),self.word.text];
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
}




- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    
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

#pragma mark - Pick view delegate
- (void)didPickedColorView:(ColorView *)colorView
{
    [colorView retain];
    [drawView setLineColor:colorView.drawColor];
    [drawView setLineWidth:penWidth];
    [colorButton setDrawColor:colorView.drawColor];
    //    [penButton setPenColor:colorView.drawColor];
    [pickColorView updatePickPenView:colorView];
    [colorView release];
}
- (void)didPickedLineWidth:(NSInteger)width
{
    [drawView setLineWidth:width];
    penWidth = width;
}
- (void)didPickedMoreColor
{
    ColorShopView *colorShop = [ColorShopView colorShopViewWithFrame:self.view.bounds];
    colorShop.delegate = self;
    [colorShop showInView:self.view animated:YES];
    
}

#pragma mark - Common Dialog Delegate
#define ESCAPE_DEDUT_COIN 1
#define DIALOG_TAG_CLEAN_DRAW 201204081
#define DIALOG_TAG_ESCAPE 201204082
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
    [[DrawGameService defaultService]sendDrawDataRequestWithPointList:pointList color:intColor width:width];
}

- (void)didStartedTouch:(Paint *)paint
{
    [pickColorView setHidden:YES];
}


#pragma mark - Actions

- (IBAction)clickChangeRoomButton:(id)sender {
    
    [pickColorView setHidden:YES animated:YES];
    
    CommonDialogStyle style;
    NSString *message = nil;
    if ([[AccountManager defaultManager] hasEnoughBalance:ESCAPE_DEDUT_COIN]) {
        style = CommonDialogStyleDoubleButton;
        message = NSLS(@"kDedutCoinQuitGameAlertMessage");
    }else{
        style = CommonDialogStyleSingleButton;
        message = NSLS(@"kNoCoinQuitGameAlertMessage");
    }
    
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kQuitGameAlertTitle") message:message style:style delegate:self];
    dialog.tag = DIALOG_TAG_ESCAPE;
    [dialog showInView:self.view];
}
- (IBAction)clickRedraw:(id)sender {
    [pickColorView setHidden:YES animated:YES];
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kCleanDrawTitle") message:NSLS(@"kCleanDrawMessage") style:CommonDialogStyleDoubleButton delegate:self];
    dialog.tag = DIALOG_TAG_CLEAN_DRAW;
    [dialog showInView:self.view];
}

- (IBAction)clickEraserButton:(id)sender {
    [drawView setLineColor:[DrawColor whiteColor]];
    [drawView setLineWidth:eraserWidth];
}

- (IBAction)clickPenButton:(id)sender {
    [pickColorView setHidden:!pickColorView.hidden animated:YES];
    //        PenView *penView = (PenView *)sender;
    //        [drawView setLineColor:penView.penColor];
    [drawView setLineWidth:penWidth];
}

- (IBAction)clickGroupChatButton:(id)sender {
    [super showGroupChatView];
}
@end
