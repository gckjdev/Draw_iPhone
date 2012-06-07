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

@class UserManager;

@interface HomeController : PPViewController<DrawGameServiceDelegate, RouterServiceDelegate, CommonDialogDelegate>
{
    BOOL        _isTryJoinGame;    
    UserManager *_userManager;
}

- (IBAction)clickStart:(id)sender;
- (IBAction)clickPlayWithFriend:(id)sender;
- (IBAction)clickShop:(id)sender;
- (IBAction)clickCheckIn:(id)sender;
- (IBAction)clickFeedback:(id)sender;
- (IBAction)clickSettings:(id)sender;
- (IBAction)clickShare:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *startButton;
@property (retain, nonatomic) IBOutlet UIButton *shopButton;
@property (retain, nonatomic) IBOutlet UIButton *shareButton;
@property (retain, nonatomic) IBOutlet UIButton *checkinButton;
@property (retain, nonatomic) IBOutlet UIButton *settingButton;
@property (retain, nonatomic) IBOutlet UIButton *feedbackButton;
@property (retain, nonatomic) IBOutlet UILabel *settingsLabel;
@property (retain, nonatomic) IBOutlet UILabel *feedbackLabel;
@property (retain, nonatomic) IBOutlet UIButton *playWithFriendButton;
@property (retain, nonatomic) IBOutlet UIButton *guessButton;
@property (retain, nonatomic) IBOutlet UIButton *drawButton;
@property (nonatomic, assign) BOOL hasRemoveNotification; 

- (IBAction)clickDrawButton:(id)sender;
- (IBAction)clickGuessButton:(id)sender;



+ (HomeController *)defaultInstance;
+ (void)returnRoom:(UIViewController*)superController;

+ (void)startOfflineDrawFrom:(UIViewController *)viewController;
+ (void)startOfflineGuessDrawFrom:(UIViewController *)viewController;

@end
