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

ShowDrawController *staticShowDrawController = nil;
ShowDrawController *GlobalGetShowDrawController()
{
    if (staticShowDrawController == nil) {
        staticShowDrawController = [[ShowDrawController alloc] init];
    }
    return staticShowDrawController;
}

#define GUESS_TIME 120

@implementation ShowDrawController
@synthesize guessDoneButton;
@synthesize clockLabel;
@synthesize popupButton;
@synthesize word = _word;
@synthesize candidateString = _candidateString;

- (void)dealloc
{
    [_word release];
    [_candidateString release];
    [guessDoneButton release];
    [clockLabel release];
    [popupButton release];
    [toolView release];
    [avatarArray release];
    [showView release];
    [super dealloc];
}

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

- (IBAction)clickRunAway:(id)sender {
    [drawGameService quitGame];
    [HomeController returnRoom:self];
}


+ (ShowDrawController *)instance
{
    return GlobalGetShowDrawController();
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

- (void)cleanAvatars
{
    //remove all the old avatars
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

- (UIButton *)getTheFirstEmptyButton
{
    NSInteger endIndex = (languageType == ChineseType) ? (WRITE_BUTTON_TAG_END - 1) : WRITE_BUTTON_TAG_END;
    for (int i = WRITE_BUTTON_TAG_START; i <= endIndex; ++ i) {
        UIButton *button = (UIButton *)[self.view viewWithTag:i];
        if ([[button titleForState:UIControlStateNormal] length] == 0) {
            return button;
        }
    }
    return nil;
}

- (void)initAnswerAndCadidateViews
{
    for (int i = WRITE_BUTTON_TAG_START; i <= WRITE_BUTTON_TAG_END; ++ i)
    {
        UIButton *button = (UIButton *)[self.view viewWithTag:i];
        [button addTarget:self action:@selector(clickWriteButton:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:nil forState:UIControlStateNormal];
        [self.view bringSubviewToFront:button];
    }
    for (int i = PICK_BUTTON_TAG_START; i <= PICK_BUTTON_TAG_END + 1; ++ i) {
        UIButton *button = (UIButton *)[self.view viewWithTag:i];
        [button setTitle:nil forState:UIControlStateNormal];
        [button addTarget:self action:@selector(clickPickingButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.view bringSubviewToFront:button];
    }
    [self.guessDoneButton setBackgroundImage:[shareImageManager orangeImage] forState:UIControlStateNormal];
    [self.guessDoneButton setTitle:NSLS(@"kSubmit") forState:UIControlStateNormal];
    [self.view bringSubviewToFront:guessDoneButton];
    
}

- (void)updateAnswerViews
{
    NSInteger endIndex = (languageType == ChineseType) ? (WRITE_BUTTON_TAG_END - 1) : WRITE_BUTTON_TAG_END;
    for (int i = WRITE_BUTTON_TAG_START; i <= endIndex; ++ i) {
        UIButton *button = (UIButton *)[self.view viewWithTag:i];     
        [button setEnabled:NO];
        [button setTitle:nil forState:UIControlStateNormal];
    }
    UIButton *lastButton = (UIButton *)[self.view 
                                        viewWithTag:WRITE_BUTTON_TAG_END];     
    if (languageType == ChineseType) {
        [guessDoneButton setHidden:NO];
        [guessDoneButton setEnabled:YES];
        lastButton.hidden = YES;
    }else{
        [guessDoneButton setHidden:YES];
        [lastButton setHidden:NO];
    }
}

- (void)updateCandidateViewsWithText:(NSString *)text
{
    self.candidateString = text;
    for (int i = PICK_BUTTON_TAG_START; i <= PICK_BUTTON_TAG_END; ++ i) {
        UIButton *button = (UIButton *)[self.view viewWithTag:i];
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

- (void)updatePickWordViews
{
    [self updateAnswerViews];
    [self updateCandidateViews];
}

- (void)updatePickViewsWithWord:(Word *)word lang:(LanguageType)lang
{
    
    NSString *upperString = [WordManager upperText:word.text];
    self.word = word;
    self.word.text = upperString;
    languageType = lang;
    [self updateCandidateViews];
    [self updateAnswerViews];
}


- (NSString *)getAnswer
{
    //get the word
    NSString *answer = @"";
    if (languageType == ChineseType) {
        
    }else{
        
    }
    NSInteger endIndex = (languageType == ChineseType) ? (WRITE_BUTTON_TAG_END - 1) : WRITE_BUTTON_TAG_END;
    for (int i = WRITE_BUTTON_TAG_START; i <= endIndex; ++ i) {
        UIButton *button = (UIButton *)[self.view viewWithTag:i];
        NSString *text = [button titleForState:UIControlStateNormal];
        if (text && [text length] == 1 && ![text isEqualToString:@" "]) {
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


#pragma mark CAAnimation delegate


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
- (void)resetTimer
{
    if (guessTimer && [guessTimer isValid]) {
        [guessTimer invalidate];
    }
    guessTimer = nil;
    retainCount = GUESS_TIME;
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
    [self.clockLabel setText:[NSString stringWithFormat:@"%d",retainCount]];
}


- (void)startTimer
{
    [self resetTimer];
    guessTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
}


- (id)init{
    self = [super init];
    if (self) {
        drawGameService = [DrawGameService defaultService];
        [drawGameService setDrawDelegate:self];
        showView = [[ShowDrawView alloc] initWithFrame:CGRectMake(8, 46, 304, 355)];   

    }
    return self;
}

- (void)resetData
{

    [showView cleanAllActions];
    [self setGuessAndPickButtonsEnabled:YES];
//    [self.guessDoneButton setEnabled:YES];
    retainCount = GUESS_TIME;
    [self.clockLabel setText:[NSString stringWithFormat:@"%d",retainCount]];
    [self updatePlayerAvatars];
    [self updateAnswerViews];
    [self updatePickViewsWithWord:self.word lang:languageType];
    gameCompleted = NO;
    [toolView setNumber:3];
    toolView.enabled = YES;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:showView];
    [self initAnswerAndCadidateViews];
    [self.popupButton setBackgroundImage:[shareImageManager popupImage] 
                                forState:UIControlStateNormal];
    [self.view addSubview:toolView];
    [toolView addTarget:self action:@selector(bomb:)];

}


- (void)viewDidAppear:(BOOL)animated
{
    [self resetData];
    [drawGameService registerObserver:self];
    [super viewDidAppear:animated];

}

- (void)viewDidDisappear:(BOOL)animated
{
    [drawGameService unregisterObserver:self];
    [self setWord:nil];
    [self updatePickViewsWithWord:nil lang:languageType];
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    [self setGuessDoneButton:nil];
    [self setClockLabel:nil];
    [self setPopupButton:nil];
    [super viewDidUnload];
    [self setWord:nil];
    showView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)alert:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:NSLS(@"kConfirm") otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

#pragma mark DrawGameServiceDelegate
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

- (void)addScore:(NSInteger)score toUser:(NSString *)userId
{
    AvatarView *avatarView = [self avatarViewForUserId:userId];
    [avatarView setScore:score];
    
}
- (void)didReceiveGuessWord:(NSString*)wordText guessUserId:(NSString*)guessUserId guessCorrect:(BOOL)guessCorrect
{
    if (![drawGameService.userId isEqualToString:guessUserId]) {
        if (!guessCorrect) {
            [self popGuessMessage:wordText userId:guessUserId];        
        }else{
            [self popGuessMessage:NSLS(@"kGuessCorrect") userId:guessUserId];
            [self addScore:self.word.level toUser:guessUserId];
        }
        
    }

}

- (void)didReceiveDrawWord:(NSString*)wordText level:(int)wordLevel language:(int)language
{
    if (wordText) {
        Word *word = [[[Word alloc] initWithText:wordText level:wordLevel]autorelease];
        
        LanguageType lang = [[UserManager defaultManager] getLanguageType];
        [self updatePickViewsWithWord:word lang:lang];
    }
}

- (void)didGameTurnGuessStart:(GameMessage *)message
{
    [self startTimer];
    [self setGuessAndPickButtonsEnabled:YES];
    [self.guessDoneButton setEnabled:YES];    
}
- (void)didGameTurnComplete:(GameMessage *)message
{
    if (!gameCompleted) {
        NSLog(@"Game is Complete");        
        gameCompleted = YES;
        [self resetTimer];
        UIImage *image = [showView createImage];
        ResultController *rc = [[ResultController alloc] initWithImage:image
                                                              wordText:self.word.text 
                                                                 score:self.word.score 
                                                        hasRankButtons:YES 
                                                             isMyPaint:NO];
        
        [self.navigationController pushViewController:rc animated:YES];
        [rc release];
        [self updatePickViewsWithWord:nil lang:languageType];
    }
}

- (void)didConnected
{
    [self alert:NSLS(@"connection recover")];
}
- (void)didBroken
{
    [self alert:NSLS(@"connection broken")];
}

- (NSInteger)userCount
{
    GameSession *session = [[DrawGameService defaultService] session];
    return [session.userList count];
}

- (void)didUserQuitGame:(GameMessage *)message
{
    NSString *userId = [message userId];
    [self popUpRunAwayMessage:userId];
    [self updatePlayerAvatars];
    if ([self userCount] <= 1) {
        [self alert:NSLS(@"kAllUserQuit")];
        [RoomController returnRoom:self startNow:NO];
    }
}

- (IBAction)clickGuessDoneButton:(id)sender {
    NSString *ans = [self getAnswer];
    BOOL flag = [ans isEqualToString:self.word.text];    
    //alter if the word is correct
    if (flag) {
        [self alert:NSLS(@"kGuessCorrect")];
        [self setGuessAndPickButtonsEnabled:NO];
    }else{
        [self alert:NSLS(@"kGuessWrong")];
    }
    [drawGameService guess:ans guessUserId:drawGameService.session.userId];
}

- (void)bomb:(id)sender
{
    NSString *result  = [WordManager bombCandidateString:self.candidateString word:self.word];
    [self updateAnswerViews];
    [self updateCandidateViewsWithText:result];
    
    [toolView decreaseNumber];
    toolView.enabled = NO;
}

@end
