//
//  ShowDrawController.m
//  Draw
//
//  Created by  on 12-3-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ShowDrawController.h"
#import "DrawView.h"
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
@synthesize guessMsgLabel;
@synthesize guessDoneButton;
@synthesize clockLabel;
@synthesize word = _word;

- (void)dealloc
{
    [_word release];
    [candidateString release];
    [guessMsgLabel release];
    [guessDoneButton release];
    [clockLabel release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.word = nil;
    }
    return self;
}

- (IBAction)clickRunAway:(id)sender {
    [drawGameService quitGame];
    [HomeController returnRoom:self];
//    [HomeController 
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
#define WRITE_BUTTON_TAG_END 17
#define PICK_BUTTON_TAG_START 21
#define PICK_BUTTON_TAG_END 36
#define PLAYER_BUTTON_TAG_START 1
#define PLAYER_BUTTON_TAG_END 6


- (void)bringAllViewsToFront
{
    for (int i = WRITE_BUTTON_TAG_START; i <= WRITE_BUTTON_TAG_END; ++ i) {
        UIButton *button = (UIButton *)[self.view viewWithTag:i];
        [self.view bringSubviewToFront:button];
    }
    
    for (int i = PLAYER_BUTTON_TAG_START; i <= PLAYER_BUTTON_TAG_END; ++ i) {
        UIButton *button = (UIButton *)[self.view viewWithTag:i];
        [self.view bringSubviewToFront:button];
    }
    for (int i = PICK_BUTTON_TAG_START; i <= PICK_BUTTON_TAG_END; ++ i) {
        UIButton *button = (UIButton *)[self.view viewWithTag:i];
        [self.view bringSubviewToFront:button];
    }
    [self.view bringSubviewToFront:self.clockLabel];
    [self.view bringSubviewToFront:self.guessMsgLabel];
    [self.view bringSubviewToFront:self.guessDoneButton];
}

- (UIButton *)getTheFirstEmptyButton
{
    for (int i = WRITE_BUTTON_TAG_START; i <= WRITE_BUTTON_TAG_END; ++ i) {
        UIButton *button = (UIButton *)[self.view viewWithTag:i];
        if ([[button titleForState:UIControlStateNormal] length] == 0) {
            return button;
        }
    }
    return nil;
}



- (NSString *)getAnswer
{
    //get the word
    NSString *ans = @"";
    for (int i = WRITE_BUTTON_TAG_START; i <= WRITE_BUTTON_TAG_END; ++ i) {
        UIButton *button = (UIButton *)[self.view viewWithTag:i];
        NSString *text = [button titleForState:UIControlStateNormal];
        if (text) {
            ans = [NSString stringWithFormat:@"%@%@",ans,text];
        }
    }
    return ans;
}


- (UIButton *)getTheCandidateButtonForText:(NSString *)text
{
    for (int i = 0; i < [candidateString length]; ++ i) {
        NSString *sub = [candidateString substringWithRange:NSMakeRange(i, 1)];
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
            [button setTitle:nil forState:UIControlStateNormal];            
        }
    }
    NSLog(@"createImage");

}



