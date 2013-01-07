//
//  LmWallService.h
//  Draw
//
//  Created by  on 12-6-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <immobSDK/immobView.h>


@interface LmWallService : NSObject<immobViewDelegate>
{
    UIViewController* _viewController;
    
}

@property (nonatomic, retain)immobView *adWallView;

+ (LmWallService*)defaultService;
- (void)show:(UIViewController*)viewController;
- (void)show:(UIViewController*)viewController isForRemoveAd:(BOOL)isForRemoveAd;
- (void)queryScore;
+ (void)showWallOnController:(UIViewController*)controller;

@end
