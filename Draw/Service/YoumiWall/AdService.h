//
//  AdService.h
//  Draw
//
//  Created by  on 12-6-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AccountService.h"
#import <immobSDK/immobView.h>
#import "AderSDK.h"
#import "AderDelegateProtocal.h"
#import "AdMoGoView.h"
#import "WapsOffer/AppConnect.h"
#import "GADBannerViewDelegate.h"

typedef enum
{
    AdPlatformAuto = 0,
    AdPlatformLm = 1,
    AdPlatformAder,
    AdPlatformMango,
    AdPlatformWanpu
} AdPlatformType;

@class PPViewController;

@protocol AdServiceDelegate <NSObject>

@optional
- (void)adLoad:(UIView*)adView;

@end

@interface AdService : NSObject<UIAlertViewDelegate, AccountServiceDelegate, immobViewDelegate, AdMoGoDelegate, AderDelegateProtocal, GADBannerViewDelegate>
{
    BOOL _isShowAd;
}

+ (AdService*)defaultService;

- (BOOL)isShowAd;
- (void)setAdDisable;
- (void)disableAd;
- (void)removeAdByIAP;

- (void)clearAdView:(UIView*)adView;


// Please call this method if you want to show Ad
- (UIView*)createAdInView:(PPViewController*)superViewContoller
                    frame:(CGRect)frame 
                iPadFrame:(CGRect)iPadFrame
                  useLmAd:(BOOL)useLmAd;

// the following is used before, don't use them
- (UIView*)createAdInView:(UIView*)superView
           adPlatformType:(AdPlatformType)adPlatformType
            adPublisherId:(NSString*)adPublisherId
                    frame:(CGRect)frame 
                iPadFrame:(CGRect)iPadFrame;

// the following is used before, don't use them
- (UIView*)createAdInView:(UIView*)superView
                    frame:(CGRect)frame 
                iPadFrame:(CGRect)iPadFrame;

// the following is used before, don't use them
- (UIView*)createLmAdInView:(UIView*)superView
                      frame:(CGRect)frame 
                  iPadFrame:(CGRect)iPadFrame;

// the following is used before, don't use them
- (UIView*)createWanpuAdInView:(UIView*)superView
                         frame:(CGRect)frame 
                     iPadFrame:(CGRect)iPadFrame;

// the following is used before, don't use them
- (UIView*)createAdmobAdInView:(UIView*)superView
                         frame:(CGRect)frame
                     iPadFrame:(CGRect)iPadFrame;

@property (nonatomic, retain) PPViewController* viewController;


@end
