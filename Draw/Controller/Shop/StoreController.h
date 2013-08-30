//
//  StoreController.h
//  Draw
//
//  Created by 王 小涛 on 13-3-4.
//
//

#import <UIKit/UIKit.h>
#import "CommonTabController.h"
#import "ColorShopView.h"
#import "AccountService.h"
#import "LocalizableLabel.h"

@interface StoreController : CommonTabController <ColorShopViewDelegate, AccountServiceDelegate>

//@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIButton *backButton;
@property (retain, nonatomic) IBOutlet UIButton *chargeButton;
@property (retain, nonatomic) IBOutlet UILabel *coinBalanceLabel;
@property (retain, nonatomic) IBOutlet UILabel *ingotBalanceLabel;
@property (retain, nonatomic) IBOutlet UIImageView *ingotImageView;
@property (retain, nonatomic) IBOutlet UIImageView *ingotBalanceBgImageView;
@property (retain, nonatomic) IBOutlet UIView *coinHolderView;
@property (retain, nonatomic) IBOutlet UIView *ingotHolderView;
@property (retain, nonatomic) IBOutlet UIImageView *bottomBarImageView;
@property (retain, nonatomic) IBOutlet UIImageView *coinBalanceBgImageView;
@property (retain, nonatomic) IBOutlet LocalizableLabel *balanceTipLabel;

@end