- (void)makeWriteButtons
{
    for (int i = WRITE_BUTTON_TAG_START; i <= WRITE_BUTTON_TAG_END; ++ i) {
        UIButton *button = (UIButton *)[self.view viewWithTag:i];
        [button addTarget:self action:@selector(clickWriteButton:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:nil forState:UIControlStateNormal];
//        [self.view bringSubviewToFront:button];
    }
}

- (void)makePickingButtons
{
    
    candidateString = [[WordManager defaultManager] randLetterWithWord:self.word count:16];
    [candidateString retain];
    for (int i = PICK_BUTTON_TAG_START; i <= PICK_BUTTON_TAG_END; ++ i) {
        UIButton *button = (UIButton *)[self.view viewWithTag:i];
        [button addTarget:self action:@selector(clickPickingButton:) forControlEvents:UIControlEventTouchUpInside];
        if (candidateString != nil) {
            NSString *string = [candidateString substringWithRange:NSMakeRange(i - PICK_BUTTON_TAG_START, 1)];
            [button setTitle:string forState:UIControlStateNormal];
        }else{
            [button setTitle:nil forState:UIControlStateNormal];
        }
    }
}

- (void)makePlayerButtons
{
    for (int i = PLAYER_BUTTON_TAG_START; i <= PLAYER_BUTTON_TAG_END; ++ i) {
        UIButton *button = (UIButton *)[self.view viewWithTag:i];
        button.hidden = YES;
        for (UIView *view in button.subviews) {
            [view removeFromSuperview];
        }
    }
    int i = 1;
    GameSession *session = [[DrawGameService defaultService] session];
    for (GameSessionUser *user in session.userList) {
        UIButton *button = (UIButton *)[self.view viewWithTag:i];
        button.hidden = NO;
        [button setTitle:user.userId forState:UIControlStateNormal];
        ++ i;
        HJManagedImageV* imageView = [[HJManagedImageV alloc] initWithFrame:button.bounds];
        [imageView clear];
        [imageView setUrl:[NSURL URLWithString:[user userAvatar]]];
        [GlobalGetImageCache() manage:imageView];
        [button addSubview:imageView];
        [imageView release];
    }
}

- (void)popUpGuessMessage:(NSString *)message
{
    [self.guessMsgLabel setText:message];
    [self.guessMsgLabel setHidden:NO];
    [self.view bringSubviewToFront:self.guessMsgLabel];
    [AnimationManager popUpView:self.guessMsgLabel fromPosition:CGPointMake(160, 335) toPosition:CGPointMake(160, 235) interval:2 delegate:self];
}

#pragma mark CAAnimation delegate
//animation delegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [self.guessMsgLabel setHidden:YES];
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


- (void)resetWord:(Word *)word
{
    self.word = word;
    [self makeWriteButtons];
    [self makePickingButtons];
}

- (id)init{
    self = [super init];
    if (self) {
        drawGameService = [DrawGameService defaultService];
        [drawGameService setDrawDelegate:self];
        showView = [[DrawView alloc] initWithFrame:CGRectMake(0, 87, 320, 330)];
        [showView setDrawEnabled:NO];
    }
    return self;
}

- (void)resetData
{
//    [showView removeFromSuperview];
//    [showView release];

    [showView clear];
    [self setGuessAndPickButtonsEnabled:YES];
    [self.guessDoneButton setEnabled:YES];
    retainCount = GUESS_TIME;
    [self.clockLabel setText:[NSString stringWithFormat:@"%d",retainCount]];
    [self makePlayerButtons];
    [self resetWord:self.word];
    [self.guessMsgLabel setHidden:YES];

    [self.view sendSubviewToBack:showView];
    gameCompleted = NO;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:showView];
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
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    [self setGuessMsgLabel:nil];
    [self setGuessDoneButton:nil];
    [self setClockLabel:nil];
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
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:NSLS(@"confirm") otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

#pragma mark DrawGameServiceDelegate
- (void)didReceiveDrawData:(GameMessage *)message
{
    Paint *paint = [[Paint alloc] initWithGameMessage:message];
    [showView addPaint:paint play:YES];
}
- (void)didReceiveRedrawResponse:(GameMessage *)message
{
    [showView clear];
}


- (void)didReceiveGuessWord:(NSString*)wordText guessUserId:(NSString*)guessUserId guessCorrect:(BOOL)guessCorrect
{
    if (![drawGameService.userId isEqualToString:guessUserId]) {
        //alert the answer;
        
        NSString *nickName = [[drawGameService session]getNickNameByUserId:guessUserId];
        
        if (!guessCorrect) {
            [self popUpGuessMessage:[NSString stringWithFormat:NSLS(@"%@ : \"%@\""), 
                                     nickName, wordText]];            
        }else{
            [self popUpGuessMessage:[NSString stringWithFormat:NSLS(@"%@ guesss correct!"), 
                                     nickName]];
        }
        
    }

}

- (void)didReceiveDrawWord:(NSString*)wordText level:(int)wordLevel
{
    if (wordText) {
        Word *word = [[[Word alloc] initWithText:wordText level:wordLevel]autorelease];
        [self resetWord:word];
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
                                                        hasRankButtons:YES];
        
        [self.navigationController pushViewController:rc animated:YES];
        [rc release];
        [self resetWord:nil];        
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

- (void)didUserQuitGame:(GameMessage *)message
{
    NSString *nickName = [[drawGameService session]getNickNameByUserId:[message userId]];
    NSString *quitText = [NSString stringWithFormat:@"%@ quit!",nickName];
    [self makePlayerButtons];
    [self popUpGuessMessage:quitText];
}

- (IBAction)clickGuessDoneButton:(id)sender {
    NSString *ans = [self getAnswer];
    BOOL flag = [ans isEqualToString:self.word.text];
    
    //alter if the word is correct
    if (flag) {
        [self alert:NSLS(@"Correct!")];
    }else{
        [self alert:NSLS(@"Wrong")];
    }
    
    [drawGameService guess:ans guessUserId:drawGameService.session.userId];
    //send the word to the server
}
@end
