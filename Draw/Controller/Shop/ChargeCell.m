//
//  ChargeCell.m
//  Draw
//
//  Created by haodong on 13-3-7.
//
//

#import "ChargeCell.h"
#import "GameBasic.pb.h"

@interface ChargeCell()
@property (retain, nonatomic) PBSaleIngot *mySaleIngot;

@end


@implementation ChargeCell

- (void)dealloc
{
    [_mySaleIngot release];
    [_countLabel release];
    [_priceLabel release];
    [_discountButton release];
    [_buyButton release];
    [super dealloc];
}

+ (NSString*)getCellIdentifier
{
    return @"ChargeCell";
}

#define CHARGE_CELL_HEIHT ([DeviceDetection isIPAD] ? (140) : (70))
+ (CGFloat)getCellHeight
{
    return CHARGE_CELL_HEIHT;
}

- (void)setCellWith:(PBSaleIngot *)saleIngot indexPath:(NSIndexPath *)oneIndexPath
{
    self.mySaleIngot = saleIngot;
    self.indexPath = oneIndexPath;
    
    self.countLabel.text = [NSString stringWithFormat:@"x %d", _mySaleIngot.count];
    self.priceLabel.text = [NSString stringWithFormat:@"%@%@", _mySaleIngot.currency, _mySaleIngot.totalPrice];
    
    if ([_mySaleIngot hasSaving] && [_mySaleIngot.saving length] != 0) {
        self.discountButton.hidden = NO;
        [self.discountButton setTitle:[NSString stringWithFormat:@"%@%@", NSLS(@"kSaveMoney"), _mySaleIngot.saving] forState:UIControlStateNormal];
    } else {
        self.discountButton.hidden = YES;
    }
}

- (IBAction)clickBuyButton:(id)sender {
    if ([delegate respondsToSelector:@selector(didClickBuyButton:)]) {
        [delegate didClickBuyButton:indexPath];
    }
}

@end
