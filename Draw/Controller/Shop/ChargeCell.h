//
//  ChargeCell.h
//  Draw
//
//  Created by haodong on 13-3-7.
//
//

#import "PPTableViewCell.h"

@protocol ChargeCellDelegate <NSObject>

@optional
- (void)didClickBuyButton:(NSIndexPath *)indexPath;

@end

@class PBSaleIngot;

@interface ChargeCell : PPTableViewCell
@property (retain, nonatomic) IBOutlet UILabel *countLabel;
@property (retain, nonatomic) IBOutlet UILabel *priceLabel;
@property (retain, nonatomic) IBOutlet UIButton *discountButton;
@property (retain, nonatomic) IBOutlet UIButton *buyButton;

- (void)setCellWith:(PBSaleIngot *)saleIngot indexPath:(NSIndexPath *)oneIndexPath;

@end
