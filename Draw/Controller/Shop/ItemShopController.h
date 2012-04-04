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

@interface ItemShopController : PPTableViewController<ShoppingCellDelegate, PriceServiceDelegate>
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
- (IBAction)clickBackButton:(id)sender;
@property (retain, nonatomic) IBOutlet UILabel *coinsAmountLabel;
@property (retain, nonatomic) IBOutlet UILabel *itemAmountLabel;

+(ItemShopController *)instance;
@end
