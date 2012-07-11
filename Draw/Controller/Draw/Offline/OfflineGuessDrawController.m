//
//  ShowDrawController.m
//  Draw
//
//  Created by  on 12-3-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "OfflineGuessDrawController.h"
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
#import "Feed.h"
#import "Draw.h"
#import "AccountManager.h"
#import "CoinShopController.h"
#import "FeedController.h"
#import "FeedDetailController.h"
#import "CommonUserInfoView.h"

#define PAPER_VIEW_TAG 20120403
#define TOOLVIEW_CENTER (([DeviceDetection isIPAD]) ? CGPointMake(695, 920):CGPointMake(284, 424))
#define MOVE_BUTTON_FONT_SIZE (([DeviceDetection isIPAD]) ? 36.0 : 18.0)




@implementation OfflineGuessDrawController
@synthesize showView;
@synthesize candidateString = _candidateString;
@synthesize drawBackground;
@synthesize word = _word;
@synthesize quitButton;
@synthesize titleLabel;
@synthesize feed = _feed;
@synthesize superController = _supperController;
@synthesize delegate = _delegate;


+ (OfflineGuessDrawController *)startOfflineGuess:(Feed *)feed 
           fromController:(UIViewController *)fromController
{
    OfflineGuessDrawController *offGuess = [[OfflineGuessDrawController alloc] 
                                            initWithFeed:feed];
    offGuess.superController = fromController;
    [fromController.navigationController pushViewController:offGuess animated:YES];
    [offGuess release];        
    return offGuess;
}

- (void)dealloc
{
    moveButton = nil;
    _shopController = nil;
    lastScaleTarget = nil;
    
    PPRelease(_candidateString);
//    PPRelease(toolView);
    PPRelease(showView);
    PPRelease(drawBackground);
    PPRelease(titleLabel);
    PPRelease(_feed);
    PPRelease(quitButton);
    PPRelease(_guessWords);
    PPRelease(_supperController);
    [super dealloc];
}


#pragma mark - Constroction
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _guessWords = [[NSMutableArray alloc] init];
    }
    return self;
}


- (id)init{
    self = [super init];
    if (self) {
        shareImageManager = [ShareImageManager defaultManager];        
    }
    return self;
}

