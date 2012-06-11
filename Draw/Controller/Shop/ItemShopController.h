//
//  ItemShopController.h
//  Draw
//
//  Created by  on 12-3-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPTableViewController.h"
#import "ShoppingCell.h"
#import "PriceService.h"
#import "CommonDialog.h"

@class CoinShopController;

enum{
    DIALOG_ACTION_ASK_BUY_COIN = 1
};

@interface ItemShopController : PPTableViewController<ShoppingCellDelegate, PriceServiceDelegate, CommonDialogDelegate>
{
    int _dialogAction;
    CoinShopController *_coinController;
}

@property (retain, nonatomic) IBOutlet UIButton *freeGetCoinsButton;

@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UILabel *coinsAmountLabel;
@property (retain, nonatomic) IBOutlet UILabel *itemAmountLabel;
@property (retain, nonatomic) IBOutlet UIButton *gotoCoinShopButton;
@property (assign, nonatomic) BOOL callFromShowViewController;

- (IBAction)clickBackButton:(id)sender;
- (IBAction)clickGotoCoinShopButton:(id)sender;
+(ItemShopController *)instance;
- (UINavigationController *)topNavigationController;

- (IBAction)showYoumiWall;

@end
