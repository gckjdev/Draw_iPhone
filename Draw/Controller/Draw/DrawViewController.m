//
//  DrawViewController.m
//  Draw
//
//  Created by gamy on 12-3-4.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "DrawViewController.h"
#import "DrawView.h"
#import "DrawGameService.h"
#import "DrawColor.h"
#import "GameMessage.pb.h"
#import "Word.h"
#import "PickColorView.h"
#import "PickLineWidthView.h"
#import "GameSessionUser.h"
#import "GameSession.h"
#import "LocaleUtils.h"
#import "AnimationManager.h"
#import "ResultController.h"
#import "HJManagedImageV.h"
#import "PPApplication.h"
#import "RoomController.h"
#import "ShowDrawController.h"
#import "ShareImageManager.h"
#import "ColorView.h"

DrawViewController *staticDrawViewController = nil;
DrawViewController *GlobalGetDrawViewController()
{
    if (staticDrawViewController == nil) {
        staticDrawViewController = [[DrawViewController alloc] init];
    }
    return staticDrawViewController;
}

@implementation DrawViewController
@synthesize popupButton;
@synthesize eraserButton;
@synthesize guessMsgLabel;
@synthesize wordLabel;
@synthesize clockButton;
@synthesize cleanButton;
@synthesize penButton;
@synthesize word = _word;

#define DRAW_TIME 60

