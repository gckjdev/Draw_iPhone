//
//  ShowDrawController.m
//  Draw
//
//  Created by  on 12-3-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "OnlineGuessDrawController.h"
#import "ShowDrawView.h"
#import "Paint.h"
#import "GameSessionUser.h"
#import "GameSession.h"
#import "Word.h"
#import "WordManager.h"
#import "LocaleUtils.h"
#import "AnimationManager.h"
#import "GameTurn.h"
#import "ResultController.h"
#import "HJManagedImageV.h"
#import "PPApplication.h"
#import "HomeController.h"
#import "DrawAction.h"
#import "StableView.h"
#import "ShareImageManager.h"
#import "RoomController.h"
#import "GameMessage.pb.h"
#import "PPDebug.h"
#import "ItemManager.h"
#import "AccountService.h"
#import "ItemShopController.h"
#import "DrawConstants.h"
#import "AudioManager.h"
#import "ConfigManager.h"
#import "CommonMessageCenter.h"
#import "GameConstants.h"
#import "AccountManager.h"
#import "ItemService.h"
#import "VendingController.h"
#import "UseItemScene.h"
#import "DrawSoundManager.h"
#import "AccountService.h"
#import "Item.h"

#define PAPER_VIEW_TAG 20120403
#define TOOLVIEW_CENTER (([DeviceDetection isIPAD]) ? CGPointMake(695, 920):CGPointMake(284, 424))
#define MOVE_BUTTON_FONT_SIZE (([DeviceDetection isIPAD]) ? 36.0 : 18.0)

#define MAX_TOMATO_CAN_THROW 3
#define MAX_FLOWER_CAN_SEND 10

#define TOOLVIEW_TAG_TIPS   120120730
#define TOOLVIEW_TAG_FLOWER 220120730
#define TOOLVIEW_TAG_TOMATO 320120730


@implementation OnlineGuessDrawController
@synthesize showView;
@synthesize candidateString = _candidateString;
@synthesize drawBackground;
- (void)dealloc
{
    moveButton = nil;
    _shopController = nil;
    lastScaleTarget = nil;
    [showView stop];
    PPRelease(_candidateString);
    PPRelease(showView);
    PPRelease(drawBackground);
    PPRelease(_pickToolView);
    PPRelease(_scene);
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


#pragma mark - init the buttons

#define TARGET_BASE_TAG 11
#define TARGET_END_TAG 17
#define CANDIDATE_BASE_TAG 21
#define CANDIDATE_END_TAG 39

#define RowNumber 2
#define WORD_BASE_X (([DeviceDetection isIPAD])? 26 : 5)
//#define WORD_BASE_Y_1 (([DeviceDetection isIPAD])? 855 : 390)
//#define WORD_BASE_Y_2 (([DeviceDetection isIPAD])? 930 : 425)
#define WORD_BASE_Y_1 (([DeviceDetection isIPAD])? 855 : ([DeviceDetection screenSize].height - 90))
#define WORD_BASE_Y_2 (([DeviceDetection isIPAD])? 930 : ([DeviceDetection screenSize].height - 55))

#define WORD_SPACE_X (([DeviceDetection isIPAD])? 22 : 4)


#define WORD_FONT (([DeviceDetection isIPAD])? [UIFont systemFontOfSize:18 * 2]: [UIFont systemFontOfSize:18])

#define WORD_BUTTON_WIDTH (([DeviceDetection isIPAD])? 30 * 2: 30)
#define WORD_BUTTON_HEIGHT (([DeviceDetection isIPAD])? 30 * 2: 30)

#define ZOOM_SCALE 1.2



- (void)resetWordButtons:(NSInteger)count
{
    int tag = CANDIDATE_BASE_TAG;
    
    CGFloat x,y;
    for (int i = 0; i < count; ++ i) {
        UIButton *button = (UIButton *)[self.view viewWithTag:tag ++];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setBackgroundImage:[shareImageManager woodImage]
                          forState:UIControlStateNormal];
        [button.titleLabel setFont:WORD_FONT];                
        NSInteger rowCount = count / RowNumber;
        NSInteger row = i / rowCount;
        NSInteger num = i % rowCount;
        
        x = WORD_BASE_X + (WORD_BUTTON_WIDTH + WORD_SPACE_X) * num; 
        y = (row == 0) ? WORD_BASE_Y_1 : WORD_BASE_Y_2;
        
        button.frame = CGRectMake(x, y, WORD_BUTTON_WIDTH, WORD_BUTTON_HEIGHT);
 
        button.hidden = NO;
        button.enabled = NO;
    }
    
    for (; tag <= CANDIDATE_END_TAG; ++ tag) {
        UIButton *button = (UIButton *)[self.view viewWithTag:tag];
        [button setTitle:nil forState:UIControlStateNormal];
        button.hidden = YES;
    }
}

