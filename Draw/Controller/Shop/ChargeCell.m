//
//  ChargeCell.m
//  Draw
//
//  Created by haodong on 13-3-7.
//
//

#import "ChargeCell.h"
#import "GameBasic.pb.h"
#import "ShareImageManager.h"

@interface ChargeCell()
@property (retain, nonatomic) PBIAPProduct *product;

@end


@implementation ChargeCell

- (void)dealloc
{
    [_product release];
    [_countLabel release];
    [_priceLabel release];
    [_discountButton release];
    [_buyButton release];
    [_productImageView release];
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

- (void)setCellWith:(PBIAPProduct *)product indexPath:(NSIndexPath *)oneIndexPath
{
    self.product = product;
    self.indexPath = oneIndexPath;
    
    if (product.type == PBIAPProductTypeIapingot) {
        self.productImageView.image = [[ShareImageManager defaultManager] currencyImageWithType:(product.type == PBIAPProductTypeIapingot ? PBGameCurrencyIngot : PBGameCurrencyCoin)];
    }
    
    self.countLabel.text = [NSString stringWithFormat:@"x %d", _product.count];
    self.priceLabel.text = [NSString stringWithFormat:@"%@%@", _product.currency, _product.totalPrice];
    
    if ([_product hasSaving] && [_product.saving length] != 0) {
        self.discountButton.hidden = NO;
        [self.discountButton setTitle:[NSString stringWithFormat:@"%@%@", NSLS(@"kSaveMoney"), _product.saving] forState:UIControlStateNormal];
    } else {
        self.discountButton.hidden = YES;
    }
    
    [self.buyButton setTitle:NSLS(@"kBuy") forState:UIControlStateNormal];
}

- (IBAction)clickBuyButton:(id)sender {
    if ([delegate respondsToSelector:@selector(didClickBuyButton:)]) {
        [delegate didClickBuyButton:indexPath];
    }
}

@end