- (void)dealloc
{

    [_word release];
    [eraserButton release];
    [guessMsgLabel release];
    [wordLabel release];
    [clockButton release];
    [cleanButton release];
    [penButton release];
    [pickPenView release];
    [popupButton release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

+ (DrawViewController *)instance
{
    return GlobalGetDrawViewController();
}

#pragma mark - View lifecycle


#define PLAYER_BUTTON_TAG_START 1
#define PLAYER_BUTTON_TAG_END 6

//- (void)bringAllViewsToFront
//{
//    for (int i = PLAYER_BUTTON_TAG_START; i <= PLAYER_BUTTON_TAG_END; ++ i) {
//        UIView *button = [self.view viewWithTag:i];
//        [self.view bringSubviewToFront:button];
//    }
//    [self.view bringSubviewToFront:guessMsgLabel];
//    [self.view bringSubviewToFront:clockButton];
//    [self.view bringSubviewToFront:drawView];
//}



- (void)setToolButtonEnabled:(BOOL)enabled
{
    [eraserButton setEnabled:enabled];
    [cleanButton setEnabled:enabled];
    [drawView setDrawEnabled:enabled];
    [penButton setEnabled:enabled];
    [pickPenView setHidden:YES];
}

- (NSInteger)userCount
{
    GameSession *session = [[DrawGameService defaultService] session];
    return [session.userList count];
}

- (UIButton *)playerButtonForUserId:(NSString *)userId
{
    NSInteger i = PLAYER_BUTTON_TAG_START;
    NSInteger tag = -1;
    GameSession *session = [[DrawGameService defaultService] session];
    for (GameSessionUser *user in session.userList) {
        if([user.userId isEqualToString:userId])
        {
            tag = i;
        }
        ++ i;
    }
    if (tag != -1 && tag <= PLAYER_BUTTON_TAG_END) {
        return (UIButton *)[self.view viewWithTag:tag];
    }
    return nil;

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



- (void)resetTimer
{
    if (drawTimer && [drawTimer isValid]) {
        [drawTimer invalidate];
    }
    drawTimer = nil;
    retainCount = DRAW_TIME;
}
- (void)handleTimer:(NSTimer *)theTimer
{
    --retainCount;
    if (retainCount <= 0) {
        [self resetTimer];
        retainCount = 0;
        [self setToolButtonEnabled:NO];
    }
    NSString *second = [NSString stringWithFormat:@"%d",retainCount];
    [self.clockButton setTitle:second forState:UIControlStateNormal];
}


- (void)startTimer
{
    [self resetTimer];
    drawTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
}

- (id)init{
    self = [super init];
    if (self) {
        drawGameService = [DrawGameService defaultService];
        drawView = [[DrawView alloc] initWithFrame:CGRectMake(8, 46, 304, 355)];   
        pickPenView = [[PickPenView alloc] initWithFrame:CGRectMake(8, 280, 304, 120)];
        pickPenView.delegate = self;
    }
    return self;
}

- (void)resetData
{
    [drawView clearAllActions];
    drawGameService.drawDelegate = self;
    [self.guessMsgLabel setHidden:YES];
    [pickPenView setHidden:YES];
    [self.wordLabel setText:self.word.text];
    retainCount = DRAW_TIME;
    NSString *second = [NSString stringWithFormat:@"%d",retainCount];
    [self.clockButton setTitle:second forState:UIControlStateNormal];
    [self makePlayerButtons];
    [self startTimer];
    [self setToolButtonEnabled:YES];
    gameComplete = NO;
}
- (void)initPickPenView
{
    [self.view addSubview:pickPenView];
    NSMutableArray *widthArray = [[NSMutableArray alloc] init];
    NSMutableArray *colorViewArray = [[NSMutableArray alloc] init];
    for (int i = 20; i >= 5 ;i -= 5) {
        NSNumber *number = [NSNumber numberWithInt:i];
        [widthArray addObject:number];
    }
    [pickPenView setLineWidths:widthArray];
    [widthArray release];
    
    [colorViewArray addObject:[ColorView blackColorView]];
    [colorViewArray addObject:[ColorView redColorView]];
    [colorViewArray addObject:[ColorView yellowColorView]];
    [colorViewArray addObject:[ColorView blueColorView]];
    [colorViewArray addObject:[ColorView redColorView]];
    [colorViewArray addObject:[ColorView yellowColorView]];
    [colorViewArray addObject:[ColorView blueColorView]];

    [pickPenView setColorViews:colorViewArray];
    [colorViewArray release];
}
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    NSLog(@"<DrawViewController>: viewDidLoad");
    [super viewDidLoad];
    drawView.delegate = self;
    [self.view addSubview:drawView];
    [self initPickPenView];
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    [self.popupButton setBackgroundImage:[imageManager popupImage] forState:UIControlStateNormal];
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
    [drawGameService setDrawDelegate:[ShowDrawController instance]];
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{

    [self setWord:nil];
    [self setEraserButton:nil];
    [self setGuessMsgLabel:nil];
    [self setWordLabel:nil];
    [self setClockButton:nil];
    [self setCleanButton:nil];
    [self setPenButton:nil];
    [self setPopupButton:nil];
    [super viewDidUnload];
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


- (IBAction)clickRedraw:(id)sender {
    [drawGameService cleanDraw];
    [drawView addCleanAction];
    [pickPenView setHidden:YES];
}

- (IBAction)clickEraserButton:(id)sender {
    [drawView setLineColor:[DrawColor whiteColor]];
    [pickPenView setHidden:YES];
}

- (IBAction)clickPenButton:(id)sender {
    [pickPenView setHidden:!pickPenView.hidden];
}

- (void)didDrawedPaint:(Paint *)paint
{

    NSInteger intColor  = [DrawUtils compressDrawColor:paint.color];    
    NSMutableArray *pointList = [[[NSMutableArray alloc] init] autorelease];
    for (NSValue *pointValue in paint.pointList) {
        CGPoint point = [pointValue CGPointValue];
        NSNumber *pointNumber = [NSNumber numberWithInt:[DrawUtils compressPoint:point]];
        [pointList addObject:pointNumber];
    }
    
    [[DrawGameService defaultService]sendDrawDataRequestWithPointList:pointList color:intColor width:paint.width];
}

- (void)didStartedTouch
{
    [pickPenView setHidden:YES];
}

- (void)popUpGuessMessage:(NSString *)message
{
    [self.guessMsgLabel setText:message];
    [self.guessMsgLabel setHidden:NO];
    [self.view bringSubviewToFront:self.guessMsgLabel];
    [AnimationManager popUpView:self.guessMsgLabel fromPosition:CGPointMake(160, 335) toPosition:CGPointMake(160, 235) interval:2 delegate:self];
}



- (void)didReceiveGuessWord:(NSString*)wordText guessUserId:(NSString*)guessUserId guessCorrect:(BOOL)guessCorrect
{
    if (![drawGameService.userId isEqualToString:guessUserId]) {
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


- (void)didGameTurnComplete:(GameMessage *)message
{
    if (!gameComplete) {
        gameComplete = YES;
        NSLog(@"Game is Complete");
        UIImage *image = [drawView createImage];
//        ResultController *rc = [[ResultController alloc] initWithImage:image 
//                                                             paintList:drawView.paintList
//                                                              wordText:self.word.text 
//                                                                 score:self.word.score 
//                                                        hasRankButtons:NO];
//        
//        [self.navigationController pushViewController:rc animated:YES];
//        [rc release];
        [self resetTimer];
    }
}

- (void)didUserQuitGame:(GameMessage *)message
{
    NSString *nickName = [[drawGameService session]getNickNameByUserId:[message userId]];
    NSString *quitText = [NSString stringWithFormat:@"%@ quit!",nickName];
    [self makePlayerButtons];
    [self popUpGuessMessage:quitText];
    if ([self userCount] <= 1) {
        [self alert:NSLS(@"all users quit")];
    }
    [RoomController returnRoom:self startNow:NO];
    
}
#pragma mark pick view delegate
- (void)didPickedColorView:(ColorView *)colorView
{
    NSLog(@"did didPickedColorView");
    [drawView setLineColor:colorView.drawColor];
}
- (void)didPickedLineWidth:(NSInteger)width
{
    [drawView setLineWidth:width];
}
- (void)didPickedMoreColor
{
    //present a buy color controller;
}

#pragma mark CAAnimation delegate
//animation delegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [self.guessMsgLabel setHidden:YES];
}

@end
