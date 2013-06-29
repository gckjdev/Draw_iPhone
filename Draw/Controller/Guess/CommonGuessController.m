//
//  CommonGuessController.m
//  Draw
//
//  Created by 王 小涛 on 13-6-19.
//
//

#import "CommonGuessController.h"
#import "AccountService.h"
#import "ConfigManager.h"
#import "CommonDialog.h"
#import "CommonMessageCenter.h"
#import "LevelService.h"
#import "DrawSoundManager.h"
#import "OpusService.h"
#import "WordManager.h"
#import "StableView.h"
#import "ItemType.h"
#import "CommonMessageCenter.h"
#import "FlowerItem.h"
#import "BalanceNotEnoughAlertView.h"
#import "DrawGameAnimationManager.h"
#import "ItemUseRecorder.h"
#import "OpusGuessRecorder.h"

#import "GameItemManager.h"
#import "OpusGuessRecorder.h"

@interface CommonGuessController ()

@property (retain, nonatomic) NSMutableArray *guessWords;
@property (retain, nonatomic) PickToolView *pickToolView;

@end

@implementation CommonGuessController

- (void)dealloc {
    [_guessWords release];
    [_wordInputView release];
    [_opus release];
    [_titleLabel release];
    [_pickToolView release];
    [super dealloc];
}

