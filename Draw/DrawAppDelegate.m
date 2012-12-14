
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
#import "RouterService.h"
#import "AccountManager.h"
#import "AccountService.h"
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
//#import "YoumiWallService.h"
#import "ChatDetailController.h"
#import "NotificationManager.h"
#import "LmWallService.h"
#import "UserStatusService.h"
//#import "FacetimeService.h"
#import "DiceGameService.h"
//#import "DiceFontManager.h"
#import "WordManager.h"
#import "DiceFontManager.h"
#import "DiceSoundManager.h"
#import "DiceHomeController.h"
#import "CommonHelpManager.h"
#import "BoardService.h"

#import "PPResourcePackage.h"
#import "PPResourceService.h"
#import "PPResourceTestViewController.h"
#import "FeedManager.h"

#import "MyPaintManager.h"

#import "PPSNSIntegerationService.h"
#import "PPSinaWeiboService.h"
#import "PPTecentWeiboService.h"
#import "PPFacebookService.h"

#import "GameConfigDataManager.h"
#import "ZJHHomeViewController.h"

NSString* GlobalGetServerURL()
{    
//    return [ConfigManager getAPIServerURL];
    return @"http://192.168.1.9:8000/api/i?";
//    return @"http://192.168.1.198:8000/api/i?";
}

NSString* GlobalGetTrafficServerURL()
{
//    return [ConfigManager getTrafficAPIServerURL];
    return @"http://192.168.1.9:8100/api/i?";
//    return @"http://192.168.1.198:8100/api/i?";
}

NSString* GlobalGetBoardServerURL()
{
    return [ConfigManager getTrafficAPIServerURL];
//    return @"http://192.168.1.13:8100/api/i?";    
}

@implementation DrawAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize roomController = _roomController;
@synthesize homeController = _homeController;
@synthesize reviewRequest = _reviewRequest;
@synthesize networkDetector = _networkDetector;
@synthesize chatDetailController = _chatDetailController;
@synthesize diceHomeController = _diceHomeController;

- (void)dealloc
{
    [_diceHomeController release];
    [_reviewRequest release];
    [_homeController release];
    [_roomController release];
    [_window release];
    [_viewController release];
    [_chatDetailController release];
    [super dealloc];
}



- (void)weiboTest
{
    // test image
    NSString* imagePath = @"/Users/qqn_pipi/Library/Application Support/iPhone Simulator/6.0/Applications/C9E97DA6-3CAB-4075-9903-B2584730D7E7/Library/Caches/ImageCache/7bfbb47435afe434611f332d56cce462";
    
    [[PPSNSIntegerationService defaultService] publishWeiboToAll:[NSString stringWithFormat:@"人生 %d", rand() % 10]
                                                   imageFilePath:imagePath
                                                    successBlock:^(int snsType, PPSNSCommonService *snsService, NSDictionary *userInfo) {
                                                        PPDebug(@"%@ publish weibo succ", [snsService snsName]);
                                                    }
                                                    failureBlock:^(int snsType, PPSNSCommonService *snsService, NSError *error) {
                                                        PPDebug(@"%@ publish weibo failure", [snsService snsName]);
                                                    }];
    
    
//    [[[PPSNSIntegerationService defaultService] snsServiceByType:TYPE_SINA] publishWeibo:@"人生" imageFilePath:imagePath successBlock:^(NSDictionary *userInfo) {
////     [sinaWeiboService publishWeibo:@"人生就是这样子" imageFilePath:nil successBlock:^(NSDictionary *userInfo) {
//        PPDebug(@"sina weibo publish ok");
//     } failureBlock:^(NSError *error) {
//         PPDebug(@"sina weibo publish failure");
//     }];

    
    /*
    [sinaWeiboService followUser:@"欢乐大话骰" successBlock:^(NSDictionary *userInfo) {
        PPDebug(@"sina follow user ok");
    } failureBlock:^(NSError *error) {
        PPDebug(@"sina follow user failure");
    }];
    
    [qqWeiboService followUser:@"liardice" successBlock:^(NSDictionary *userInfo) {
        PPDebug(@"qq follow user ok");
    } failureBlock:^(NSError *error) {
        PPDebug(@"qq follow user failure");
    }];
    */
    
    
    //    [qqWeiboService publishWeibo:@"人生" imageFilePath:imagePath successBlock:^(NSDictionary *userInfo) {
    //    [qqWeiboService publishWeibo:@"人生就是这样子" imageFilePath:nil successBlock:^(NSDictionary *userInfo) {
    //        PPDebug(@"qq weibo publish ok");
    //    } failureBlock:^(NSError *error) {
    //        PPDebug(@"qq weibo publish failure");
    //    }];
}

