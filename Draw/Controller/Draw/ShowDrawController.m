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
@implementation ShowDrawController
@synthesize word = _word;

- (void)dealloc
{
    [_word release];
    [candidateString release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
#define PLAYER_BUTTON_TAG_START 1
#define PLAYER_BUTTON_TAG_END 6


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
        //TODO set the title nil, and reset the picking button.
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
        //TODO find out the empty button and set the button title.
        UIButton *wButton = [self getTheFirstEmptyButton];
        [wButton setTitle:text forState:UIControlStateNormal];
        [button setTitle:nil forState:UIControlStateNormal];
    }
}



- (void)makeWriteButtons
{
    for (int i = WRITE_BUTTON_TAG_START; i <= WRITE_BUTTON_TAG_END; ++ i) {
        UIButton *button = (UIButton *)[self.view viewWithTag:i];
        [button addTarget:self action:@selector(clickWriteButton:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)makePickingButtons
{
    
    candidateString = [[WordManager defaultManager] randLetterWithWord:self.word];
    [candidateString retain];
    NSLog(@"candidate String = %@", candidateString);
    for (int i = PICK_BUTTON_TAG_START; i <= PICK_BUTTON_TAG_END; ++ i) {
        UIButton *button = (UIButton *)[self.view viewWithTag:i];
        [button addTarget:self action:@selector(clickPickingButton:) forControlEvents:UIControlEventTouchUpInside];
        NSString *string = [candidateString substringWithRange:NSMakeRange(i - PICK_BUTTON_TAG_START, 1)];
        [button setTitle:string forState:UIControlStateNormal];
    }
}

- (void)makePlayerButtons
{
    for (int i = PLAYER_BUTTON_TAG_START; i <= PLAYER_BUTTON_TAG_END; ++ i) {
        UIButton *button = (UIButton *)[self.view viewWithTag:i];
        button.hidden = YES;
    }
    int i = 1;
    GameSession *session = [[DrawGameService defaultService] session];
    for (GameSessionUser *user in session.userList) {
        UIButton *button = (UIButton *)[self.view viewWithTag:i];
        button.hidden = NO;
        NSLog(@"userId = %@", user.userId);
        [button setTitle:user.userId forState:UIControlStateNormal];
        ++ i;
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"猜词中"];
    showView = [[DrawView alloc] initWithFrame:CGRectMake(0, 100, 320, 200)];
    [self.view addSubview:showView];
    [showView release];
    [showView setDrawEnabled:NO];
    drawGameService = [DrawGameService defaultService];
    [drawGameService setDrawDelegate:self];
    
    [self makeWriteButtons];
//    [self makePickedButtons];
    [self makePlayerButtons];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self setWord:nil];
    showView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//- (id)initWithWord:(Word *)word
//{
//    self = [super init];
//    if (self) {
//        self.word = word;
//    }
//    return self;
//}

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


- (void)didReceiveDrawWord:(NSString*)wordText level:(int)wordLevel
{
    self.word = [[[Word alloc] initWithText:wordText level:wordLevel]autorelease];
    [self makePickingButtons];
}

- (void)didConnected
{
    
}
- (void)didBroken
{
    
}

- (void)didUserQuitGame:(GameMessage *)message
{
    
}


@end
