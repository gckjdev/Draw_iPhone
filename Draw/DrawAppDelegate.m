
//
//  DrawAppDelegate.m
//  Draw
//
//  Created by gamy on 12-3-4.
//  Copyright 2012Âπ?__MyCompanyName__. All rights reserved.
//



#import "DrawAppDelegate.h"
#import "MLNavigationController.h"
#import "OnlineDrawViewController.h"
#import "GameNetworkClient.h"
#import "DrawGameService.h"
#import "UserManager.h"
#import "HomeController.h"
#import "OnlineGuessDrawController.h"
#import "AccountManager.h"
#import "AccountService.h"
#import "PriceService.h"
#import "DeviceDetection.h"
#import "NetworkDetector.h"
#import "MobClickUtils.h"
#import "PPConfigManager.h"
#import "AudioManager.h"
#import "FriendManager.h"
#import "CommonMessageCenter.h"
#import "FriendService.h"
#import "UIUtils.h"
#import "LevelService.h"
#import "ChatDetailController.h"
#import "NotificationManager.h"
#import "UserStatusService.h"
#import "WordManager.h"
#import "CommonHelpManager.h"

#import "PPResourcePackage.h"
#import "PPResourceService.h"
#import "FeedManager.h"

#import "MyPaintManager.h"
#import "AppTaskManager.h"

#import <UMCommon/UMCommon.h>

#import "GameConfigDataManager.h"
#import "BulletinService.h"
#import "PPSmartUpdateDataUtils.h"

#import "BBSService.h"
#import "DrawBgManager.h"
#import "GameItemService.h"
#import "IAPProductService.h"
#import "SKProductService.h"
#import "ShareController.h"

#import "DrawUtils.h"
#import "ImageShapeManager.h"
#import "UserDeviceService.h"

#import "WordFilterService.h"
#import "GuessService.h"
#import "CPMotionRecognizingWindow.h"

#import "LocalNotificationUtil.h"
#import "TimeUtils.h"
#import "BackgroundMusicPlayer.h"
#import "GuessManager.h"

#import "GameSNSService.h"
#import "GroupService.h"
#import "IQKeyBoardManager.h"
//#import "ZeroQianManager.h"

#import "OpusClassInfoManager.h"

//#import "DMSplashAdController.h"
#import "OpenCVUtils.h"

#import "OpenCVUtils.h"
#import "TutorialCoreManager.h"
#import "BillboardManager.h"

#import "FileUtil.h"

NSString* GlobalGetServerURL()
{

#ifdef DEBUG
//    return @"http://localhost:8000/api/i?";
//    return @"http://43.247.90.45:8002/api/i?";
//    return @"http://192.168.1.13:8001/api/i?";
//    return @"http://43.247.90.45:8001/api/i?";
//    return @"http://192.168.1.198:8000/api/i?";
//    return @"http://43.247.90.45:8888/api/i?";
//
//    NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
//    NSString* str = [def objectForKey:@"api_server"];
//    if (str && str.length > 5) {
//        PPDebug(@"<for test!!!!!!> get api server %@", str);
//        return [NSString stringWithFormat:@"http://%@/api/i?",str];
//    }

    return @"http://43.247.90.45:8001/api/i?";
    
#endif
    
    
    
    return [PPConfigManager getAPIServerURL];
}

NSString* GlobalGetTrafficServerURL()
{

#ifdef DEBUG
//    NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
//    NSString* str = [def objectForKey:@"traffic_server"];
//    if (str && str.length > 5) {
//        PPDebug(@"<for test!!!!!!> get traffic server %@", str);
//        return [NSString stringWithFormat:@"http://%@/api/i?",str];
//    }
#endif
    

#ifdef DEBUG
    
//    return @"http://localhost:8100/api/i?";

//    return @"http://192.168.1.8:8100/api/i?";
    
    
//    return @"http://43.247.90.45:8699/api/i?";
    return @"http://43.247.90.45:8100/api/i?";
    
    
    

//    return @"http://43.247.90.45:8037/api/i?";
//    return @"http://192.168.1.198:8100/api/i?";
//      return @"http://58.215.172.169:8037/api/i?";
//    return @"http://192.168.1.198:8100/api/i?";
//    return @"http://58.215.172.169:8037/api/i?";

//    return @"http://192.168.1.198:8100/api/i?";
//    return @"http://58.215.172.169:8037/api/i?";
    
//    return @"http://192.168.1.3:8100/api/i?";
//    return @"http://192.168.1.12:8100/api/i?";
#endif
    
    return [PPConfigManager getTrafficAPIServerURL];
}

