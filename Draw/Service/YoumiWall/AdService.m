//
//  AdService.m
//  Draw
//
//  Created by  on 12-6-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AdService.h"
#import "ConfigManager.h"
#import "CommonDialog.h"
#import "LocaleUtils.h"
#import "ShoppingManager.h"
#import "PPViewController.h"
#import "AccountService.h"
#import "ItemType.h"
#import "DeviceDetection.h"
#import "LmWallService.h"
#import "AdMoGoView.h"
#import "UserManager.h"
#import "HomeController.h"
#import "GADBannerView.h"

//#import "YoumiWallService.h"
//#import "YoumiWallController.h"

#define ASK_REMOVE_AD_BY_WALL       101
#define ASK_REMOVE_AD_BY_IAP        102

#define AD_VIEW_TAG                 201206281

@interface AdService()

- (void)gotoWall;
- (void)buyCoins;

@end

@implementation AdService

@synthesize viewController = _viewController;

static AdService* _defaultService;

- (void)dealloc
{
    PPRelease(_viewController);
    [super dealloc];
}

- (void)initWappuAdSDK
{
    // init Wanpu Ad
//    [AppConnect getConnect:[GameApp wanpuAdPublisherId] pid:[ConfigManager getChannelId]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWanpuConnectSuccess:) name:WAPS_CONNECT_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWanpuConnectFailed:) name:WAPS_CONNECT_FAILED object:nil];        
}

- (id)init
{
    self = [super init];

    [self initWappuAdSDK];
    
    _isShowAd = ([[AccountService defaultService] hasEnoughItemAmount:ItemTypeRemoveAd                                                             
                                                               amount:1] == NO);    
    return self;
}

+ (AdService*)defaultService
{
    if (_defaultService == nil){
        _defaultService = [[AdService alloc] init];
    }
    
    return _defaultService;
}

- (NSInteger)getRemoveAdPrice
{
    return [MobClickUtils getIntValueByKey:@"REMOVE_AD_PRICE" defaultValue:1];
}

- (int)getLmAdPercentage
{
    return [MobClickUtils getIntValueByKey:@"LM_AD_PERCENTAGE" defaultValue:0];
}

- (int)getAderAdPercentage
{
    return [MobClickUtils getIntValueByKey:@"ADER_AD_PERCENTAGE" defaultValue:100];    
}

- (int)getWanpuAdPercentage
{
    return [MobClickUtils getIntValueByKey:@"WANPU_AD_PERCENTAGE" defaultValue:0];        
}

- (BOOL)isShowAdByPercentage:(int)percentage
{
    if (percentage == 0)
        return NO;
    
    int randValue = rand() % 100;
    if (randValue <= percentage)
        return YES;
    else
        return NO;    
}

- (BOOL)isShowLmAd
{
    int percentage = [self getLmAdPercentage];
    return [self isShowAdByPercentage:percentage];
}

- (BOOL)isShowAderAd
{
    int percentage = [self getAderAdPercentage];
    return [self isShowAdByPercentage:percentage];    
}

- (BOOL)isShowWanpuAd
{
    return NO;
//    int percentage = [self getWanpuAdPercentage];
//    return [self isShowAdByPercentage:percentage];        
}

- (void)setAdDisable
{
    PPDebug(@"<setAdDisable> Ad Is Disabled Now");
    
    [[AccountService defaultService] buyItem:ItemTypeRemoveAd 
                                   itemCount:1
                                   itemCoins:[self getRemoveAdPrice]];
 
    _isShowAd = NO;
}

- (void)askRemoveAdByWall
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLS(@"kRemoveAd") 
                                                        message:@"下载免费应用即可移除广告！记住下载完应用一定要打开才可以成功移除广告哦！" 
                                                       delegate:self 
                                              cancelButtonTitle:NSLS(@"Cancel") 
                                              otherButtonTitles:NSLS(@"OK"), nil];
    
    alertView.tag = ASK_REMOVE_AD_BY_WALL;
    [alertView show];
    [alertView release];
}

