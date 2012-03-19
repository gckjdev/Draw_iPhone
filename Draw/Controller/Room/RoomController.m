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

@interface RoomController ()

- (void)updateGameUsers;

@end

@implementation RoomController
@synthesize roomNameLabel;
@synthesize startGameButton;

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
    [self updateGameUsers];
    
    [super viewDidAppear:animated];
}

- (void)joinGame
{
    [self showActivityWithText:NSLS(@"kJoining")];
    
    [[DrawGameService defaultService] setRoomDelegate:self];
    [[DrawGameService defaultService] registerObserver:self];

    [[DrawGameService defaultService] joinGame];    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self hideActivity];
    [super viewDidDisappear:animated];
    [[DrawGameService defaultService] unregisterObserver:self];    
}

- (void)viewDidUnload
{
    [[DrawGameService defaultService] unregisterObserver:self];
    [self setStartGameButton:nil];
    [self setRoomNameLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

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
        
        if ([session isHostUser:[user userId]]){
            NSString* title = [NSString stringWithFormat:@"%@ (Host)", [user userId]];
//            [button setTitle:title forState:UIControlStateNormal];
            [label setText:title];
        }
        
        if ([session isMe:[user userId]]){
            NSString* title = [NSString stringWithFormat:@"%@ (Me)", [user userId]];
            [label setText:title];
//            [button setTitle:title forState:UIControlStateNormal];
        }

        if ([session isCurrentPlayUser:[user userId]]){
            [label setTextColor:[UIColor redColor]];
//            [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
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
    
    [self.startGameButton setHidden:![[DrawGameService defaultService] isMeHost]];

}

- (void)updateRoomName
{
    NSString* name = [NSString stringWithFormat:NSLS(@"Room %@"),  
                      [[[DrawGameService defaultService] session] roomName]];
    self.roomNameLabel.text = name;
}

#pragma Draw Game Service Delegate

- (void)didJoinGame:(GameMessage *)message
{
    [self hideActivity];
    [UIUtils alert:@"Join Game OK!"];

    // update 
    [self updateGameUsers];
    [self updateRoomName];
}

- (void)didStartGame:(GameMessage *)message
{
    [self hideActivity];
    [self updateGameUsers];

    SelectWordController *sw = [[SelectWordController alloc] init];
    [self.navigationController pushViewController:sw animated:YES];
    [sw release];    

}

- (void)didGameStart:(GameMessage *)message
{
    
    //TODO check if the user is the host. 
    [self updateGameUsers];    
    if (![[DrawGameService defaultService] isMyTurn]) {
        ShowDrawController *sd = [[ShowDrawController alloc] init];
        [self.navigationController pushViewController:sd animated:YES];
        [sd release];
        
    }

//    SelectWordController *sw = [[SelectWordController alloc] init];
//    [self.navigationController pushViewController:sw animated:YES];
//    [sw release];    
}

- (void)didNewUserJoinGame:(GameMessage *)message
{
    [self updateGameUsers];    
}

- (void)didUserQuitGame:(GameMessage *)message
{
    [self updateGameUsers];    
}

- (IBAction)clickStart:(id)sender
{
    [self showActivityWithText:NSLS(@"kStartingGame")];
    [[DrawGameService defaultService] startGame];
    // Goto Select Word UI
}

- (IBAction)clickChangeRoom:(id)sender
{
    [self showActivityWithText:NSLS(@"kChangeRoom")];
    [[DrawGameService defaultService] changeRoom];
    
}

- (void)dealloc {
    [startGameButton release];
    [roomNameLabel release];
    [super dealloc];
}

+ (void)showRoom:(UIViewController*)superController
{
    DrawAppDelegate* app = (DrawAppDelegate*)[[UIApplication sharedApplication] delegate];
    if (app.roomController == nil){    
        app.roomController = [[[RoomController alloc] init] autorelease];
    }
    
    [superController.navigationController pushViewController:app.roomController 
                           animatedWithTransition:UIViewAnimationTransitionCurlUp];

    [app.roomController joinGame];
}

@end