NSString* GlobalGetMessageServerURL()
{
    return [PPConfigManager getMessageServerURL];
}

NSString* GlobalGetBBSServerURL()
{
    return [PPConfigManager getBBSServerURL];
}


NSString* GlobalGetBoardServerURL()
{
    return [PPConfigManager getTrafficAPIServerURL];
}

@implementation DrawAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize roomController = _roomController;
@synthesize homeController = _homeController;
@synthesize reviewRequest = _reviewRequest;
@synthesize networkDetector = _networkDetector;
@synthesize chatDetailController = _chatDetailController;

- (void)dealloc
{
    PPRelease(_rootNavigationController);
    PPRelease(_reviewRequest);
    PPRelease(_homeController);
    PPRelease(_roomController);
    PPRelease(_window);
    PPRelease(_viewController);
    PPRelease(_chatDetailController);
    [super dealloc];
}

- (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *) filePathString
{
    NSURL* URL= [NSURL fileURLWithPath: filePathString];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath: [URL path]]){
        return NO;
    }
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        PPDebug(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    else{
        PPDebug(@"Success excluding %@ from backu", [URL lastPathComponent]);
        
    }
    return success;
}

- (void)excludeBakcupDir
{
    NSMutableArray* dirs = [NSMutableArray array];
    [dirs addObject:[FileUtil filePathInAppDocument:@"avatar"]];
    [dirs addObject:[FileUtil filePathInAppDocument:@"PAGE_BG"]];
    [dirs addObject:[FileUtil filePathInAppDocument:@"BBS_BG"]];
    [dirs addObject:[FileUtil filePathInAppDocument:@"tencent_analysis_qc.db"]];
    [dirs addObject:[FileUtil filePathInAppDocument:@"TCSdkConfig.plist"]];
    [dirs addObject:[FileUtil filePathInAppDocument:@"TutorialImage"]];
    [dirs addObject:[FileUtil filePathInAppDocument:@"config_data"]];
    [dirs addObject:[FileUtil filePathInAppDocument:@"copy_paint.png"]];
    [dirs addObject:[FileUtil filePathInAppDocument:@"AlixPay-RSAPrivateKey"]];
    [dirs addObject:[FileUtil filePathInAppDocument:@"draw_bg_normal"]];
//    [dirs addObject:[FileUtil filePathInAppDocument:@"AlixPay-RSAPrivateKey"]];
//    [dirs addObject:[FileUtil filePathInAppDocument:@"AppDB.sqlite-wal"]];
//    [dirs addObject:[FileUtil filePathInAppDocument:@"AlixPay-RSAPrivateKey"]];
    
    for (NSString* dir in dirs){
        [self addSkipBackupAttributeToItemAtPath:dir];
    }
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    [DrawUtils testSpendTime];
    //Enabling keyboard manager(Use this line to enable managing distance between keyboard & textField/textView).
    
    
//    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:181 green:261 blue:245 alpha:1.0]];
    [self excludeBakcupDir];
    
    [IQKeyBoardManager installKeyboardManager];
    [IQKeyBoardManager disableKeyboardManager];
    
    // TODO check benson
    [LocalNotificationUtil cancelAllLocalNotifications];
        
    srand(time(0));
    
#ifdef DEBUG
    [UMConfigure setLogEnabled:YES];
//    [UMCommonLogManager setUpUMCommonLogManager];
#endif
        
    // clear all badges
    application.applicationIconBadgeNumber = 0;

    // init mob click
//    [MobClick startWithAppkey:[GameApp umengId]
//                 reportPolicy:BATCH
//                    channelId:[PPConfigManager getChannelId]];
//    [MobClick updateOnlineConfig];
    
    [UMConfigure initWithAppkey:[GameApp umengId] channel:@"App Store"];
        
//    [self initImageCacheManager];
    [PPSmartUpdateDataUtils initPaths];


#ifdef DEBUG
    [[TutorialCoreManager defaultManager] createTestData];
    [DrawBgManager createTestData:0];
    [GameConfigDataManager createTestConfigData];
    [ImageShapeManager createMetaFile];
    [DrawBgManager scaleImages];
    [ImageShapeManager loadMetaFile];
    [GameItemService createDrawTestDataFile];
#endif

    // load config data
    [GameConfigDataManager defaultManager];
    
    // load item data
    [[GameItemService defaultService] syncData:NULL];
//    [[IAPProductService defaultService] syncData:NULL];
    
//    [DrawBgManager scaleImages];

    [GameApp HandleWithDidFinishLaunching];
    
    if ([GameApp supportWeixin] == YES){
        PPDebug(@"Init Weixin SDK, AppId(%@)", [GameApp weixinId]);
//        [WXApi registerApp:[GameApp weixinId]]; //@"wx427a2f57bc4456d1"];
    }
    
    // Push Setup
    BOOL isAskBindDevice = NO;
    if (![self isPushNotificationEnable]){
        isAskBindDevice = YES;
        [self bindDevice];
    }
    
    // Ask For Review
//    if ([PPConfigManager isInReviewVersion] == NO){
//        if ([DeviceDetection isOS5]){
//            self.reviewRequest = [ReviewRequest startReviewRequest:[PPConfigManager appId] appName:GlobalGetAppName() isTest:YES];
//            self.reviewRequest.delegate = self;
//        }
//    }

    // Init Home Controller As Root View Controller
    PPViewController* rootController = [GameApp homeController];
    if ([rootController conformsToProtocol:@protocol(DrawHomeControllerProtocol)]) {
        self.homeController = (PPViewController<DrawHomeControllerProtocol>*)rootController;
    }
    
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    NotificationType type = [NotificationManager typeForUserInfo:userInfo];
    
    PPDebug(@"<AppDelegate> notification type = %d", type);
    _homeController.notificationType = type;
    
        self.rootNavigationController = [[[MLNavigationController alloc]
                                                        initWithRootViewController:rootController]
                                                        autorelease];

    self.rootNavigationController.navigationBarHidden = YES;

    self.window.rootViewController = self.rootNavigationController;
    
    [self.window makeKeyAndVisible];
    
    
    [[AccountService defaultService] retryVerifyReceiptAtBackground];

    // Show News If Exists
    [self performSelector:@selector(showNews) withObject:nil afterDelay:1.5];
    
    [[BBSService defaultService] getBBSPrivilegeList];  //kira:get bbs permission first, for super user manage
    
    [UIUtils checkAppVersion];
    
    // 比赛的local notification通知
    if ([PPConfigManager getGuessContestLocalNotificationEnabled]) {

    }
    
//    //注册微信，用于微信支付
//    [WXApi registerApp:@"wx427a2f57bc4456d1"];
    
    return YES;
}

