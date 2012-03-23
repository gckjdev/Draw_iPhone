//
//  ResultController.m
//  Draw
//
//  Created by  on 12-3-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ResultController.h"
#import "HomeController.h"
#import "RoomController.h"
#import "DrawGameService.h"
#import "GameConstants.h"

#define CONTINUE_TIME 1000

@implementation ResultController
@synthesize drawImage;
@synthesize upButton;
@synthesize downButton;
@synthesize continueButton;
@synthesize saveButton;
@synthesize exitButton;
@synthesize wordText;
@synthesize score;
@synthesize wordLabel;
@synthesize scoreLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        didGameStarted = NO;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (id)initWithImage:(UIImage *)image wordText:(NSString *)aWordText score:(NSInteger)aScore hasRankButtons:(BOOL)has
{
    self = [super init];
    if (self) {
        _image = image;
        [_image retain];
        self.wordText = aWordText;
        self.score = aScore;
        hasRankButtons = has;
    }
    return self;
}

- (void)updateContinueButton:(NSInteger)count
{
    [self.continueButton setTitle:[NSString stringWithFormat:NSLS(@"Continue(%d)"),count] forState:UIControlStateNormal];
}

- (void)resetTimer
{
    if (continueTimer && [continueTimer isValid]) {
            [continueTimer invalidate];
    }
    continueTimer = nil;
    retainCount = CONTINUE_TIME;
}

- (void)handleContinueTimer:(NSTimer *)theTimer
{
    -- retainCount;
    if (retainCount <= 0) {
        retainCount = 0;
        [self clickContinueButton:nil];
        return;
    }
    [self updateContinueButton:retainCount];
}

- (void)startTimer
{
    [self resetTimer];
    continueTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(handleContinueTimer:) userInfo:nil repeats:YES];
}

- (void)setUpAndDownButtonEnabled:(BOOL)enabled
{
    [upButton setEnabled:enabled];
    [downButton setEnabled:enabled];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.drawImage setImage:_image];
    [self.wordLabel setText:self.wordText];
    [self.scoreLabel setText:[NSString stringWithFormat:@"+%d",self.score]];

    [self startTimer];
    drawGameService = [DrawGameService defaultService];
    [self setUpAndDownButtonEnabled:YES];
    
    upButton.hidden = downButton.hidden = !hasRankButtons;
    NSLog(@"Result Controller view Did load");
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [drawGameService unregisterObserver:self];
    [drawGameService setRoomDelegate:nil];
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
        
    [drawGameService setRoomDelegate:self];
    [drawGameService registerObserver:self];
    [self.upButton setEnabled:YES];
    [self.downButton setEnabled:YES];
}

- (void)viewDidUnload
{
    [self setUpButton:nil];
    [self setDownButton:nil];
    [self setContinueButton:nil];
    [self setSaveButton:nil];
    [self setExitButton:nil];
    [self setDrawImage:nil];
    _image = nil;
    [self setWordLabel:nil];
    [self setScoreLabel:nil];
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [upButton release];
    [downButton release];
    [continueButton release];
    [saveButton release];
    [exitButton release];
    [drawImage release];
    [_image release];
    [wordText release];
    [wordLabel release];
    [scoreLabel release];
    [super dealloc];
}
- (IBAction)clickUpButton:(id)sender {
    [drawGameService rankGameResult:RANK_GOOD];
    [self setUpAndDownButtonEnabled:NO];
}

- (IBAction)clickDownButton:(id)sender {
    [drawGameService rankGameResult:RANK_BAD];
    [self setUpAndDownButtonEnabled:NO];
}

- (IBAction)clickContinueButton:(id)sender {
    [self resetTimer];
    [RoomController returnRoom:self startNow:didGameStarted];
}

- (IBAction)clickSaveButton:(id)sender {
    UIImageWriteToSavedPhotosAlbum(_image, nil, nil, nil);
}

- (IBAction)clickExitButton:(id)sender {
    [[DrawGameService defaultService] quitGame];
    [HomeController returnRoom:self];
}
- (void)didGameStart:(GameMessage *)message
{
    NSLog(@"<ResultController>: didGameStart");
    didGameStarted = YES;
//    [self.navigationController popViewControllerAnimated:YES];

}


- (void)didReceiveRank:(NSNumber*)rank fromUserId:(NSString*)userId
{
    if (rank.integerValue == RANK_BAD) {
        NSLog(@"%@ give you an egg", userId);
    }else{
        NSLog(@"%@ give you a flower", userId);
    }
}


@end
