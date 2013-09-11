
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
#import "RegisterUserController.h"
#import "OnlineGuessDrawController.h"
//#import "RouterService.h"
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
#import "PPResourceTestViewController.h"
#import "FeedManager.h"

#import "MyPaintManager.h"

#import "PPSNSIntegerationService.h"
#import "PPSinaWeiboService.h"
#import "PPTecentWeiboService.h"
#import "PPFacebookService.h"

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

NSString* GlobalGetServerURL()
{

#ifdef DEBUG
//    return @"http://localhost:8000/api/i?";
//    return @"http://58.215.160.100:8002/api/i?";
//    return @"http://192.168.1.13:8001/api/i?";
//    return @"http://58.215.160.100:8020/api/i?";
//    return @"http://192.168.1.198:8000/api/i?";
//    return @"http://58.215.160.100:8888/api/i?";
//
    NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
    NSString* str = [def objectForKey:@"api_server"];
    if (str && str.length > 5) {
        PPDebug(@"<for test!!!!!!> get api server %@", str);
        return [NSString stringWithFormat:@"http://%@/api/i?",str];
    }

#endif

    
    return [ConfigManager getAPIServerURL];
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
    
    return @"http://localhost:8100/api/i?";

//    return @"http://58.215.184.18:8699/api/i?";

//    return @"http://58.215.184.18:8037/api/i?";
//    return @"http://192.168.1.198:8100/api/i?";
//      return @"http://58.215.172.169:8037/api/i?";
//    return @"http://192.168.1.198:8100/api/i?";
//    return @"http://58.215.172.169:8037/api/i?";

//    return @"http://192.168.1.198:8100/api/i?";
//    return @"http://58.215.172.169:8037/api/i?";
    
#endif
    
    return [ConfigManager getTrafficAPIServerURL];
}

NSString* GlobalGetMessageServerURL()
{
    return [ConfigManager getMessageServerURL];
}

NSString* GlobalGetBBSServerURL()
{
    return [ConfigManager getBBSServerURL];
}


NSString* GlobalGetBoardServerURL()
{
    return [ConfigManager getTrafficAPIServerURL];
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
    PPRelease(_reviewRequest);
    PPRelease(_homeController);
    PPRelease(_roomController);
    PPRelease(_window);
    PPRelease(_viewController);
    PPRelease(_chatDetailController);
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
                                                                   officialWeiboId:[UIUtils getAppName]] autorelease];
    
    
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
                    channelId:[ConfigManager getChannelId]];
    [MobClick updateOnlineConfig];
        
    [self initImageCacheManager];
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
    [[IAPProductService defaultService] syncData:NULL];
    
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
    if ([ConfigManager isInReviewVersion] == NO){
        if ([DeviceDetection isOS5]){
            self.reviewRequest = [ReviewRequest startReviewRequest:[ConfigManager appId] appName:GlobalGetAppName() isTest:YES];
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
    
    MLNavigationController* navigationController = [[[MLNavigationController alloc] 
                                                     initWithRootViewController:rootController] 
                                                    autorelease];
    navigationController.navigationBarHidden = YES;

    // Try Fetch User Data By Device Id
    if ([[UserManager defaultManager] hasUser] == NO){
        BOOL autoRegister = [GameApp isAutoRegister];
        [[UserService defaultService] loginByDeviceWithViewController:rootController
                                                         autoRegister:autoRegister
                                                          resultBlock:nil];
    }
    
    

    self.window.rootViewController = navigationController;
    
    // Init SNS service
    [self initSNSService];
    
    [self.window makeKeyAndVisible];
    
    [[SKProductService defaultService] syncDataFromIAPService];
    
    [[AccountService defaultService] retryVerifyReceiptAtBackground];
    
    // Detect Network Availability
    self.networkDetector = [[[NetworkDetector alloc] initWithErrorTitle:NSLS(@"kNetworkErrorTitle") ErrorMsg:NSLS(@"kNetworkErrorMessage") detectInterval:2] autorelease];
    [self.networkDetector start];

    // Show News If Exists
    [self performSelector:@selector(showNews) withObject:nil afterDelay:1.5];
    
    [[BBSService defaultService] getBBSPrivilegeList];  //kira:get bbs permission first, for super user manage
    
    [UIUtils checkAppVersion];
    
    // 比赛的local notification通知
    if ([ConfigManager getGuessContestLocalNotificationEnabled]) {
        [self scheduleLocalNotificationForGuessContest];
    }
    
    return YES;
}

- (void)scheduleLocalNotificationForGuessContest{
    
    NSString *today = dateToStringByFormat([NSDate date], @"yyyyMMdd");// yyyyMMddHHmmss
    NSString *beginTime = [today stringByAppendingString:[ConfigManager getContestBeginTimeString]];
    NSDate *date = dateFromStringByFormat(@"yyyyMMddHHmmss", beginTime);
    
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
    
    // load item data
    [[GameItemService defaultService] syncData:NULL];
    [[IAPProductService defaultService] syncData:NULL];
    
    if ([GameApp isAutoRegister]){
        [[UserService defaultService] autoRegisteration:nil];
    }
    
    // Start the long-running task and return immediately.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        sleep(60);
    });     
    
    [[UserStatusService defaultService] stop];
    
    // store user defaults
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults synchronize];
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */

    PPDebug(@"<applicationWillEnterForeground>");    
    application.applicationIconBadgeNumber = 0;
    
    
