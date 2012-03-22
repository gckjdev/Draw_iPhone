//
//  RoomController.m
//  Draw
//
//  Created by  on 12-3-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RoomController.h"
#import "DrawGameService.h"
#import "SelectWordController.h"
#import "ShowDrawController.h"
#import "GameSession.h"
#import "HJManagedImageV.h"
#import "PPApplication.h"
#import "DrawAppDelegate.h"
#import "UINavigationController+UINavigationControllerAdditions.h"
#import "PPDebug.h"
#import "GameSessionUser.h"
#import "GameMessage.pb.h"


@interface RoomController ()

- (void)updateGameUsers;
- (void)updateRoomName;
- (void)updateStartButton;

- (void)resetStartTimer;
- (void)scheduleStartTimer;
- (void)prolongStartTimer;

- (BOOL)isMyTurn;
- (NSInteger)userCount;

@end

@implementation RoomController

@synthesize prolongButton = _prolongButton;
@synthesize roomNameLabel;
@synthesize startGameButton;
@synthesize startTimer = _startTimer;

- (void)dealloc {
    [_startTimer release];
    [startGameButton release];
    [roomNameLabel release];
    [_prolongButton release];
    [super dealloc];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self resetStartTimer];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    self.roomNameLabel.text = @"";
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
}

- (void)viewDidAppear:(BOOL)animated
{    
    [[DrawGameService defaultService] registerObserver:self];
    [[DrawGameService defaultService] setRoomDelegate:self];
    [self updateGameUsers];
    [self updateRoomName];
    [self updateStartButton];
    
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self hideActivity];
    [super viewDidDisappear:animated];
    [[DrawGameService defaultService] unregisterObserver:self]; 
    PPDebug(@"<unregisterObserver> room controller");
}