- (void)askRemoveAdByBuyCoins
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLS(@"kRemoveAd") 
                                                        message:NSLS(@"kRemoveAdByIAP") 
                                                       delegate:self 
                                              cancelButtonTitle:NSLS(@"Cancel") 
                                              otherButtonTitles:NSLS(@"OK"), nil];
    
    alertView.tag = ASK_REMOVE_AD_BY_IAP;
    [alertView show];
    [alertView release];    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0){
        return;
    }
    
    switch (alertView.tag) {
        case ASK_REMOVE_AD_BY_IAP:
            [self buyCoins];
            break;
            
        case ASK_REMOVE_AD_BY_WALL:
            [self gotoWall];
            break;
            
        default:
            break;
    }
}

#pragma mark - Buy Coins By IAP

- (void)removeAdByIAP
{
    [MobClick event:@"BUY_REMOVE_AD"];
    [[AccountService defaultService] buyRemoveAd];
}

- (void)buyCoins
{
    [MobClick event:@"BUY_COINS"];
    
    NSArray* coinPriceList = [[ShoppingManager defaultManager] findCoinPriceList];
    if ([coinPriceList count] > 0){
        PriceModel* model = [coinPriceList objectAtIndex:0];
        [_viewController showActivityWithText:NSLS(@"kBuying")];
        [[AccountService defaultService] setDelegate:self];
        [[AccountService defaultService] buyCoin:model];
        
    }    
}

#pragma mark - Show Ad Wall

- (void)gotoWall
{
    [[LmWallService defaultService] show:_viewController isForRemoveAd:YES];
}

#pragma mark - Account Service Delegate

- (void)didFinishBuyProduct:(int)resultCode
{
    [_viewController hideActivity];
    
    if (resultCode != 0 && resultCode != PAYMENT_CANCEL){
        [MobClick event:@"BUY_COINS_FAIL"];        
        [_viewController popupMessage:NSLS(@"kFailToConnectIAPServer") title:nil]; 

        // clear view controller after finishing IAP
        [self setViewController:nil]; 
        return;
    }
    else if (resultCode == PAYMENT_CANCEL){
        [MobClick event:@"BUY_COINS_CANCEL"];

        // clear view controller after finishing IAP
        [self setViewController:nil]; 
        return;
    }
    
    if (resultCode == 0){
        [MobClick event:@"BUY_COINS_OK"];        
        [_viewController popupMessage:NSLS(@"kBuyCoinsSucc") title:nil];
        
        // Remove Ad here
        [self setAdDisable];
    }

    // clear view controller after finishing IAP
    [self setViewController:nil];    
}

- (void)didProcessingBuyProduct
{
    [_viewController hideActivity];
    [_viewController showActivityWithText:NSLS(@"kProcessingIAP")];
}

#pragma mark - LM Ad View Delegate

- (void) immobView: (immobView*) immobView didFailReceiveimmobViewWithError: (NSInteger) errorCode{
    NSLog(@"errorCode:%i",errorCode);
}
- (void) onDismissScreen:(immobView *)immobView{
    NSLog(@"onDismissScreen");
}

/**
 *email phone sms等所需要
 *返回当前添加immobView的ViewController
 */
- (UIViewController *)immobViewController{
    
    return nil;
}

/**
 *根据广告的状态来决定当前广告是否展示到当前界面上 AdReady 
 *YES  当前广告可用
 *NO   当前广告不可用
 */
- (void) immobViewDidReceiveAd:(BOOL)AdReady{    
    //[adView_AdWall immobViewDisplay];
    PPDebug(@"<immobViewDidReceiveAd>");    
}


#pragma mark - Mango Ad View Delegate

- (NSString *)adMoGoApplicationKey
{
    return [GameApp mangoAdPublisherId];    
}

- (UIViewController *)viewControllerForPresentingModalView
{
    return [[UIApplication sharedApplication] delegate].window.rootViewController;    
}

- (void)adMoGoDidReceiveAd:(AdMoGoView *)adMoGoView
{
    PPDebug(@"<adMoGoDidReceiveAd>");
}

