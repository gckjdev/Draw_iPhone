//
//  DrawAppDelegate.m
//  Draw
//
//  Created by gamy on 12-3-4.
//  Copyright 2012Âπ?__MyCompanyName__. All rights reserved.
//

#import "DrawAppDelegate.h"

#import "OnlineDrawViewController.h"
#import "GameNetworkClient.h"
#import "DrawGameService.h"
#import "UserManager.h"
#import "HomeController.h"
#import "RegisterUserController.h"
#import "OnlineGuessDrawController.h"
#import "SinaSNSService.h"
#import "QQWeiboService.h"
#import "RouterService.h"
#import "AccountManager.h"
#import "AccountService.h"
#import "FacebookSNSService.h"
#import "PriceService.h"
#import "DeviceDetection.h"
#import "NetworkDetector.h"
#import "MobClick.h"
#import "TKAlertCenter.h"
#import "ConfigManager.h"
#import "AudioManager.h"
#import "FriendManager.h"
#import "MusicItemManager.h"
#import "CommonMessageCenter.h"
#import "MusicDownloadService.h"
#import "FriendService.h"
#import "UIUtils.h"
#import "LevelService.h"
#import "YoumiWallService.h"

NSString* GlobalGetServerURL()
{    
    return [ConfigManager getAPIServerURL];
  
//    return @"http://you100.me:8001/api/i?";        
//    return @"http://106.187.89.232:8001/api/i?";    
//    return @"http://192.168.1.9:8000/api/i?";    
}

NSString* GlobalGetTrafficServerURL()
{
//    return [ConfigManager getTrafficAPIServerURL];
    return @"http://192.168.1.13:8100/api/i?";    
}

@implementation DrawAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize roomController = _roomController;
@synthesize homeController = _homeController;
@synthesize reviewRequest = _reviewRequest;
@synthesize networkDetector = _networkDetector;
- (void)dealloc
{
    [_reviewRequest release];
    [_homeController release];
    [_roomController release];
    [_window release];
    [_viewController release];
    [super dealloc];
}



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    srand(time(0));
    
    application.applicationIconBadgeNumber = 0;
    
    [self initImageCacheManager];
    
    [WXApi registerApp:@"wx427a2f57bc4456d1"];
    
    //init sounds
    [[AudioManager defaultManager] initSounds:[NSArray arrayWithObjects:
                                               @"ding.wav", 
                                               @"dingding.mp3", 
                                               @"correct.mp3", 
                                               @"oowrong.mp3", 
                                               @"congratulations.mp3", nil]];
        
    // init mob click 
    [MobClick startWithAppkey:@"4f83980852701565c500003a" 
                 reportPolicy:BATCH 
                    channelId:[ConfigManager getChannelId]];
    [MobClick updateOnlineConfig];
    
    // Init SNS Service
    [[SinaSNSService defaultService] setAppKey:@"2831348933" 
                                        Secret:@"ff89c2f5667b0199ee7a8bad6c44b265"];
    [[QQWeiboService defaultService] setAppKey:@"801123669" 
                                        Secret:@"30169d80923b984109ee24ade9914a5c"];        
    [[FacebookSNSService defaultService] setAppId:@"352182988165711" 
                                           appKey:@"352182988165711" 
                                           Secret:@"51c65d7fbef9858a5d8bc60014d33ce2"];
    
    
    // Init Account Service and Sync Balance and Item
    [[AccountService defaultService] syncAccountAndItem];
    
    [[RouterService defaultService] fetchServerListAtBackground];    
    
    // Push Setup
    BOOL isAskBindDevice = NO;
    if (![self isPushNotificationEnable]){
        isAskBindDevice = YES;
        [self bindDevice];
    }
    
    // Ask For Review
    if ([ConfigManager isInReviewVersion] == NO){
        if ([DeviceDetection isOS5]){
            self.reviewRequest = [ReviewRequest startReviewRequest:DRAW_APP_ID appName:GlobalGetAppName() isTest:YES];
            self.reviewRequest.delegate = self;
        }
    }

    // Init Home Controller As Root View Controller
    self.homeController = [[[HomeController alloc] init] autorelease];     
    
    NSNotification *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    
    self.homeController.hasRemoveNotification = (notification != nil);
    
    UINavigationController* navigationController = [[[UINavigationController alloc] 
                                                     initWithRootViewController:self.homeController] 
                                                    autorelease];
    navigationController.navigationBarHidden = YES;

    // Try Fetch User Data By Device Id
    if ([[UserManager defaultManager] hasUser] == NO){
        [[UserService defaultService] loginByDeviceWithViewController:self.homeController];
    }


    // Check Whether App Has Update
    if ([DeviceDetection isOS5]){
        [self checkAppVersion:DRAW_APP_ID];
    }
    else if (isAskBindDevice == NO){        
        [self checkAppVersion:DRAW_APP_ID];
    }

    // Show Root View
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    
    // Fetch Server List At Background
    [[PriceService defaultService] syncShoppingListAtBackground];
    [[AccountService defaultService] retryVerifyReceiptAtBackground];
    
    // Detect Network Availability
    self.networkDetector = [[[NetworkDetector alloc] initWithErrorTitle:NSLS(@"kNetworkErrorTitle") ErrorMsg:NSLS(@"kNetworkErrorMessage") detectInterval:2] autorelease];
    [self.networkDetector start];

    // Show News If Exists
    [self performSelector:@selector(showNews) withObject:nil afterDelay:1.5];
    
    [[FriendManager defaultManager] removeAllDeletedFriends];

