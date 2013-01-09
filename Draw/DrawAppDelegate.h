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

//#define DRAW_APP_ID      @"513819630"

@class OnlineDrawViewController;
@class RoomController;
@class HomeController;
@class NetworkDetector;
@class ChatDetailController;
@class DiceHomeController;

@interface DrawAppDelegate : PPApplication <UIApplicationDelegate, CommonNetworkClientDelegate, WXApiDelegate, ReviewRequestDelegate> {

    UIBackgroundTaskIdentifier bgTask;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet OnlineDrawViewController *viewController;
@property (nonatomic, retain) ReviewRequest *reviewRequest; 

@property (nonatomic, retain) RoomController *roomController;
@property (nonatomic, retain) HomeController *homeController;
@property (nonatomic, retain) DiceHomeController *diceHomeController;
@property (nonatomic, retain) NetworkDetector *networkDetector;

@property (nonatomic, retain) ChatDetailController *chatDetailController;
@property (retain, nonatomic) NSTimer *timer;

@end