- (id)initWithFeed:(Feed *)feed
{
    self = [super init];
    if (self) {
        shareImageManager = [ShareImageManager defaultManager];        
        self.feed = feed;
        _opusId = _feed.feedId;
        if (_feed.feedType == FeedTypeGuess) {
            _opusId = _feed.opusId;
        }
        _draw = _feed.drawData;
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
#define WORD_BASE_X (([DeviceDetection isIPAD])? 26 : 9)
#define WORD_BASE_Y_1 (([DeviceDetection isIPAD])? 855 : 390)
#define WORD_BASE_Y_2 (([DeviceDetection isIPAD])? 930 : 425)
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
    [[AudioManager defaultManager] playSoundById:CLICK_WORD];
    if ([text length] != 0) {
        if (target) {
            [self setButton:target title:text enabled:YES];
            [self setButton:button title:nil enabled:NO];
            
            NSString *ans = [self getAnswer];
            if ([ans length] == [self.word.text length]) {
                [self commitAnswer:ans];;
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
        [button setTag:i];
        [self initCandidateButton:button];
        [self.view addSubview:button];
    }
    [self resetWordButtons:CANDIDATE_WORD_NUMBER];
    [self initMoveButton];
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


//- (void)updateBomb
//{
//    toolView.number = [[ItemManager defaultManager] tipsItemAmount];
//}
//
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

- (void)updateDrawInfo
{

    self.word = _draw.word;
    [self updateTargetViews:_draw.word];
    [self updateCandidateViews:_draw.word lang:_draw.languageType];
//    toolView.enabled = YES;
    if ([_draw.drawActionList count] != 0) {
        
        NSMutableArray *list =  [NSMutableArray arrayWithArray:_draw.drawActionList];            
        [self.showView setDrawActionList:list];
        double speed = [DrawAction calculateSpeed:self.showView.drawActionList];
        self.showView.playSpeed = speed;
        [self.showView play];
    }
    
    AvatarView *avatar = [[AvatarView alloc] initWithUrlString:_draw.avatar type:Guesser gender:YES level:1];
    avatar.userId = _draw.userId;
    if ([DeviceDetection isIPAD]) {
        avatar.center = CGPointMake(21 * 2, 22 * 2);
    }else{
        avatar.center = CGPointMake(21, 22);
    }
    avatar.delegate = self;
    [self.view addSubview:avatar];
    [avatar release];
    
    if ([[_draw nickName] length] != 0) {
        if ([_draw.userId isEqualToString:[UserManager defaultManager].userId]) {
            [self.titleLabel setText:[NSString stringWithFormat:NSLS(@"kGuessUserDraw_MyDraw")]];
        } else {
            [self.titleLabel setText:[NSString stringWithFormat:NSLS(@"kGuessUserDraw"),[_draw nickName]]];
        }
    }

}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.titleLabel setText:NSLS(@"kGuessDraw")];
    [self.quitButton setTitle:NSLS(@"kQuit") forState:UIControlStateNormal];
    [self.quitButton setBackgroundImage:[shareImageManager orangeImage] forState:UIControlStateNormal];
    
    [self initShowView];
    
    //init the toolView for bomb the candidate words
//    [self initBomb];
    [self initWordViews];
    [self initTargetViews];

    _shopController = nil;
    
    [self updateDrawInfo];
    
}


- (void)viewDidAppear:(BOOL)animated
{
//    [self updateBomb];
    [super viewDidAppear:animated];
}



- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _shopController = nil;
}

- (void)viewDidUnload
{
    [self setShowView:nil];
    [self setDrawBackground:nil];
    [self setTitleLabel:nil];
    [self setQuitButton:nil];
    [super viewDidUnload];
    [self setWord:nil];
}



- (void)updateFeed:(BOOL)isCorrect
{
    if ([_guessWords count] != 0) {
        self.feed.guessTimes ++;
        if (isCorrect) {
            self.feed.correctTimes ++;
        }
        if (_delegate && [_delegate respondsToSelector:@selector(didGuessFeed:isCorrect:words:)]) {
            [_delegate didGuessFeed:_feed isCorrect:isCorrect words:_guessWords];
        }
    }
}

#pragma mark - Common Dialog Delegate
#define SHOP_DIALOG_TAG 20120406
#define QUIT_DIALOG_TAG 20120613
#define ESCAPE_DEDUT_COIN 1

- (void)clickOk:(CommonDialog *)dialog
{
    //run away
    if (dialog.tag == SHOP_DIALOG_TAG) {
        ItemShopController *itemShop = [ItemShopController instance];
        [self.navigationController pushViewController:itemShop animated:YES];
        _shopController = itemShop;
    }else if(dialog.tag == QUIT_DIALOG_TAG){

        //if have no words, don't send the action.
        if ([_guessWords count] != 0) {
            [[DrawDataService defaultService] guessDraw:_guessWords opusId:_opusId opusCreatorUid:_draw.userId isCorrect:NO score:0 delegate:nil];            
            [self updateFeed:NO];
        }
        UIViewController *feedDetail = [self superViewControllerForClass:[FeedDetailController class]];
        if (feedDetail) {
            [self.navigationController popToViewController:feedDetail animated:YES];
        }else{
            [HomeController returnRoom:self];        
        }
    }
}
- (void)clickBack:(CommonDialog *)dialog
{
    
}

#pragma mark - Actions

- (void)commitAnswer:(NSString *)answer
{
    [_guessWords addObject:answer];
    
    //alter if the word is correct
    if ([answer isEqualToString:self.word.text]) {
        if ([self.showView status] != Stop) {
            [self.showView show];            
        }

        
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kGuessCorrect") delayTime:1 isHappy:YES];
        [[AudioManager defaultManager] playSoundById:BINGO];
        [self setWordButtonsEnabled:NO];
    
        NSInteger score = [_draw.word score] * [ConfigManager guessDifficultLevel];
        
        ResultController *result = [[ResultController alloc] initWithImage:showView.createImage drawUserId:_draw.userId drawUserNickName:_draw.nickName wordText:_draw.word.text score:score correct:YES isMyPaint:NO drawActionList:_draw.drawActionList];
    
        //send http request.
        [[DrawDataService defaultService] guessDraw:_guessWords opusId:_opusId opusCreatorUid:_draw.userId isCorrect:YES score:score delegate:nil];
        [self updateFeed:YES];
        
        //store locally.
        [[UserManager defaultManager] guessCorrectOpus:_opusId];
        [self.navigationController pushViewController:result animated:YES];
        [result release];
        
    }else{
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kGuessWrong") delayTime:1 isHappy:NO];
        [[AudioManager defaultManager] playSoundById:WRONG];
    }
}




- (void)bomb:(id)sender
{
    if ([self.candidateString length] == 0) {
        return;
    }
    if ([[ItemManager defaultManager] tipsItemAmount] <= 0) {
        CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kNoTipsItemTitle") message:NSLS(@"kNoTipsItemMessage") style:CommonDialogStyleDoubleButton delegate:self];
        dialog.tag = SHOP_DIALOG_TAG;
        [dialog showInView:self.view];
    }else{
        [self updateTargetViews:self.word];
        NSString *result  = [WordManager bombCandidateString:self.candidateString word:self.word];
        [self updateCandidateViewsWithText:result];
        [[AccountService defaultService] consumeItem:ItemTypeTips amount:1];
    }
    
}
- (IBAction)clickToolBox:(id)sender {
//    [self bomb:sender];
}

- (IBAction)clickRunAway:(id)sender {
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kQuitGameAlertTitle") message:NSLS(@"kQuitGameAlertMessage") style:CommonDialogStyleDoubleButton delegate:self];
    dialog.tag = QUIT_DIALOG_TAG;
    [self.view addSubview:dialog];
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
    [self.view insertSubview:showView aboveSubview:drawBackground];
    showView.playSpeed = 1.0/28.0;
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

#pragma mark - avatar view delegate
- (void)didClickOnAvatar:(NSString *)userId
{
    [CommonUserInfoView showUser:userId 
                        nickName:nil 
                          avatar:nil 
                          gender:nil 
                        location:nil 
                           level:1
                         hasSina:NO 
                           hasQQ:NO 
                     hasFacebook:NO 
                      infoInView:self];
}


@end