- (id)initWithOpus:(Opus *)opus{
    
    if (self = [super init]) {
        
        self.opus = opus;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _wordInputView.answerImage = [UIImage imageNamed:@"wood_button@2x.png"];
    _wordInputView.candidateImage = [UIImage imageNamed:@"wood_button@2x.png"];
    _wordInputView.answer = _opus.pbOpus.name;
    _wordInputView.delegate = self;
    
    NSString *candidates = [[WordManager defaultManager] randChineseCandidateStringWithWord:_opus.pbOpus.name count:27];
    // TODO: Set candidate here
    [_wordInputView setCandidates:candidates column:9];
    
    [_wordInputView setClickSound:[DrawSoundManager defaultManager].clickWordSound];
    [_wordInputView setWrongSound:[DrawSoundManager defaultManager].guessWrongSound];
    [_wordInputView setCorrectSound:[DrawSoundManager defaultManager].guessCorrectSound];
    
    self.guessWords = [NSMutableArray array];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidUnload {
    
    [self setWordInputView:nil];
    [self setTitleLabel:nil];
    [super viewDidUnload];
}


- (void)initPickToolView
{
    NSMutableArray *array = [NSMutableArray array];
    ToolView *tips = [ToolView tipsViewWithNumber:0];
    //    tips.tag = TOOLVIEW_TAG_TIPS;
    ToolView *flower = [ToolView flowerViewWithNumber:0];
    //    flower.tag = TOOLVIEW_TAG_FLOWER;
    [array addObject:tips];
    [array addObject:flower];
    _pickToolView = [[PickToolView alloc] initWithTools:array];
    _pickToolView.hidden = YES;
    _pickToolView.delegate = self;
    [self.view addSubview:_pickToolView];
}


- (IBAction)clickBack:(id)sender{
    
    [[OpusService defaultService] submitGuessWords:_guessWords
                                              opus:_opus
                                         isCorrect:NO
                                             score:3
                                          delegate:nil];
    
    [_guessWords removeAllObjects];
    
    [super clickBack:sender];
}

- (IBAction)clickToolBoxButton:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    float originY = button.frame.origin.y - _pickToolView.frame.size.height;
    
    [_pickToolView updateOriginY:originY];

    [self.view bringSubviewToFront:_pickToolView];
    [_pickToolView setHidden:!_pickToolView.hidden animated:YES];
}

- (void)wordInputView:(WordInputView *)wordInputView
           didGetWord:(NSString *)word
            isCorrect:(BOOL)isCorrect{

    [_guessWords addObject:word];
    
    if (isCorrect) {
        
        [[OpusService defaultService] submitGuessWords:_guessWords
                                                  opus:_opus
                                             isCorrect:YES
                                                 score:3
                                              delegate:nil];
        [_guessWords removeAllObjects];
        
        [self didGuessCorrect:word];
    }else{
        [self didGuessWrong:word];
    }
}

- (void)didGuessCorrect:(NSString *)word{
    
    [OpusGuessRecorder setOpusAsGuessed:_opus.pbOpus.opusId];
    [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kGuessCorrect") delayTime:1 isHappy:YES];
}

- (void)didGuessWrong:(NSString *)word{
    [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kGuessWrong") delayTime:1 isHappy:NO];
}

- (void)didPickedPickView:(PickView *)pickView toolView:(ToolView *)toolView{
    
    int limitTimes = [ConfigManager numberOfItemCanUsedOnNormalOpus];
    int itemTimes = [ItemUseRecorder itemTimes:toolView.itemType onOpus:_opus.pbOpus.opusId];
    if (itemTimes >= limitTimes) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:[NSString stringWithFormat:NSLS(@"kCanotSendItemToOpus"), limitTimes] delayTime:1.5 isHappy:YES];
            return;
        }
    
    if (toolView.itemType == ItemTypeTips) {
        [self bomb:toolView];
    }else if(toolView.itemType == ItemTypeFlower)
    {
        [self throwFlower:toolView];
    }
}

- (void)bomb:(ToolView *)toolView
{
    int price = [[GameItemManager defaultManager] priceWithItemId:ItemTypeTips];

    __block typeof (self) bself = self;
    [[UserGameItemService defaultService] consumeItem:toolView.itemType count:1 forceBuy:YES handler:^(int resultCode, int itemId, BOOL isBuy) {
        if (resultCode == ERROR_SUCCESS) {
            [_wordInputView bombHalf];
            toolView.enabled = NO;
            if (isBuy) {
                [[CommonMessageCenter defaultCenter] postMessageWithText:[NSString stringWithFormat:NSLS(@"kBuyABagAndUse"), price] delayTime:2];
            }
        }else if (ERROR_BALANCE_NOT_ENOUGH){
            [BalanceNotEnoughAlertView showInController:bself];
        }else{
            
        }
    }];
}


- (void)throwFlower:(ToolView *)toolView
{
    // send request for item usage and award
    __block typeof (self) bself = self;
    NSString *opusId = _opus.pbOpus.opusId;
    NSString *authorId = _opus.pbOpus.author.userId;
    [[FlowerItem sharedFlowerItem] useItem:authorId isOffline:YES feedOpusId:opusId feedAuthor:authorId forFree:NO resultHandler:^(int resultCode, int itemId, BOOL isBuy) {
        if (resultCode == ERROR_SUCCESS) {
            [self showAnimationThrowTool:toolView isBuy:isBuy];
            [ItemUseRecorder increaseItemTimes:ItemTypeFlower onOpus:opusId];
        }else if (resultCode == ERROR_BALANCE_NOT_ENOUGH){
            [BalanceNotEnoughAlertView showInController:bself];
        }else if (resultCode == ERROR_NETWORK){
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kSystemFailure") delayTime:2 isHappy:NO];
        }
    }];
}

#define ITEM_FRAME  ([DeviceDetection isIPAD]?CGRectMake(0, 0, 122, 122):CGRectMake(0, 0, 61, 61))
- (void)showAnimationThrowTool:(ToolView*)toolView isBuy:(BOOL)isBuy
{
    UIImageView* throwItem = [[[UIImageView alloc] initWithFrame:ITEM_FRAME] autorelease];
    throwItem.center = self.view.center;
    [self.view addSubview:throwItem];
    [throwItem setImage:[toolView backgroundImageForState:UIControlStateNormal]];
    if (toolView.itemType == ItemTypeTomato) {
        [DrawGameAnimationManager showThrowTomato:throwItem animInController:self rolling:NO itemEnough:!isBuy shouldShowTips:YES completion:^(BOOL finished) {
            
        }];
    }
    if (toolView.itemType == ItemTypeFlower) {
        [DrawGameAnimationManager showThrowFlower:throwItem animInController:self rolling:NO itemEnough:!isBuy shouldShowTips:YES completion:^(BOOL finished) {
            
        }];
    }
}

@end
