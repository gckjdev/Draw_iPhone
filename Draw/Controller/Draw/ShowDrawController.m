//
//  ShowDrawController.m
//  Draw
//
//  Created by  on 12-3-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ShowDrawController.h"
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

ShowDrawController *staticShowDrawController = nil;
ShowDrawController *GlobalGetShowDrawController()
{
    if (staticShowDrawController == nil) {
        staticShowDrawController = [[ShowDrawController alloc] init];
    }
    return staticShowDrawController;
}

#define PAPER_VIEW_TAG 20120403
#define TOOLVIEW_CENTER (([DeviceDetection isIPAD]) ? CGPointMake(695, 920):CGPointMake(284, 424))




@implementation ShowDrawController
@synthesize showView;
@synthesize scrollView;
@synthesize pageControl;
@synthesize leftPageButton;
@synthesize rightPageButton;
@synthesize word = _word;
@synthesize candidateString = _candidateString;
@synthesize needResetData;
@synthesize drawBackground;
- (void)dealloc
{
    [_word release];
    [_candidateString release];
    [toolView release];
    [showView release];
    [scrollView release];
    [pageControl release];
    [leftPageButton release];
    [rightPageButton release];
    [drawBackground release];
    [super dealloc];
}
#pragma mark - Static Method


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
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - init the buttons

#define TARGET_BASE_TAG 11
#define WRITE_BUTTON_TAG_END 18
#define CANDIDATE_BASE_TAG 21
#define CANDIDATE_END_TAG 44

#define RowNumber 2
#define CN_WORD_WIDTH (([DeviceDetection isIPAD])? 496:218) 
#define WORD_HEIGHT (([DeviceDetection isIPAD])? 75 * 2 : 75)
#define CN_WORD_FRAME (([DeviceDetection isIPAD])? CGRectMake(80, 845, CN_WORD_WIDTH, WORD_HEIGHT): CGRectMake(24, 385, CN_WORD_WIDTH, WORD_HEIGHT))
#define CN_WORD_PAGE 2
#define CN_WORD_COUNT_PER_PAGE 12

#define EN_WORD_WIDTH (([DeviceDetection isIPAD])?  650 : 253)
#define EN_WORD_PAGE 1
#define EN_WORD_COUNT_PER_PAGE (([DeviceDetection isIPAD]) ? 16 : 14)
#define EN_WORD_FRAME (([DeviceDetection isIPAD])? CGRectMake(1*2, 845, EN_WORD_WIDTH, WORD_HEIGHT):CGRectMake(1, 385, EN_WORD_WIDTH, WORD_HEIGHT))
#define SCOROLLVIEW_SPACE (([DeviceDetection isIPAD])? 28 * 2: 28)


#define WORD_BUTTON_WIDTH (([DeviceDetection isIPAD])? 30 * 2: 30)
#define WORD_BUTTON_HEIGHT (([DeviceDetection isIPAD])? 30 * 2: 30)

#define ZOOM_SCALE 1.2

- (void)enablePageButton:(NSInteger)pageIndex
{
    if (pageIndex == 0) {
        leftPageButton.enabled = NO;
        rightPageButton.enabled = YES;
    }
    if (pageIndex == pageControl.numberOfPages - 1) {
        rightPageButton.enabled = NO;
        leftPageButton.enabled = YES;
    }
}

