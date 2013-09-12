//
//  ShowDrawController.m
//  Draw
//
//  Created by  on 12-3-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "OnlineGuessDrawController.h"
#import "ShowDrawView.h"
#import "GameSessionUser.h"
#import "GameSession.h"
#import "Word.h"
#import "WordManager.h"
#import "AnimationManager.h"
#import "GameTurn.h"
#import "ResultController.h"
#import "PPApplication.h"
#import "HomeController.h"
#import "StableView.h"
#import "RoomController.h"
#import "GameMessage.pb.h"
#import "AccountService.h"
#import "DrawConstants.h"
#import "AudioManager.h"
#import "ConfigManager.h"
#import "CommonMessageCenter.h"
#import "GameConstants.h"
#import "AccountManager.h"
#import "UseItemScene.h"
#import "AccountService.h"
#import "Item.h"
#import "CanvasRect.h"
#import "UserGameItemService.h"
#import "FlowerItem.h"
#import "GameItemManager.h"
#import "UserGameItemManager.h"
#import "DrawHolderView.h"
#import "TomatoItem.h"
#import "WordInputView.h"
#import "BalanceNotEnoughAlertView.h"

#define MAX_TOMATO_CAN_THROW 3
#define MAX_FLOWER_CAN_SEND 10




@implementation OnlineGuessDrawController
@synthesize showView;


- (void)dealloc
{
    [drawGameService setShowDelegate:nil];
    
    [showView stop];
    PPRelease(showView);
    PPRelease(_scene);
    PPRelease(_wordInputView);
    PPRelease(_toolView);
    PPRelease(_popView);
    [super dealloc];
}


