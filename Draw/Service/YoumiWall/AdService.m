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
//#import "LmWallService.h"
//#import "AdMoGoView.h"
#import "UserManager.h"
#import "HomeController.h"
//#import <GoogleMobileAds/GoogleMobileAds.h>

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
//    [[LmWallService defaultService] show:_viewController isForRemoveAd:YES];
}

#pragma mark - Account Service Delegate

- (void)didFinishBuyProduct:(int)resultCode
{
    [_viewController hideActivity];
    
    if (resultCode != 0 && resultCode != PAYMENT_CANCEL){
//        [MobClick event:@"BUY_COINS_FAIL"];
        POSTMSG(NSLS(@"kFailToConnectIAPServer"));
        // clear view controller after finishing IAP
        [self setViewController:nil]; 
        return;
    }
    else if (resultCode == PAYMENT_CANCEL){
//        [MobClick event:@"BUY_COINS_CANCEL"];

        // clear view controller after finishing IAP
        [self setViewController:nil]; 
        return;
    }
    
    if (resultCode == 0){
//        [MobClick event:@"BUY_COINS_OK"];        
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

//#pragma mark - LM Ad View Delegate
//
//- (void) immobView: (immobView*) immobView didFailReceiveimmobViewWithError: (NSInteger) errorCode{
//    NSLog(@"errorCode:%i",errorCode);
//}
//- (void) onDismissScreen:(immobView *)immobView{
//    NSLog(@"onDismissScreen");
//}
//
///**
// *email phone sms等所需要
// *返回当前添加immobView的ViewController
// */
//- (UIViewController *)immobViewController{
//    
//    return nil;
//}
//
///**
// *根据广告的状态来决定当前广告是否展示到当前界面上 AdReady 
// *YES  当前广告可用
// *NO   当前广告不可用
// */
//- (void) immobViewDidReceiveAd:(immobView *)immobView{
//    //[adView_AdWall immobViewDisplay];
//    PPDebug(@"<immobViewDidReceiveAd>");    
//}


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
    
    if ([PPConfigManager isInReviewVersion]){
        return YES;
    }
    
    if ([PPConfigManager isProVersion])
        return NO;
    
    if ([PPConfigManager isEnableAd] == NO){
        return NO;
    }

    return ([[UserGameItemManager defaultManager] hasItem:ItemTypeRemoveAd] == NO);
}

- (void)clearAdView:(UIView*)adView
{
    if (adView == nil || adView.superview == nil){
        return;
    }
    
    @try {
        PPDebug(@"<clearAdView>");
        [adView removeFromSuperview];
    }
    @catch (NSException *exception) {
        PPDebug(@"<clearAdView> catch exception=%@", [exception description]);
    }
    @finally {
    }

}

- (UIView*)createLmAdInView:(UIView*)superView
                      appId:(NSString*)appId
                      frame:(CGRect)frame 
                  iPadFrame:(CGRect)iPadFrame
{
    return nil;
}

- (UIView*)createAdInView:(UIView*)superView
                    frame:(CGRect)frame 
                iPadFrame:(CGRect)iPadFrame
{        
    PPDebug(@"<createAdView>");
    
    if ([self isShowAd] == NO){
        return nil;
    }
    
    return [self createAdmobAdInView:superView frame:frame iPadFrame:iPadFrame];
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
}

- (UIView*)createAdInView:(UIView*)superView
             adPlatformType:(AdPlatformType)adPlatformType
              adPublisherId:(NSString*)adPublisherId
                      frame:(CGRect)frame 
                  iPadFrame:(CGRect)iPadFrame
{
    switch (adPlatformType) {
        case AdPlatformLm:
            return [self createLmAdInView:superView appId:adPublisherId frame:frame iPadFrame:iPadFrame];
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
    return nil;
}

@end
