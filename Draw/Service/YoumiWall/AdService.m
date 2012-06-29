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

#define ASK_REMOVE_AD_BY_WALL       101
#define ASK_REMOVE_AD_BY_IAP        102

#define AD_VIEW_TAG                 201206281

@interface AdService()

- (void)gotoWall;
- (void)buyCoins;

@end

@implementation AdService

@synthesize viewController = _viewController;
//@synthesize adView = _adView;

static AdService* _defaultService;

- (void)dealloc
{
//    PPRelease(_adView);
    PPRelease(_viewController);
    PPRelease(_allAdViews);
    [super dealloc];
}

- (id)init
{
    self = [super init];
    _allAdViews = [[NSMutableDictionary alloc] init];
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
    return [MobClickUtils getIntValueByKey:@"" defaultValue:1];
}

- (void)setAdDisable
{
    PPDebug(@"<setAdDisable> Ad Is Disabled Now");
    
    [[AccountService defaultService] buyItem:ITEM_TYPE_REMOVE_AD 
                                   itemCount:1
                                   itemCoins:[self getRemoveAdPrice]];
    
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
        [MobClick event:@"BUY_COINS_OK"];        
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

- (void) lmmobAdBannerViewDidReceiveAd: (LmmobAdBannerView*) bannerView{
    
    PPDebug(@"<lmmobAdBannerViewDidReceiveAd> success");    
}

- (void) lmmobAdBannerViewWillPresentScreen: (LmmobAdBannerView*) bannerView{
    PPDebug(@"<lmmobAdBannerViewWillPresentScreen> success");        
}

- (void) lmmobAdBannerView: (LmmobAdBannerView*) bannerView didFailReceiveBannerADWithError: (NSError*) error{
    PPDebug(@"<didFailReceiveBannerADWithError>:%@", error);    
}

#pragma mark - Ad View Dictionary Management

- (void)addAdView:(UIView*)adView superView:(UIView*)superView
{
    if (superView == nil || adView == nil)
        return;

    NSString* key = [superView description];
    [_allAdViews setObject:adView forKey:key];
}

- (UIView*)adViewBySuperView:(UIView*)superView
{
    if (superView == nil)
        return nil;
    
    NSString* key = [superView description];
    return [_allAdViews objectForKey:key];
}

#pragma mark - Methods For External

- (void)requestRemoveAd:(PPViewController*)viewController
{
    self.viewController = viewController;
    if ([ConfigManager wallEnabled]){
        [self askRemoveAdByWall];
    }
    else{
        [self askRemoveAdByBuyCoins];
    }    
}

- (BOOL)isShowAd
{
//    return YES;
    
    BOOL hasItemBought = [[AccountService defaultService] hasEnoughItemAmount:ITEM_TYPE_REMOVE_AD 
                                                                     amount:1];
    return (hasItemBought == NO); // item not bought, then show Ad
}

- (void)hideAdViewInView:(UIView*)superView;
{
    UIView* adView = [self adViewBySuperView:superView];    
    if ([adView superview] != nil){
        [adView removeFromSuperview];
    }
}

- (void)showAdInView:(UIView*)superView frame:(CGRect)frame iPadFrame:(CGRect)iPadFrame
{
    LmmobAdBannerView* adView = (LmmobAdBannerView*)[self adViewBySuperView:superView];
    
    if ([self isShowAd] == NO){
        // Ad Disable, Remove Ad View
        [adView removeFromSuperview];
        return;
    }
    
    if ([superView viewWithTag:AD_VIEW_TAG] != nil){
        // Ad View Exist, Return
        return;
    }
    
    BOOL firstRequest = NO;
    if (adView == nil){
        if ([DeviceDetection isIPAD]){
            adView = [[LmmobAdBannerView alloc] initWithFrame:iPadFrame];
            adView.adPositionIdString = @"5a1da27e02e91c4bf169452cef159a6e";    
            adView.specId = 0;
        }
        else{
            adView = [[LmmobAdBannerView alloc] initWithFrame:frame];
            adView.adPositionIdString = @"eb4ce4f0a0f1f49b6b29bf4c838a5147";
            adView.specId = 0;
        }
        
        [self addAdView:adView superView:superView];
        firstRequest = YES;
    }
    
    if ([DeviceDetection isIPAD]){
        [adView setFrame:iPadFrame];
    }
    else{
        [adView setFrame:frame];
    }
    
    adView.tag = AD_VIEW_TAG;
    adView.appVersionString = [UIUtils getAppVersion];
    adView.delegate = self;
    adView.autoRefreshAdTimeOfSeconds = 30;
    [superView addSubview:adView];
    
    if (firstRequest){
        [adView requestBannerAd];    
    }
}



@end
