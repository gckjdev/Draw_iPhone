//
//  ShoppingCell.h
//  Draw
//
//  Created by  on 12-3-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPTableViewCell.h"
#import "PriceModel.h"


@protocol ShoppingCellDelegate <NSObject>

@optional
- (void)didClickBuyButtonAtIndexPath:(NSIndexPath *)indexPath 
                                model:(PriceModel *)model;

@end

@interface ShoppingCell : PPTableViewCell
{

    PriceModel *_model;
    id<ShoppingCellDelegate>_shoppingDelegate;
}

@property(nonatomic, retain) PriceModel *model;
@property(nonatomic, assign)id<ShoppingCellDelegate>shoppingDelegate;
@property (retain, nonatomic) IBOutlet UIButton *buyButton;

- (IBAction)clickBuyButton:(id)sender;
@property (retain, nonatomic) IBOutlet UILabel *priceLabel;
@property (retain, nonatomic) IBOutlet UIImageView *coinImage;
@property (retain, nonatomic) IBOutlet UILabel *countLabel;
@property (retain, nonatomic) IBOutlet UIImageView *toolImage;
@property (retain, nonatomic) IBOutlet UIImageView *costCoinImage;

- (void)setCellInfo:(PriceModel *)model indexPath:(NSIndexPath *)aIndexPath;
@end
