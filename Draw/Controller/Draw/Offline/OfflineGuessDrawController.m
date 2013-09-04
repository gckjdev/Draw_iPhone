//
//  ShowDrawController.m
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
#import "ConfigManager.h"
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


@interface OfflineGuessDrawController()
{
    CommonTitleView *_titleView;
}
@property (nonatomic, retain)ShowDrawView *showView;

@end

@implementation OfflineGuessDrawController

+ (OfflineGuessDrawController *)startOfflineGuess:(DrawFeed *)feed 
           fromController:(UIViewController *)fromController
{
    OfflineGuessDrawController *offGuess = [[OfflineGuessDrawController alloc]
                                            initWithFeed:feed];
    [fromController.navigationController pushViewController:offGuess animated:YES];
    [offGuess release];        
    return offGuess;
}

- (void)dealloc
{
    PPRelease(_feed);
    PPRelease(_showView);
    PPRelease(_wordInputView);
    [super dealloc];
}

- (IBAction)bomb:(id)sender {
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

- (id)initWithFeed:(DrawFeed *)feed
{
    self = [super init];
    if (self) {
        self.feed = feed;
        if (_feed.drawData == nil) {
            [_feed parseDrawData];
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
    self.wordInputView.answerColor = [UIColor whiteColor];

    
    NSString *candidates = nil;
    if (_feed.drawData.languageType == EnglishType) {
        candidates = [[WordManager defaultManager] randEnglishCandidateStringWithWord:_feed.wordText
                                                                                count:18];
    }else{
        candidates = [[WordManager defaultManager] randChineseCandidateStringWithWord:_feed.wordText
                                                                                count:18];
    }
    
    [self.wordInputView setCandidates:candidates column:9];
    
    [self.wordInputView setCandidateColor:[UIColor whiteColor]];

}


- (void)wordInputView:(WordInputView *)wordInputView
           didGetWord:(NSString *)word
            isCorrect:(BOOL)isCorrect
{
    if (isCorrect) {
        POSTMSG(NSLS(@"kGuessCorrect"));
        [self quit:YES];
    }else{
        POSTMSG(NSLS(@"kGuessWrong"));
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
                                           delegate:nil];   
    }
    if (correct) {
        [_feed incGuessTimes];
    }
    [self cleanData];
    [self.navigationController popViewControllerAnimated:YES];

}

- (IBAction)clickBack:(id)sender
{
    CommonDialog* dialog;
    __block OfflineGuessDrawController* cp = self;
    if ([[AccountService defaultService] hasEnoughBalance:[ConfigManager getBuyAnswerPrice] currency:PBGameCurrencyCoin]) {
        
        dialog = [CommonDialog createDialogWithTitle:NSLS(@"kQuitGameAlertTitle") message:[NSString stringWithFormat:NSLS(@"kQuitGameWithPaidForAnswer"), [ConfigManager getBuyAnswerPrice]] style:CommonDialogStyleDoubleButtonWithCross];
        
        [dialog setClickOkBlock:^(UILabel *label){
            [[AccountService defaultService] deductCoin:[ConfigManager getBuyAnswerPrice] source:BuyAnswer];
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
}

- (void)initShowView
{
    CGRect rect = [CanvasRect defaultRect];
    if (self.feed.drawData) {
        rect = [self.feed.drawData canvasRect];
    }
    self.showView = [[ShowDrawView alloc] initWithFrame:rect];
    [self.showView updateLayers:self.feed.drawData.layers];
    [self.showView setDrawActionList:_feed.drawData.drawActionList];
    DrawHolderView *holder = [DrawHolderView defaultDrawHolderViewWithContentView:_showView];
    [self.view insertSubview:holder atIndex:0];
    [holder updateOriginY:COMMON_TITLE_VIEW_HEIGHT];
    [self.showView play];
}
@end
