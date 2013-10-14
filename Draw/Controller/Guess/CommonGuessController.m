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
#import "OpusService.h"
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
#import "UIButtonExt.h"
#import "HPThemeManager.h"
#import "CustomInfoView.h"
#import "TimeUtils.h"
#import "ShareImageManager.h"
#import "GuessManager.h"
#import "UIImageView+ProgressView.h"
#import "WordManager.h"
#import "OrangeLoadingView.h"

@interface CommonGuessController (){
    PBUserGuessMode _mode;
}

@property (retain, nonatomic) PickToolView *pickToolView;
@property (retain, nonatomic) NSDate *startDate;
@property (retain, nonatomic) PBGuessContest *contest;

@end

@implementation CommonGuessController

- (void)dealloc {
    
    [_startDate release];
    [_guessWords release];
    [_wordInputView release];
    [_opus release];
    [_pickToolView release];
    [_opusButton release];
    [_toolBoxButton release];
    [_contest release];
    [_tipButton release];
    [_opusImageView release];
    [super dealloc];
}

- (id)initWithOpus:(Opus *)opus mode:(PBUserGuessMode)mode contest:(PBGuessContest *)contest{

    if (self = [super init]) {
        
        self.opus = opus;
        _mode = mode;
        self.contest = contest;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // Set candidates, move before viewDidLoad to make load image quicker
    NSString *candidates = [[WordManager defaultManager] randChineseCandidateStringWithWord:self.opus.pbOpus.name count:27];
        
    // Init guess words
    self.guessWords = [NSMutableArray array];
    
    // Init item box
    [self initItemBox];
    
    if (_mode == PBUserGuessModeGuessModeContest){
        [_toolBoxButton removeFromSuperview];
    }
    
    // Set opus image
    [self.opusButton setBackgroundColor:[UIColor clearColor]];
    self.opusImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    // Set bgView
    SET_VIEW_BG(self.view);
    
    // Set answer
    self.wordInputView.answer = self.opus.pbOpus.name;
    self.wordInputView.delegate = self;    
    
    [self.toolBoxButton setBackgroundImage:UIThemeImageNamed(@"item_box@2x.png") forState:UIControlStateNormal];

    [self setCanDragBack:NO];
    
    PPDebug(@"start loading image %@ for guess", self.opus.pbOpus.image);    
    NSURL *url = [NSURL URLWithString:self.opus.pbOpus.image];
//    [self showActivityWithText:NSLS(@"kLoadImage") center:self.opusImageView.center];
//    UIProgressView *progress = [[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault] autorelease];
    
    OrangeLoadingView *progress = [OrangeLoadingView orageLoadingView];
    progress.center = self.opusImageView.center;
    [self.opusImageView addSubview:progress];
    
    
    [self.opusImageView setImageWithURL:url placeholderImage:[[ShareImageManager defaultManager] unloadBg] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        [self hideActivity];
        [progress removeFromSuperview];
        
        if (error == nil) {
            self.startDate = [NSDate date];
            [self.wordInputView setCandidates:candidates column:9];
        }
    } usingProgressView:progress];

    
    if (_mode == PBUserGuessModeGuessModeGenius) {
        self.tipButton.enabled = [GuessManager getTipUseTimes] < [ConfigManager getTipUseTimesLimitInGeniusMode];
    }
    
}


- (void)viewDidUnload {
    
    [self setWordInputView:nil];
    [self setOpusButton:nil];
    [self setToolBoxButton:nil];
    [self setTipButton:nil];
    [super viewDidUnload];
}

- (void)initItemBox
{
    NSMutableArray *array = [NSMutableArray array];
    ToolView *tips = [ToolView tipsViewWithNumber:0];
    ToolView *flower = [ToolView flowerViewWithNumber:0];
    [array addObject:tips];
    [array addObject:flower];
    _pickToolView = [[PickToolView alloc] initWithTools:array];
    _pickToolView.hidden = YES;
    _pickToolView.delegate = self;
    [self.view addSubview:_pickToolView];
}

- (void)submitWords:(BOOL)correct{
    

    [[GuessService defaultService] guessOpus:self.opus.pbOpus
                                        mode:_mode
                                   contestId:_contest.contestId
                                       words:self.guessWords
                                     correct:correct
                                   startDate:_startDate
                                     endDate:[NSDate date]
                                    delegate:self];
    
    [_guessWords removeAllObjects];
}