- (void)adMoGoDeleteAd:(AdMoGoView *)adMoGoView
{
    PPDebug(@"<adMoGoDeleteAd>");    
}

- (void)adMoGoDidFailToReceiveAd:(AdMoGoView *)adMoGoView usingBackup:(BOOL)yesOrNo
{
    PPDebug(@"<adMoGoDidFailToReceiveAd> usingBackup=%d", yesOrNo);    
}

- (NSString *)gender
{
    return [[UserManager defaultManager] gender];
}

#pragma mark - Methods For External

- (void)requestRemoveAd:(PPViewController*)viewController
{
    self.viewController = viewController;
    if ([ConfigManager wallEnabled] == YES && [ConfigManager removeAdByIAP] == NO){
        [self askRemoveAdByWall];
    }
    else{
        [self removeAdByIAP];
//        [self askRemoveAdByBuyCoins];
    }    
}

- (BOOL)isShowAd
{    
//    PPDebug(@"WARNING!!! isShowAd is forced to YES for testing!!!");
//    return YES;    
    
    if ([ConfigManager isProVersion])
        return NO;
    
    if ([ConfigManager isEnableAd] == NO){
        return NO;
    }

    return _isShowAd;
}

- (UIView*)createMangoAdInView:(UIView*)superView
                         frame:(CGRect)frame 
                     iPadFrame:(CGRect)iPadFrame
{
    if ([self isShowAd] == NO){
        return nil;
    }
        
    AdMoGoView* adView = nil;
    
    // create view
    adView = [AdMoGoView requestAdMoGoViewWithDelegate:self 
                                             AndAdType:AdViewTypeNormalBanner
                                           ExpressMode:YES];
    
    // set view frame
    if ([DeviceDetection isIPAD]){
        [adView setFrame:iPadFrame];
    }
    else{
        [adView setFrame:frame];
    }
    
    // set view data
    adView.tag = AD_VIEW_TAG;
    adView.delegate = self;
    
    // add to super view
    [superView addSubview:adView];
    [adView resumeAdRequest];
    return adView;
}


- (void)clearAdView:(UIView*)adView
{
    
    @try {
        PPDebug(@"<clearAdView>");
        [adView removeFromSuperview];
        
        if ([adView isKindOfClass:[AdMoGoView class]]){
            [((AdMoGoView*)adView) pauseAdRequest];
            ((AdMoGoView*)adView).delegate = nil;
        }
        else if ([adView isKindOfClass:[immobView class]]){
            ((immobView*)adView).delegate = nil;  
        }            
    }
    @catch (NSException *exception) {
        PPDebug(@"<clearAdView> catch exception=%@", [exception description]);
    }
    @finally {
    }

}

- (void)pauseAdView:(UIView*)adView
{
    if ([adView isKindOfClass:[AdMoGoView class]]){
        [((AdMoGoView*)adView) pauseAdRequest];
    }
    else if ([adView isKindOfClass:[immobView class]]){
        // Do Nothing For Lmmob, because of not support
    }
    
    [AderSDK pauseAdService:YES];
}

- (void)resumeAdView:(UIView*)adView
{
    if ([adView isKindOfClass:[AdMoGoView class]]){
        [((AdMoGoView*)adView) resumeAdRequest];
    }
    else if ([adView isKindOfClass:[immobView class]]){
        // Do Nothing For Lmmob, because of not support
    }    
    
    [AderSDK pauseAdService:NO];
}

- (UIView*)createAderAdInView:(UIView*)superView
                        appId:(NSString*)appId
                        frame:(CGRect)frame 
                    iPadFrame:(CGRect)iPadFrame
{
    PPDebug(@"<createAderAdInView>");
    [AderSDK setDelegate:self];    
    if ([DeviceDetection isIPAD]){
        [AderSDK startAdService:superView
                          appID:appId
                        adFrame:iPadFrame 
                          model:MODEL_RELEASE];
    }
    else{
        [AderSDK startAdService:superView
                          appID:appId
                        adFrame:frame 
                          model:MODEL_RELEASE];
    }
    
    return nil;
}


