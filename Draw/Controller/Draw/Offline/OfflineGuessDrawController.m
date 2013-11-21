//
//  offlineguessdrawcontroller.m
//  Draw
//
//  Created by  on 12-3-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "OfflineGuessDrawController.h"
#import "ShowDrawView.h"
#import "Word.h"
#import "WordManager.h"
#import "AnimationManager.h"
#import "AccountService.h"
#import "AudioManager.h"
#import "PPConfigManager.h"
#import "CommonMessageCenter.h"
#import "Draw.h"
#import "AccountManager.h"
#import "ShowFeedController.h"
#import "FeedService.h"
#import "DrawGameAnimationManager.h"
#import "UIImageExt.h"
#import "UseItemScene.h"
#import "MyFriend.h"
#import "UserGameItemService.h"
#import "FlowerItem.h"
#import "UserGameItemManager.h"
#import "GameItemManager.h"
#import "DrawHolderView.h"
#import "BalanceNotEnoughAlertView.h"
#import "AccountService.h"
#import "WordInputView.h"
#import "FeedSceneGuessResult.h"
#import "StringUtil.h"
#import "AudioPlayer.h"
#import "UIImageView+WebCache.h"
#import "WhisperStyleView.h"
#import "LevelService.h"
#import "TaskManager.h"

@interface OfflineGuessDrawController()
{
    CommonTitleView *_titleView;
}
@property (nonatomic, retain) ShowDrawView *showView;
@property (nonatomic, retain) AudioStreamer *audioPlayer;

@end

@implementation OfflineGuessDrawController

+ (OfflineGuessDrawController *)startOfflineGuess:(DrawFeed *)feed 
           fromController:(PPViewController *)fromController
{
    OfflineGuessDrawController *offGuess = [[OfflineGuessDrawController alloc]
                                            initWithFeed:feed];
    [fromController.navigationController pushViewController:offGuess animated:YES];
    [offGuess release];
    
    offGuess.fromController = fromController;
    return offGuess;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ASStatusChangedNotification object:self.audioPlayer];
    
    PPRelease(_feed);
    PPRelease(_showView);
    PPRelease(_wordInputView);
    PPRelease(_audioPlayer);
    [super dealloc];
}

- (IBAction)bomb:(id)sender {
    int price = [[GameItemManager defaultManager] priceWithItemId:ItemTypeTips];
    __block typeof (self) bself = self;
    [sender setEnabled:NO];
    [[UserGameItemService defaultService] consumeItem:ItemTypeTips
                                                count:1
                                             forceBuy:YES
                                              handler:^(int resultCode, int itemId, BOOL isBuy) {
        if (resultCode == ERROR_SUCCESS) {
            [_wordInputView bombHalf];
            if (isBuy) {
                POSTMSG(([NSString stringWithFormat:NSLS(@"kBuyABagAndUse"), price]));
            }
        }else if (resultCode == ERROR_BALANCE_NOT_ENOUGH){
            [BalanceNotEnoughAlertView showInController:bself];
            [sender setEnabled:YES];
        }else{
            POSTMSG(NSLS(@"kOperationFailed"));
            [sender setEnabled:YES];            
        }
    }];
}

- (id)initWithFeed:(DrawFeed *)feed
{
    self = [super init];
    if (self) {
        self.feed = feed;

        if ([feed isDrawCategory]) {
            if (_feed.drawData == nil) {
                [_feed parseDrawData];
                _feed.pbDrawData = nil; // add by Benson to clear the data for memory usage
            }
        }else if ([feed isSingCategory]){
            
            // init audio player here.
            self.audioPlayer = [[[AudioStreamer alloc] initWithURL:[NSURL URLWithString:self.feed.drawDataUrl]] autorelease];
            
            // register the streamer on notification
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(playbackStateChanged:)
                                                         name:ASStatusChangedNotification
                                                       object:self.audioPlayer];
            
            [self.audioPlayer start];
        }
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


- (void)initWordViews
{
    
    // Set answer
    self.wordInputView.answer = self.feed.wordText;
    self.wordInputView.delegate = self;
    

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *candidates = nil;

        if ([self.feed.wordText isEnglishString]) {
            NSString *txt = _feed.wordText;
            candidates = [[WordManager defaultManager] randEnglishCandidateStringWithWord:txt
                                                                                    count:18];
            
        }else{
            candidates = [[WordManager defaultManager] randChineseCandidateStringWithWord:_feed.wordText
                                                                                    count:18];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.wordInputView setCandidates:candidates column:9];
        });
    });

}


