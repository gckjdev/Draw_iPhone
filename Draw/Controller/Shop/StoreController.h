//
//  StoreController.h
//  Draw
//
//  Created by 王 小涛 on 13-3-4.
//
//

#import <UIKit/UIKit.h>
#import "CommonTabController.h"
#import "FriendController.h"
#import "ColorShopView.h"

@interface StoreController : CommonTabController <FriendControllerDelegate, ColorShopViewDelegate>

//@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIButton *backButton;
@property (retain, nonatomic) IBOutlet UIButton *chargeButton;


@end
