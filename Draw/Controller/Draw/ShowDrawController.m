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

#define WORD_LENGTH_TIP_TIME 20
#define PAPER_VIEW_TAG 20120403
#define TOOLVIEW_CENTER (([DeviceDetection isIPAD]) ? CGPointMake(695, 920):CGPointMake(284, 424))




@implementation ShowDrawController
@synthesize scrollView;
@synthesize pageControl;
@synthesize leftPageButton;
@synthesize rightPageButton;
@synthesize guessDoneButton;
@synthesize word = _word;
@synthesize candidateString = _candidateString;
@synthesize needResetData;
- (void)dealloc
{
    [_word release];
    [_candidateString release];
    [guessDoneButton release];
    [toolView release];
    [showView release];
    [scrollView release];
    [pageControl release];
    [leftPageButton release];
    [rightPageButton release];
    [super dealloc];
}
#pragma mark - Static Method
+ (ShowDrawController *)instance
{
    return GlobalGetShowDrawController();
}

+ (void)returnFromController:(UIViewController*)fromController
{
    ShowDrawController *sc = [ShowDrawController instance];
    sc.needResetData = NO;
    [fromController.navigationController popToViewController:sc animated:YES];
}

+ (void)startGuessFromController:(UIViewController*)fromController
{
    ShowDrawController *sc = [ShowDrawController instance];
    sc.needResetData = YES;
    [fromController.navigationController pushViewController:sc animated:NO];            
}


#pragma mark - Constroction
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.word = nil;
        toolView = [[ToolView alloc] initWithNumber:0];
        toolView.center = TOOLVIEW_CENTER;
    }
    return self;
}