- (UIButton *)targetButton:(CGPoint)point
{
    
    for (int tag = TARGET_BASE_TAG; tag <= TARGET_END_TAG; ++ tag) {
        UIButton *button = (UIButton *)[self.view viewWithTag:tag];
        //can write
        if (button.hidden == NO && [[button titleForState:UIControlStateNormal] length] == 0) {
            //distance
            if ([DrawUtils distanceBetweenPoint:point point2:button.center] < button.frame.size.width) {
                return button;
            }
        }
    }
    return nil;
}


- (UIButton *)candidateButtonForText:(NSString *)text
{
    for (int i = 0; i < [self.candidateString length]; ++ i) {
        NSString *sub = [self.candidateString substringWithRange:NSMakeRange(i, 1)];
        if ([sub isEqualToString:text]) {
            UIButton *button = (UIButton *)[self.view viewWithTag:CANDIDATE_BASE_TAG + i];
            if ([[button titleForState:UIControlStateNormal] length] == 0) {
                return button;
            }
        }
    }
    return nil;
}

- (void)clickWriteButton:(UIButton *)button
{
    NSString *text = [self realValueForButton:button];
    if ([text length] != 0) {
        UIButton *pButton = [self candidateButtonForText:text];
        if (pButton) {
            [self setButton:pButton title:text enabled:YES];
            [self setButton:button title:nil enabled:NO];
        }
        
    }
}


- (NSString *)getAnswer
{
    //get the word
    NSString *answer = @"";
    NSInteger endIndex = TARGET_END_TAG;
    for (int i = TARGET_BASE_TAG; i <= endIndex; ++ i) {
        UIButton *button = (UIButton *)[self.view viewWithTag:i];
        NSString *text = [self realValueForButton:button];
        if ([text length] == 1 && ![text isEqualToString:@" "]) {
            answer = [NSString stringWithFormat:@"%@%@",answer,text];
        }
    }
    return answer;
}

- (UIButton *)getTheFirstEmptyButton
{
    NSInteger endIndex = TARGET_END_TAG;//(languageType == ChineseType) ? (TARGET_END_TAG - 1) : TARGET_END_TAG;
    for (int i = TARGET_BASE_TAG; i <= endIndex; ++ i) {
        UIButton *button = (UIButton *)[self.view viewWithTag:i];
        if (button.hidden == NO && [[button titleForState:UIControlStateNormal] length] == 0) {
            return button;
        }
    }
    return nil;
}

- (void)clickPickingButton:(UIButton *)button target:(UIButton *)target text:(NSString *)text
{
    [[AudioManager defaultManager] playSoundByName:[DrawSoundManager defaultManager].clickWordSound];
    if ([text length] != 0) {
        if (target) {
            [self setButton:target title:text enabled:YES];
            [self setButton:button title:nil enabled:NO];
            
            NSString *ans = [self getAnswer];
            if ([ans length] == [self.word.text length]) {
                [self commitAnswer:ans];
            } 
        }
    }
}