- (void)testResourcePackage
{
     NSSet* resourcePackages1 = [NSSet setWithObjects:
     [PPResourcePackage resourcePackageWithName:@"common_core" type:PPResourceImage],
     [PPResourcePackage resourcePackageWithName:@"draw_core" type:PPResourceImage],
     [PPResourcePackage resourcePackageWithName:@"dice_core" type:PPResourceImage],
     nil];
     
     NSSet* resourcePackages2 = [NSSet setWithObjects:
     [PPResourcePackage resourcePackageWithName:@"dice_beautiful" type:PPResourceImage],
     [PPResourcePackage resourcePackageWithName:@"dice_music" type:PPResourceImage],
     [PPResourcePackage resourcePackageWithName:@"dice_voice" type:PPResourceImage],
     [PPResourcePackage resourcePackageWithName:@"dice_help" type:PPResourceImage],
     nil];
     
     [[PPResourceService defaultService] addExplicitResourcePackage:resourcePackages1];
     [[PPResourceService defaultService] addImplicitResourcePackage:resourcePackages2];
     
     PPResourceTestViewController* resourceTestController = [[[PPResourceTestViewController alloc] init] autorelease];
     self.window.rootViewController = resourceTestController;
}

- (void)initSNSService
{
    PPSinaWeiboService* sinaWeiboService = [[[PPSinaWeiboService alloc] initWithAppKey:[GameApp sinaAppKey]
                                                                            appSecret:[GameApp sinaAppSecret]
                                                                       appRedirectURI:[GameApp sinaAppRedirectURI]
                                                                      officialWeiboId:[GameApp sinaWeiboId]] autorelease];
    PPTecentWeiboService* qqWeiboService = [[[PPTecentWeiboService alloc] initWithAppKey:[GameApp qqAppKey]
                                                                              appSecret:[GameApp qqAppSecret]
                                                                         appRedirectURI:[GameApp qqAppRedirectURI]
                                                                        officialWeiboId:[GameApp qqWeiboId]] autorelease];
    PPFacebookService* facebookService = [[[PPFacebookService alloc] initWithAppKey:[GameApp facebookAppKey]
                                                                         appSecret:[GameApp facebookAppSecret]
                                                                    appRedirectURI:nil
                                                                   officialWeiboId:nil] autorelease];
    
    
    [[PPSNSIntegerationService defaultService] addSNS:sinaWeiboService];
    [[PPSNSIntegerationService defaultService] addSNS:qqWeiboService];
    [[PPSNSIntegerationService defaultService] addSNS:facebookService];    
}

