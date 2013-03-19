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
#import "DrawColorManager.h"
#import "PointNode.h"
#import "BuyItemView.h"
#import "GameItemManager.h"

@interface OnlineDrawViewController ()
{

    CGFloat _alpha;
}
@property(nonatomic, retain)DrawToolPanel *drawToolPanel;
@property (retain, nonatomic) DrawColor* eraserColor;
@property (retain, nonatomic) DrawColor* bgColor;
@property (retain, nonatomic) DrawColor* penColor;
@property (retain, nonatomic) DrawColor *tempColor;

@property (retain, nonatomic) IBOutlet UIImageView *wordLabelBGView;

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
    [drawGameService setDrawDelegate:nil];
    
    PPRelease(wordLabel);
    PPRelease(drawView);
    PPRelease(_gameCompleteMessage);
    PPRelease(_tempColor);
    [_wordLabelBGView release];
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

#define STATUSBAR_HEIGHT 20.0
- (void)initDrawToolPanel
{
    self.drawToolPanel = [DrawToolPanel createViewWithdelegate:self];
    CGFloat x = self.view.center.x;
    CGFloat y = CGRectGetHeight([[UIScreen mainScreen] bounds]) - CGRectGetHeight(self.drawToolPanel.bounds) / 2 - STATUSBAR_HEIGHT;
    self.drawToolPanel.center = CGPointMake(x, y);
    [self.drawToolPanel setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.drawToolPanel];
    [self.drawToolPanel setPanelForOnline:YES];
    [self.drawToolPanel setTimerDuration:60];
    [self.drawToolPanel startTimer];
}

//#define DRAW_VIEW_Y_OFFSET (ISIPAD ? 6 : 6)

- (void)initDrawView
{
    UIView *paperView = [self.view viewWithTag:PAPER_VIEW_TAG];
    CGRect frame = DRAW_VIEW_FRAME;
//    frame.origin.y -= DRAW_VIEW_Y_OFFSET;
    drawView = [[DrawView alloc] initWithFrame:frame];
    [drawView setDrawEnabled:YES];
    drawView.delegate = self;
    drawView.strawDelegate = self.drawToolPanel;
    [self.view insertSubview:drawView aboveSubview:paperView];
    self.eraserColor = self.bgColor = [DrawColor whiteColor];
    self.penColor = [DrawColor blackColor];
    _alpha = 1.0;
}

- (void)initWordLabel
{
    NSString *wordText = self.word.text;
    [self.wordLabel setText:wordText];
    [self.wordLabelBGView setImage:[shareImageManager drawColorBG]];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    drawGameService.drawDelegate = self;
    [self initWordLabel];
    [self initDrawToolPanel];
    [self initDrawView];
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
    [self setWordLabelBGView:nil];
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
        
    }else{
        PPDebug(@"%@ give you a flower", userId);
        [self recieveFlower];
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
        [[AccountService defaultService] deductAccount:[ConfigManager getOnlineDrawFleeCoin] source:EscapeType];
        [self cleanData];
        [[LevelService defaultService] minusExp:NORMAL_EXP delegate:self];
    }
}

- (void)clickBack:(CommonDialog *)dialog
{
    //    [dialog removeFromSuperview];
}


#pragma mark - Draw View Delegate

- (void)drawView:(DrawView *)drawView didFinishDrawAction:(DrawAction *)action
{
    if ([action isDrawAction]) {
        Paint *paint = action.paint;
        NSInteger intColor  = [DrawUtils compressDrawColor:paint.color];
        NSMutableArray *pointList = [paint createNumberPointList:YES pointXList:nil pointYList:nil];
        CGFloat width = paint.width;
        if ([DeviceDetection isIPAD]) {
            width /= 2;
        }
        [[DrawGameService defaultService]sendDrawDataRequestWithPointList:pointList color:intColor width:width penType:paint.penType];        
    }else if([action isShapeAction]){
        //TODO send shape action
    }
}

