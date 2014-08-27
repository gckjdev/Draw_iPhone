
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
//#import "RegisterUserController.h"
#import "OnlineGuessDrawController.h"
//#import "RouterService.h"
#import "AccountManager.h"
#import "AccountService.h"
#import "PriceService.h"
#import "DeviceDetection.h"
#import "NetworkDetector.h"
#import "MobClick.h"
//#import "TKAlertCenter.h"
#import "PPConfigManager.h"
#import "AudioManager.h"
#import "FriendManager.h"
//#import "MusicItemManager.h"
#import "CommonMessageCenter.h"
//#import "MusicDownloadService.h"
#import "FriendService.h"
#import "UIUtils.h"
#import "LevelService.h"
//#import "YoumiWallService.h"
#import "ChatDetailController.h"
#import "NotificationManager.h"
#import "LmWallService.h"
#import "UserStatusService.h"
//#import "FacetimeService.h"
//#import "DiceGameService.h"
//#import "DiceFontManager.h"
#import "WordManager.h"
//#import "DiceFontManager.h"
//#import "DiceSoundManager.h"
#import "CommonHelpManager.h"
//#import "BoardService.h"

#import "PPResourcePackage.h"
#import "PPResourceService.h"
//#import "PPResourceTestViewController.h"
#import "FeedManager.h"

#import "MyPaintManager.h"
#import "AppTaskManager.h"

//#import "PPSNSIntegerationService.h"
//#import "PPSinaWeiboService.h"
//#import "PPTecentWeiboService.h"
//#import "PPFacebookService.h"

#import "GameConfigDataManager.h"
#import "BulletinService.h"
#import "PPSmartUpdateDataUtils.h"

#import "BBSService.h"
#import "DrawBgManager.h"
#import "GameAdWallService.h"
#import "GameItemService.h"
#import "IAPProductService.h"
#import "AliPayManager.h"
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

#import "DMSplashAdController.h"
#import "OpenCVUtils.h"

#import "OpenCVUtils.h"
#import "TutorialCoreManager.h"

NSString* GlobalGetServerURL()
{

#ifdef DEBUG
//    return @"http://localhost:8000/api/i?";
//    return @"http://58.215.160.100:8002/api/i?";
//    return @"http://192.168.1.13:8001/api/i?";
    return @"http://58.215.160.100:8020/api/i?";
//    return @"http://192.168.1.198:8000/api/i?";
//    return @"http://58.215.160.100:8888/api/i?";
//
//    NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
//    NSString* str = [def objectForKey:@"api_server"];
//    if (str && str.length > 5) {
//        PPDebug(@"<for test!!!!!!> get api server %@", str);
//        return [NSString stringWithFormat:@"http://%@/api/i?",str];
//    }

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
    
    
//    return @"http://58.215.184.18:8699/api/i?";

//    return @"http://58.215.184.18:8037/api/i?";
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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    [DrawUtils testSpendTime];
    //Enabling keyboard manager(Use this line to enable managing distance between keyboard & textField/textView).
    
    
//    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:181 green:261 blue:245 alpha:1.0]];
    
    [IQKeyBoardManager installKeyboardManager];
    [IQKeyBoardManager disableKeyboardManager];
    
    // TODO check benson
    [LocalNotificationUtil cancelAllLocalNotifications];
        
    srand(time(0));
    
#ifdef DEBUG
    [MobClick setLogEnabled:YES];
#endif
        
    // clear all badges
    application.applicationIconBadgeNumber = 0;

    // init mob click
    [MobClick startWithAppkey:[GameApp umengId]
                 reportPolicy:BATCH
                    channelId:[PPConfigManager getChannelId]];
    [MobClick updateOnlineConfig];
        
//    [self initImageCacheManager];
    [PPSmartUpdateDataUtils initPaths];


#ifdef DEBUG
//    [DrawBgManager createTestData:0];
    [GameConfigDataManager createTestConfigData];
//    [ImageShapeManager createMetaFile];
//    [DrawBgManager scaleImages];
//    [ImageShapeManager loadMetaFile];
//    [GameItemService createDrawTestDataFile];
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
        [WXApi registerApp:[GameApp weixinId]]; //@"wx427a2f57bc4456d1"];
    }
    
    // Push Setup
    BOOL isAskBindDevice = NO;
    if (![self isPushNotificationEnable]){
        isAskBindDevice = YES;
        [self bindDevice];
    }
    
    // Ask For Review
    if ([PPConfigManager isInReviewVersion] == NO){
        if ([DeviceDetection isOS5]){
            self.reviewRequest = [ReviewRequest startReviewRequest:[PPConfigManager appId] appName:GlobalGetAppName() isTest:YES];
            self.reviewRequest.delegate = self;
        }
    }

    // Init Home Controller As Root View Controller
    PPViewController* rootController = [GameApp homeController];
    if ([rootController conformsToProtocol:@protocol(DrawHomeControllerProtocol)]) {
        self.homeController = (PPViewController<DrawHomeControllerProtocol>*)rootController;
    }
    
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    NotificationType type = [NotificationManager typeForUserInfo:userInfo];
    
    PPDebug(@"<AppDelegate> notification type = %d", type);
    _homeController.notificationType = type;
    