- (void) dragBegan: (UIControl *) c withEvent:ev
{
    
    UIButton *bt = (UIButton *)c;
    NSString *title = [self realValueForButton:bt];
    moveButton.hidden = NO;
    [self setButton:moveButton title:title enabled:YES];
    [self setButton:bt title:nil enabled:NO];
    moveButton.center = [[[ev allTouches] anyObject] locationInView:self.view];
    
}
- (void) dragMoving: (UIControl *) c withEvent:ev
{
    moveButton.center = [[[ev allTouches] anyObject] locationInView:self.view];
    UIButton *targetButton = [self targetButton:moveButton.center];
    if (targetButton != lastScaleTarget) {
        //scale
        lastScaleTarget.layer.transform = CATransform3DMakeScale(1, 1, 1);
        targetButton.layer.transform = CATransform3DMakeScale(ZOOM_SCALE, ZOOM_SCALE, 1);
        lastScaleTarget = targetButton;
    }
}
- (void) dragEnded: (UIControl *) c withEvent:ev
{
    moveButton.center = [[[ev allTouches] anyObject] locationInView:self.view];
    CGPoint touchPoint = [[[ev allTouches] anyObject] locationInView:self.view]; 
    NSString *title = [self realValueForButton:moveButton];
    UIButton *targetButton = [self targetButton:moveButton.center];
    UIButton *bt = (UIButton *)c;    
    
    lastScaleTarget.layer.transform = CATransform3DMakeScale(1, 1, 1);
    lastScaleTarget = nil;
    
    
    if (targetButton != nil) {
        [self clickPickingButton:bt target:targetButton text:title];
    }else{ 
        NSInteger distance = [DrawUtils distanceBetweenPoint:touchPoint point2:c.center];
        if(distance < c.frame.size.width / 2 && 
           (targetButton = [self getTheFirstEmptyButton]) != nil)
        {
            [self clickPickingButton:bt target:targetButton text:title];            
        }else{
            [self setButton:bt title:title enabled:YES];
        }
    }
    [self setButton:moveButton title:nil enabled:NO];
    moveButton.hidden = YES;
}

- (void)addDragActions:(UIButton *)button
{
    [button addTarget:self action:@selector(dragBegan:withEvent: )
     forControlEvents: UIControlEventTouchDown];
    [button addTarget:self action:@selector(dragMoving:withEvent: )
     forControlEvents: UIControlEventTouchDragInside];
    [button addTarget:self action:@selector(dragMoving:withEvent: )
     forControlEvents: UIControlEventTouchDragOutside];
    
    [button addTarget:self action:@selector(dragEnded:withEvent: )
     forControlEvents: UIControlEventTouchUpInside | 
     UIControlEventTouchUpOutside];
    [button addTarget:self action:@selector(dragEnded:withEvent:) forControlEvents:UIControlEventTouchCancel];
    
}

- (void)initMoveButton
{
    moveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [moveButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [moveButton setBackgroundImage:[UIImage imageNamed:@"wood_button.png"] forState:UIControlStateNormal];
    moveButton.hidden = YES;
    [moveButton.titleLabel setFont:[UIFont systemFontOfSize:MOVE_BUTTON_FONT_SIZE]];
    moveButton.frame = CGRectMake(0, 0, WORD_BUTTON_WIDTH, WORD_BUTTON_HEIGHT);
    moveButton.layer.transform = CATransform3DMakeScale(ZOOM_SCALE, ZOOM_SCALE, 1);
    [self.view addSubview:moveButton];
}

- (void)initCandidateButton:(UIButton *)button
{
    
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setBackgroundImage:[shareImageManager woodImage]
                      forState:UIControlStateNormal];
    button.enabled = NO;
    button.frame = CGRectMake(0, 0, WORD_BUTTON_WIDTH, WORD_BUTTON_HEIGHT);
    [self addDragActions:button];
    
}
- (void)initWordViews
{
    
    for (int i = CANDIDATE_BASE_TAG; i <= CANDIDATE_END_TAG; ++ i) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.autoresizingMask = !UIViewAutoresizingFlexibleBottomMargin |UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;

        
        [button setTag:i];
        [self initCandidateButton:button];

        [self.view addSubview:button];
    }
    [self resetWordButtons:CANDIDATE_WORD_NUMBER];
    [self initMoveButton];
}

