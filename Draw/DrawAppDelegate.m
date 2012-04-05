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

NSString* GlobalGetServerURL()
{    
//    return @"http://106.187.89.232:8001/api/i?";    
    return @"http://192.168.1.198:8000/api/i?";    
}

@implementation DrawAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize roomController = _roomController;
@synthesize homeController = _homeController;

- (void)dealloc
{
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
    [[QQWeiboService defaultService] setAppKey:@"801123669" Secret:@"30169d80923b984109ee24ade9914a5c"];        
    
    // Init Account Service and Sync Balance and Item
    [[AccountService defaultService] syncAccountAndItem];
    
    // Init Home
    self.homeController = [[[HomeController alloc] init] autorelease];    
    
    UINavigationController* navigationController = [[[UINavigationController alloc] initWithRootViewController:self.homeController] autorelease];
    navigationController.navigationBarHidden = YES;
    
    if ([[UserManager defaultManager] hasUser] == NO){
        [RegisterUserController showAt:self.homeController];
    }

    
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    
    [[RouterService defaultService] stopUpdateTimer];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
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
    
    // Fetch Server List At Background
    [[RouterService defaultService] startUpdateTimer];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}



@end
