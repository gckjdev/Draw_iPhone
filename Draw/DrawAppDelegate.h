//
//  DrawAppDelegate.h
//  Draw
//
//  Created by gamy on 12-3-4.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonNetworkClient.h"
#import "PPApplication.h"
#import "ReviewRequest.h"
#import "WXApi.h"
#import "DrawHomeControllerProtocol.h"

//#import "DMSplashAdController.h"
//#import "DMRTSplashAdController.h"


//#define DRAW_APP_ID      @"513819630"

@class OnlineDrawViewController;
@class RoomController;
@class NetworkDetector;
@class ChatDetailController;
@class HomeController;
@class CPMotionRecognizingWindow;

@interface DrawAppDelegate : PPApplication <UIApplicationDelegate, CommonNetworkClientDelegate, WXApiDelegate, ReviewRequestDelegate> {

    UIBackgroundTaskIdentifier bgTask;
//    DMSplashAdController *_splashAd;
//    DMRTSplashAdController* _rtsplashAd;
    

}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet OnlineDrawViewController *viewController;
@property (nonatomic, retain) ReviewRequest *reviewRequest; 

@property (nonatomic, retain) RoomController *roomController;
@property (nonatomic, retain) UINavigationController *rootNavigationController;
@property (nonatomic, retain) UIViewController<DrawHomeControllerProtocol> *homeController;
@property (nonatomic, retain) NetworkDetector *networkDetector;

@property (nonatomic, retain) ChatDetailController *chatDetailController;
@property (retain, nonatomic) NSTimer *timer;

@end
