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
#import "CommonBgView.h"
#import "UIButtonExt.h"
#import "HPThemeManager.h"
#import "CustomInfoView.h"
#import "TimeUtils.h"

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
    [_bgImageView release];
    [_toolBoxButton release];
    [_contest release];
    [super dealloc];
}

- (id)initWithOpus:(Opus *)opus mode:(PBUserGuessMode)mode contest:(PBGuessContest *)contest{

    if (self = [super init]) {
        
        self.opus = opus;
        _mode = mode;
        self.contest = contest;
        self.startDate = [NSDate date];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Init guess words
    self.guessWords = [NSMutableArray array];
    
    // Init item box
    [self initItemBox];
    
    if (_mode == PBUserGuessModeGuessModeContest){
        [_toolBoxButton removeFromSuperview];
    }
    
    // Set opus image
    self.opusButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.opusButton.backgroundColor = [UIColor clearColor];
    NSURL *url = [NSURL URLWithString:self.opus.pbOpus.image];
    NSURL *thumbUrl = [NSURL URLWithString:self.opus.pbOpus.thumbImage];
    [self.opusButton setImageUrl:url thumbImageUrl:thumbUrl placeholderImage:nil];
    
    // Set bgView
    UIView *bgView = [CommonBgView create];
    [self.view addSubview:bgView];
    [self.view sendSubviewToBack:bgView];
    
    // Set answer
    self.wordInputView.answer = self.opus.pbOpus.name;
    self.wordInputView.delegate = self;
    self.wordInputView.answerColor = [UIColor whiteColor];
    
    
    [self.toolBoxButton setImage:UIThemeImageNamed(@"item_box@2x.png") forState:UIControlStateNormal];
}


- (void)viewDidUnload {
    
    [self setWordInputView:nil];
    [self setOpusButton:nil];
    [self setBgImageView:nil];
    [self setToolBoxButton:nil];
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

    [OpusGuessRecorder setOpusAsGuessed:_opus.pbOpus.opusId];
    
    if ([_delegate respondsToSelector:@selector(didGuessCorrect)]) {
        [_delegate didGuessCorrect];
    }

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didGuessWrong:(NSString *)word{
    
    [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kGuessWrong") delayTime:1.5 isHappy:NO];

    if (_mode == PBUserGuessModeGuessModeGenius) {
        
        if ([_delegate respondsToSelector:@selector(didGuessWrong)]) {
            [_delegate didGuessWrong];
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