- (void)drawView:(DrawView *)drawView didStartTouchWithAction:(DrawAction *)action
{
    [self.drawToolPanel dismissAllPopTipViews];
    [self updateRecentColors];
}


#pragma mark - Actions


- (IBAction)clickChangeRoomButton:(id)sender {
    [self.drawToolPanel dismissAllPopTipViews];
    
    CommonDialogStyle style;
    NSString *message = nil;
    if ([[AccountManager defaultManager] hasEnoughBalance:ESCAPE_DEDUT_COIN]) {
        style = CommonDialogStyleDoubleButton;
        message =[NSString stringWithFormat:NSLS(@"kDedutCoinQuitGameAlertMessage"), [ConfigManager getOnlineDrawFleeCoin]];
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
#pragma mark - CommonItemInfoView Delegate

- (void)didBuyItem:(int)itemId
            result:(int)result
{
    if (result == 0) {
        switch (itemId) {
            case PaletteItem:
            case ColorAlphaItem:
            case ColorStrawItem:
                [self.drawToolPanel updateNeedBuyToolViews];
                [self.drawToolPanel userItem:itemId];
                break;
            case Pen:
            case Pencil:
            case IcePen:
            case Quill:
            case WaterPen:
            {
                [self.drawToolPanel setPenType:itemId];
                [drawView setPenType:itemId];
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


- (void)synEraserColor
{
    self.eraserColor = drawView.bgColor;
    if (drawView.penType == Eraser) {
        drawView.lineColor = self.eraserColor;
    }
}

#pragma mark - Draw Tool Panel Delegate

- (void)drawToolPanel:(DrawToolPanel *)toolPanel didClickRedoButton:(UIButton *)button
{
    [drawView redo];
    [self synEraserColor];
}

- (void)performRevoke
{
    [drawView revoke:^{
        [self hideActivity];
    }];
    [self synEraserColor];
}

- (void)drawToolPanel:(DrawToolPanel *)toolPanel didClickUndoButton:(UIButton *)button
{
    drawView.touchActionType = TouchActionTypeDraw;
    [self showActivityWithText:NSLS(@"kRevoking")];
    [self performSelector:@selector(performRevoke) withObject:nil afterDelay:0.1f];
}
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didClickEraserButton:(UIButton *)button
{
    drawView.touchActionType = TouchActionTypeDraw;
    [drawView setLineColor:self.eraserColor];
    [drawView setPenType:Eraser];
}
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didClickPaintBucket:(UIButton *)button
{
    drawView.touchActionType = TouchActionTypeDraw;
    self.penColor.alpha = 1.0;
    [drawView changeBackWithColor:self.penColor];
    [self drawView:drawView didFinishDrawAction:[DrawAction changeBackgroundActionWithColor:self.penColor]];

    self.eraserColor = self.penColor;
    self.penColor = drawView.lineColor = [DrawColor blackColor];
    [drawView.lineColor setAlpha:_alpha];
    [toolPanel setColor:self.penColor];
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
    }else{
        [BuyItemView showOnlyBuyItemView:penType inView:self.view resultHandler:^(int resultCode, int itemId, int count, NSString *toUserId) {
            
        }];
    }
}
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didSelectWidth:(CGFloat)width
{
    drawView.touchActionType = TouchActionTypeDraw;
    drawView.lineWidth = width;
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
        [drawView.lineColor setAlpha:alpha];
    }
}

- (void)drawToolPanel:(DrawToolPanel *)toolPanel didClickChatButton:(UIButton *)button
{
    [self showGroupChatView];
}

- (void)drawToolPanelDidTimeout:(DrawToolPanel *)toolPanel
{
    
}
- (void)drawToolPanel:(DrawToolPanel *)toolPanel startToBuyItem:(ItemType)type
{    
    [BuyItemView showOnlyBuyItemView:type inView:self.view resultHandler:^(int resultCode, int itemId, int count, NSString *toUserId) {
        
    }];
}

- (void)drawToolPanel:(DrawToolPanel *)toolPanel didClickStrawButton:(UIButton *)button
{
    drawView.touchActionType = TouchActionTypeGetColor;
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