#if DEBUG
    
//    [[UserService defaultService] sendPassword:@"29356050@qq.com" resultBlock:nil];
//    [[UserService defaultService] sendVerificationRequest:nil];
//    [[UserService defaultService] verifyAccount:@"233149" resultBlock:nil];
    
#endif
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    PPDebug(@"<applicationDidBecomeActive>");
    
    [[GameAdWallService defaultService] queryWallScore];
    
    // Init Account Service and Sync Balance and Item
    [[AccountService defaultService] syncAccount:nil];
    
    [[DrawGameService defaultService] clearDisconnectTimer];
//    [[DiceGameService defaultService] clearDisconnectTimer];
    [self.networkDetector start];
    
    [[UserStatusService defaultService] start];
    
    [[ContestService defaultService] syncOngoingContestList];
    
    [GameApp HandleWithDidBecomeActive];
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

}

#pragma mark - Device Notification Delegate

- (BOOL)handleURL:(NSURL*)url
{
    PPDebug(@"<handleURL> url=%@", url.absoluteString);
    
    if ([[url absoluteString] hasPrefix:@"wx"]){
        return [WXApi handleOpenURL:url delegate:self];;
    }else if ([[url absoluteString] hasPrefix:@"alipay"]){
        return [AliPayManager parseURL:url alipayPublicKey:[ConfigManager getAlipayAlipayPublicKey]];
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
            [UIUtils openAppForUpgrade:[ConfigManager appId]];
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

/*
 
 db.action.insert(
 
 {
 "_id" : ObjectId("51e5084a03648b38d2d61de5"),
 "app_id" : "513819630",
 "avatar" : "http://app.qlogo.cn/mbloghead/32222b7df0b6a95af3de/100",
 "c_date" : ISODate("2013-07-15T06:24:13.745Z"),
 "comment_times" : 7,
 "correct_times" : 6,
 "create_uid" : "51e507ff036498e676b37fed",
 "data_len" : 2621,
 "data_url" : "20130715/2b15dce0-ed17-11e2-a60f-00163e017d23.zip",
 "desc" : "粉笔 好玩吧",
 "device_model" : "x86_64",
 "device_type" : 2,
 "file_gen" : 1,
 "file_gen_result" : 0,
 "flower_times" : 1,
 "gender" : "m",
 "guess_list" : [
 "粉笔",
 "口硒"
 ],
 "guess_times" : 7,
 "history_score" : 17.917,
 "hot" : 190845.47936720427,
 "image" : "20130715/2b0b7ca0-ed17-11e2-a60f-00163e017d23.jpg",
 "language" : 1,
 "level" : 1,
 "match_times" : 0,
 "nick_name" : "Little Gee",
 "opus_status" : 0,
 "related_uid" : [
 "4fc3089a26099b2ca8c7a4ab"
 ],
 "signature" : "Hello World",
 "thumb" : "20130715/2b0b7ca0-ed17-11e2-a60f-00163e017d23_m.jpg",
 "type" : 1,
 "user_list" : [ ],
 "word" : "粉笔",
 "word_score" : 2
 });

 db.user.insert(
 {
 "_id" : ObjectId("51e507ff036498e676b37fed"),
 "app_id" : "513819630",
 "avatar" : "http://app.qlogo.cn/mbloghead/32222b7df0b6a95af3de/100",
 "award_exp" : 0,
 "balance" : 577,
 "birthday" : "1997-09-02",
 "c_date" : ISODate("2012-08-09T14:12:59.689Z"),
 "city" : "27",
 "country_code" : "CN",
 "device_id" : "aec5664308b000d184baa0e997576f58",
 "device_model" : "iPad",
 "device_os" : "iPhone OS_5.0.1",
 "device_type" : 1,
 "draw_rank_score" : NumberLong(9310),
 "feed_timestamp" : ISODate("2013-06-15T16:48:46.799Z"),
 "gender" : "f",
 "guess_balance" : 0,
 "language" : "zh-Hans",
 "level_dice" : {
 "level" : 1,
 "experience" : NumberLong(0)
 },
 "level_draw" : {
 "level" : 20,
 "experience" : NumberLong(9310)
 },
 "level_game" : {
 "level" : 20,
 "experience" : NumberLong(9505),
 "m_date" : ISODate("2013-07-30T14:42:28.154Z")
 },
 "level_zhajinhua" : {
 "level" : 1,
 "experience" : NumberLong(0)
 },
 "location" : "中国 火星",
 "new_fan_cnt" : 0,
 "nick_name" : "自守自城",
 "province" : "52",
 "qq_at" : "6934e0953e8d4ac78da1b2350f188c66",
 "qq_ats" : "d8d738f7d0b679473f97eb6be40363b2",
 "qq_domain" : "longtbj",
 "qq_id" : "longtbj",
 "qq_nick" : "谭琲珺",
 "source_id" : "513819630",
 "top_draw" : {
 "score" : 1.9019,
 "opus_id" : "51f7cf89e4b0577e07ca8f5c",
 "m_date" : ISODate("2013-07-30T14:36:57.409Z")
 },
 "version" : "6.88"
 });

 
 */

@end
