//
//  DrawAppDelegate.m
//  Draw
//
//  Created by gamy on 12-3-4.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "DrawAppDelegate.h"

#import "DrawViewController.h"
#import "GameNetworkClient.h"
#import "DrawGameService.h"
#import "UserManager.h"
#import "HomeController.h"
#import "RegisterUserController.h"
#import "ShowDrawController.h"
#import "SinaSNSService.h"
#import "QQWeiboService.h"
#import "RouterService.h"
#import "AccountManager.h"
#import "AccountService.h"
#import "FacebookSNSService.h"
#import "PriceService.h"
#import "DeviceDetection.h"
#import "MobClick.h"

NSString* GlobalGetServerURL()
{    
 //   return @"http://you100.me:8001/api/i?";    
//    return @"http://106.187.89.232:8001/api/i?";    
    return @"http://192.168.1.10:8000/api/i?";    
}

@implementation DrawAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize roomController = _roomController;
@synthesize homeController = _homeController;
@synthesize reviewRequest = _reviewRequest;

- (void)dealloc
{
    [_reviewRequest release];
    [_homeController release];
    [_roomController release];
    [_window release];
    [_viewController release];
    [super dealloc];
}

- (void)updateDataFromServer
{
//    [[AccountManager defaultManager] updateAccountForServer];
}

- (void)initGlobalObjects
{
    [DrawViewController instance];
    [ShowDrawController instance];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    srand(time(0));
    [self initGlobalObjects];
    [self initImageCacheManager];
    [self updateDataFromServer];
        
    // Init SNS Service
    [[SinaSNSService defaultService] setAppKey:@"2831348933" Secret:@"ff89c2f5667b0199ee7a8bad6c44b265"];
//    [[SinaSNSService defaultService] setAppKey:@"2457135690" Secret:@"9886c6c3a5683950bad471b44f47a312"];
    [[QQWeiboService defaultService] setAppKey:@"801123669" Secret:@"30169d80923b984109ee24ade9914a5c"];        
    [[FacebookSNSService defaultService] setAppId:@"352182988165711" appKey:@"352182988165711" Secret:@"51c65d7fbef9858a5d8bc60014d33ce2"];
    
    
    // Init Account Service and Sync Balance and Item
    [[AccountService defaultService] syncAccountAndItem];
    
    // Init Home
    self.homeController = [[[HomeController alloc] init] autorelease];            
    
    // Push Setup
    BOOL isAskBindDevice = NO;
    if (![self isPushNotificationEnable]){
        isAskBindDevice = YES;
        [self bindDevice];
    }
    
    // Ask For Review
    if ([DeviceDetection isOS5]){
        self.reviewRequest = [ReviewRequest startReviewRequest:APP_ID appName:GlobalGetAppName() isTest:YES];
    }
    
    UINavigationController* navigationController = [[[UINavigationController alloc] initWithRootViewController:self.homeController] autorelease];
    navigationController.navigationBarHidden = YES;
    
    if ([[UserManager defaultManager] hasUser] == NO){
        [RegisterUserController showAt:self.homeController];
    }

    if ([DeviceDetection isOS5]){
        [self checkAppVersion:APP_ID];
    }
    else if (isAskBindDevice == NO){        
        [self checkAppVersion:APP_ID];
    }
    
    [MobClick startWithAppkey:@"4f83980852701565c500003a"]; // reportPolicy:BATCH channelId:@"91"];
    
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    
    // Fetch Server List At Background
    [[RouterService defaultService] fetchServerListAtBackground];
    [[PriceService defaultService] syncShoppingListAtBackground];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    
    [[RouterService defaultService] stopUpdateTimer];
    [[DrawGameService defaultService] startDisconnectTimer];
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
        sleep(60);
    });                       
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */

    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    [[DrawGameService defaultService] clearDisconnectTimer];

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

#pragma mark - Device Notification Delegate

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [[[FacebookSNSService defaultService] facebook] handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[[FacebookSNSService defaultService] facebook] handleOpenURL:url];
}

#pragma mark - Device Notification Delegate

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	
    //	if ([application enabledRemoteNotificationTypes] == UIRemoteNotificationTypeNone){
    //        [UIUtils alert:@"由于您未同意接受推送通知功能，团购购物推送通知功能无法正常使用"];
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
            [self openAppForUpgrade:APP_ID];
        }
    }
}



@end