#pragma mark - Constroction
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)init{
    self = [super init];
    if (self) {
        _scene = [[UseItemScene createSceneByType:UseSceneTypeOnlineGuess feed:nil] retain];
        _guessCorrect = NO;        
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
    [[WordManager defaultManager] clearWordBaseDictionary];
}



#pragma makr - Timer Handle

- (void)handleTimer:(NSTimer *)theTimer
{
    PPDebug(@"<OnlineGuessDrawViewController> handle timer");    
    --retainCount;
    if (retainCount <= 0) {
        [self resetTimer];
        retainCount = 0;
    }
    [self updateClockButton];
}


- (void)initPickToolView
{
    
}

- (void)initWordInputView
{
    self.wordInputView.delegate = self;    
    
    NSString *candidates = @"                  "; //18 space.
    [self.wordInputView setCandidates:candidates column:9];
    [self.wordInputView setDisable:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [drawGameService setShowDelegate:self];
    
    [self initShowView];
    [self initPickToolView];
    [self initWordInputView];
    [self initWithCacheData];
    
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


- (void)viewDidUnload
{
    [self setClockButton:nil];
    [self setTurnNumberButton:nil];
    [self setShowView:nil];
    [self setWordInputView:nil];
    [super viewDidUnload];
    [self setWord:nil];
}

#pragma mark- word input view delegate

- (void)wordInputView:(WordInputView *)wordInputView
           didGetWord:(NSString *)word
            isCorrect:(BOOL)isCorrect
{
    if (isCorrect) {
//        POSTMSG(NSLS(@"kGuessCorrect"));
        [wordInputView setDisable:YES];
        _guessCorrect = YES;
    }else{
//        POSTMSG(NSLS(@"kGuessWrong"));
    }
    [drawGameService guess:word guessUserId:drawGameService.session.userId];
}
#pragma mark - Draw Game Service Delegate

- (void)didReceiveDrawWord:(NSString*)wordText level:(int)wordLevel language:(int)language
{
    if (wordText) {
        [self.wordInputView setDisable:NO];
        [self.wordInputView setAnswer:wordText];
        NSString *candidates = nil;
        if (language == EnglishType) {
            candidates = [[WordManager defaultManager] randEnglishCandidateStringWithWord:wordText count:18];
        }else{
            candidates = [[WordManager defaultManager] randChineseCandidateStringWithWord:wordText count:18];
        }
        [self.wordInputView setCandidates:candidates column:9];
        self.wordInputView.delegate = self;
        //Add animations?
    }else{
        PPDebug(@"warn:<ShowDrawController> word is nil");
    }
}


// new draw action delegate methods, add by Benson 2013-04-02
- (void)didReceiveDrawActionData:(PBDrawAction*)drawAction
                 isSetCanvasSize:(BOOL)isSetCanvasSize
                      canvasSize:(CGSize)canvasSize
{
    if (isSetCanvasSize) {
        [showView changeRect:CGRectFromCGSize(canvasSize)];
    }
        
    DrawAction *action = [DrawAction drawActionWithPBDrawAction:drawAction];
    [showView addDrawAction:action play:YES];
}

- (void)didReceiveRedrawResponse:(GameMessage *)message
{
    DrawAction *action = [[[CleanAction alloc] init] autorelease];
    [showView addDrawAction:action play:YES];
    
}
- (void)didBroken
{
    PPDebug(@"<ShowDrawController>:didBroken");
    [self cleanData];
    [HomeController returnRoom:self];
}




#pragma mark - Observer Method/Game Process
- (void)didGameTurnGuessStart:(GameMessage *)message
{
    PPDebug(@"<ShowDrawController>didGameTurnGuessStart");
    [self startTimer];
}


- (void)didUserQuitGame:(GameMessage *)message
{
    NSString *userId = [[message notification] quitUserId];
    [self popUpRunAwayMessage:userId];
    [self adjustPlayerAvatars:userId];
    if ([self userCount] <= 1) {
        POSTMSG(NSLS(@"kAllUserQuit"));
    }
}
- (void)didGameTurnComplete:(GameMessage *)message
{
    PPDebug(@"<ShowDrawController>didGameTurnComplete");

    NSInteger gainCoin = [[message notification] turnGainCoins];
    [showView setShowPenHidden:YES];
    [showView show];
    UIImage *image = [showView createImage];
    
    NSString* drawUserId = [[[drawGameService session] currentTurn] lastPlayUserId];
    NSString* drawUserNickName = [[drawGameService session] getNickNameByUserId:drawUserId];
    [self cleanData];

    ResultController *rc = [[ResultController alloc] initWithImage:image
                                                        drawUserId:drawUserId
                                                  drawUserNickName:drawUserNickName
                                                          wordText:self.word.text 
                                                             score:gainCoin
                                                           correct:_guessCorrect 
                                                         isMyPaint:NO 
                                                    drawActionList:showView.drawActionList
                                                             scene:[UseItemScene createSceneByType:UseSceneTypeOnlineGuess feed:nil]];
    [self.navigationController pushViewController:rc animated:YES];
    [rc release];
    
}

- (void)didReceiveRank:(NSNumber*)rank fromUserId:(NSString*)userId
{
    if (rank.integerValue == RANK_TOMATO) {
        PPDebug(@"%@ give you an tomato", userId);
    }else{
        PPDebug(@"%@ give you a flower", userId);
    }
    
}

#pragma mark - Common Dialog Delegate

- (void)didClickOk:(CommonDialog *)dialog infoView:(id)infoView
{
    //run away
    switch (dialog.tag) {
        default:
            [drawGameService quitGame];
            [HomeController returnRoom:self];
            [self.showView stop];
            [self cleanData];
            [[LevelService defaultService] minusExp:NORMAL_EXP delegate:self];
            break;
    }

}

- (void)throwFlower:(ToolView *)toolView
{
    [self.popView dismissAnimated:YES];    
    [[FlowerItem sharedFlowerItem] useItem:[[[drawGameService session] currentTurn] currentPlayUserId] isOffline:NO drawFeed:nil forFree:NO resultHandler:^(int resultCode, int itemId, BOOL isBuy) {
        if (resultCode == ERROR_SUCCESS) {
            [self showAnimationThrowTool:toolView isBuy:isBuy];
            [_scene throwAFlower];
            if (![_scene canThrowFlower]) {
                [toolView setEnabled:NO];
            }
        }
        else if (resultCode == ERROR_BALANCE_NOT_ENOUGH){
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kNotEnoughCoin") delayTime:1 isHappy:NO];
        }
        else if (resultCode == ERROR_NETWORK){
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kSystemFailure") delayTime:2 isHappy:NO];
        }
    }];
}

- (void)throwTomato:(ToolView *)toolView
{
    [self.popView dismissAnimated:YES];    
    [[TomatoItem sharedTomatoItem] useItem:[[[drawGameService session] currentTurn] currentPlayUserId] isOffline:NO feedOpusId:nil feedAuthor:nil forFree:NO resultHandler:^(int resultCode, int itemId, BOOL isBuy) {
        if (resultCode == ERROR_SUCCESS) {
            [self showAnimationThrowTool:toolView isBuy:isBuy];
            [_scene throwATomato];
            if (![_scene canThrowTomato]) {
                [toolView setEnabled:NO];
            }
        }else if (resultCode == ERROR_BALANCE_NOT_ENOUGH){
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kNotEnoughCoin") delayTime:1 isHappy:NO];
        }else if (resultCode == ERROR_NETWORK){
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kSystemFailure") delayTime:2 isHappy:NO];
        }
    }];
    

}
- (IBAction)clickRunAway:(id)sender {
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kQuitGameAlertTitle") message:NSLS(@"kQuitGameAlertMessage") style:CommonDialogStyleDoubleButton delegate:self];
    [dialog showInView:self.view];
}



- (void)initShowView
{

    CGRect rect = [CanvasRect defaultRect];
    if (!CGSizeEqualToSize(drawGameService.canvasSize, CGSizeZero)) {
        rect = CGRectFromCGSize(drawGameService.canvasSize);
    }
    showView = [[ShowDrawView alloc] initWithFrame:rect];
    
    [showView updateLayers:[DrawLayer defaultOldLayersWithFrame:rect]];
    
    [showView setPlaySpeed:[ConfigManager getOnlinePlayDrawSpeed]];
    DrawHolderView *holder = [DrawHolderView defaultDrawHolderViewWithContentView:showView];
    if (ISIPHONE5) {
        [holder updateHeight:CGRectGetHeight(holder.frame) + 108];
        [holder updateContentScale];
    }    
    [self.view insertSubview:holder atIndex:0];
    
}

- (void)initWithCacheData
{
    if (drawGameService.sessionStatus == SESSION_PLAYING) {
        if (drawGameService.word.text) {
            [self didReceiveDrawWord:drawGameService.word.text 
                               level:drawGameService.word.level
                            language:drawGameService.language];
        }
        
        [showView changeRect:CGRectFromCGSize(drawGameService.canvasSize)];

        NSArray *actionList = drawGameService.drawActionList;
        for (DrawAction *action in actionList) {
            [showView addDrawAction:action play:YES];
        }
        [self startTimer];
    }
}

- (void)bomb:(ToolView *)tip
{
    [self.popView dismissAnimated:YES];
    [tip setEnabled:NO];
    int price = [[GameItemManager defaultManager] priceWithItemId:ItemTypeTips];
    
    __block typeof (self) bself = self;
    [[UserGameItemService defaultService] consumeItem:ItemTypeTips
                                                count:1
                                             forceBuy:YES
                                              handler:^(int resultCode, int itemId, BOOL isBuy) {
                                                  if (resultCode == ERROR_SUCCESS) {
                                                      [_wordInputView bombHalf];
                                                      if (isBuy) {
                                                          POSTMSG(([NSString stringWithFormat:NSLS(@"kBuyABagAndUse"), price]));
                                                      }
                                                  }else if (ERROR_BALANCE_NOT_ENOUGH){
                                                      [BalanceNotEnoughAlertView showInController:bself];
                                                  }else{
                                                      POSTMSG(NSLS(@"kOperationFailed"));
                                                  }
                                              }];

}

- (IBAction)clickGroupChatButton:(id)sender {
    [super showGroupChatView];
}

#define TOOL_VIEW_SPACE (ISIPAD?15:8)
- (IBAction)clickToolBox:(id)sender
{
    if (_toolView == nil) {
        CGFloat width = (ISIPAD?80:40);
        CGFloat height = width * 3 + TOOL_VIEW_SPACE * 2;
        _toolView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];

        //add button
        ToolView *tip = [ToolView tipsViewWithNumber:0];
        ToolView *flower = [ToolView flowerViewWithNumber:0];
        ToolView *tomato = [ToolView tomatoViewWithNumber:0];

        flower.frame = tomato.frame = tip.frame = CGRectMake(0, 0, width, width);
        
        [tip addTarget:self action:@selector(bomb:)];
        [flower addTarget:self action:@selector(throwFlower:)];
        [tomato addTarget:self action:@selector(throwTomato:)];
        [flower updateOriginY:(width+TOOL_VIEW_SPACE)];
        [tomato updateOriginY:(width+TOOL_VIEW_SPACE)*2];
        


        [_toolView addSubview:tip];
        [_toolView addSubview:flower];
        [_toolView addSubview:tomato];
    }
    if (self.popView == nil) {
        self.popView = [[[CMPopTipView alloc] initWithCustomView:_toolView] autorelease];
        self.popView.delegate = self;
        [self.popView presentPointingAtView:sender inView:self.view animated:YES];
        [self.popView setBackgroundColor:COLOR_GRAY];
        
    }else{
        [self.popView dismissAnimated:YES];
        self.popView = nil;
    }
}
- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
    self.popView = nil;
}
- (void)popTipViewWasDismissedByCallingDismissAnimatedMethod:(CMPopTipView *)popTipView
{
    self.popView = nil;
    
}


@end
