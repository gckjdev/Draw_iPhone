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

@interface HomeController : PPViewController<DrawGameServiceDelegate, RouterServiceDelegate>
{
    BOOL _isTryJoinGame;    
}

- (IBAction)clickStart:(id)sender;
- (IBAction)clickShop:(id)sender;

- (IBAction)clickFeedback:(id)sender;
- (IBAction)clickSettings:(id)sender;
- (IBAction)clickShare:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *startButton;
@property (retain, nonatomic) IBOutlet UIButton *shopButton;
@property (retain, nonatomic) IBOutlet UIButton *shareButton;
@property (retain, nonatomic) IBOutlet UIButton *checkinButton;
@property (retain, nonatomic) IBOutlet UIButton *settingButton;
@property (retain, nonatomic) IBOutlet UIButton *feedbackButton;

+ (HomeController *)defaultInstance;
+ (void)returnRoom:(UIViewController*)superController;
@end