- (UIView*)createAderAdInView:(UIView*)superView
                        frame:(CGRect)frame 
                    iPadFrame:(CGRect)iPadFrame
{
    PPDebug(@"<createAderAdInView>");
    [AderSDK setDelegate:self];    
    if ([DeviceDetection isIPAD]){
        [AderSDK startAdService:superView
                          appID:[GameApp aderAdPublisherId] // @"3b47607e44f94d7c948c83b7e6eb800e" 
                        adFrame:iPadFrame 
                          model:MODEL_RELEASE];
    }
    else{
        [AderSDK startAdService:superView
                          appID:[GameApp aderAdPublisherId] // @"3b47607e44f94d7c948c83b7e6eb800e" 
                        adFrame:frame 
                          model:MODEL_RELEASE];
    }
    
    return nil;
}

- (UIView*)createLmAdInView:(UIView*)superView
                      appId:(NSString*)appId
                      frame:(CGRect)frame 
                  iPadFrame:(CGRect)iPadFrame
{
    if (frame.size.height == 0 && frame.size.width == 0 && [DeviceDetection isIPAD] == NO){
        return nil;
    }
    
    // Create LM Ad View
    immobView* adView = nil;
    adView = [[[immobView alloc] initWithAdUnitID:appId] autorelease];
    
    if ([DeviceDetection isIPAD]){
        [adView setFrame:iPadFrame];
    }
    else{
        [adView setFrame:frame];
    }
    
    adView.backgroundColor = [UIColor clearColor];
    adView.tag = AD_VIEW_TAG;
    adView.delegate = self;
    [adView immobViewRequest];
    
    [superView addSubview:adView];    
    [adView immobViewDisplay];        
    return adView;    
}

- (UIView*)createWanpuAdInView:(UIView*)superView
                      appId:(NSString*)appId
                      frame:(CGRect)frame 
                  iPadFrame:(CGRect)iPadFrame
{    
    PPDebug(@"<createWanpuAdInView> at view %@", [superView description]);
    
    UIView* view = [AppConnect getDisplayAdView];
    [view removeFromSuperview];
    
    if ([DeviceDetection isIPAD]){
        [AppConnect displayAd:_viewController showX:0 showY:iPadFrame.origin.y-1];
    }
    else{
        [AppConnect displayAd:_viewController showX:frame.origin.x showY:frame.origin.y-1];
    }
        
    // hack Wanpu Ad View here, remove it from its super view and add into the right view we want
    view = [AppConnect getDisplayAdView];
//    [view removeFromSuperview];
    
    if ([DeviceDetection isIPAD]){
        view.frame = iPadFrame;
    }
    else{
        view.frame = frame;
    }
    
    [superView addSubview:view];    
    return view;
}

- (UIView*)createAdInView:(UIView*)superView
                    frame:(CGRect)frame 
                iPadFrame:(CGRect)iPadFrame
{        
    PPDebug(@"<createAdView>");
    
    if ([self isShowAd] == NO){
        return nil;
    }
    
    if ([self isShowWanpuAd] == YES){
        return [self createWanpuAdInView:superView frame:frame iPadFrame:iPadFrame];
    }        
    
    if ([self isShowAderAd] == YES){
        return [self createAderAdInView:superView frame:frame iPadFrame:iPadFrame];
    }
    
    if ([self isShowLmAd] == NO){
        return [self createMangoAdInView:superView frame:frame iPadFrame:iPadFrame];
    }
    
    return [self createLmAdInView:superView
                            appId:[GameApp lmAdPublisherId] //@"eb4ce4f0a0f1f49b6b29bf4c838a5147" 
                            frame:frame 
                        iPadFrame:iPadFrame];            
}