- (void)scheduleLocalNotificationForGuessContest:(PBContest *)contest{
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:contest.startDate];
    [LocalNotificationUtil scheduleLocalNotificationWithFireDate:date alertBody:NSLS(@"kGuessContestBeginTip") repeatInterval:kCFCalendarUnitDay userInfo:@{
     }];
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
    if ([PPConfigManager isProVersion]){
        news = nil; // [MobClick getConfigParams:@"NEWS_PRO"];
    }
    else{
        news = nil; // [MobClick getConfigParams:@"NEWS"];
    }
    if ([news length] <= 1)
        return;
    
    [[CommonMessageCenter defaultCenter] postMessageWithText:news delayTime:2.5 isHappy:YES];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    PPDebug(@"<applicationWillResignActive>");
    
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    
    [[DrawGameService defaultService] startDisconnectTimer];
//    [[DiceGameService defaultService] startDisconnectTimer];
    [self.networkDetector stop];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    
    PPDebug(@"<applicationDidEnterBackground>");
    
    // store user defaults
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults synchronize];

    [[ComebackManager defaultManager] registerNotification];
    
    UIApplication* app = [UIApplication sharedApplication];
    
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
        // update when enter background
        [MobClick updateOnlineConfig];
        
        [[BillboardManager defaultManager] autoUpdate:nil];
        [[TutorialCoreManager defaultManager] autoUpdate];

        // upload user device info
        [[UserDeviceService defaultService] uploadUserDeviceInfo:NO];
        
        // load config data
        [[GameConfigDataManager defaultManager] syncData];
        
        [[AppTaskManager defaultManager] autoUpdate];
        
        // load item data
        [[GameItemService defaultService] syncData:NULL];
        [[IAPProductService defaultService] syncData:NULL];
        [[SKProductService defaultService] syncDataFromIAPService];
        
        [[UserStatusService defaultService] stop];
        
        if ([[UserManager defaultManager] hasUser]) {
            [[GroupService defaultService] syncGroupRoles];
            [[GroupService defaultService] syncFollowGroupIds];
            [[GroupService defaultService] syncFollowTopicIds];
        }

}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification*)notification
{
    PPDebug(@"<didReceiveLocalNotification>");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */

    PPDebug(@"<applicationWillEnterForeground>");    
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    PPDebug(@"<applicationDidBecomeActive>");
    
    // Init Account Service and Sync Balance and Item
    [[AccountService defaultService] syncAccount:nil];
    
    [[DrawGameService defaultService] clearDisconnectTimer];
    [self.networkDetector start];
    
    [[UserStatusService defaultService] start];
    
    [[ContestService defaultService] syncOngoingContestList];
    
    [GameApp HandleWithDidBecomeActive];
    
    [[ComebackManager defaultManager] registerNotification];
    
    [[OpusClassInfoManager defaultManager] autoUpdate];
    
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    PPDebug(@"<applicationWillTerminate>");
    
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    
    [[MyPaintManager defaultManager] removeAlldeletedPaints];
    [[FeedManager defaultManager] removeOldCache];
    [[GroupManager defaultManager] saveTempDataToDisk];

}