//count is per page count, page is the total page count
- (void)resetWordButtons:(NSInteger)count page:(NSInteger)page
{
    CGFloat width = CN_WORD_WIDTH;
    CGFloat height = WORD_HEIGHT;
    if (page < 2) {
        pageControl.hidden = leftPageButton.hidden = rightPageButton.hidden = YES;
        [scrollView setFrame:EN_WORD_FRAME];       
        width = EN_WORD_WIDTH;
        height = WORD_HEIGHT;
    }else{
        [scrollView setFrame:CN_WORD_FRAME];       
        leftPageButton.hidden = rightPageButton.hidden = pageControl.hidden = NO;
        pageControl.center = CGPointMake(scrollView.center.x,scrollView.center.y + SCOROLLVIEW_SPACE);
        [self clickLeftPage:leftPageButton];
        pageControl.currentPage = 0;
        [self enablePageButton:0];
    }
    
    CGFloat contentWidth = width * page;
    [scrollView setContentSize:CGSizeMake(contentWidth, height)];
    pageControl.numberOfPages = page;
    int tag = CANDIDATE_BASE_TAG;
    for (int p = 0; p < page; ++ p) {
        CGFloat xStart = 7 + width * p;
        CGFloat yStart = 5;
        CGFloat xSpace = 5;
        CGFloat ySpace = 7;
        if ([DeviceDetection isIPAD]) {
             xStart = 7*2 + width * p;
             yStart = 5*2;
             xSpace = 20;
             ySpace = 7*2.2;
        }
        
        CGFloat x,y;
        for (int i = 0; i < count; ++ i) {
            UIButton *button = (UIButton *)[scrollView viewWithTag:tag ++];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button setBackgroundImage:[shareImageManager woodImage]
                              forState:UIControlStateNormal];
            
            if ([DeviceDetection isIPAD]) {
                [button.titleLabel setFont:[UIFont systemFontOfSize:18 * 2]];                
            }else{
                [button.titleLabel setFont:[UIFont systemFontOfSize:18]];
            }
            
            x = xStart + (WORD_BUTTON_WIDTH + xSpace) * (i % (count / RowNumber));
            if (i < count / RowNumber) {
                y = yStart;
            }else{
                y = yStart + WORD_BUTTON_HEIGHT + ySpace;
            }
            button.frame = CGRectMake(x, y, WORD_BUTTON_WIDTH, WORD_BUTTON_HEIGHT);
            button.hidden = NO;
            button.enabled = NO;
        }
    }
    for (; tag <= CANDIDATE_END_TAG; ++ tag) {
        UIButton *button = (UIButton *)[scrollView viewWithTag:tag];
        [button setTitle:nil forState:UIControlStateNormal];
        button.hidden = YES;
    }
}

- (UIButton *)targetButton:(CGPoint)point
{
    
    for (int tag = TARGET_BASE_TAG; tag <= WRITE_BUTTON_TAG_END; ++ tag) {
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


- (void)clickWriteButton:(UIButton *)button
{
    NSString *text = [button titleForState:UIControlStateNormal];
    if ([LocaleUtils isTraditionalChinese]) {
        text = [button titleForState:UIControlStateSelected];
    }
    if ([text length] != 0) {
        UIButton *pButton = [self getTheCandidateButtonForText:text];
        if (pButton) {
            [pButton setTitle:text forState:UIControlStateNormal];            
            [button setTitle:nil forState:UIControlStateNormal];
            [pButton setEnabled:YES];
            [button setEnabled:NO];
        }
        
    }
}


- (NSString *)getAnswer
{
    //get the word
    NSString *answer = @"";
    NSInteger endIndex = (languageType == ChineseType) ? (WRITE_BUTTON_TAG_END - 1) : WRITE_BUTTON_TAG_END;
    for (int i = TARGET_BASE_TAG; i <= endIndex; ++ i) {
        UIButton *button = (UIButton *)[self.view viewWithTag:i];
        NSString *text = [button titleForState:UIControlStateNormal];
        if ([text length] == 1 && ![text isEqualToString:@" "]) {
            if ([LocaleUtils isTraditionalChinese]) {
                NSString *temp = [button titleForState:UIControlStateSelected];
                if (temp) {
                    text = temp;
                }
            }
            answer = [NSString stringWithFormat:@"%@%@",answer,text];
        }
    }
    return answer;
}

- (UIButton *)getTheFirstEmptyButton
{
    NSInteger endIndex = (languageType == ChineseType) ? (WRITE_BUTTON_TAG_END - 1) : WRITE_BUTTON_TAG_END;
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
    [[AudioManager defaultManager] playSoundById:CLICK_WORD];
    if ([text length] != 0) {
        if (target) {
            [target setTitle:text forState:UIControlStateNormal];
            [target setTitle:nil forState:UIControlStateSelected];
            [target setEnabled:YES];
            
            if ([LocaleUtils isTraditionalChinese]) {
                NSInteger index = button.tag - CANDIDATE_BASE_TAG;
                if (index < [self.candidateString length]) {
                    NSString *simpleChineseText = [self.candidateString substringWithRange:NSMakeRange(index, 1)];
                    [target setTitle:simpleChineseText forState:UIControlStateSelected];
                }
            }
            
            [button setEnabled:NO];
            [button setTitle:nil forState:UIControlStateNormal];            
            
            NSString *ans = [self getAnswer];
            if ([ans length] == [self.word.text length]) {
                [self commitAnswer:ans];;
            } 
        }
    }
}

- (void) dragBegan: (UIControl *) c withEvent:ev
{
    scrollView.scrollEnabled = NO;
    UIButton *bt = (UIButton *)c;
    NSString *title = [bt titleForState:UIControlStateNormal];
    
    moveButton.hidden = NO;
    [moveButton setTitle:title forState:UIControlStateNormal];
    [bt setTitle:nil forState:UIControlStateNormal];
    bt.enabled = NO;
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
    CGPoint touchPoint = [[[ev allTouches] anyObject] locationInView:scrollView]; 
    NSString *title = [moveButton titleForState:UIControlStateNormal];
    UIButton *targetButton = [self targetButton:moveButton.center];
    UIButton *bt = (UIButton *)c;    
    
    lastScaleTarget.layer.transform = CATransform3DMakeScale(1, 1, 1);
    lastScaleTarget = nil;

    
    if (targetButton != nil) {
        [self clickPickingButton:bt target:targetButton text:title];
    }else{ 
        NSInteger distance = [DrawUtils distanceBetweenPoint:touchPoint point2:c.center];
        if(distance < c.frame.size.width / 2 && (targetButton = [self getTheFirstEmptyButton]) != nil)
        {
            [self clickPickingButton:bt target:targetButton text:title];            
        }else{
            [bt setTitle:title forState:UIControlStateNormal];
            bt.enabled = YES;
        }
    }
    [moveButton setTitle:nil forState:UIControlStateNormal];
    moveButton.hidden = YES;
    scrollView.scrollEnabled = YES;
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
    scrollView.delegate = self;
    scrollView.pagingEnabled = YES;

    for (int i = CANDIDATE_BASE_TAG; i <= CANDIDATE_END_TAG; ++ i) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTag:i];
        [self initCandidateButton:button];
        [scrollView addSubview:button];
    }
    if ([[UserManager defaultManager] getLanguageType] == ChineseType) {
        [self resetWordButtons:CN_WORD_COUNT_PER_PAGE page:CN_WORD_PAGE];
    }else{
        [self resetWordButtons:EN_WORD_COUNT_PER_PAGE page:EN_WORD_PAGE];
    }
    [self initMoveButton];
}