- (void)viewDidUnload
{
    [[DrawGameService defaultService] unregisterObserver:self];
    [self setStartGameButton:nil];
    [self setRoomNameLabel:nil];
    [self setProlongButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - GUI Update Methods

- (void)updateGameUsers
{
    
    
    GameSession* session = [[DrawGameService defaultService] session];
    NSArray* userList = [session userList];
    int startTag = 21;
    int endTag = 26;
    int imageStartTag = 31;
    int imageEndTag = 32;
    
    for (GameSessionUser* user in userList){
//        UIButton* button = (UIButton*)[self.view viewWithTag:startTag++];
//        [button setTitle:[user userId] forState:UIControlStateNormal];
//        button.titleLabel.numberOfLines = 2;

        UILabel* label = (UILabel*)[self.view viewWithTag:startTag++];
        [label setText:[user userId]];
        
//        if ([session isHostUser:[user userId]]){
//            NSString* title = [NSString stringWithFormat:@"%@ (Host)", [user userId]];
////            [button setTitle:title forState:UIControlStateNormal];
//            [label setText:title];
//        }
        
        if ([session isMe:[user userId]]){
            NSString* title = [NSString stringWithFormat:@"%@ (Me)", [user userId]];
            [label setText:title];
//            [button setTitle:title forState:UIControlStateNormal];
        }

        if ([session isCurrentPlayUser:[user userId]]){
            [label setTextColor:[UIColor redColor]];
        }
        
        // set images
        HJManagedImageV* imageView = (HJManagedImageV*)[self.view viewWithTag:imageStartTag++];
        [imageView clear];
        [imageView setUrl:[NSURL URLWithString:[user userAvatar]]];
        [GlobalGetImageCache() manage:imageView];
    }
    
    // clean all data
    for (int i=startTag; i<=endTag; i++){
//        UIButton* button = (UIButton*)[self.view viewWithTag:i];
//        [button setTitle:@"" forState:UIControlStateNormal];
        UILabel* label = (UILabel*)[self.view viewWithTag:startTag++];
        [label setText:@""];
    }
    
    for (int i=imageStartTag; i<=imageEndTag; i++){
        HJManagedImageV* imageView = (HJManagedImageV*)[self.view viewWithTag:imageStartTag++];
        [imageView clear];
    }
    
    [self updateStartButton];
}

- (void)updateRoomName
{
    NSString* name = [NSString stringWithFormat:NSLS(@"Room %@"),  
                      [[[DrawGameService defaultService] session] roomName]];
    self.roomNameLabel.text = name;
}

- (void)updateStartButton
{
    if ([self isMyTurn]){
        NSString* title = [NSString stringWithFormat:NSLS(@"kClickToStart (%d)"), _currentTimeCounter];                           
        [self.startGameButton setTitle:title forState:UIControlStateNormal];
        [self.startGameButton setEnabled:YES];
        
        [self.prolongButton setTitle:NSLS(@"kWaitABit") forState:UIControlStateNormal];
    }
    else{
        NSString* title = [NSString stringWithFormat:NSLS(@"kStartAfter (%d)"), _currentTimeCounter];                           
        [self.startGameButton setTitle:title forState:UIControlStateNormal];
        [self.startGameButton setEnabled:NO];

        [self.prolongButton setTitle:NSLS(@"kQuickQuick") forState:UIControlStateNormal];
    }
    
    // one user cannot start...
    if ([self userCount] <= 1){
        [self.startGameButton setTitle:NSLS(@"kWaitForMoreUsers") forState:UIControlStateNormal];
        [self.startGameButton setEnabled:NO];        
    }
}

- (NSInteger)userCount
{
    GameSession* session = [[DrawGameService defaultService] session];
    NSArray* userList = [session userList];
    return [userList count];
}

#pragma mark - Draw Game Service Delegate

- (void)didJoinGame:(GameMessage *)message
{
    [self hideActivity];
    if ([message resultCode] == 0){
        [UIUtils alert:@"Join Game OK!"];
    }
    else{
        [UIUtils alert:[NSString stringWithFormat:@"Join Game Fail, Code = %d", [message resultCode]]];
    }

    // update 
    [self updateGameUsers];
    [self updateRoomName];    
    if ([self userCount] > 1) {
        [self scheduleStartTimer];        
    }else{
        [self resetStartTimer];
    }
}

- (void)didStartGame:(GameMessage *)message
{
    _hasClickStartGame = NO;
    [self hideActivity];
    
    if ([message resultCode] == 0){
        [self popupHappyMessage:@"Start Game OK!" title:@""];
    }
    else{
        [self popupHappyMessage:[NSString stringWithFormat:@"Start Game Fail, Code = %d", [message resultCode]] title:@""];
    }
    
    [self updateGameUsers];
    
    SelectWordController *sw = [[SelectWordController alloc] init];
    [self.navigationController pushViewController:sw animated:NO];
    [sw release];    

}

- (void)didGameStart:(GameMessage *)message
{
    _hasClickStartGame = NO;
    
    //TODO check if the user is the host. 
    [self updateGameUsers];    
    if (![self isMyTurn]) {
        ShowDrawController *sd = [ShowDrawController instance];
//        ShowDrawController *sd = [[[ShowDrawController alloc] init]autorelease];
        [self.navigationController pushViewController:sd animated:NO];        
    }
}

- (void)didNewUserJoinGame:(GameMessage *)message
{
    [self updateGameUsers];    
    if (self.startTimer == nil && [self userCount] > 1) {
        [self scheduleStartTimer];
    }
}

- (void)didUserQuitGame:(GameMessage *)message
{
    [self updateGameUsers];    
    if ([self userCount] > 1) {
        [self scheduleStartTimer];        
    }else{
        [self resetStartTimer];
    }
   
}

- (void)didGameAskQuick:(GameMessage *)message
{
    NSString* text = [NSString stringWithFormat:@"%@ says quick quick!", [message userId]];    
    [UIUtils alert:text];
}

- (void)didGameProlong:(GameMessage *)message
{
    // receive host prolong game message, prolong the timer
    if ([self isMyTurn] == NO){
        [self prolongStartTimer];
    }
}

#pragma mark - Core Methods

- (void)joinGame
{
    [self showActivityWithText:NSLS(@"kJoining")];
    
    [[DrawGameService defaultService] setRoomDelegate:self];
    [[DrawGameService defaultService] registerObserver:self];
    PPDebug(@"<registerObserver> room controller");
    
    [[DrawGameService defaultService] joinGame];        
}

- (void)startGame
{
    if (_hasClickStartGame){
        return;
    }
    
    [self resetStartTimer];
    
    _hasClickStartGame = YES;
    [self showActivityWithText:NSLS(@"kStartingGame")];
    [[DrawGameService defaultService] startGame];    
}

- (BOOL)isMyTurn
{
    return [[DrawGameService defaultService] isMyTurn];
}



#pragma mark - Button Click Action

- (IBAction)clickStart:(id)sender
{
    [self startGame];
}

- (IBAction)clickChangeRoom:(id)sender
{
    [self showActivityWithText:NSLS(@"kChangeRoom")];
    [[DrawGameService defaultService] changeRoom];
    
}

- (IBAction)clickProlongStart:(id)sender
{
    if ([self isMyTurn]){
        [self prolongStartTimer];
    }
    else{
        // TODO send an urge request
        [[DrawGameService defaultService] askQuickGame];
    }
}

#pragma mark - Room Enter/Return

+ (RoomController*)defaultInstance
{
    DrawAppDelegate* app = (DrawAppDelegate*)[[UIApplication sharedApplication] delegate];
    if (app.roomController == nil){    
        app.roomController = [[[RoomController alloc] init] autorelease];
    }
    
    return app.roomController;
}

+ (void)firstEnterRoom:(UIViewController*)superController
{
    DrawAppDelegate* app = (DrawAppDelegate*)[[UIApplication sharedApplication] delegate];
    if (app.roomController == nil){    
        app.roomController = [[[RoomController alloc] init] autorelease];
    }
    
    [superController.navigationController pushViewController:app.roomController 
                           animatedWithTransition:UIViewAnimationTransitionCurlUp];
    
    // update 
    if ([app.roomController userCount] > 1) {
        [app.roomController scheduleStartTimer];        
    }else{
        [app.roomController resetStartTimer];
    }    
    [app.roomController updateGameUsers];
    [app.roomController updateRoomName];    
}

+ (void)returnRoom:(UIViewController*)superController
{
    [superController.navigationController popToViewController:[RoomController defaultInstance] animated:YES];
    if ([[RoomController defaultInstance] userCount] > 1) {
        [[RoomController defaultInstance] scheduleStartTimer];        
    }else
    {
        [[RoomController defaultInstance] resetStartTimer];        
    }

}

#pragma mark - Timer Handling

#define START_TIMER_INTERVAL    (1)
#define PROLONG_INTERVAL        (10)
#define DEFAULT_START_TIME      (60)

- (void)resetStartTimer
{
    _currentTimeCounter = DEFAULT_START_TIME;
    [self updateStartButton];
    if (self.startTimer != nil){
        [self.startTimer invalidate];
        self.startTimer = nil;
    }
}

- (void)scheduleStartTimer
{
    [self resetStartTimer];
    self.startTimer = [NSTimer scheduledTimerWithTimeInterval:START_TIMER_INTERVAL
                                                       target:self 
                                                     selector:@selector(handleStartTimer:) 
                                                     userInfo:nil 
                                                      repeats:YES];
}

- (void)prolongStartTimer
{
    _currentTimeCounter += PROLONG_INTERVAL;
    if (_currentTimeCounter >= DEFAULT_START_TIME){
        _currentTimeCounter = DEFAULT_START_TIME;
    }
    
    // notice all other users
    if ([self isMyTurn]){
        [[DrawGameService defaultService] prolongGame];
    }
}

- (void)handleStartTimer:(id)sender
{
    _currentTimeCounter --;
    [self updateStartButton];    

    if (_currentTimeCounter <= 0){
        // start game directly!
        if ([self isMyTurn]){
            [self resetStartTimer];
            [self startGame];
        }
        else{
            // if you are not host, you have to wait again...
            [self scheduleStartTimer];
        }
    }
}

@end