- (IBAction)clickBack:(id)sender{
    
    [self submitWords:NO];
    [super clickBack:sender];
}

- (IBAction)clickToolBoxButton:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    float originY = button.frame.origin.y - _pickToolView.frame.size.height;
    
    [_pickToolView updateOriginY:originY];

    [self.view bringSubviewToFront:_pickToolView];
    [_pickToolView setHidden:!_pickToolView.hidden animated:YES];
}

- (IBAction)clickTipButton:(id)sender
{
    [self bomb:sender];
}



- (IBAction)clickOpusButton:(id)sender {
    
    PPDebug(@"Implement this method <%s> in your sub-class", __FUNCTION__);
}

- (void)wordInputView:(WordInputView *)wordInputView
           didGetWord:(NSString *)word
            isCorrect:(BOOL)isCorrect{
    
    int time = [[NSDate date] timeIntervalSince1970];
    if (_mode == PBUserGuessModeGuessModeContest && time > _contest.endTime) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kContestIsOver") delayTime:1.5 isHappy:NO];
        return;
    }

    [_guessWords addObject:word];
    
    if (isCorrect) {

        [self didGuessCorrect:word];
    }else{
        [self didGuessWrong:word];
    }
}

- (void)didGuessCorrect:(NSString *)word{
    
    [self submitWords:YES];
    
    if (_mode == PBUserGuessModeGuessModeGenius) {
        [GuessManager clearTipUseTimes];
    }

    [OpusGuessRecorder setOpusAsGuessed:_opus.pbOpus.opusId];
    
    if ([_delegate respondsToSelector:@selector(didGuessCorrect:index:)]) {
        [_delegate didGuessCorrect:self.opus index:self.index];
    }

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didGuessWrong:(NSString *)word{
    
    [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"尼玛，猜错了！") delayTime:1.5 isHappy:NO];

    
    if (_mode == PBUserGuessModeGuessModeGenius) {
        
        if ([_delegate respondsToSelector:@selector(didGuessWrong:index:)]) {
            [_delegate didGuessWrong:self.opus index:self.index];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
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

- (void)bomb:(UIButton *)toolView
{
    toolView.enabled = NO;
    int price = [[GameItemManager defaultManager] priceWithItemId:ItemTypeTips];

    __block typeof (self) bself = self;
    [[UserGameItemService defaultService] consumeItem:ItemTypeTips count:1 forceBuy:YES handler:^(int resultCode, int itemId, BOOL isBuy) {
        if (resultCode == ERROR_SUCCESS) {
            
            [_wordInputView bombHalf];
            
            if (_mode == PBUserGuessModeGuessModeGenius) {
                [GuessManager incTipUseTimes];
            }
            int leftTipTimes = [ConfigManager getTipUseTimesLimitInGeniusMode] - [GuessManager getTipUseTimes];
            
            if (isBuy) {
                
                if (_mode == PBUserGuessModeGuessModeGenius) {
                    
                    NSString *message = leftTipTimes <= 0 ?
                    [NSString stringWithFormat:NSLS(@"kBuyABagAndUseAndNoLeftTips"), price]
                    :[NSString stringWithFormat:NSLS(@"kBuyABagAndUseAndLeftTipsTimes"), price, leftTipTimes];
                    
                    [[CommonMessageCenter defaultCenter] postMessageWithText:message delayTime:2];
                }else{
                    [[CommonMessageCenter defaultCenter] postMessageWithText:[NSString stringWithFormat:NSLS(@"kBuyABagAndUse"), price] delayTime:2];
                }

            }else{
                
                if (_mode == PBUserGuessModeGuessModeGenius) {
                    
                    NSString *message = leftTipTimes <= 0 ?
                    [NSString stringWithFormat:NSLS(@"kNoLeftTips")]
                    :[NSString stringWithFormat:NSLS(@"kLeftTipsTimes"), leftTipTimes];
                    
                    [[CommonMessageCenter defaultCenter] postMessageWithText:message delayTime:2];
                }
            }

        }else if (resultCode == ERROR_BALANCE_NOT_ENOUGH){
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
    [[FlowerItem sharedFlowerItem] useItem:authorId isOffline:YES opus:_opus forFree:NO resultHandler:^(int resultCode, int itemId, BOOL isBuy) {
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