- (void)initResourceService
{
    NSSet* explicitsResourcePackages = [NSSet setWithObjects:
                                        [PPResourcePackage resourcePackageWithName:RESOURCE_PACKAGE_COMMON type:PPResourceImage],
                                        [PPResourcePackage resourcePackageWithName:RESOURCE_PACKAGE_ZJH type:PPResourceImage],
                                        [PPResourcePackage resourcePackageWithName:RESOURCE_PACKAGE_DICE type:PPResourceImage],
                                        [PPResourcePackage resourcePackageWithName:RESOURCE_PACKAGE_DRAW type:PPResourceImage],
                                        nil];
    
    NSSet* implicitResourcePackages = [NSSet setWithObjects:
                                       [PPResourcePackage resourcePackageWithName:RESOURCE_PACKAGE_ZJH_AUDIO type:PPResourceAudio],
                                       nil];
    
    [[PPResourceService defaultService] addExplicitResourcePackage:explicitsResourcePackages];
    [[PPResourceService defaultService] addImplicitResourcePackage:implicitResourcePackages];
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    srand(time(0));
    
    application.applicationIconBadgeNumber = 0;

    
    if (isDrawApp()) {
        [WordManager defaultManager];
    } else if (isDiceApp()){
        [DiceFontManager unZipFiles];
    }
    
    [[CommonHelpManager defaultManager] unzipHelpFiles];
    
    [self initImageCacheManager];
    
    if ([GameApp supportWeixin] == YES){
        PPDebug(@"Init Weixin SDK");
        [WXApi registerApp:@"wx427a2f57bc4456d1"];
    }
    
    // TODO Check whether this is required or not?
    /*
    NSArray* drawSoundArray = [NSArray arrayWithObjects:
                                @"ding.m4a", 
                                @"dingding.mp3", 
                                @"correct.mp3", 
                                @"oowrong.mp3", 
                                @"congratulations.mp3", 
                                @"rolling.mp3",
                               @"open.aiff", nil];
    NSArray* diceArray = [[DiceSoundManager defaultManager] diceSoundNameArray];
    if (isDrawApp()){
        [[AudioManager defaultManager] initSounds:drawSoundArray];        
    }
    else{
        [[AudioManager defaultManager] initSounds:[drawSoundArray arrayByAddingObjectsFromArray:diceArray]];        
    }
    */
        
    // init mob click 
    [MobClick startWithAppkey:[GameApp umengId]
                 reportPolicy:BATCH 
                    channelId:[ConfigManager getChannelId]];
    [MobClick updateOnlineConfig];
    
    // Init Account Service and Sync Balance and Item
    [[AccountService defaultService] syncAccount:nil forceServer:YES];
    
    if (isDrawApp()){
        [[RouterService defaultService] fetchServerListAtBackground];    
    }
    
    // Push Setup
    BOOL isAskBindDevice = NO;
    if (![self isPushNotificationEnable]){
        isAskBindDevice = YES;
        [self bindDevice];
    }
    
    // Ask For Review
    if ([ConfigManager isInReviewVersion] == NO){
        if ([DeviceDetection isOS5]){
            self.reviewRequest = [ReviewRequest startReviewRequest:[ConfigManager appId] appName:GlobalGetAppName() isTest:YES];
            self.reviewRequest.delegate = self;
        }
    }

    // Init Home Controller As Root View Controller
    PPViewController* rootController = nil;
    if (isDiceApp()){
        self.diceHomeController = [[[DiceHomeController alloc] init] autorelease];
        rootController = _diceHomeController;
    }else if (isZhajinhuaApp())
    {
        ZJHHomeViewController *controller = [[[ZJHHomeViewController alloc] init] autorelease];
        rootController = controller;
    }else{
        self.homeController = [[[HomeController alloc] init] autorelease];
        rootController = _homeController;
    }
    
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    NotificationType type = [NotificationManager typeForUserInfo:userInfo];
    
    PPDebug(@"<AppDelegate> notification type = %d", type);
    self.homeController.notificationType = type;
    
    UINavigationController* navigationController = [[[UINavigationController alloc] 
                                                     initWithRootViewController:rootController] 
                                                    autorelease];
    navigationController.navigationBarHidden = YES;

    // Try Fetch User Data By Device Id
    if ([[UserManager defaultManager] hasUser] == NO){
        [[UserService defaultService] loginByDeviceWithViewController:rootController];
    }


    // Check Whether App Has Update
    if ([DeviceDetection isOS5]){
        [self checkAppVersion:[ConfigManager appId]];
    }
    else if (isAskBindDevice == NO){        
        [self checkAppVersion:[ConfigManager appId]];
    }
    
    // Show Root View
    self.window.rootViewController = navigationController;
    
    // Init Resource Service
//    [self initResourceService];
    
    // Init SNS service
    [self initSNSService];    
    
    [self.window makeKeyAndVisible];
    
    // Fetch Server List At Background
    [[PriceService defaultService] syncShoppingListAtBackground];
    [[AccountService defaultService] retryVerifyReceiptAtBackground];
    
    // Detect Network Availability
    self.networkDetector = [[[NetworkDetector alloc] initWithErrorTitle:NSLS(@"kNetworkErrorTitle") ErrorMsg:NSLS(@"kNetworkErrorMessage") detectInterval:2] autorelease];
    [self.networkDetector start];

    // Show News If Exists
    [self performSelector:@selector(showNews) withObject:nil afterDelay:1.5];
    
//    [HomeController defaultInstance].hasRemoveNotification = YES;//(obj != nil);
    
    //sync level details
    [[LevelService defaultService] syncExpAndLevel:SYNC];
    
//    [GameConfigDataManager createTestConfigData];  
//    [GameConfigDataManager defaultInstance];

    
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
    
    NSString* news = @"";
    if ([ConfigManager isProVersion]){
        news = [MobClick getConfigParams:@"NEWS_PRO"];
    }
    else{
        news = [MobClick getConfigParams:@"NEWS"];
    }
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
    [[DiceGameService defaultService] startDisconnectTimer];
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
    
    [[UserStatusService defaultService] stop];
//    [[FacetimeService defaultService] disconnectServer];
    
//    [[FriendManager defaultManager] removeAllDeletedFriends];
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    [[AudioManager defaultManager] backgroundMusicStart];

    //update the statistic
    // rem by Benson due to ViewDidAppear also called it
//    if (_homeController) {
//        [[UserService defaultService] getStatistic:_homeController];        
//    }
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    [[BoardService defaultService] syncBoards];
    
    if ([ConfigManager wallEnabled]){
        [[LmWallService defaultService] queryScore];            
    }
    
    [[DrawGameService defaultService] clearDisconnectTimer];
    [[DiceGameService defaultService] clearDisconnectTimer];
    [self.networkDetector start];     
    
    [[UserStatusService defaultService] start];
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    
    [[MusicItemManager defaultManager] saveMusicItems];
    [[MyPaintManager defaultManager] removeAlldeletedPaints];
    [[FeedManager defaultManager] removeOldCache];
//    [Feed]
}