- (UIView*)createAdInView:(PPViewController*)superViewContoller
                    frame:(CGRect)frame 
                iPadFrame:(CGRect)iPadFrame
                  useLmAd:(BOOL)useLmAd
{        
    PPDebug(@"<createAdView>");
    
    if ([self isShowAd] == NO){
        return nil;
    }
    
    if ([self isShowWanpuAd] == YES){
        return [self createWanpuAdInView:superViewContoller.view frame:frame iPadFrame:iPadFrame];
    }

    if ([self isShowAderAd] == YES){
        return [self createAderAdInView:superViewContoller.view frame:frame iPadFrame:iPadFrame];
    }
    
    if (useLmAd == NO || [self isShowLmAd] == NO){
        return [self createMangoAdInView:superViewContoller.view frame:frame iPadFrame:iPadFrame];
    }
    
    return [self createLmAdInView:superViewContoller.view 
                            appId:[GameApp lmAdPublisherId] //@"eb4ce4f0a0f1f49b6b29bf4c838a5147" 
                            frame:frame 
                        iPadFrame:iPadFrame];            
}

- (UIView*)createAdInView:(UIView*)superView
             adPlatformType:(AdPlatformType)adPlatformType
              adPublisherId:(NSString*)adPublisherId
                      frame:(CGRect)frame 
                  iPadFrame:(CGRect)iPadFrame
{
    switch (adPlatformType) {
        case AdPlatformAder:
            return [self createAderAdInView:superView appId:adPublisherId frame:frame iPadFrame:iPadFrame];
            
        case AdPlatformLm:
            return [self createLmAdInView:superView appId:adPublisherId frame:frame iPadFrame:iPadFrame];

        case AdPlatformMango:
            return [self createMangoAdInView:superView frame:frame iPadFrame:iPadFrame];
            
        case AdPlatformWanpu:
            return [self createWanpuAdInView:superView frame:frame iPadFrame:iPadFrame];
            
        default:
            break;
    }
    
    return nil;
}

- (UIView*)createLmAdInView:(UIView*)superView
                      frame:(CGRect)frame 
                  iPadFrame:(CGRect)iPadFrame
{
    return [self createLmAdInView:superView
                            appId:[GameApp lmAdPublisherId] //@"eb4ce4f0a0f1f49b6b29bf4c838a5147" 
                            frame:frame 
                        iPadFrame:iPadFrame];
}

- (UIView*)createWanpuAdInView:(UIView*)superView
                         frame:(CGRect)frame 
                     iPadFrame:(CGRect)iPadFrame
{
    return [self createWanpuAdInView:superView
                            appId:[GameApp wanpuAdPublisherId] //@"eb4ce4f0a0f1f49b6b29bf4c838a5147" 
                            frame:frame 
                        iPadFrame:iPadFrame];
}

- (UIView*)createAdmobAdInView:(UIView*)superView
                         frame:(CGRect)frame
                     iPadFrame:(CGRect)iPadFrame
{
    if (frame.size.height == 0 && frame.size.width == 0 && [DeviceDetection isIPAD] == NO){
        return nil;
    }
    
    // Create LM Ad View
    GADBannerView* adView = nil;
    adView = [[[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    
    if ([DeviceDetection isIPAD]){
        [adView setFrame:iPadFrame];
    }
    else{
        [adView setFrame:frame];
    }
    
              //   GADBannerView *adView =
              //       [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
              //   adView.rootViewController = self;
              //   adView.adUnitID = @"ID created when registering my app";
              //
              //   // Place the ad view onto the screen.
              //   [self.view addSubview:adView];
              //   [adView release];
              //
              //   // Request an ad without any additional targeting information.
              //   [adView loadRequest:nil];
              
    adView.tag = AD_VIEW_TAG;
    adView.rootViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
              adView.adUnitID = [ConfigManager getAdMobId];
    
    [adView loadRequest:nil];
              
    [superView addSubview:adView];
    return adView;

}

#pragma mark - Wanpu Delegates

- (void)onWanpuConnectSuccess:(id)sender
{
    PPDebug(@"<onWanpuConnectSuccess>");
}

- (void)onWanpuConnectFailed:(id)sender
{
    PPDebug(@"<onWanpuConnectFailed>");    
}

@end