//    if (ISIOS7 && !ISIPAD) {
//        self.rootNavigationController = [[[UINavigationController alloc]
//                                          initWithRootViewController:rootController]
//                                         autorelease];
//        self.rootNavigationController.interactivePopGestureRecognizer.enabled = YES;
//    }else{
        self.rootNavigationController = [[[MLNavigationController alloc]
                                                        initWithRootViewController:rootController]
                                                        autorelease];
//    }
    self.rootNavigationController.navigationBarHidden = YES;

    // Try Fetch User Data By Device Id
    /* disable this from new learn draw version
    if ([[UserManager defaultManager] hasUser] == NO){
        BOOL autoRegister = [GameApp isAutoRegister];
        [[UserService defaultService] loginByDeviceWithViewController:rootController
                                                         autoRegister:autoRegister
                                                          resultBlock:nil];
    }
    */
    
        
    self.window.rootViewController = self.rootNavigationController;
    
    [self.window makeKeyAndVisible];
    
    
    
    [[AccountService defaultService] retryVerifyReceiptAtBackground];
    
    // Detect Network Availability
//    self.networkDetector = [[[NetworkDetector alloc] initWithErrorTitle:NSLS(@"kNetworkErrorTitle") ErrorMsg:NSLS(@"kNetworkErrorMessage") detectInterval:2] autorelease];
//    [self.networkDetector start];

    // Show News If Exists
    [self performSelector:@selector(showNews) withObject:nil afterDelay:1.5];
    
    [[BBSService defaultService] getBBSPrivilegeList];  //kira:get bbs permission first, for super user manage
    
    [UIUtils checkAppVersion];
    
    // 比赛的local notification通知
    if ([PPConfigManager getGuessContestLocalNotificationEnabled]) {

    }
    
    [self loadSplashAd];
    return YES;
}

- (void)loadSplashAd
{
    if ([PPConfigManager enableSplashAd] == NO){
        return;
    }
    
    // 设置适合的背景图片
    // Set background image
    NSString *defaultImgName = [GameApp defaultImage]; // @"DrawDefault";
    CGFloat offset = 0.0f;
    CGSize adSize;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        adSize = DOMOB_AD_SIZE_768x576;
        defaultImgName = [GameApp defaultImageIPAD];// @"DrawDefault@2x~ipad";
        offset = 374.0f;
    } else {
        adSize = DOMOB_AD_SIZE_320x400;
        if ([UIScreen mainScreen].bounds.size.height > 480.0f) {
            defaultImgName = [GameApp defaultImageRetina]; //@"DrawDefault-568h";
            offset = 233.0f;
        } else {
            offset = 168.0f;
        }
    }
    
    BOOL isCacheSplash = [PPConfigManager enableCacheSplash]; // NO;
    // 选择测试缓存开屏还是实时开屏，NO为实时开屏。
    // Choose NO or YES for RealTimeSplashView or SplashView
    // 初始化开屏广告控制器，此处使用的是测试ID，请登陆多盟官网（www.domob.cn）获取新的ID
    // Get your ID from Domob website
    NSString* testPubID = [PPConfigManager splashAdPublisherId]; // @"56OJz8QIuMyvO2LjPI";
    NSString* testSplashPlacementID = [PPConfigManager splashAdPlacementId]; // @"16TLmCOoAcaIONUEOHEOnqoz";
    UIColor* bgColor = [UIColor colorWithPatternImage:[UIImage imageNamed:defaultImgName]];
    if (isCacheSplash) {
        _splashAd = [[DMSplashAdController alloc] initWithPublisherId:testPubID
                                                          placementId:testSplashPlacementID
                                                                 size:adSize
                                                               offset:offset
                                                               window:self.window
                                                           background:bgColor
                                                            animation:YES];
        _splashAd.delegate = self;
        if (_splashAd.isReady)
        {
            [_splashAd present];
        }
//        _splashAd.delegate = nil;
        [_splashAd release];
        _splashAd = nil;
        
    } else {
        _rtsplashAd = [[DMRTSplashAdController alloc] initWithPublisherId:testPubID
                                                             placementId:testSplashPlacementID
                                                                    size:adSize
                                                                  offset:233.5f
                                                                  window:self.window
                                                              background:bgColor
                                                               animation:YES];
        
        
        _rtsplashAd.delegate = self;
        [_rtsplashAd present];
//        _rtsplashAd.delegate = nil;
        [_rtsplashAd release];
        _rtsplashAd = nil;
    }
    
}