#pragma mark - Device Notification Delegate

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url { 
    PPDebug(@"<handleURL> url=%@", url.absoluteString);
    if ([url.absoluteString containsString:@"safepay"]) {
        return YES;
    }
    
    // TODO
//    [WXApi handleOpenURL:url delegate:self];
    
    [[GameSNSService defaultService] handleOpenURL:url];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {

    PPDebug(@"<handleURL> url=%@, sourceApplication=%@, annotation=%@", url.absoluteString, sourceApplication, [annotation description]);
    
    // TODO
//    [WXApi handleOpenURL:url delegate:self];
    
    
    [[GameSNSService defaultService] handleOpenURL:url sourceApplication:sourceApplication annotation:annotation];
    return YES;
}

#pragma mark - Device Notification Delegate

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	
    // Get a hex string from the device token with no spaces or < >	
	[self saveDeviceToken:deviceToken];    
    
    // user already register
    [[UserManager defaultManager] setDeviceToken:[self getDeviceToken]];
    
    // update user device token
    [[UserDeviceService defaultService] uploadUserDeviceInfo:YES];
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
        [_chatDetailController loadNewMessage:NO];
    }
    
    [[NotificationManager defaultManager] showNotification:userInfo];
}

#pragma mark - Alert View Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == CHECK_APP_VERSION_ALERT_VIEW){
        if (buttonIndex == 1){
            [UIUtils openAppForUpgrade:[PPConfigManager appId]];
        }
    }
}

//-(void) onReq:(BaseReq*)req
//{
//    if (self.homeController && [self.homeController conformsToProtocol:@protocol(DrawHomeControllerProtocol)]) {
//        if ([self.homeController isRegistered]) {
//            [self.homeController toRegister];
//        } else {
//            [ShareController shareFromWeiXin:self.homeController];
//        }
//    }
//
//}

//-(void) onResp:(BaseResp*)resp
//{
    //发送信息到微信的response（分享到朋友圈之类）
//    if([resp isKindOfClass:[SendMessageToWXResp class]])
//    {
//        if (resp.errCode == WXSuccess){
//            [UIUtils alert:@"已成功分享至微信"];
//            PPDebug(@"<onResp> weixin response success");
//        }else {
//            PPDebug(@"<onResp> weixin response fail");
//        }
//    }
    
//    POSTMSG2(strMsg, 3);
//}

@end