- (void)initPickToolView
{
    NSMutableArray *array = [NSMutableArray array];
    ItemManager *itemManager = [ItemManager defaultManager];
    ToolView *tips = [ToolView tipsViewWithNumber:[itemManager amountForItem:ItemTypeTips]];
    tips.tag = TOOLVIEW_TAG_TIPS;
    ToolView *flower = [ToolView flowerViewWithNumber:[itemManager amountForItem:ItemTypeFlower]];
    flower.tag = TOOLVIEW_TAG_FLOWER;
    ToolView *tomato = [ToolView tomatoViewWithNumber:[itemManager amountForItem:ItemTypeTomato]];
    tomato.tag = TOOLVIEW_TAG_TOMATO;
    [array addObject:tips];
    [array addObject:flower];
    [array addObject:tomato];
    _pickToolView = [[PickToolView alloc] initWithTools:array];
    _pickToolView.hidden = YES;
    _pickToolView.delegate = self;
    [self.view addSubview:_pickToolView];
}


#pragma mark - Word && Word Views


- (void)updateCandidateViewsWithText:(NSString *)text
{
    self.candidateString = text;
    NSInteger tag = CANDIDATE_BASE_TAG;
    
    for (int i = 0; i < text.length; ++ i) {
        UIButton *button = (UIButton *)[self.view viewWithTag:tag ++];
        NSString *title = [self.candidateString substringWithRange:NSMakeRange(i, 1)];
        if ([title isEqualToString:@" "]) {
            [self setButton:button title:nil enabled:NO];
        }else{
            [self setButton:button title:title enabled:YES];
        }
    }
    for (; tag <= CANDIDATE_END_TAG; ++ tag) {
        UIButton *button = (UIButton *)[self.view viewWithTag:tag];
        [self setButton:button title:nil enabled:NO];
        button.hidden = YES;
    }
}
- (void)updateCandidateViews:(Word *)word lang:(LanguageType)lang
{
    self.word = word;
    languageType = lang;
    if (lang == EnglishType) {
        NSString *upperString = [WordManager upperText:word.text];
        self.word.text = upperString;        
    }
    NSString *text = nil;
    if (languageType == ChineseType) {
        text = [[WordManager defaultManager] randChinesStringWithWord:
                self.word count:CANDIDATE_WORD_NUMBER];
    }else{
        text = [[WordManager defaultManager] randEnglishStringWithWord:
                self.word count:CANDIDATE_WORD_NUMBER];        
    }
    [self resetWordButtons:CANDIDATE_WORD_NUMBER];
    [self updateCandidateViewsWithText:text];
}



- (void)setWordButtonsEnabled:(BOOL)enabled
{
    for (int i = TARGET_BASE_TAG; i <= TARGET_END_TAG; ++ i) {
        UIButton *button = (UIButton *)[self.view viewWithTag:i];
        [button setEnabled:enabled];
    }
    
    for (int i = CANDIDATE_BASE_TAG; i <= CANDIDATE_END_TAG; ++ i) {
        UIButton *button = (UIButton *)[self.view viewWithTag:i];
        [button setEnabled:enabled];
    }
    //    [toolView setEnabled:enabled];
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






#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [drawGameService setShowDelegate:self];
    
    [self initShowView];
    
    [self initWordViews];
    [self initTargetViews];
    [self initWithCachData];
    [self initPickToolView];
    _guessCorrect = NO;
    _shopController = nil;
    
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}



- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _shopController = nil;
}

- (void)viewDidUnload
{
    [self setClockButton:nil];
    [self setPopupButton:nil];
    [self setTurnNumberButton:nil];
    [self setShowView:nil];
    [self setDrawBackground:nil];
    [super viewDidUnload];
    [self setWord:nil];
}


#pragma mark - Draw Game Service Delegate

