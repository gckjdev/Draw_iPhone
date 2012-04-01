//
//  CoinShopController.h
//  Draw
//
//  Created by  on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPTableViewController.h"
#import "ShoppingCell.h"
#import "PriceService.h"

@interface CoinShopController : PPTableViewController<ShoppingCellDelegate, PriceServiceDelegate>
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;

@property (retain, nonatomic) IBOutlet UILabel *coinNumberLabel;
- (IBAction)clickBackButton:(id)sender;

+(CoinShopController *)instance;

@end
