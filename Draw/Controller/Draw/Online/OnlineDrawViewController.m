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
#import "UIButtonExt.h"
#import "HomeController.h"
#import "StableView.h"
#import "AccountManager.h"
#import "AccountService.h"
#import "PenView.h"
#import "WordManager.h"
#import "GameTurn.h"
#import "DrawUtils.h"
#import "DeviceDetection.h"
#import "CommonMessageCenter.h"
#import "FriendRoomController.h"
#import "GameConstants.h"
#import "ItemService.h"

//#import "DrawToolPanel.h"

@interface OnlineDrawViewController ()

@property(nonatomic, retain)DrawToolPanel *drawToolPanel;
@property (retain, nonatomic) DrawColor* eraserColor;
@property (retain, nonatomic) DrawColor* bgColor;
@property (retain, nonatomic) DrawColor* penColor;

@end

@implementation OnlineDrawViewController


@synthesize wordLabel;
@synthesize gameCompleteMessage = _gameCompleteMessage;

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
    PPRelease(wordLabel);
    PPRelease(drawView);
    PPRelease(_gameCompleteMessage);
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}



#pragma mark - Construction

- (id)initWithWord:(Word *)word lang:(LanguageType)lang{
    self = [super init];
    if (self) {
        self.word = word;
        languageType = lang;
    }
    return self;
}


- (void)initDrawToolPanel
{
    self.drawToolPanel = [DrawToolPanel createViewWithdelegate:self];
    CGFloat x = self.view.center.x;
    CGFloat y = CGRectGetHeight([[UIScreen mainScreen] bounds]) - CGRectGetHeight(self.drawToolPanel.bounds) / 2;
    self.drawToolPanel.center = CGPointMake(x, y);
    [self.drawToolPanel setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.drawToolPanel];
    [self.drawToolPanel setPanelForOnline:YES];
    [self.drawToolPanel setTimerDuration:60];
    [self.drawToolPanel startTimer];
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
    [self.wordLabel setText:wordText];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    drawGameService.drawDelegate = self;
    [self initDrawView];
    [self initWordLabel];
    [self initDrawToolPanel];
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
    [_drawToolPanel stopTimer];
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    drawView.delegate = nil;
    [self setWord:nil];
    [self setPopupButton:nil];
    [self setTurnNumberButton:nil];
    [_drawToolPanel stopTimer];
    [self setDrawToolPanel:nil];
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
#define DIALOG_TAG_ESCAPE 201204082


#pragma mark - Common Dialog Delegate
- (void)clickOk:(CommonDialog *)dialog
{
    if (dialog.tag == DIALOG_TAG_ESCAPE && dialog.style == CommonDialogStyleDoubleButton && [[AccountManager defaultManager] hasEnoughBalance:1]) {
        [drawGameService quitGame];
        [HomeController returnRoom:self];
        [[AccountService defaultService] deductAccount:ESCAPE_DEDUT_COIN source:EscapeType];
        [self cleanData];
        [[LevelService defaultService] minusExp:NORMAL_EXP delegate:self];
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
    [self.drawToolPanel dismissAllPopTipViews];
}


#pragma mark - Actions


- (IBAction)clickChangeRoomButton:(id)sender {
    [self.drawToolPanel dismissAllPopTipViews];
    
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


#pragma mark - levelServiceDelegate
- (void)levelDown:(int)level
{
    
}

#pragma mark - Draw Tool Panel Delegate

- (void)drawToolPanel:(DrawToolPanel *)toolPanel didClickRedoButton:(UIButton *)button
{
    [drawView redo];
}
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didClickUndoButton:(UIButton *)button
{
    [drawView revoke];
}
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didClickEraserButton:(UIButton *)button
{
    [drawView setLineColor:self.eraserColor];
}
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didClickPaintBucket:(UIButton *)button
{
    DrawAction *drawAction = [drawView addChangeBackAction:self.penColor];
    self.eraserColor = self.penColor;
    [self didDrawedPaint:drawAction.paint];
}
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didSelectPen:(ItemType)penType
{
    drawView.penType = penType;
}
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didSelectWidth:(CGFloat)width
{
    drawView.lineWidth = width;
}
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didSelectColor:(DrawColor *)color
{
    self.penColor = color;
    [drawView setLineColor:color];
}
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didSelectAlpha:(CGFloat)alpha
{
    [self.penColor setAlpha:alpha];
    [drawView setLineColor:self.penColor];
}

- (void)drawToolPanel:(DrawToolPanel *)toolPanel didClickChatButton:(UIButton *)button
{
    [self showGroupChatView];
}

- (void)drawToolPanelDidTimeout:(DrawToolPanel *)toolPanel
{
    
}

@end