- (void)didReceiveDrawWord:(NSString*)wordText level:(int)wordLevel language:(int)language
{
    if (wordText) {
        PPDebug(@"<ShowDrawController> ReceiveWord:%@", wordText);
        Word *word = [Word wordWithText:wordText level:wordLevel];
        [self updateTargetViews:word];
        [self updateCandidateViews:word lang:language];
    }else{
        PPDebug(@"warn:<ShowDrawController> word is nil");
    }
}

- (void)didReceiveDrawData:(GameMessage *)message
{
    Paint *paint = [[Paint alloc] initWithGameMessage:message];
    DrawAction *action = [DrawAction actionWithType:DRAW_ACTION_TYPE_DRAW paint:paint];
    [showView addDrawAction:action play:YES];
    [paint release];
}

- (void)didReceiveRedrawResponse:(GameMessage *)message
{
    DrawAction *action = [DrawAction actionWithType:DRAW_ACTION_TYPE_CLEAN paint:nil];
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
        [self popupUnhappyMessage:NSLS(@"kAllUserQuit") title:nil];
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
    if (_shopController) {
        [_shopController.topNavigationController popToViewController:self animated:NO];
        [self.navigationController pushViewController:rc animated:NO];
    }else{
        [self.navigationController pushViewController:rc animated:YES];
    }
    [rc release]; 
//    [showView stop];
}

- (void)didReceiveRank:(NSNumber*)rank fromUserId:(NSString*)userId
{
    if (rank.integerValue == RANK_TOMATO) {
        PPDebug(@"%@ give you an tomato", userId);
        //[self popupMessage:[NSString stringWithFormat:NSLS(@"kSendFlowerMessage"),REWARD_EXP, REWARD_COINS] title:nil];
    }else{
        PPDebug(@"%@ give you a flower", userId);
        //[self popupMessage:[NSString stringWithFormat:NSLS(@"kSendFlowerMessage"),REWARD_EXP, REWARD_COINS] title:nil];
    }
    
}

#pragma mark - Common Dialog Delegate
#define SHOP_DIALOG_TAG 20120406
#define ITEM_TAG_OFFSET 20120728


- (void)clickOk:(CommonDialog *)dialog
{
    //run away
    switch (dialog.tag) {
        case (ItemTypeTomato + ITEM_TAG_OFFSET): {
            [CommonItemInfoView showItem:[Item tomato] infoInView:self];
        } break;
        case (ItemTypeFlower + ITEM_TAG_OFFSET): {
            [CommonItemInfoView showItem:[Item flower] infoInView:self];
        } break;
        case (ItemTypeTips + ITEM_TAG_OFFSET): {
            [CommonItemInfoView showItem:[Item tips] infoInView:self];
        } break;
        default:
            [drawGameService quitGame];
            [HomeController returnRoom:self];
            [self.showView stop];
            [self cleanData];
            [[LevelService defaultService] minusExp:NORMAL_EXP delegate:self];
            break;
    }

}
- (void)clickBack:(CommonDialog *)dialog
{
    
}

#pragma mark - Actions

- (void)commitAnswer:(NSString *)answer
{
    //alter if the word is correct
    if ([answer isEqualToString:self.word.text]) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kGuessCorrect") delayTime:1 isHappy:YES];
        [[AudioManager defaultManager] playSoundByName:[DrawSoundManager defaultManager].guessCorrectSound];
        _guessCorrect = YES;
        [self setWordButtonsEnabled:NO];
    }else{
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kGuessWrong") delayTime:1 isHappy:NO];
        [[AudioManager defaultManager] playSoundByName:[DrawSoundManager defaultManager].guessWrongSound];
    }
    [drawGameService guess:answer guessUserId:drawGameService.session.userId];
}

