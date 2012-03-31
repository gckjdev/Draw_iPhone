//
//  ShopMainController.h
//  Draw
//
//  Created by  on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShopMainController : UIViewController

@property (retain, nonatomic) IBOutlet UIButton *buyCoinButton;
@property (retain, nonatomic) IBOutlet UIButton *buyItemButton;
- (IBAction)clickBuyCoinButton:(id)sender;
- (IBAction)clickBuyItemButton:(id)sender;
@property (retain, nonatomic) IBOutlet UILabel *coinNumberLabel;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIImageView *showcaseBg;
@property (retain, nonatomic) IBOutlet UIButton *backButton;
@property (retain, nonatomic) IBOutlet UILabel *itemNumberLabel;
- (IBAction)clickBackButton:(id)sender;
@end
