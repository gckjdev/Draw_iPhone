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
#import <Lmmob/LmmobADBannerView.h>
#import "BoardService.h"
@class UserManager;
@class MenuPanel;
@class BottomMenuPanel;

@interface HomeController : PPViewController<DrawGameServiceDelegate, RouterServiceDelegate, CommonDialogDelegate,DrawDataServiceDelegate, UserServiceDelegate, LmmobAdBannerViewDelegate,BoardServiceDelegate>
{
    BOOL        _isTryJoinGame;  
    BOOL        _isJoiningDice;
    UserManager *_userManager;
}

@property (retain, nonatomic) IBOutlet UIButton *diceButton;
@property (retain, nonatomic) MenuPanel *menuPanel;
@property (retain, nonatomic) BottomMenuPanel *bottomMenuPanel;

@property (retain, nonatomic) IBOutlet UIButton *recommendButton;
@property (retain, nonatomic) IBOutlet UIButton *facetimeButton;
@property (retain, nonatomic) UIView  *adView;
@property (nonatomic, assign) NotificationType notificationType; 



// Ad View

+ (HomeController *)defaultInstance;
+ (void)returnRoom:(UIViewController*)superController;

+ (void)startOfflineDrawFrom:(UIViewController *)viewController;

+ (void)startOfflineDrawFrom:(UIViewController *)viewController 
                      uid:(NSString *)uid;

+ (void)startOfflineGuessDraw:(Feed *)feed 
                         from:(UIViewController *)viewController;

- (void)updateBadgeWithUserInfo:(NSDictionary *)userInfo;
- (IBAction)clickAnnounce:(id)sender;

- (void)enterShareFromWeixin;
@end
