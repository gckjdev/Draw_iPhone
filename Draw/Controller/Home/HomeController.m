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
#import "TrafficServer.h"
#import "Reachability.h"
#import "ShareImageManager.h"
#import "AccountService.h"
#import "CommonDialog.h"

@implementation HomeController
@synthesize startButton = _startButton;
@synthesize shopButton = _shopButton;
@synthesize shareButton = _shareButton;
@synthesize checkinButton = _checkinButton;
@synthesize settingButton = _settingButton;
@synthesize feedbackButton = _feedbackButton;

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
    [self setBackgroundImageName:@"home.png"];

    [super viewDidLoad];

    
    // setup button images
    UIImage* buttonImage = [[ShareImageManager defaultManager] woodImage];
    [self.startButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.shareButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.shopButton  setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    // set text
    [self.startButton setTitle:NSLS(@"kStart") forState:UIControlStateNormal];
    [self.shareButton setTitle:NSLS(@"kShare") forState:UIControlStateNormal];
    [self.shopButton  setTitle:NSLS(@"kShop") forState:UIControlStateNormal];
    [self.checkinButton setTitle:NSLS(@"kCheckin") forState:UIControlStateNormal];
    
    [self.settingButton setImage:[UIImage imageNamed:SETTING_BUTTON_IMAGE] forState:UIControlStateNormal];
    [self.settingButton setTitle:NSLS(@"kSettings") forState:UIControlStateNormal];
    
    [self.feedbackButton setImage:[UIImage imageNamed:FEEDBACK_BUTTON_IMAGE] forState:UIControlStateNormal];
    [self.feedbackButton setTitle:NSLS(@"kFeedback") forState:UIControlStateNormal];

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
    [[RouterService defaultService] fetchServerListAtBackground];
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
    [self setStartButton:nil];
    [self setShopButton:nil];
    [self setShareButton:nil];
    [self setCheckinButton:nil];
    [self setSettingButton:nil];
    [self setFeedbackButton:nil];
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
        [[RouterService defaultService] tryFetchServerList:self];        
    }
}



- (IBAction)clickShop:(id)sender {
    ShopMainController *sc = [[ShopMainController alloc] init];
    [self.navigationController pushViewController:sc animated:YES];
    [sc release];
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
        [[DrawGameService defaultService] disconnectServer];
        [[RouterService defaultService] putServerInFailureList:[[DrawGameService defaultService] serverAddress]
                                                          port:[[DrawGameService defaultService] serverPort]];
        return;
    }

    [RoomController firstEnterRoom:self];
}

- (IBAction)clickFeedback:(id)sender
{
    FeedbackController* feedBack = [[FeedbackController alloc] init];
    [self.navigationController pushViewController:feedBack animated:YES];
    [feedBack release];
}

- (IBAction)clickCheckIn:(id)sender
{
    int coins = [[AccountService defaultService] checkIn];
    NSString* message = nil;
    if (coins > 0){        
        message = [NSString stringWithFormat:NSLS(@"kCheckInMessage"), coins];
    }
    else{
        message = NSLS(@"kCheckInAlreadyToday");
    }
    CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"kCheckInTitle") 
                                                       message:message
                                                         style:CommonDialogStyleSingleButton 
                                                     deelegate:self];    
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
    
    //        // disable this policy at this moment...
//    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable){
//        [[RouterService defaultService] putServerInFailureList:[[DrawGameService defaultService] serverAddress]
//                                                          port:[[DrawGameService defaultService] serverPort]];
//    }
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

- (void)didServerListFetched:(int)result
{
    TrafficServer* server = [[RouterService defaultService] assignTrafficServer];
    if (server == nil){
        [self hideActivity];
        [UIUtils alert:NSLS(@"kNoServerAvailable")];
        return;
    }

    [[DrawGameService defaultService] setServerAddress:server.serverAddress];
    [[DrawGameService defaultService] setServerPort:server.port];    
//    [[DrawGameService defaultService] setServerAddress:@"192.168.1.198"];
//    [[DrawGameService defaultService] setServerPort:8080];    
    [[DrawGameService defaultService] connectServer];
    _isTryJoinGame = YES;
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

- (void)dealloc {
    [_startButton release];
    [_shopButton release];
    [_shareButton release];
    [_checkinButton release];
    [_settingButton release];
    [_feedbackButton release];
    [super dealloc];
}
@end
