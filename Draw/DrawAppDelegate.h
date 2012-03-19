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

@class DrawViewController;
@class RoomController;
@class HomeController;

@interface DrawAppDelegate : PPApplication <UIApplicationDelegate, CommonNetworkClientDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet DrawViewController *viewController;

@property (nonatomic, retain) RoomController *roomController;
@property (nonatomic, retain) HomeController *homeController;


@end