- (id)init{
    self = [super init];
    if (self) {
        _viewIsAppear = NO;
        showView = [[ShowDrawView alloc] initWithFrame:DRAW_VEIW_FRAME];   
        drawGameService.showDelegate = self;
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - init the buttons

#define WRITE_BUTTON_TAG_START 11
#define WRITE_BUTTON_TAG_END 18
#define PICK_BUTTON_TAG_START 21
#define PICK_BUTTON_TAG_END 44

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
    int tag = PICK_BUTTON_TAG_START;
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
            
//            [button addTarget:self action:@selector(clickPickingButton:) forControlEvents:UIControlEventTouchUpInside];
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
    for (; tag <= PICK_BUTTON_TAG_END; ++ tag) {
        UIButton *button = (UIButton *)[scrollView viewWithTag:tag];
        [button setTitle:nil forState:UIControlStateNormal];
        button.hidden = YES;
    }
}

- (UIButton *)targetButton:(CGPoint)point
{
    
    for (int tag = WRITE_BUTTON_TAG_START; tag <= WRITE_BUTTON_TAG_END; ++ tag) {
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
    for (int i = WRITE_BUTTON_TAG_START; i <= endIndex; ++ i) {
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
    for (int i = WRITE_BUTTON_TAG_START; i <= endIndex; ++ i) {
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
                NSInteger index = button.tag - PICK_BUTTON_TAG_START;
                if (index < [self.candidateString length]) {
                    NSString *simpleChineseText = [self.candidateString substringWithRange:NSMakeRange(index, 1)];
                    [target setTitle:simpleChineseText forState:UIControlStateSelected];
                }
            }
            
            [button setEnabled:NO];
            [button setTitle:nil forState:UIControlStateNormal];            
            
            NSString *ans = [self getAnswer];
            if ([ans length] == [self.word.text length]) {
                [self clickGuessDoneButton:nil];
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

- (void)initWordButtons
{
    scrollView.delegate = self;
    scrollView.pagingEnabled = YES;

    for (int i = PICK_BUTTON_TAG_START; i <= PICK_BUTTON_TAG_END; ++ i) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setBackgroundImage:[shareImageManager woodImage]
                          forState:UIControlStateNormal];
        [button setTag:i];

        button.enabled = NO;
        button.frame = CGRectMake(0, 0, WORD_BUTTON_WIDTH, WORD_BUTTON_HEIGHT);
        [self addDragActions:button];
        [scrollView addSubview:button];
    }
    if ([[UserManager defaultManager] getLanguageType] == ChineseType) {
        [self resetWordButtons:CN_WORD_COUNT_PER_PAGE page:CN_WORD_PAGE];
    }else{
        [self resetWordButtons:EN_WORD_COUNT_PER_PAGE page:EN_WORD_PAGE];
    }
    
    
    moveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [moveButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [moveButton setBackgroundImage:[UIImage imageNamed:@"wood_button.png"] forState:UIControlStateNormal];
    moveButton.hidden = YES;
    moveButton.frame = CGRectMake(0, 0, WORD_BUTTON_WIDTH, WORD_BUTTON_HEIGHT);
    moveButton.layer.transform = CATransform3DMakeScale(ZOOM_SCALE, ZOOM_SCALE, 1);
    [self.view addSubview:moveButton];
    
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
    for (int i = WRITE_BUTTON_TAG_START; i <= WRITE_BUTTON_TAG_END; ++ i)
    {
        UIButton *button = (UIButton *)[self.view viewWithTag:i];
        [button addTarget:self action:@selector(clickWriteButton:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:nil forState:UIControlStateNormal];
        [self.view bringSubviewToFront:button];
        button.enabled = NO;
    }
    [self.guessDoneButton setBackgroundImage:[shareImageManager orangeImage] forState:UIControlStateNormal];
    [self.guessDoneButton setTitle:NSLS(@"kSubmit") forState:UIControlStateNormal];
    [self.view bringSubviewToFront:guessDoneButton];
    self.guessDoneButton.enabled = NO;
    toolView.enabled = NO;
}


#pragma mark - Word && Word Views



- (void)updateAnswerViews
{

//    NSInteger endIndex = WRITE_BUTTON_TAG_END;
//    if (languageType == ChineseType) {
//        endIndex --;
//        [guessDoneButton setHidden:NO];
//        [guessDoneButton setEnabled:(self.word.text != nil)];
//    }else{
        [guessDoneButton setHidden:YES];
        [guessDoneButton setEnabled:NO];
    NSInteger endIndex = WRITE_BUTTON_TAG_START + (self.word.text.length) - 1;
//    }    
    for (int i = WRITE_BUTTON_TAG_START; i <= WRITE_BUTTON_TAG_END; ++ i) {
        UIButton *button = (UIButton *)[self.view viewWithTag:i];     
        if (button) {
            [button setTitle:nil forState:UIControlStateNormal];
            [button setEnabled:NO];
            if (i <= endIndex) {
                [button setHidden:NO];
            }else{
                [button setHidden:YES];
            }
        }
    }
}

- (void)updateCandidateViewsWithText:(NSString *)text
{
    self.candidateString = text;
    
    NSInteger tag = PICK_BUTTON_TAG_START;
    
    for (; tag < PICK_BUTTON_TAG_START + [text length]; ++ tag) {
        UIButton *button = (UIButton *)[scrollView viewWithTag:tag];
        [button setEnabled:YES];
            NSString *string = [self.candidateString substringWithRange:NSMakeRange(tag - PICK_BUTTON_TAG_START, 1)];
        if (languageType == ChineseType && [LocaleUtils isTraditionalChinese]) {
            string = [WordManager changeToTraditionalChinese:string];
        }
        [button setTitle:string forState:UIControlStateNormal];
        if ([string isEqualToString:@" "]) {
            [button setEnabled:NO];
        }
    }

    for (; tag <= PICK_BUTTON_TAG_END; ++ tag) {
        UIButton *button = (UIButton *)[scrollView viewWithTag:tag];
        [button setTitle:nil forState:UIControlStateNormal];
        [button setEnabled:NO];
    }

}

- (void) updateCandidateViews
{
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

- (void)updateBomb
{
    if ([self.candidateString length] != 0) {
        [toolView setEnabled:YES];        
    }
    toolView.number = [[ItemManager defaultManager] tipsItemAmount];
}

- (void)updatePickViewsWithWord:(Word *)word lang:(LanguageType)lang
{
    NSString *upperString = [WordManager upperText:word.text];
    self.word = word;
    self.word.text = upperString;
    languageType = lang;
    [self updateCandidateViews];
    [self updateBomb];
    [self updateAnswerViews];
}




- (UIButton *)getTheCandidateButtonForText:(NSString *)text
{
    for (int i = 0; i < [self.candidateString length]; ++ i) {
        NSString *sub = [self.candidateString substringWithRange:NSMakeRange(i, 1)];
        if ([sub isEqualToString:text]) {
            UIButton *button = (UIButton *)[scrollView viewWithTag:PICK_BUTTON_TAG_START + i];
            if ([[button titleForState:UIControlStateNormal] length] == 0) {
                return button;
            }
        }
    }
    return nil;
}

- (void)setAnswerButtonsEnabled
{
    for (int i = WRITE_BUTTON_TAG_START; i <= WRITE_BUTTON_TAG_END; ++ i) {
        UIButton *button = (UIButton *)[self.view viewWithTag:i];
        if ([button titleForState:UIControlStateNormal]) {
            button.enabled = YES;
        }
    }
}

- (void)setGuessAndPickButtonsEnabled:(BOOL)enabled
{
    for (int i = WRITE_BUTTON_TAG_START; i <= WRITE_BUTTON_TAG_END; ++ i) {
        UIButton *button = (UIButton *)[self.view viewWithTag:i];
        [button setEnabled:enabled];
    }
    
    for (int i = PICK_BUTTON_TAG_START; i <= PICK_BUTTON_TAG_END; ++ i) {
        UIButton *button = (UIButton *)[scrollView viewWithTag:i];
        [button setEnabled:enabled];
    }
}

- (void)setWordButtonsEnabled:(BOOL)enabled
{
    [self setGuessAndPickButtonsEnabled:enabled];
    [self.guessDoneButton setEnabled:enabled];
    [toolView setEnabled:enabled];
}

#pragma makr - Timer Handle

- (void)handleTimer:(NSTimer *)theTimer
{
    --retainCount;
    if (retainCount <= 0) {
        [self resetTimer];
        [self setGuessAndPickButtonsEnabled:NO];
        [self.guessDoneButton setEnabled:NO];
        retainCount = 0;
    }else if(retainCount == WORD_LENGTH_TIP_TIME){
        [self popupWordLengthMessage];
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

- (void)updateLastAnswerButton
{
    UIView *lastAnwserButton = [self.view viewWithTag:WRITE_BUTTON_TAG_END];
    BOOL flag = [[UserManager defaultManager]getLanguageType] == ChineseType;
    self.guessDoneButton.hidden = !flag;
    lastAnwserButton.hidden = flag;
}

- (void)resetData
{
    [self startTimer];
    [self updatePlayerAvatars];
    [self.turnNumberButton setTitle:[NSString stringWithFormat:@"%d",drawGameService.roundNumber] forState:UIControlStateNormal];
    [self updateLastAnswerButton];
    _guessCorrect = NO;
    _shopController = nil;

}

- (void)cleanData
{
    [self resetTimer];
    [showView cleanAllActions];
    [self setWord:nil];
    [drawGameService unregisterObserver:self];
    _viewIsAppear = NO;
    
    [self updateCandidateViews];
    [self updateBomb];
    [self updateAnswerViews];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    //put the show view above the paper background
    UIView *paperView = [self.view viewWithTag:PAPER_VIEW_TAG];
    [self.view insertSubview:showView aboveSubview:paperView];
    
    [self initWordButtons];
        
    //init the word buttons
    [self initAnswerViews];
    
//    [self didReceiveDrawWord:@"永远" level:1 language:ChineseType];
    //init the popup buttons
    [self.popupButton setBackgroundImage:[shareImageManager popupImage] 
                                forState:UIControlStateNormal];
    [self.view bringSubviewToFront:self.popupButton];
    
    //init the toolView for bomb the candidate words
    [self.view addSubview:toolView];
    [toolView addTarget:self action:@selector(bomb:)];
}
- (void)cleanScreen
{
    [self.popupButton.layer removeAllAnimations];
    [self.popupButton setHidden:YES];    
    [self clearUnPopupMessages];
    for (UIView *view in self.view.subviews) {
        if (view && [view isKindOfClass:[CommonDialog class]]) {
            [view removeFromSuperview];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    _viewIsAppear = YES;
    if (needResetData) {
        [self resetData];        
    }
    [self cleanScreen];
    [self updateBomb];
    [drawGameService registerObserver:self];
    [super viewDidAppear:animated];
}



- (void)viewDidDisappear:(BOOL)animated
{
    if (!_shopController) {
        _viewIsAppear = NO;
        [self setWord:nil];
    }
    [self cleanScreen];
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    [self setGuessDoneButton:nil];
    [self setClockButton:nil];
    [self setPopupButton:nil];
    [self setTurnNumberButton:nil];
    [self setScrollView:nil];
    [self setPageControl:nil];
    [self setLeftPageButton:nil];
    [self setRightPageButton:nil];
    [super viewDidUnload];
    [self setWord:nil];
    showView = nil;
}


#pragma mark - Draw Game Service Delegate

- (void)didReceiveDrawWord:(NSString*)wordText level:(int)wordLevel language:(int)language
{
    PPDebug(@"<ShowDrawController> ReceiveWord:%@", wordText);
    if (wordText) {
        Word *word = [[[Word alloc] initWithText:wordText level:wordLevel]autorelease];
        [self updatePickViewsWithWord:word lang:language];
        [showView cleanAllActions];
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
/* unused in this version
- (void)didConnected
{
    [self popupHappyMessage:NSLS(@"kConnectionRecover") title:nil];

}
 */
- (void)didBroken
{
    PPDebug(@"<ShowDrawController>:didBroken");
    [self cleanData];

}




#pragma mark - Observer Method/Game Process
- (void)didGameTurnGuessStart:(GameMessage *)message
{
    PPDebug(@"<ShowDrawController>didGameTurnGuessStart");
    [self startTimer];
    [showView cleanAllActions];
}


- (void)didUserQuitGame:(GameMessage *)message
{
    NSString *userId = [[message notification] quitUserId];
    [self popUpRunAwayMessage:userId];
//    [self updatePlayerAvatars];
    [self adjustPlayerAvatars:userId];
    if (_viewIsAppear && [self userCount] <= 1) {
        [self popupUnhappyMessage:NSLS(@"kAllUserQuit") title:nil];
    }
}
- (void)didGameTurnComplete:(GameMessage *)message
{
    PPDebug(@"<ShowDrawController>didGameTurnComplete");
    [self resetTimer];
    if (_viewIsAppear) {
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
            [_shopController.navigationController popViewControllerAnimated:NO];
            [self.navigationController pushViewController:rc animated:NO];
        }else{
            [self.navigationController pushViewController:rc animated:YES];
        }
        [rc release];
        [self updatePickViewsWithWord:nil lang:languageType];        
        
    }
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
        itemShop.callFromShowViewController = YES;
        [self.navigationController pushViewController:itemShop animated:YES];
        _shopController = itemShop;
    }else{
        [drawGameService quitGame];
        [HomeController returnRoom:self];
        [self cleanData];
        [self updatePickViewsWithWord:nil lang:languageType];        
    }
}
- (void)clickBack:(CommonDialog *)dialog
{
    
}

#pragma mark - Actions
- (IBAction)clickGuessDoneButton:(id)sender {
    if (_guessCorrect) {
        return;
    }
    
    NSString *ans = [self getAnswer];
    
    //if the answer is nil, don't send the answer.
    if ([ans length] == 0) {
        [self popupUnhappyMessage:NSLS(@"kGuessWrong") title:nil];
        [[AudioManager defaultManager] playSoundById:WRONG];
        return;
    }
    
    BOOL flag = [ans isEqualToString:self.word.text];    
    //alter if the word is correct
    if (flag) {
        [self popupHappyMessage:NSLS(@"kGuessCorrect") title:nil];
        [[AudioManager defaultManager] playSoundById:BINGO];
        _guessCorrect = YES;
        [self setWordButtonsEnabled:NO];
        [self setAnswerButtonsEnabled];
//        [self addScore:self.word.score toUser:drawGameService.userId];
    }else{
        [self popupUnhappyMessage:NSLS(@"kGuessWrong") title:nil];
        [[AudioManager defaultManager] playSoundById:WRONG];
    }
    [drawGameService guess:ans guessUserId:drawGameService.session.userId];
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
        [self updateAnswerViews];
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


@end
