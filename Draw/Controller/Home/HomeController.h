//
//  HomeController.h
//  Draw
//
//  Created by  on 12-3-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPViewController.h"
#import "DrawGameService.h"
#import "RouterService.h"
#import "CommonDialog.h"
#import "DrawDataService.h"
#import "NotificationManager.h"
#import "UserService.h"
#import "SuperHomeController.h"
#import "ContestService.h"
#import "WallService.h"
#import "DrawHomeControllerProtocol.h"

@class UserManager;
@class MenuPanel;
@class BottomMenuPanel;

@interface HomeController : SuperHomeController<DrawGameServiceDelegate, RouterServiceDelegate, CommonDialogDelegate,DrawDataServiceDelegate, UserServiceDelegate, WallServiceDelegate, DrawHomeControllerProtocol, ContestServiceDelegate>
{
    BOOL        _isTryJoinGame;  
    UserManager *_userManager;
    BOOL        _connectState;
}


@property (retain, nonatomic) MenuPanel *menuPanel;
@property (retain, nonatomic) BottomMenuPanel *bottomMenuPanel;

@property (retain, nonatomic) IBOutlet UIButton *recommendButton;
@property (retain, nonatomic) IBOutlet UIButton *facetimeButton;
//@property (retain, nonatomic) UIView  *adView;
@property (nonatomic, assign) NotificationType notificationType; 
@property (retain, nonatomic) IBOutlet UIButton *testBulletin;

@property (retain, nonatomic) IBOutlet UIButton *testCreateWallBtn;


// Ad View

+ (HomeController *)defaultInstance;
+ (void)returnRoom:(UIViewController*)superController;

+ (void)startOfflineDrawFrom:(UIViewController *)viewController;

+ (void)startOfflineDrawFrom:(UIViewController *)viewController 
                      uid:(NSString *)uid;

+ (void)startOfflineGuessDraw:(DrawFeed *)feed
                         from:(UIViewController *)viewController;

- (void)enterShareFromWeixin;

@end
