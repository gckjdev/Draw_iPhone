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

@class PPViewController;

@interface AdService : NSObject<UIAlertViewDelegate, AccountServiceDelegate, LmmobAdBannerViewDelegate>
{
//    LmmobAdBannerView   *_adView;
    NSMutableDictionary *_allAdViews;
}
+ (AdService*)defaultService;

- (BOOL)isShowAd;
- (void)requestRemoveAd:(PPViewController*)viewController;
- (void)showAdInView:(UIView*)superView frame:(CGRect)frame iPadFrame:(CGRect)iPadFrame;
- (void)setAdDisable;
- (void)hideAdViewInView:(UIView*)superView;

@property (nonatomic, retain) PPViewController* viewController;
//@property (nonatomic, retain) LmmobAdBannerView* adView;

@end