- (BOOL)bomb:(ToolView *)toolView isItemEnough:(BOOL)itemEnough
{
    if ([self.candidateString length] == 0) {
        return NO;
    }
    [self updateTargetViews:self.word];
    NSString *result  = [WordManager bombCandidateString:self.candidateString word:self.word];
    [self updateCandidateViewsWithText:result];
    [toolView setEnabled:NO];
    
    if (!itemEnough) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:[NSString stringWithFormat:NSLS(@"kBuyABagAndUse"), [Item tips].price/[Item tips].buyAmountForOnce] delayTime:2];
    }
    
    return YES;
}

 
- (BOOL)throwFlower:(ToolView *)toolView isItemEnough:(BOOL)itemEnough
{
//    [[DrawGameService defaultService] rankGameResult:RANK_FLOWER];
    [self showAnimationThrowTool:toolView isItemEnough:itemEnough];
    [_scene throwAFlower];
    // send request for item usage and award
    [[ItemService defaultService] sendItemAward:toolView.itemType 
                                   targetUserId:[[[drawGameService session] currentTurn] currentPlayUserId]
                                      isOffline:NO
                                     feedOpusId:nil
                                     feedAuthor:nil];
    
    //[self popupMessage:[NSString stringWithFormat:NSLS(@"kSendFlowerMessage"),REWARD_EXP, REWARD_COINS] title:nil];
    [toolView decreaseNumber];
    
    if (![_scene canThrowFlower]) {
        [toolView setEnabled:NO];
    }
    return NO;
}

- (BOOL)throwTomato:(ToolView *)toolView isItemEnough:(BOOL)itemEnough
{
//    [[DrawGameService defaultService] rankGameResult:RANK_TOMATO];

    [toolView decreaseNumber];
    [self showAnimationThrowTool:toolView isItemEnough:itemEnough];
    [_scene throwATomato];
    // send request for item usage and award
    [[ItemService defaultService] sendItemAward:toolView.itemType 
                                   targetUserId:[[[drawGameService session] currentTurn] currentPlayUserId]
                                      isOffline:NO
                                     feedOpusId:nil
                                     feedAuthor:nil];

    
    //[self popupMessage:[NSString stringWithFormat:NSLS(@"kThrowTomatoMessage"),REWARD_EXP, REWARD_COINS] title:nil];
    if (![_scene canThrowTomato]) {
        [toolView setEnabled:NO];
    }
    return NO;
}
#pragma mark - click tool delegate
- (void)didPickedPickView:(PickView *)pickView toolView:(ToolView *)toolView
{
    NSInteger amout = [[ItemManager defaultManager] amountForItem:toolView.itemType];
    BOOL itemEnough = YES;
    if(amout <= 0){
//        CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kNoItemTitle") message:NSLS(@"kNoItemMessage") style:CommonDialogStyleDoubleButton delegate:self];
//        dialog.tag = ITEM_TAG_OFFSET + toolView.itemType;
//        [dialog showInView:self.view];
//        return;
        Item* item = [Item itemWithType:toolView.itemType amount:1];
        int result = [[AccountService defaultService] buyItem:toolView.itemType itemCount:1 itemCoins:(item.price/item.buyAmountForOnce)];
        itemEnough = NO;
        if (result == ERROR_COINS_NOT_ENOUGH) {
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kNotEnoughCoinOrItem") delayTime:1];
            return;
        }
    }
    BOOL flag = NO;
    if (toolView.itemType == ItemTypeTips) {
        flag = [self bomb:toolView isItemEnough:itemEnough];
    }else if(toolView.itemType == ItemTypeFlower)
    {
        flag = [self throwFlower:toolView isItemEnough:itemEnough];
    }else if(toolView.itemType == ItemTypeTomato)
    {
        flag = [self throwTomato:toolView isItemEnough:itemEnough];
    }
    if (flag) {
        [[AccountService defaultService] consumeItem:ItemTypeTips 
                                              amount:toolView.itemType];        
        [toolView decreaseNumber];
    }
    
}
- (IBAction)clickToolBox:(id)sender {
    [self.view bringSubviewToFront:_pickToolView];
    [_pickToolView setHidden:!_pickToolView.hidden animated:YES];
}