- (void) scrollViewDidScroll:(UIScrollView *)sender {
    CGFloat pageWidth = sender.frame.size.width;
    int currentPage = floor((sender.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if (currentPage != pageControl.currentPage) {
        pageControl.currentPage = currentPage;
        [self enablePageButton:currentPage];        
    }
}

- (void)initAnswerViews
{
    for (int i = TARGET_BASE_TAG; i <= WRITE_BUTTON_TAG_END; ++ i)
    {
        UIButton *button = (UIButton *)[self.view viewWithTag:i];
        [button addTarget:self action:@selector(clickWriteButton:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:nil forState:UIControlStateNormal];
        [self.view bringSubviewToFront:button];
        button.enabled = NO;
    }
    toolView.enabled = NO;
}


#pragma mark - Word && Word Views


- (void)updateCandidateViewsWithText:(NSString *)text
{
    self.candidateString = text;
    NSInteger tag = CANDIDATE_BASE_TAG;
    
    for (int i = 0; i < text.length; ++ i) {
        UIButton *button = (UIButton *)[scrollView viewWithTag:tag ++];
        NSString *selectedTitle = [self.candidateString substringWithRange:NSMakeRange(i, 1)];
        NSString *normalTitle = selectedTitle;
        if ([selectedTitle isEqualToString:@" "]) {
            [button setEnabled:NO];
        }else{
            [button setEnabled:YES];
            if (languageType == ChineseType && [LocaleUtils isTraditionalChinese]) {
                normalTitle = [WordManager changeToTraditionalChinese:selectedTitle];
            }
        }
        [button setTitle:normalTitle forState:UIControlStateNormal];
        [button setTitle:selectedTitle forState:UIControlStateSelected];
    }

    for (; tag <= CANDIDATE_END_TAG; ++ tag) {
        UIButton *button = (UIButton *)[scrollView viewWithTag:tag];
        [button setTitle:nil forState:UIControlStateNormal];
        [button setEnabled:NO];
    }
}


- (void)updateBomb
{
    toolView.number = [[ItemManager defaultManager] tipsItemAmount];
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
        text = [[WordManager defaultManager] randChinesStringWithWord:self.word count:CN_WORD_COUNT_PER_PAGE * CN_WORD_PAGE];
        [self resetWordButtons:CN_WORD_COUNT_PER_PAGE page:CN_WORD_PAGE];
    }else{
        text = [[WordManager defaultManager] randEnglishStringWithWord:self.word count:EN_WORD_COUNT_PER_PAGE];
        [self resetWordButtons:EN_WORD_COUNT_PER_PAGE page:EN_WORD_PAGE];
    }
    [self updateCandidateViewsWithText:text];
}




- (UIButton *)getTheCandidateButtonForText:(NSString *)text
{
    for (int i = 0; i < [self.candidateString length]; ++ i) {
        NSString *sub = [self.candidateString substringWithRange:NSMakeRange(i, 1)];
        if ([sub isEqualToString:text]) {
            UIButton *button = (UIButton *)[scrollView viewWithTag:CANDIDATE_BASE_TAG + i];
            if ([[button titleForState:UIControlStateNormal] length] == 0) {
                return button;
            }
        }
    }
    return nil;
}

- (void)setAnswerButtonsEnabled
{
    for (int i = TARGET_BASE_TAG; i <= WRITE_BUTTON_TAG_END; ++ i) {
        UIButton *button = (UIButton *)[self.view viewWithTag:i];
        if ([button titleForState:UIControlStateNormal]) {
            button.enabled = YES;
        }
    }
}

- (void)setGuessAndPickButtonsEnabled:(BOOL)enabled
{
    for (int i = TARGET_BASE_TAG; i <= WRITE_BUTTON_TAG_END; ++ i) {
        UIButton *button = (UIButton *)[self.view viewWithTag:i];
        [button setEnabled:enabled];
    }
    
    for (int i = CANDIDATE_BASE_TAG; i <= CANDIDATE_END_TAG; ++ i) {
        UIButton *button = (UIButton *)[scrollView viewWithTag:i];
        [button setEnabled:enabled];
    }
}

- (void)setWordButtonsEnabled:(BOOL)enabled
{
    [self setGuessAndPickButtonsEnabled:enabled];
    [toolView setEnabled:enabled];
}

#pragma makr - Timer Handle

- (void)handleTimer:(NSTimer *)theTimer
{
    --retainCount;
    if (retainCount <= 0) {
        [self resetTimer];
        [self setGuessAndPickButtonsEnabled:NO];
        retainCount = 0;
    }
    [self updateClockButton];
}





#pragma mark - Update Data

- (void)popupWordLengthMessage
{
    if (languageType == ChineseType && !_guessCorrect && [self.word.text length] > 0) {
        NSString *tip = [NSString stringWithFormat:NSLS(@"kWordLengthTip"),[self.word.text length]];
        [self popupHappyMessage:tip title:nil];
    }
}


- (void)cleanData
{
    [self resetTimer];
    drawGameService.showDelegate = nil;
    [drawGameService unregisterObserver:self];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [drawGameService registerObserver:self];
    [drawGameService setShowDelegate:self];
    
    [self initRoundNumber];
    [self updatePlayerAvatars];
    [self initShowView];
    [self initClock];
    
    //init the toolView for bomb the candidate words
    [self initBomb];
    [self initWordViews];
    [self initPopButton];
    [self initTargetViews];
    [self initWithCachData];

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
    [self setScrollView:nil];
    [self setPageControl:nil];
    [self setLeftPageButton:nil];
    [self setRightPageButton:nil];
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
        Word *word = [[[Word alloc] initWithText:wordText level:wordLevel]autorelease];
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
    UIImage *image = [showView createImage];
    ResultController *rc = [[ResultController alloc] initWithImage:image
                                                          wordText:self.word.text 
                                                             score:gainCoin
                                                           correct:_guessCorrect 
                                                         isMyPaint:NO 
                                                    drawActionList:showView.drawActionList];
    if (_shopController) {
        [_shopController.topNavigationController popToViewController:self animated:NO];
        [self.navigationController pushViewController:rc animated:NO];
    }else{
        [self.navigationController pushViewController:rc animated:YES];
    }
    [rc release]; 
    
    [self cleanData];
}



#pragma mark - Common Dialog Delegate
#define SHOP_DIALOG_TAG 20120406


- (void)clickOk:(CommonDialog *)dialog
{
    //run away
//    [dialog removeFromSuperview];
    if (dialog.tag == SHOP_DIALOG_TAG) {
        ItemShopController *itemShop = [ItemShopController instance];
//        itemShop.callFromShowViewController = YES;
        [self.navigationController pushViewController:itemShop animated:YES];
        _shopController = itemShop;
    }else{
        [drawGameService quitGame];
        [HomeController returnRoom:self];
        [self cleanData];
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
        [self popupHappyMessage:NSLS(@"kGuessCorrect") title:nil];
        [[AudioManager defaultManager] playSoundById:BINGO];
        _guessCorrect = YES;
        [self setWordButtonsEnabled:NO];
        [self setAnswerButtonsEnabled];
    }else{
        [self popupUnhappyMessage:NSLS(@"kGuessWrong") title:nil];
        [[AudioManager defaultManager] playSoundById:WRONG];
    }
    [drawGameService guess:answer guessUserId:drawGameService.session.userId];
}

- (IBAction)clickLeftPage:(id)sender {
    CGFloat width = scrollView.frame.size.width;
    CGRect frame = CGRectMake(0, 0, width , scrollView.frame.size.height);
    [scrollView scrollRectToVisible:frame animated:YES];
    if (pageControl.currentPage != 0) {
        pageControl.currentPage --;
        [self enablePageButton:pageControl.currentPage];
    }
    
}

- (IBAction)clickRightPage:(id)sender {
    CGFloat width = scrollView.frame.size.width;
    CGRect frame = CGRectMake(width, 0, width, scrollView.frame.size.height);
    [scrollView scrollRectToVisible:frame animated:YES];
    if (pageControl.currentPage < pageControl.numberOfPages - 1) {
        pageControl.currentPage ++;
        [self enablePageButton:pageControl.currentPage];
    }
}
- (void)bomb:(id)sender
{
    if ([self.candidateString length] == 0) {
        return;
    }
    if ([[ItemManager defaultManager] tipsItemAmount] <= 0) {
        CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kNoTipsItemTitle") message:NSLS(@"kNoTipsItemMessage") style:CommonDialogStyleDoubleButton deelegate:self];
        dialog.tag = SHOP_DIALOG_TAG;
        [dialog showInView:self.view];
    }else{
        NSString *result  = [WordManager bombCandidateString:self.candidateString word:self.word];
        [self updateTargetViews:self.word];
        [self updateCandidateViewsWithText:result];
        [[AccountService defaultService] consumeItem:ITEM_TYPE_TIPS amount:1];
        [toolView setNumber:[ItemManager defaultManager].tipsItemAmount];
        toolView.enabled = NO;
    }
    
}

- (IBAction)clickRunAway:(id)sender {
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kQuitGameAlertTitle") message:NSLS(@"kQuitGameAlertMessage") style:CommonDialogStyleDoubleButton deelegate:self];
    [self.view addSubview:dialog];
}


- (void)initRoundNumber
{
    [self.turnNumberButton setTitle:[NSString stringWithFormat:@"%d",drawGameService.roundNumber] forState:UIControlStateNormal];
}


- (void)initClock
{
//    [self startTimer];
}

- (void)initBomb
{
    toolView = [[ToolView alloc] initWithNumber:0];
    toolView.center = TOOLVIEW_CENTER;
    [self.view addSubview:toolView];
    [toolView addTarget:self action:@selector(bomb:)];
    [self updateBomb];
}

- (void)initTargetViews
{
    NSInteger tag = TARGET_BASE_TAG;
    for (int i = TARGET_BASE_TAG; i <= WRITE_BUTTON_TAG_END; ++ i)
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
        [button setTitle:nil forState:UIControlStateNormal];
        button.hidden = NO;
        button.enabled = NO;
    }
    
}

- (void)initShowView
{
    showView = [[ShowDrawView alloc] initWithFrame:DRAW_VEIW_FRAME];       
    [self.view insertSubview:showView aboveSubview:drawBackground];
}

- (void)initPopButton
{
    [self.popupButton setBackgroundImage:[shareImageManager popupImage] 
                                forState:UIControlStateNormal];
    [self.view bringSubviewToFront:self.popupButton];
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


@end