#pragma mark - Device Notification Delegate

- (BOOL)handleURL:(NSURL*)url
{
    if ([[url absoluteString] hasPrefix:@"wx"]){
        return [WXApi handleOpenURL:url delegate:self];;
    }
    else if ([[PPSNSIntegerationService defaultService] handleOpenURL:url]){
    }

    return YES;
}


- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url { 
    return [self handleURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [self handleURL:url];
}

#pragma mark - Device Notification Delegate

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	
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

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo 
{
    //test
    PPDebug(@"didReceiveRemoteNotification");
    NSArray *testAllKeys = [userInfo allKeys];
    for (NSString *key in testAllKeys) {
        PPDebug(@"<didReceiveRemoteNotification> loc-key=%@", key);
    }
    PPDebug(@"<didReceiveRemoteNotification> aps=%@", [userInfo objectForKey:@"aps"]);
    
    [[NotificationManager defaultManager] saveStatistic:userInfo];
    [_homeController updateAllBadge];
    
    NotificationType type = [NotificationManager typeForUserInfo:userInfo];
    if (type == NotificationTypeMessage && _chatDetailController) {
        [_chatDetailController loadNewMessage];
    }
    
    [[NotificationManager defaultManager] showNotification:userInfo];
}

#pragma mark - Alert View Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == CHECK_APP_VERSION_ALERT_VIEW){
        if (buttonIndex == 1){
            [self openAppForUpgrade:[ConfigManager appId]];
        }
    }
}

-(void) onReq:(BaseReq*)req
{
    [self.homeController enterShareFromWeixin];
}

-(void) onResp:(BaseResp*)resp
{
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        if (resp.errCode == WXSuccess){
            [UIUtils alert:@"已成功分享至微信"];
            PPDebug(@"<onResp> weixin response success");
        }else {
            PPDebug(@"<onResp> weixin response fail");
        }
    }
}

@end
