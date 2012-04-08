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
#import "Reachability.h"
#import "ShareImageManager.h"
#import "AccountService.h"
#import "CommonDialog.h"
#import "FacebookSNSService.h"
#import "ItemShopController.h"
#import "RouterTrafficServer.h"

@implementation HomeController
@synthesize startButton = _startButton;
@synthesize shopButton = _shopButton;
@synthesize shareButton = _shareButton;
@synthesize checkinButton = _checkinButton;
@synthesize settingButton = _settingButton;
@synthesize feedbackButton = _feedbackButton;
@synthesize settingsLabel = _settingsLabel;
@synthesize feedbackLabel = _feedbackLabel;

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
//    [self setBackgroundImageName:@"home.png"];

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
    
    if ([[LocaleUtils getLanguageCode] isEqualToString:@"zh-Hans"]){
        self.checkinButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    }
    else{
        self.checkinButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];        
    }
    
    self.feedbackLabel.text = NSLS(@"kFeedback");
    self.settingsLabel.text = NSLS(@"kSettings");

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
    [UIApplication sharedApplication].idleTimerDisabled = NO;
//    [[RouterService defaultService] fetchServerListAtBackground];
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
    [self setSettingsLabel:nil];
    [self setFeedbackLabel:nil];
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
    [self showActivityWithText:NSLS(@"kJoiningGame")];
    
    if ([[DrawGameService defaultService] isConnected]){        
        [[DrawGameService defaultService] joinGame];    
    }
    else{
        
        [self showActivityWithText:NSLS(@"kConnectingServer")];        
        [[RouterService defaultService] tryFetchServerList:self];        
    }
}



- (IBAction)clickShop:(id)sender {
//    ShopMainController *sc = [[ShopMainController alloc] init];
//    [self.navigationController pushViewController:sc animated:YES];
//    [sc release];
    
    ItemShopController *ic = [ItemShopController instance];
    [self.navigationController pushViewController:ic animated:YES];

}



- (void)didJoinGame:(GameMessage *)message
{
    [self hideActivity];
    if ([message resultCode] == 0){
        [self popupHappyMessage:NSLS(@"kJoinGameSucc") title:@""];
    }
    else{
        NSString* text = [NSString stringWithFormat:NSLS(@"kJoinGameFailure")];
        [self popupUnhappyMessage:text title:@""];
        [[DrawGameService defaultService] disconnectServer];
//        [[RouterService defaultService] putServerInFailureList:[[DrawGameService defaultService] serverAddress]
//                                                          port:[[DrawGameService defaultService] serverPort]];
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
    
    [dialog showInView:self.view];
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
    [self popupUnhappyMessage:NSLS(@"kNetworkFailure") title:@""];
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
    [self showActivityWithText:NSLS(@"kJoiningGame")];
    if (_isTryJoinGame){
        [[DrawGameService defaultService] joinGame];    
    }
    
    _isTryJoinGame = NO;
    
}

- (void)didServerListFetched:(int)result
{
    RouterTrafficServer* server = [[RouterService defaultService] assignTrafficServer];
    if (server == nil){
        [self hideActivity];
        CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"Message") message:NSLS(@"kNoServerAvailable") style:CommonDialogStyleSingleButton deelegate:nil];
        [dialog showInView:self.view];
        return;
    }

//    [[DrawGameService defaultService] setServerAddress:server.address];
//    [[DrawGameService defaultService] setServerPort:[server.port intValue]];    
    [[DrawGameService defaultService] setServerAddress:@"192.168.1.198"];
    [[DrawGameService defaultService] setServerPort:8080];    
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
    [_settingsLabel release];
    [_feedbackLabel release];
    [super dealloc];
}
@end