- (IBAction)clickRunAway:(id)sender {
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kQuitGameAlertTitle") message:NSLS(@"kQuitGameAlertMessage") style:CommonDialogStyleDoubleButton delegate:self];
    [dialog showInView:self.view];
}




- (void)initTargetViews
{
    NSInteger tag = TARGET_BASE_TAG;
    for (int i = TARGET_BASE_TAG; i <= TARGET_END_TAG; ++ i)
    {
        UIButton *button = (UIButton *)[self.view viewWithTag: tag ++];
        [button addTarget:self action:@selector(clickWriteButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.view bringSubviewToFront:button];
        button.hidden = YES;
    }    
}
- (void)updateTargetViews:(Word *)word
{

    NSInteger tag = TARGET_BASE_TAG;
    for (int i = 0; i < word.length; ++ i)
    {
        UIButton *button = (UIButton *)[self.view viewWithTag: tag ++];
        [self setButton:button title:nil enabled:NO];
        button.hidden = NO;
    }
    
}

- (void)initShowView
{
    showView = [[ShowDrawView alloc] initWithFrame:DRAW_VIEW_FRAME];
    [showView setPlaySpeed:[ConfigManager getOnlinePlayDrawSpeed]];
    [self.view insertSubview:showView aboveSubview:drawBackground];
}




- (void)initWithCachData
{
    if (drawGameService.sessionStatus == SESSION_PLAYING) {
        
        if (drawGameService.word.text) {
            [self didReceiveDrawWord:drawGameService.word.text 
                               level:drawGameService.word.level 
                            language:drawGameService.language];
        }        
        NSArray *actionList = drawGameService.drawActionList;
        for (DrawAction *action in actionList) {
            [showView addDrawAction:action play:YES];
        }
        [self startTimer];
    }
}

- (void)setButton:(UIButton *)button title:(NSString *)title enabled:(BOOL)enabled
{
    [button setTitle:title forState:UIControlStateSelected];
    [button setEnabled:enabled];
    if (languageType == ChineseType && [LocaleUtils isTraditionalChinese]) {
        NSString *realValue = [WordManager changeToTraditionalChinese:title];
        [button setTitle:realValue forState:UIControlStateNormal];
    }else{
        [button setTitle:title forState:UIControlStateNormal];
    }
}
- (NSString *)realValueForButton:(UIButton *)button
{
    return [button titleForState:UIControlStateSelected];
}

- (IBAction)clickGroupChatButton:(id)sender {
    [super showGroupChatView];
}

#pragma mark - levelServiceDelegate
- (void)levelDown:(int)level
{
//    [[CommonMessageCenter defaultCenter] postMessageWithText:[NSString stringWithFormat:NSLS(@"kDegradeMsg"),level] delayTime:2 isHappy:NO];
}

#pragma mark - commonItemInfoView delegate
- (void)didBuyItem:(Item *)anItem 
            result:(int)result
{
    if (result == 0) {
        [[CommonMessageCenter defaultCenter]postMessageWithText:NSLS(@"kBuySuccess") delayTime:1 isHappy:YES];
        ToolView* toolview = nil;
        switch (anItem.type) {
            case ItemTypeTips: {
                toolview = (ToolView*)[self.view viewWithTag:TOOLVIEW_TAG_TIPS];
            } break;
            case ItemTypeFlower: {
                toolview = (ToolView*)[self.view viewWithTag:TOOLVIEW_TAG_FLOWER];
            } break;
            case ItemTypeTomato: {
                toolview = (ToolView*)[self.view viewWithTag:TOOLVIEW_TAG_TOMATO];
            } break;
            default:
                break;
        }
        [toolview setNumber:[[ItemManager defaultManager] amountForItem:toolview.itemType]];
    }
    if (result == ERROR_COINS_NOT_ENOUGH)
    {
        [[CommonMessageCenter defaultCenter]postMessageWithText:NSLS(@"kNotEnoughCoin") delayTime:1 isHappy:NO];
    }
}

@end
