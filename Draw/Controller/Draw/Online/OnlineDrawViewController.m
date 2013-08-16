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
#import "ToolCommand.h"
#import "DrawHolderView.h"
#import "DrawInfo.h"


@interface OnlineDrawViewController ()
{

}
@property(nonatomic, retain)DrawToolPanel *drawToolPanel;

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
    PPRelease(_drawToolPanel);
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
    
    self.drawToolPanel = [DrawToolPanel createViewWithDrawView:drawView];
    
    CGFloat x = self.view.center.x;
    CGFloat y = CGRectGetHeight([[UIScreen mainScreen] bounds]) - CGRectGetHeight(self.drawToolPanel.bounds) / 2 - STATUSBAR_HEIGHT;
    self.drawToolPanel.center = CGPointMake(x, y);
    [self.drawToolPanel setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.drawToolPanel];

    [self.drawToolPanel setPanelForOnline:YES];
    [self.drawToolPanel setTimerDuration:60];
    [self.drawToolPanel bindController:self];
    [self.drawToolPanel startTimer];
}

//#define DRAW_VIEW_Y_OFFSET (ISIPAD ? 6 : 6)

- (void)initDrawView
{
    drawView = [[DrawView alloc] initWithFrame:[CanvasRect defaultRect]
                                        layers:[DrawLayer defaultOldLayersWithFrame:[CanvasRect defaultRect]]];

    [drawView setDrawEnabled:YES];
    drawView.delegate = self;
    
    DrawHolderView *holder = [DrawHolderView defaultDrawHolderViewWithContentView:drawView];
    
    [self.view insertSubview:holder atIndex:4];
    PPDebug(@"DrawView Rect = %@",NSStringFromCGRect(drawView.frame));
    
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
    [self initDrawView];
    [self initDrawToolPanel];
    [drawGameService sendDrawAction:nil canvasSize:CGSizeToPBSize(drawView.bounds.size)];
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
    if (dialog.tag == DIALOG_TAG_ESCAPE && dialog.style == CommonDialogStyleDoubleButton && [[AccountManager defaultManager] hasEnoughBalance:1 currency:PBGameCurrencyCoin]) {
        [drawGameService quitGame];
        [HomeController returnRoom:self];
        [[AccountService defaultService] deductCoin:[ConfigManager getOnlineDrawFleeCoin] source:EscapeType];
        [self cleanData];
        [[LevelService defaultService] minusExp:NORMAL_EXP delegate:self];
    }
}

- (void)clickBack:(CommonDialog *)dialog
{
    //    [dialog removeFromSuperview];
}


#pragma mark - Draw View Delegate

- (void)drawView:(DrawView *)aDrawView didFinishDrawAction:(DrawAction *)action
{

    [[DrawGameService defaultService] sendDrawAction:[action toPBDrawAction] canvasSize:nil];
}

- (void)drawView:(DrawView *)aDrawView didStartTouchWithAction:(DrawAction *)action
{
    if ([[ToolCommandManager defaultManager] isPaletteShowing]) {
        [self.drawToolPanel updateRecentColorViewWithColor:aDrawView.drawInfo.penColor updateModel:YES];
    }
    [[ToolCommandManager defaultManager] hideAllPopTipViews];
}


#pragma mark - Actions


- (IBAction)clickRunAway:(id)sender {
    
    CommonDialogStyle style;
    NSString *message = nil;
    if ([[AccountManager defaultManager] hasEnoughBalance:ESCAPE_DEDUT_COIN currency:PBGameCurrencyCoin]) {
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

@end