- (void)wordInputView:(WordInputView *)wordInputView
           didGetWord:(NSString *)word
            isCorrect:(BOOL)isCorrect
{
    if (isCorrect) {
        
        [[TaskManager defaultManager] completeTask:PBTaskIdTypeTaskGuessOpus
                                           isAward:NO
                                        clearBadge:YES];
        
        [self awardScoreAndLevel];
        [self quit:YES];
    }else{
//        POSTMSG(NSLS(@"kGuessWrong"));
    }
}



#pragma mark - View lifecycle

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_showView pause];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_showView resume];
}


- (void)checkDrawDataVersion
{
    if ([self.feed.drawData isNewVersion]) {
        POSTMSG(NSLS(@"kNewDrawVersionTip"));
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    SET_VIEW_BG(self.view);    
    [self initTitleView];

    [self initWordViews];
    [self checkDrawDataVersion];
    [self initShowView];
    [self setCanDragBack:NO];
}


- (void)viewDidUnload
{
    [self setShowView:nil];    
    [self setWordInputView:nil];
    [super viewDidUnload];
}

- (void)awardScoreAndLevel
{
    PPDebug(@"<awardScoreAndLevel>");

    //init score, award user
    BalanceSourceType type = GuessRewardType;
    int award = [PPConfigManager getOffLineGuessAward];
    [[AccountService defaultService] chargeCoin:award source:type];
    
    //add exp
    NSInteger exp = 0;
    exp = [PPConfigManager getOffLineGuessExp];
    BOOL isLevelUp = [[LevelService defaultService] addExp:exp delegate:nil];
    
    NSString* msg;
    if (isLevelUp){
        msg = [NSString stringWithFormat:NSLS(@"kGuessAwardWithLevelUpMsg"), [[LevelService defaultService] level]];
    }
    else{
        msg = [NSString stringWithFormat:NSLS(@"kGuessNormalAwardMsg"), award, exp];
    }
    
    POSTMSG2(msg, 2);
}

- (void)cleanData
{
    [self.showView stop];
    [self.showView removeFromSuperview];
    self.showView = nil;
}

- (void)quit:(BOOL)correct
{
    if ([_wordInputView.guessedWords count] > 0) {
        [[DrawDataService defaultService] guessDraw:_wordInputView.guessedWords
                                             opusId:_feed.feedId
                                     opusCreatorUid:_feed.feedUser.userId
                                          isCorrect:correct
                                              score:_feed.drawData.word.score
                                           category:_feed.categoryType         
                                           delegate:nil];
    }
    
    if (correct) {
        [[UserManager defaultManager] guessCorrectOpus:_feed.feedId];
        [_feed incGuessTimes];
    }
    [self cleanData];
    if (correct && [self.fromController isKindOfClass:[ShowFeedController class]]) {
        [(ShowFeedController *)self.fromController setFeedScene:[[[FeedSceneGuessResult alloc] init] autorelease]];
    } 
    
    if ([self.feed isSingCategory]) {
        if ([self.audioPlayer isPlaying]){
            [self.audioPlayer pause];
        }
        self.audioPlayer = nil;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickBack:(id)sender
{
    CommonDialog* dialog;
    __block OfflineGuessDrawController* cp = self;
    if ([[AccountService defaultService] hasEnoughBalance:[PPConfigManager getBuyAnswerPrice] currency:PBGameCurrencyCoin]) {
        
        dialog = [CommonDialog createDialogWithTitle:NSLS(@"kQuitGameAlertTitle") message:[NSString stringWithFormat:NSLS(@"kQuitGameWithPaidForAnswer"), [PPConfigManager getBuyAnswerPrice]] style:CommonDialogStyleDoubleButtonWithCross];
        
        [dialog setClickOkBlock:^(UILabel *label){
            [[AccountService defaultService] deductCoin:[PPConfigManager getBuyAnswerPrice] source:BuyAnswer];
            [(NSMutableArray *)cp.wordInputView.guessedWords addObject:cp.feed.wordText];
            [cp quit:YES];
        }];
        
        [dialog setClickCancelBlock:^(NSString *inputStr){
            [cp quit:NO];
        }];
        
        
        [dialog.cancelButton setTitle:NSLS(@"kQuitDirectly") forState:UIControlStateNormal];
    } else {
        
        dialog = [CommonDialog createDialogWithTitle:NSLS(@"kQuitGameAlertTitle") message:NSLS(@"kQuitGameAlertMessage") style:CommonDialogStyleDoubleButton];
        [dialog setClickOkBlock:^(UILabel *label){
            [cp quit:NO];
        }];
    }
    
    [dialog showInView:self.view];
}

- (void)initTitleView
{
    CommonTitleView *titleView = [CommonTitleView createTitleView:self.view];
    [titleView setTarget:self];
    [titleView setBackButtonSelector:@selector(clickBack:)];
    [titleView setTitle:NSLS(@"kGuessing")];
    _titleView = titleView;
    
    if ([self.feed isSingCategory]) {
        [titleView setRightButtonTitle:NSLS(@"kPlayAudioAgain")];
        [titleView setRightButtonSelector:@selector(clickPlayAudioAgain:)];
        [titleView hideRightButton];
    }
}

- (void)initShowView
{
    if ([self.feed isDrawCategory]) {
        [self initShowDrawView];
    }else if ([self.feed isSingCategory]){
        [self initShowSingView];
    }
}

- (void)initShowDrawView
{
    CGRect rect = [CanvasRect defaultRect];
    if (self.feed.drawData) {
        rect = [self.feed.drawData canvasRect];
    }
    ShowDrawView* showDrawView = [[ShowDrawView alloc] initWithFrame:rect];
    self.showView = showDrawView;
    [self.showView updateLayers:self.feed.drawData.layers];
    [self.showView setDrawActionList:_feed.drawData.drawActionList];
    DrawHolderView *holder = [DrawHolderView defaultDrawHolderViewWithContentView:_showView];
    [self.view insertSubview:holder atIndex:0];
    [holder updateOriginY:COMMON_TITLE_VIEW_HEIGHT];
    if (ISIPHONE5) {
        [holder updateHeight:CGRectGetHeight(holder.frame) + 108];
        [holder updateContentScale];
    }
    [self.showView play];
    [showDrawView release];
}

- (void)initShowSingView{
    
    CGRect rect;
    
    if (ISIPAD) {
        rect = CGRectMake(70, 92, 628, 628);
    }else if (ISIPHONE5){
        rect = CGRectMake(21, 88, 280, 280);
    }else{
        rect = CGRectMake(21, 48, 280, 280);
    }
    
    WhisperStyleView *v = [WhisperStyleView createWithFrame:rect feed:self.feed];
    
    [self.view addSubview:v];
}

- (void)clickPlayAudioAgain:(id)sender{
    
    [_audioPlayer start];
}

/*
 *  observe the notification listener when loading an audio
 */
- (void)playbackStateChanged:(NSNotification *)notification
{
    CommonTitleView *titleView = [CommonTitleView titleView:self.view];

    if ([_audioPlayer isIdle]) {
        [titleView showRightButton];
	}else{
        [titleView hideRightButton];
    }
}

@end
