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


ShowDrawController *staticShowDrawController = nil;
ShowDrawController *GlobalGetShowDrawController()
{
    if (staticShowDrawController == nil) {
        staticShowDrawController = [[ShowDrawController alloc] init];
    }
    return staticShowDrawController;
}

#define GUESS_TIME 120
#define PAPER_VIEW_TAG 20120403

@implementation ShowDrawController
@synthesize guessDoneButton;
@synthesize clockButton;
@synthesize turnNumberButton;
@synthesize popupButton;
@synthesize word = _word;
@synthesize candidateString = _candidateString;

- (void)dealloc
{
    [_word release];
    [_candidateString release];
    [guessDoneButton release];
    [clockButton release];
    [popupButton release];
    [toolView release];
    [avatarArray release];
    [showView release];
    [turnNumberButton release];
    [super dealloc];
}
#pragma mark - Static Method
+ (ShowDrawController *)instance
{
    return GlobalGetShowDrawController();
}


#pragma mark - Constroction
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.word = nil;
        avatarArray = [[NSMutableArray alloc] init];
        shareImageManager = [ShareImageManager defaultManager];
        toolView = [[ToolView alloc] initWithNumber:0];
        toolView.center = CGPointMake(284, 428);
    }
    return self;
}

- (id)init{
    self = [super init];
    if (self) {
        _viewIsAppear = NO;
        drawGameService = [DrawGameService defaultService];
        [drawGameService setShowDelegate:self];
        showView = [[ShowDrawView alloc] initWithFrame:CGRectMake(8, 46, 304, 355)];   
        
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
#define PICK_BUTTON_TAG_END 36

- (void)initAnswerAndCadidateViews
{
    for (int i = WRITE_BUTTON_TAG_START; i <= WRITE_BUTTON_TAG_END; ++ i)
    {
        UIButton *button = (UIButton *)[self.view viewWithTag:i];
        [button addTarget:self action:@selector(clickWriteButton:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:nil forState:UIControlStateNormal];
        [self.view bringSubviewToFront:button];
        button.enabled = NO;
    }
    for (int i = PICK_BUTTON_TAG_START; i <= PICK_BUTTON_TAG_END + 1; ++ i) {
        UIButton *button = (UIButton *)[self.view viewWithTag:i];
        [button setTitle:nil forState:UIControlStateNormal];
        [button addTarget:self action:@selector(clickPickingButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.view bringSubviewToFront:button];
        button.enabled = NO;
    }
    [self.guessDoneButton setBackgroundImage:[shareImageManager orangeImage] forState:UIControlStateNormal];
    [self.guessDoneButton setTitle:NSLS(@"kSubmit") forState:UIControlStateNormal];
    [self.view bringSubviewToFront:guessDoneButton];
    self.guessDoneButton.enabled = NO;
    toolView.enabled = NO;
    [self setWordButtonsHidden:YES];
}


#pragma mark - Word && Word Views

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

- (void)updateAnswerViews
{

    NSInteger endIndex = WRITE_BUTTON_TAG_END;
    if (languageType == ChineseType) {
        endIndex --;
        [guessDoneButton setHidden:NO];
        [guessDoneButton setEnabled:YES];
    }else{
        [guessDoneButton setHidden:YES];
        [guessDoneButton setEnabled:NO];
        endIndex = WRITE_BUTTON_TAG_START + (self.word.text.length) - 1;
    }    
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
    for (int i = PICK_BUTTON_TAG_START; i <= PICK_BUTTON_TAG_END; ++ i) {
        UIButton *button = (UIButton *)[self.view viewWithTag:i];
        [button setHidden:NO];
        [button setEnabled:YES];
        if (self.candidateString != nil) {
            NSString *string = [self.candidateString substringWithRange:NSMakeRange(i - PICK_BUTTON_TAG_START, 1)];
            [button setTitle:string forState:UIControlStateNormal];
            if ([string isEqualToString:@" "]) {
                [button setEnabled:NO];
            }
        }else{
            [button setTitle:nil forState:UIControlStateNormal];
            [button setEnabled:NO];
        }
    }

}

- (void) updateCandidateViews
{
    NSString *text = nil;
    if (languageType == ChineseType) {
        text = [[WordManager defaultManager] randChinesStringWithWord:self.word count:16];
    }else{
        text = [[WordManager defaultManager] randEnglishStringWithWord:self.word count:16];
    }
    [self updateCandidateViewsWithText:text];
}


- (void)updatePickViewsWithWord:(Word *)word lang:(LanguageType)lang
{
    NSString *upperString = [WordManager upperText:word.text];
    self.word = word;
    self.word.text = upperString;
    languageType = lang;
    
    toolView.number = [[ItemManager defaultManager] tipsItemAmount];
    toolView.hidden = NO;
    if (toolView.number > 0 && [word.text length] != 0) {
        toolView.enabled = YES;
        toolView.hidden = NO;
    }else{
        toolView.enabled = NO;
        toolView.hidden = YES;
    }
    [self updateCandidateViews];
    [self updateAnswerViews];
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
            answer = [NSString stringWithFormat:@"%@%@",answer,text];
        }
    }
    return answer;
}


- (UIButton *)getTheCandidateButtonForText:(NSString *)text
{
    for (int i = 0; i < [self.candidateString length]; ++ i) {
        NSString *sub = [self.candidateString substringWithRange:NSMakeRange(i, 1)];
        if ([sub isEqualToString:text]) {
            UIButton *button = (UIButton *)[self.view viewWithTag:PICK_BUTTON_TAG_START + i];
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
        UIButton *button = (UIButton *)[self.view viewWithTag:i];
        [button setEnabled:enabled];
    }
}

- (void)setWordButtonsEnabled:(BOOL)enabled
{
    [self setGuessAndPickButtonsEnabled:enabled];
    [self.guessDoneButton setEnabled:enabled];
    [toolView setEnabled:enabled];
}

- (void)setWordButtonsHidden:(BOOL)hidden
{
    for (int i = WRITE_BUTTON_TAG_START; i <= WRITE_BUTTON_TAG_END; ++ i) {
        UIButton *button = (UIButton *)[self.view viewWithTag:i];
        [button setHidden:hidden];
    }
    for (int i = PICK_BUTTON_TAG_START; i <= PICK_BUTTON_TAG_END; ++ i) {
        UIButton *button = (UIButton *)[self.view viewWithTag:i];
        [button setHidden:hidden];
    }
    [guessDoneButton setHidden:hidden];
    [toolView setHidden:hidden];
}

#pragma makr - Timer Handle
- (void)resetTimer
{
    if (guessTimer && [guessTimer isValid]) {
        [guessTimer invalidate];
    }
    guessTimer = nil;
    retainCount = GUESS_TIME;
}
- (void)updateClockButton
{
    NSString *clockString = [NSString stringWithFormat:@"%d",retainCount];
    [self.clockButton setTitle:clockString forState:UIControlStateNormal];
}

- (void)handleTimer:(NSTimer *)theTimer
{
    --retainCount;
    if (retainCount <= 0) {
        [self resetTimer];
        [self setGuessAndPickButtonsEnabled:NO];
        [self.guessDoneButton setEnabled:NO];
        retainCount = 0;
    }
    [self updateClockButton];
}


- (void)startTimer
{
    [self resetTimer];
    [self updateClockButton];
    guessTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
}




#pragma mark - Update Data
- (void)cleanAvatars
{
    for (AvatarView *view in avatarArray) {
        [view removeFromSuperview];
    }
    [avatarArray removeAllObjects];
    
}

- (void)updatePlayerAvatars
{
    [self cleanAvatars];
    GameSession *session = [[DrawGameService defaultService] session];
    int i = 0;
    for (GameSessionUser *user in session.userList) {
        AvatarType type = Guesser;
        if([user.userId isEqualToString:session.drawingUserId])
        {
            type = Drawer;
        }
        AvatarView *aView = [[AvatarView alloc] initWithUrlString:[user userAvatar] type:type];
        [aView setUserId:user.userId];
        //set center
        aView.center = CGPointMake(70 + 36 * i, 21);
        [self.view addSubview:aView];
        [avatarArray addObject:aView];
        [aView release];
        ++ i;                                  
    }
}


- (AvatarView *)avatarViewForUserId:(NSString *)userId
{
    
    for (AvatarView *view in avatarArray) {
        if ([view.userId isEqualToString:userId]) {
            return view;
        }
    }
    return nil;
}

- (void)popGuessMessage:(NSString *)message userId:(NSString *)userId
{
    AvatarView *player = [self avatarViewForUserId:userId];
    if (player == nil) {
        return;
    }
    CGFloat x = player.frame.origin.x;
    CGFloat y = player.frame.origin.y + player.frame.size.height;
    CGSize size = [message sizeWithFont:[UIFont systemFontOfSize:14]];
    [popupButton setFrame:CGRectMake(x, y, size.width + 20, size.height + 15)];
    [popupButton setTitle:message forState:UIControlStateNormal];
    [popupButton setHidden:NO];
    UIEdgeInsets inSets = UIEdgeInsetsMake(7, 0, 0, 0);
    [popupButton setTitleEdgeInsets:inSets];
    CAAnimation *animation = [AnimationManager missingAnimationWithDuration:4];
    [popupButton.layer addAnimation:animation forKey:@"DismissAnimation"];
}

- (void)popUpRunAwayMessage:(NSString *)userId
{
    AvatarView *player = [self avatarViewForUserId:userId];
    if (player == nil) {
        return;
    }
    NSString *nickName = [[drawGameService session] getNickNameByUserId:userId];
    NSString *message = [NSString stringWithFormat:NSLS(@"kRunAway"),nickName];
    CGFloat x = 8;
    CGFloat y = player.frame.origin.y + player.frame.size.height;
    CGSize size = [message sizeWithFont:[UIFont systemFontOfSize:14]];
    [popupButton setFrame:CGRectMake(x, y, size.width + 20, size.height + 15)];
    [popupButton setTitle:message forState:UIControlStateNormal];
    [popupButton setHidden:NO];
    UIEdgeInsets inSets = UIEdgeInsetsMake(7, 0, 0, 0);
    [popupButton setTitleEdgeInsets:inSets];
    CAAnimation *animation = [AnimationManager missingAnimationWithDuration:4];
    [popupButton.layer addAnimation:animation forKey:@"DismissAnimation"];
    
}
- (void)resetData
{
    [self updatePlayerAvatars];
    [self.turnNumberButton setTitle:[NSString stringWithFormat:@"%d",drawGameService.roundNumber] forState:UIControlStateNormal];
    _guessCorrect = NO;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [drawGameService registerObserver:self];
    
    //put the show view above the paper background
    UIView *paperView = [self.view viewWithTag:PAPER_VIEW_TAG];
    [self.view insertSubview:showView aboveSubview:paperView];
    
    //init the word buttons
    [self initAnswerAndCadidateViews];
    
    //init the popup buttons
    [self.popupButton setBackgroundImage:[shareImageManager popupImage] 
                                forState:UIControlStateNormal];
    [self.view bringSubviewToFront:popupButton];
    
    //init the toolView for bomb the candidate words
    [self.view addSubview:toolView];
    [toolView addTarget:self action:@selector(bomb:)];
}


- (void)viewDidAppear:(BOOL)animated
{
    _viewIsAppear = YES;
    [self resetData];
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    _viewIsAppear = NO;
    [self setWord:nil];
    [self setWordButtonsHidden:YES];
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    [self setGuessDoneButton:nil];
    [self setClockButton:nil];
    [self setPopupButton:nil];
    [self setTurnNumberButton:nil];
    [super viewDidUnload];
    [self setWord:nil];
    showView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



- (NSInteger)userCount
{
    GameSession *session = [[DrawGameService defaultService] session];
    return [session.userList count];
}
- (void)addScore:(NSInteger)score toUser:(NSString *)userId
{
    AvatarView *avatarView = [self avatarViewForUserId:userId];
    [avatarView setScore:score];
}

#pragma mark - Draw Game Service Delegate

- (void)didReceiveGuessWord:(NSString*)wordText 
                guessUserId:(NSString*)guessUserId 
               guessCorrect:(BOOL)guessCorrect
                  gainCoins:(int)gainCoins
{
    if (!guessCorrect) {
        [self popGuessMessage:wordText userId:guessUserId];        
    }else{
        [self popGuessMessage:NSLS(@"kGuessCorrect") userId:guessUserId];
        [self addScore:gainCoins toUser:guessUserId];
    }
}

- (void)didReceiveDrawWord:(NSString*)wordText level:(int)wordLevel language:(int)language
{
    PPDebug(@"<ShowDrawController> ReceiveWord:%@", wordText);
    if (wordText) {
        Word *word = [[[Word alloc] initWithText:wordText level:wordLevel]autorelease];
        LanguageType lang = [[UserManager defaultManager] getLanguageType];
        [self updatePickViewsWithWord:word lang:lang];
        [showView cleanAllActions];
    }
}

- (void)didReceiveDrawData:(GameMessage *)message
{
    Paint *paint = [[Paint alloc] initWithGameMessage:message];
    DrawAction *action = [DrawAction actionWithType:DRAW_ACTION_TYPE_DRAW paint:paint];
    [showView addDrawAction:action play:YES];
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
- (void)didBroken
{
    [self popupUnhappyMessage:NSLS(@"kConnectionBroken") title:nil];

}
*/



#pragma mark - Observer Method/Game Process
- (void)didGameTurnGuessStart:(GameMessage *)message
{
    PPDebug(@"<ShowDrawController>didGameTurnGuessStart");
    _guessCorrect = NO;
    [self startTimer];
    //make the show view can play the actions
    [showView cleanAllActions];
}


- (void)didUserQuitGame:(GameMessage *)message
{
    NSString *userId = [message userId];
    [self popUpRunAwayMessage:userId];
    [self updatePlayerAvatars];
    if ([self userCount] <= 1) {
        [self popupUnhappyMessage:NSLS(@"kAllUserQuit") title:nil];
    }
}
- (void)didGameTurnComplete:(GameMessage *)message
{
    PPDebug(@"<ShowDrawController>didGameTurnComplete");
    [self resetTimer];
    if (_viewIsAppear) {
        NSInteger gainCoin = [[message notification] turnGainCoins];
        UIImage *image = [showView createImage];
        ResultController *rc = [[ResultController alloc] initWithImage:image
                                                              wordText:self.word.text 
                                                                 score:gainCoin
                                                               correct:_guessCorrect 
                                                             isMyPaint:NO];
        
        [self.navigationController pushViewController:rc animated:YES];
        [rc release];
        [self updatePickViewsWithWord:nil lang:languageType];        
    }
    [showView cleanAllActions];
}



#pragma mark - Common Dialog Delegate

- (void)clickOk:(CommonDialog *)dialog
{
    //run away
    [dialog removeFromSuperview];
    [drawGameService quitGame];
    [HomeController returnRoom:self];
    [showView cleanAllActions];
    [self resetTimer];
}
- (void)clickBack:(CommonDialog *)dialog
{
    //stay
    [dialog removeFromSuperview];
}

#pragma mark - Actions
- (IBAction)clickGuessDoneButton:(id)sender {
    NSString *ans = [self getAnswer];
    BOOL flag = [ans isEqualToString:self.word.text];    
    //alter if the word is correct
    if (flag) {
        [self popupHappyMessage:NSLS(@"kGuessCorrect") title:nil];
        _guessCorrect = YES;
        [self setWordButtonsEnabled:NO];
        [self setAnswerButtonsEnabled];
        [self addScore:self.word.score toUser:drawGameService.userId];
    }else{
        [self popupUnhappyMessage:NSLS(@"kGuessWrong") title:nil];
        
    }
    [drawGameService guess:ans guessUserId:drawGameService.session.userId];
}

- (void)bomb:(id)sender
{
    NSString *result  = [WordManager bombCandidateString:self.candidateString word:self.word];
    [self updateAnswerViews];
    [self updateCandidateViewsWithText:result];
//    [toolView decreaseNumber];
    [[AccountService defaultService] consumeItem:ITEM_TYPE_TIPS amount:1];
    [toolView setNumber:[ItemManager defaultManager].tipsItemAmount];
    toolView.enabled = NO;
}

- (IBAction)clickRunAway:(id)sender {
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kQuitGameAlertTitle") message:NSLS(@"kQuitGameAlertMessage") style:CommonDialogStyleDoubleButton deelegate:self];
    [self.view addSubview:dialog];
}

- (void)clickWriteButton:(UIButton *)button
{
    NSString *text = [button titleForState:UIControlStateNormal];
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
- (void)clickPickingButton:(UIButton *)button
{
    NSString *text = [button titleForState:UIControlStateNormal];
    if ([text length] != 0) {
        UIButton *wButton = [self getTheFirstEmptyButton];
        if (wButton) {
            [wButton setTitle:text forState:UIControlStateNormal];
            [wButton setEnabled:YES];
            [button setEnabled:NO];
            [button setTitle:nil forState:UIControlStateNormal];            
        }
    }
    if (languageType != ChineseType) {
        NSString *ans = [self getAnswer];
        BOOL flag = [ans isEqualToString:self.word.text];
        if (flag) {
            [self clickGuessDoneButton:nil];
        }        
    }
}

@end
