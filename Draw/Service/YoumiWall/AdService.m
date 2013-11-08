//
//  AdService.m
//  Draw
//
//  Created by  on 12-6-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AdService.h"
#import "PPConfigManager.h"
#import "CommonDialog.h"
#import "LocaleUtils.h"
#import "ShoppingManager.h"
#import "PPViewController.h"
#import "DeviceDetection.h"
#import "LmWallService.h"
//#import "AdMoGoView.h"
#import "UserManager.h"
#import "HomeController.h"
#import "GADBannerView.h"

#import "UserGameItemManager.h"
#import "GameItemService.h"
#import "GameItemManager.h"
#import "UserGameItemService.h"

//#import "YoumiWallService.h"
//#import "YoumiWallController.h"

#define ASK_REMOVE_AD_BY_WALL       101

#define AD_VIEW_TAG                 201206281

@interface AdService()

@end

@implementation AdService

@synthesize viewController = _viewController;

static AdService* _defaultService;

- (void)dealloc
{
    PPRelease(_viewController);
    [super dealloc];
}


- (id)init
{
    self = [super init];

    
     _isShowAd = ([[UserGameItemManager defaultManager] hasItem:ItemTypeRemoveAd] == NO);
    
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

- (void)disableAd
{
    _isShowAd = NO;
}

// old, will be deleted after new item implementation is fully done and tested
- (void)setAdDisable
{
    PPDebug(@"<setAdDisable> Ad Is Disabled Now");
    
    [[UserGameItemService defaultService] buyItem:ItemTypeRemoveAd count:1 handler:NULL];
    _isShowAd = NO;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0){
        return;
    }
    
    switch (alertView.tag) {
        case ASK_REMOVE_AD_BY_WALL:
            [self gotoWall];
            break;
            
        default:
            break;
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
        POSTMSG(NSLS(@"kFailToConnectIAPServer"));
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
        POSTMSG(NSLS(@"kBuyCoinsSucc"));
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
- (void) immobViewDidReceiveAd:(immobView *)immobView{
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

//- (void)adMoGoDidReceiveAd:(AdMoGoView *)adMoGoView
//{
//    PPDebug(@"<adMoGoDidReceiveAd>");
//}
//
//- (void)adMoGoDeleteAd:(AdMoGoView *)adMoGoView
//{
//    PPDebug(@"<adMoGoDeleteAd>");    
//}
//
//- (void)adMoGoDidFailToReceiveAd:(AdMoGoView *)adMoGoView usingBackup:(BOOL)yesOrNo
//{
//    PPDebug(@"<adMoGoDidFailToReceiveAd> usingBackup=%d", yesOrNo);    
//}

- (NSString *)gender
{
    return [[UserManager defaultManager] gender];
}

#pragma mark - Methods For External

- (BOOL)isShowAd
{
//#ifdef DEBUG
//    return YES;
//#endif
    
    if ([PPConfigManager isProVersion])
        return NO;
    
    if ([PPConfigManager isEnableAd] == NO){
        return NO;
    }

    return ([[UserGameItemManager defaultManager] hasItem:ItemTypeRemoveAd] == NO);
}

//- (UIView*)createMangoAdInView:(UIView*)superView
//                         frame:(CGRect)frame 
//                     iPadFrame:(CGRect)iPadFrame
//{
//    if ([self isShowAd] == NO){
//        return nil;
//    }
//        
//    AdMoGoView* adView = nil;
//    
//    // create view
//    adView = [AdMoGoView requestAdMoGoViewWithDelegate:self 
//                                             AndAdType:AdViewTypeNormalBanner
//                                           ExpressMode:YES];
//    
//    // set view frame
//    if ([DeviceDetection isIPAD]){
//        [adView setFrame:iPadFrame];
//    }
//    else{
//        [adView setFrame:frame];
//    }
//    
//    // set view data
//    adView.tag = AD_VIEW_TAG;
//    adView.delegate = self;
//    
//    // add to super view
//    [superView addSubview:adView];
//    [adView resumeAdRequest];
//    return adView;
//}


- (void)clearAdView:(UIView*)adView
{
    if (adView == nil || adView.superview == nil){
        return;
    }
    
    @try {
        PPDebug(@"<clearAdView>");
        [adView removeFromSuperview];
        
//        if ([adView isKindOfClass:[AdMoGoView class]]){
//            [((AdMoGoView*)adView) pauseAdRequest];
//            ((AdMoGoView*)adView).delegate = nil;
//        }
        if ([adView isKindOfClass:[immobView class]]){
            ((immobView*)adView).delegate = nil;  
        }        
    }
    @catch (NSException *exception) {
        PPDebug(@"<clearAdView> catch exception=%@", [exception description]);
    }
    @finally {
    }

}

//- (void)pauseAdView:(UIView*)adView
//{
////    if ([adView isKindOfClass:[AdMoGoView class]]){
////        [((AdMoGoView*)adView) pauseAdRequest];
////    }
//    if ([adView isKindOfClass:[immobView class]]){
//        // Do Nothing For Lmmob, because of not support
//    }
//    
////    [AderSDK pauseAdService:YES];
//}
//
//- (void)resumeAdView:(UIView*)adView
//{
////    if ([adView isKindOfClass:[AdMoGoView class]]){
////        [((AdMoGoView*)adView) resumeAdRequest];
////    }
//    if ([adView isKindOfClass:[immobView class]]){
//        // Do Nothing For Lmmob, because of not support
//    }    
//    
//    [AderSDK pauseAdService:NO];
//}
//
//- (UIView*)createAderAdInView:(UIView*)superView
//                        appId:(NSString*)appId
//                        frame:(CGRect)frame 
//                    iPadFrame:(CGRect)iPadFrame
//{
//    PPDebug(@"<createAderAdInView>");
//    [AderSDK setDelegate:self];    
//    if ([DeviceDetection isIPAD]){
//        [AderSDK startAdService:superView
//                          appID:appId
//                        adFrame:iPadFrame 
//                          model:MODEL_RELEASE];
//    }
//    else{
//        [AderSDK startAdService:superView
//                          appID:appId
//                        adFrame:frame 
//                          model:MODEL_RELEASE];
//    }
//    
//    return nil;
//}
//
//
//- (UIView*)createAderAdInView:(UIView*)superView
//                        frame:(CGRect)frame 
//                    iPadFrame:(CGRect)iPadFrame
//{
//    PPDebug(@"<createAderAdInView>");
//    [AderSDK setDelegate:self];    
//    if ([DeviceDetection isIPAD]){
//        [AderSDK startAdService:superView
//                          appID:[GameApp aderAdPublisherId] // @"3b47607e44f94d7c948c83b7e6eb800e" 
//                        adFrame:iPadFrame 
//                          model:MODEL_RELEASE];
//    }
//    else{
//        [AderSDK startAdService:superView
//                          appID:[GameApp aderAdPublisherId] // @"3b47607e44f94d7c948c83b7e6eb800e" 
//                        adFrame:frame 
//                          model:MODEL_RELEASE];
//    }
//    
//    return nil;
//}

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

//- (UIView*)createWanpuAdInView:(UIView*)superView
//                      appId:(NSString*)appId
//                      frame:(CGRect)frame 
//                  iPadFrame:(CGRect)iPadFrame
//{    
//    PPDebug(@"<createWanpuAdInView> at view %@", [superView description]);
//    
////    UIView* view = [AppConnect getDisplayAdView];
//    [view removeFromSuperview];
//    
//    if ([DeviceDetection isIPAD]){
//        [AppConnect displayAd:_viewController showX:0 showY:iPadFrame.origin.y-1];
//    }
//    else{
//        [AppConnect displayAd:_viewController showX:frame.origin.x showY:frame.origin.y-1];
//    }
//        
//    // hack Wanpu Ad View here, remove it from its super view and add into the right view we want
//    view = [AppConnect getDisplayAdView];
////    [view removeFromSuperview];
//    
//    if ([DeviceDetection isIPAD]){
//        view.frame = iPadFrame;
//    }
//    else{
//        view.frame = frame;
//    }
//    
//    [superView addSubview:view];    
//    return view;
//}

- (UIView*)createAdInView:(UIView*)superView
                    frame:(CGRect)frame 
                iPadFrame:(CGRect)iPadFrame
{        
    PPDebug(@"<createAdView>");
    
    if ([self isShowAd] == NO){
        return nil;
    }
    
    return [self createAdmobAdInView:superView frame:frame iPadFrame:iPadFrame];
//
//    if ([self isShowWanpuAd] == YES){
//        return [self createWanpuAdInView:superView frame:frame iPadFrame:iPadFrame];
//    }        
    
//    if ([self isShowAderAd] == YES){
//        return [self createAderAdInView:superView frame:frame iPadFrame:iPadFrame];
//    }
//    
//    if ([self isShowLmAd] == NO){
//        return [self createMangoAdInView:superView frame:frame iPadFrame:iPadFrame];
//    }
    
//    return [self createLmAdInView:superView
//                            appId:[GameApp lmAdPublisherId] //@"eb4ce4f0a0f1f49b6b29bf4c838a5147" 
//                            frame:frame 
//                        iPadFrame:iPadFrame];            
}


- (UIView*)createAdInView:(PPViewController*)superViewContoller
                    frame:(CGRect)frame 
                iPadFrame:(CGRect)iPadFrame
                  useLmAd:(BOOL)useLmAd
{        
    
    if ([self isShowAd] == NO){
        PPDebug(@"<createAdView> but ad is disabled");
        return nil;
    }
    
    PPDebug(@"<createAdView>");
    return [self createAdmobAdInView:superViewContoller.view frame:frame iPadFrame:iPadFrame];

    
//    return [self createLmAdInView:superViewContoller.view 
//                            appId:[GameApp lmAdPublisherId] //@"eb4ce4f0a0f1f49b6b29bf4c838a5147" 
//                            frame:frame 
//                        iPadFrame:iPadFrame];            
}

- (UIView*)createAdInView:(UIView*)superView
             adPlatformType:(AdPlatformType)adPlatformType
              adPublisherId:(NSString*)adPublisherId
                      frame:(CGRect)frame 
                  iPadFrame:(CGRect)iPadFrame
{
    switch (adPlatformType) {
//        case AdPlatformAder:
//            return [self createAderAdInView:superView appId:adPublisherId frame:frame iPadFrame:iPadFrame];
            
        case AdPlatformLm:
            return [self createLmAdInView:superView appId:adPublisherId frame:frame iPadFrame:iPadFrame];

//        case AdPlatformMango:
//            return [self createMangoAdInView:superView frame:frame iPadFrame:iPadFrame];
//            
//        case AdPlatformWanpu:
//            return [self createWanpuAdInView:superView frame:frame iPadFrame:iPadFrame];
//            
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

//- (UIView*)createWanpuAdInView:(UIView*)superView
//                         frame:(CGRect)frame 
//                     iPadFrame:(CGRect)iPadFrame
//{
//    return [self createWanpuAdInView:superView
//                            appId:[GameApp wanpuAdPublisherId] //@"eb4ce4f0a0f1f49b6b29bf4c838a5147" 
//                            frame:frame 
//                        iPadFrame:iPadFrame];
//}

- (void)loadAdmobView:(GADBannerView*)adView
{
    GADRequest* request = [[GADRequest alloc] init];
    [request setGender:[[UserManager defaultManager] isUserMale] ? kGADGenderMale : kGADGenderFemale];
    if ([[UserManager defaultManager] hasUser]){
        [adView loadRequest:request];
    }
    else{
        [adView loadRequest:nil];
    }
    [request release];
}

- (UIView*)createAdmobAdInView:(UIView*)superView
                         frame:(CGRect)frame
                     iPadFrame:(CGRect)iPadFrame
{
    if ([self isShowAd] == NO){
        return nil;
    }
    
    if (frame.size.height == 0 && frame.size.width == 0 && [DeviceDetection isIPAD] == NO){
        return nil;
    }

    GADBannerView* adView = nil;
    adView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    
    if ([DeviceDetection isIPAD]){
        [adView setFrame:iPadFrame];
    }
    else{
        [adView setFrame:frame];
    }
                  
    adView.tag = AD_VIEW_TAG;
    adView.rootViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    adView.adUnitID = [PPConfigManager getAdMobId];
    adView.delegate = self;
    
    [self loadAdmobView:adView];
              
    [superView addSubview:adView];
    return adView;

}

#pragma mark - Wanpu Delegates

//- (void)onWanpuConnectSuccess:(id)sender
//{
//    PPDebug(@"<onWanpuConnectSuccess>");
//}
//
//- (void)onWanpuConnectFailed:(id)sender
//{
//    PPDebug(@"<onWanpuConnectFailed>");    
//}

#pragma mark - AdMob Delegate

- (void)adViewDidReceiveAd:(GADBannerView *)view
{
    PPDebug(@"<adViewDidReceiveAd> success");
    
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error;
{
    PPDebug(@"<didFailToReceiveAdWithError> error=%@", [error description]);
//    [self loadAdmobView:view];
}

#pragma mark Click-Time Lifecycle Notifications

// Sent just before presenting the user a full screen view, such as a browser,
// in response to clicking on an ad.  Use this opportunity to stop animations,
// time sensitive interactions, etc.
//
// Normally the user looks at the ad, dismisses it, and control returns to your
// application by calling adViewDidDismissScreen:.  However if the user hits the
// Home button or clicks on an App Store link your application will end.  On iOS
// 4.0+ the next method called will be applicationWillResignActive: of your
// UIViewController (UIApplicationWillResignActiveNotification).  Immediately
// after that adViewWillLeaveApplication: is called.
//- (void)adViewWillPresentScreen:(GADBannerView *)adView
//{
//    PPDebug(@"<adViewWillPresentScreen>");      
//}
//
//// Sent just before dismissing a full screen view.
//- (void)adViewWillDismissScreen:(GADBannerView *)adView
//{
//    PPDebug(@"<adViewWillDismissScreen>");      
//}
//
//// Sent just after dismissing a full screen view.  Use this opportunity to
//// restart anything you may have stopped as part of adViewWillPresentScreen:.
//- (void)adViewDidDismissScreen:(GADBannerView *)adView
//{
//    PPDebug(@"<adViewDidDismissScreen>");    
//}
//
//// Sent just before the application will background or terminate because the
//// user clicked on an ad that will launch another application (such as the App
//// Store).  The normal UIApplicationDelegate methods, like
//// applicationDidEnterBackground:, will be called immediately before this.
//- (void)adViewWillLeaveApplication:(GADBannerView *)adView
//{
//    PPDebug(@"<adViewWillLeaveApplication>");
//}

@end
