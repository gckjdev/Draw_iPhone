//
//  HomeController.m
//  Draw
//
//  Created by  on 12-3-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "HomeController.h"
#import "RoomController.h"
#import "UINavigationController+UINavigationControllerAdditions.h"
#import "DrawGameService.h"
#import "DrawAppDelegate.h"
#import "UserManager.h"
#import "PPDebug.h"
#import "GameMessage.pb.h"
#import "ShopMainController.h"
#import "CommonDialog.h"
#import "FeedbackController.h"
#import "UserSettingController.h"
#import "ShareController.h"

@implementation HomeController

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
    [super viewDidLoad];

    
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Do any additional setup after loading the view from its nib.
    
    // Start Game Service And Set User Id
    [[DrawGameService defaultService] setHomeDelegate:self];
    [[DrawGameService defaultService] setUserId:[[UserManager defaultManager] userId]];
    [[DrawGameService defaultService] setNickName:[[UserManager defaultManager] nickName]];    
    [[DrawGameService defaultService] setAvatar:[[UserManager defaultManager] avatarURL]];    
    
//    [[DrawGameService defaultService] connectServer];
}

- (void)viewDidAppear:(BOOL)animated
{
    [[DrawGameService defaultService] registerObserver:self];
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self hideActivity];
    [[DrawGameService defaultService] unregisterObserver:self];
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)clickStart:(id)sender
{        
    [self showActivityWithText:NSLS(@"kJoingGame")];
    
    if ([[DrawGameService defaultService] isConnected]){        
        [[DrawGameService defaultService] joinGame];    
    }
    else{
        [self showActivityWithText:@"kConnectingServer"];        
        [[DrawGameService defaultService] connectServer];
        _isTryJoinGame = YES;
    }
}

- (IBAction)clickShop:(id)sender {
    ShopMainController *sc = [[ShopMainController alloc] init];
    [self.navigationController pushViewController:sc animated:YES];
    [sc release];
}

- (IBAction)testDialog:(id)sender
{
    CommonDialog* dialog = [CommonDialog createDialogWithStyle:SINGLE_BUTTON];
    [self.view addSubview:dialog];
}

- (void)didJoinGame:(GameMessage *)message
{
    [self hideActivity];
    if ([message resultCode] == 0){
        [self popupHappyMessage:@"Join Game OK" title:@""];
    }
    else{
        NSString* text = [NSString stringWithFormat:@"Join Game Fail, Code = %d", [message resultCode]];
        [self popupUnhappyMessage:text title:@""];
    }

    [RoomController firstEnterRoom:self];
}

- (IBAction)clickFeedback:(id)sender
{
    FeedbackController* feedBack = [[FeedbackController alloc] init];
    [self.navigationController pushViewController:feedBack animated:YES];
    [feedBack release];
}

- (IBAction)clickSettings:(id)sender
{
    UserSettingController *settings = [[UserSettingController alloc] init];
    [self.navigationController pushViewController:settings animated:YES];
    [settings release];
}

- (IBAction)clickShare:(id)sender
{
    ShareController* share = [[ShareController alloc] init ];
    [self.navigationController pushViewController:share animated:YES];
    [share release];
}


- (void)didBroken
{
    _isTryJoinGame = NO;
    PPDebug(@"<didBroken>");
    [self hideActivity];
    [self popupUnhappyMessage:@"Network Failure, Connect Server Failure" title:@""];
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)didConnected
{
    [self hideActivity];
    [self popupHappyMessage:@"Server Connected" title:@""];
    if (_isTryJoinGame){
        [[DrawGameService defaultService] joinGame];    
    }
    
    _isTryJoinGame = NO;
    
}
+ (HomeController *)defaultInstance
{
    DrawAppDelegate* app = (DrawAppDelegate*)[[UIApplication sharedApplication] delegate];
    if (app.homeController == nil){    
        app.homeController = [[[HomeController alloc] init] autorelease];
    }
    
    return app.homeController;
}
+ (void)returnRoom:(UIViewController*)superController
{
    [superController.navigationController popToViewController:[HomeController defaultInstance] animated:YES];
}

@end
