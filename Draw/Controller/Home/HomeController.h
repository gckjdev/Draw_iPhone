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

@interface HomeController : PPViewController<DrawGameServiceDelegate, RouterServiceDelegate, CommonDialogDelegate,DrawDataServiceDelegate, UserServiceDelegate, LmmobAdBannerViewDelegate,BoardServiceDelegate>
{
    BOOL        _isTryJoinGame;  
    BOOL        _isJoiningDice;
    UserManager *_userManager;
}
@property (retain, nonatomic) IBOutlet UIButton *facetimeButton;
@property (retain, nonatomic) IBOutlet UIButton *diceButton;
@property (retain, nonatomic) MenuPanel *menuPanel;

- (IBAction)clickCheckIn:(id)sender;
- (IBAction)clickFeedback:(id)sender;
- (IBAction)clickSettings:(id)sender;
- (IBAction)clickShare:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *shareButton;
@property (retain, nonatomic) IBOutlet UIButton *checkinButton;
@property (retain, nonatomic) IBOutlet UIButton *settingButton;
@property (retain, nonatomic) IBOutlet UIButton *feedbackButton;
//@property (nonatomic, assign) BOOL hasRemoveNotification; 
@property (nonatomic, assign) NotificationType notificationType; 
@property (retain, nonatomic) IBOutlet UILabel *settingLabel;
@property (retain, nonatomic) IBOutlet UILabel *shareLabel;
@property (retain, nonatomic) IBOutlet UILabel *signLabel;
@property (retain, nonatomic) IBOutlet UILabel *friendLabel;
@property (retain, nonatomic) IBOutlet UILabel *chatLabel;
@property (retain, nonatomic) IBOutlet UILabel *feedbackLabel;
@property (retain, nonatomic) IBOutlet UIButton *fanBadge;
@property (retain, nonatomic) IBOutlet UIButton *messageBadge;
@property (retain, nonatomic) UIView  *adView;
@property (retain, nonatomic) IBOutlet UIButton *recommendButton;

// Ad View
- (IBAction)clickChatButton:(id)sender;
- (IBAction)clickFriendsButton:(id)sender;

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