#pragma mark -
#pragma makr Domob Splash Ad Delegate
//成功加开屏广告后调用
//This method will be used after load splash advertisement successfully
- (void)dmSplashAdSuccessToLoadAd:(DMSplashAdController *)dmSplashAd
{
    PPDebug(@"[Domob Splash] success to load ad.");
}

// 当开屏广告加载失败后，回调该方法
// This method will be used after load splash advertisement faild
- (void)dmSplashAdFailToLoadAd:(DMSplashAdController *)dmSplashAd withError:(NSError *)err
{
    PPDebug(@"[Domob Splash] fail to load ad. error=%@", [err description]);
}

// 当插屏广告要被呈现出来前，回调该方法
// This method will be used before the splashView will show
- (void)dmSplashAdWillPresentScreen:(DMSplashAdController *)dmSplashAd
{
    PPDebug(@"[Domob Splash] will appear on screen.");
}

// 当插屏广告被关闭后，回调该方法
// This method will be used after the splashView dismiss
- (void)dmSplashAdDidDismissScreen:(DMSplashAdController *)dmSplashAd
{
    PPDebug(@"[Domob Splash] did disappear on screen.");
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
    
    [[ComebackManager defaultManager] registerNotification];
    
    UIApplication* app = [UIApplication sharedApplication];
    
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];

    // upload user device info
    [[UserDeviceService defaultService] uploadUserDeviceInfo:NO];
    
    // update when enter background
    [MobClick updateOnlineConfig];
    
    // load config data
    [[GameConfigDataManager defaultManager] syncData];
    
    [[AppTaskManager defaultManager] autoUpdate];
    
    // load item data
    [[GameItemService defaultService] syncData:NULL];
    [[IAPProductService defaultService] syncData:NULL];
    [[SKProductService defaultService] syncDataFromIAPService];
    
    
    if ([GameApp isAutoRegister]){
        [[UserService defaultService] autoRegisteration:nil];
    }
    
    [[UserStatusService defaultService] stop];
    
    if ([[UserManager defaultManager] hasUser]) {
        [[GroupService defaultService] syncGroupRoles];
        [[GroupService defaultService] syncFollowGroupIds];
        [[GroupService defaultService] syncFollowTopicIds];
    }
    
    // store user defaults
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults synchronize];
    
//    [[GameAdWallService defaultService] queryWallScore];

    [[TutorialCoreManager defaultManager] autoUpdate];
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

//- (BOOL)handleURL:(NSURL*)url
//{
//    PPDebug(@"<handleURL> url=%@", url.absoluteString);
//    if ([[url absoluteString] hasPrefix:@"alipay"]){
//        return [AliPayManager parseURL:url alipayPublicKey:[PPConfigManager getAlipayAlipayPublicKey]];
//    }
//
//    [[GameSNSService defaultService] handleOpenURL:url];
//    return YES;
//}


- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url { 
    PPDebug(@"<handleURL> url=%@", url.absoluteString);
    if ([[url absoluteString] hasPrefix:@"alipay"]){
        return [AliPayManager parseURL:url alipayPublicKey:[PPConfigManager getAlipayAlipayPublicKey]];
    }
    
    [[GameSNSService defaultService] handleOpenURL:url];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {

    PPDebug(@"<handleURL> url=%@, sourceApplication=%@, annotation=%@", url.absoluteString, sourceApplication, [annotation description]);
    if ([[url absoluteString] hasPrefix:@"alipay"]){
        return [AliPayManager parseURL:url alipayPublicKey:[PPConfigManager getAlipayAlipayPublicKey]];
    }
    
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

-(void) onReq:(BaseReq*)req
{
    if (self.homeController && [self.homeController conformsToProtocol:@protocol(DrawHomeControllerProtocol)]) {
        if ([self.homeController isRegistered]) {
            [self.homeController toRegister];
        } else {
            [ShareController shareFromWeiXin:self.homeController];
        }
    }
    
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




