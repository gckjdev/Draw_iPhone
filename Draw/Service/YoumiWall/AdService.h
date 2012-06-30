//
//  AdService.h
//  Draw
//
//  Created by  on 12-6-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AccountService.h"
#import <Lmmob/LmmobADBannerView.h>
#import "AdMoGoView.h"

@class PPViewController;

@interface AdService : NSObject<UIAlertViewDelegate, AccountServiceDelegate, LmmobAdBannerViewDelegate, AdMoGoDelegate>
{
//    LmmobAdBannerView   *_adView;
    NSMutableDictionary *_allAdViews;
}
+ (AdService*)defaultService;

- (BOOL)isShowAd;
- (void)requestRemoveAd:(PPViewController*)viewController;
- (void)setAdDisable;
//- (void)hideAdViewInView:(UIView*)superView;
//- (void)showAdInView:(UIViewController*)superViewContoller
//               frame:(CGRect)frame 
//           iPadFrame:(CGRect)iPadFrame;

- (void)clearAdView:(UIView*)adView;
- (UIView*)createAdInView:(UIViewController*)superViewContoller
                 frame:(CGRect)frame 
             iPadFrame:(CGRect)iPadFrame;


@property (nonatomic, retain) PPViewController* viewController;
@property (nonatomic, retain) UIViewController* adSuperViewController;
//@property (nonatomic, retain) LmmobAdBannerView* adView;

@end