//    [HomeController defaultInstance].hasRemoveNotification = YES;//(obj != nil);
    
    //sync level details
    [[LevelService defaultService] syncExpAndLevel:SYNC];
    
    return YES;
}

- (void)reviewDone
{
    [self setReviewRequest:nil];
}

- (void)showNews
{
    if ([LocaleUtils isChina] == NO)
        return;
    
    NSString* news = [MobClick getConfigParams:@"NEWS"];
    if ([news length] <= 1)
        return;
    
    [[CommonMessageCenter defaultCenter] postMessageWithText:news delayTime:2.5 isHappy:YES];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    
    [[RouterService defaultService] stopUpdateTimer];
    [[DrawGameService defaultService] startDisconnectTimer];
    [self.networkDetector stop];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    
    UIApplication* app = [UIApplication sharedApplication];
    
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    
    // Start the long-running task and return immediately.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        sleep(60);
    });     
    
    [[AudioManager defaultManager] backgroundMusicStop];
    [[MusicItemManager defaultManager] saveMusicItems];

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    [[AudioManager defaultManager] backgroundMusicStart];
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    [[YoumiWallService defaultService] queryPoints];
    [[DrawGameService defaultService] clearDisconnectTimer];
    [self.networkDetector start];        
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    
    [[MusicItemManager defaultManager] saveMusicItems];

}

#pragma mark - Device Notification Delegate

- (BOOL)handleURL:(NSURL*)url
{
    if ([[url absoluteString] hasPrefix:@"wx"]){
        return [WXApi handleOpenURL:url delegate:self];;
    }
    return [[[FacebookSNSService defaultService] facebook] handleOpenURL:url];
}


- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url { 
    return [self handleURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [self handleURL:url];
}

#pragma mark - Device Notification Delegate

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	
    //	if ([application enabledRemoteNotificationTypes] == UIRemoteNotificationTypeNone){
    //        [UIUtils alert:@"?±‰??®Ê?????•Â??®È???????Ôº??Ë¥?¥≠?©Ê?????•Â??ΩÊ?Ê≥??Â∏∏‰Ωø??];
    //		return;
    //	}
	
    // Get a hex string from the device token with no spaces or < >	
	[self saveDeviceToken:deviceToken];    
    
    // user already register
    [[UserManager defaultManager] setDeviceToken:[self getDeviceToken]];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *) error {
	NSString *message = [error localizedDescription];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLS(@"Message")
													message: message
                                                   delegate: nil
                                          cancelButtonTitle: NSLS(@"OK")
                                          otherButtonTitles: nil];
    [alert show];
    [alert release];
	
	// try again
	// [self bindDevice];
}

- (void)showNotification:(NSDictionary*)payload
{
	NSDictionary *dict = [[payload objectForKey:@"aps"] objectForKey:@"alert"];
	NSString* msg = [dict valueForKey:@"loc-key"];
	NSArray*  args = [dict objectForKey:@"loc-args"];
	
	if (args != nil && [args count] >= 2){
		NSString* from = [args objectAtIndex:0];
		NSString* text = [args objectAtIndex:1];		
		[UIUtils alert:[NSString stringWithFormat:NSLS(msg), from, text]];
	}	
}

#pragma mark - Alert View Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == CHECK_APP_VERSION_ALERT_VIEW){
        if (buttonIndex == 1){
            [self openAppForUpgrade:DRAW_APP_ID];
        }
    }
}

-(void) onReq:(BaseReq*)req
{
    
}

-(void) onResp:(BaseResp*)resp
{
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        if (resp.errCode == WXSuccess){
            PPDebug(@"sucdess");
        }else {
            PPDebug(@"faile");
        }
    }
}

@end
