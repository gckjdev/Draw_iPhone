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
#import "PBIAPProduct+Utils.h"

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
    [_cellBgImageView release];
    [super dealloc];
}

+ (NSString*)getCellIdentifier
{
    return @"ChargeCell";
}

#define CHARGE_CELL_HEIHT ([DeviceDetection isIPAD] ? (153) : (70))
+ (CGFloat)getCellHeight
{
    return CHARGE_CELL_HEIHT;
}

- (void)setCellWith:(PBIAPProduct *)product indexPath:(NSIndexPath *)oneIndexPath
{
    self.product = product;
    self.indexPath = oneIndexPath;
    
    if (product.type == PBIAPProductTypeIapingot) {
        self.productImageView.image = [[ShareImageManager defaultManager] currencyImageWithType:PBGameCurrencyIngot];
    }else if(product.type == PBIAPProductTypeIapcoin){
        self.productImageView.image = [[ShareImageManager defaultManager] currencyImageWithType:PBGameCurrencyCoin];
    }else{
        self.productImageView.image = nil;
    } 
    
    self.priceLabel.text = [product localizedPrice];
    
    if (_product.count < 10000) {
        self.countLabel.text = [NSString stringWithFormat:@"x %d", _product.count];
    }else{
        self.countLabel.text = [NSString stringWithFormat:@"x%d", _product.count];
    }
    
    if ([_product hasSaving] && [_product.saving length] != 0) {
        self.discountButton.hidden = NO;
        [self.discountButton setTitle:[NSString stringWithFormat:@"%@%@", NSLS(@"kSaveMoney"), _product.saving] forState:UIControlStateNormal];
    } else {
        self.discountButton.hidden = YES;
    }
    
    [self.buyButton setTitle:NSLS(@"kBuy") forState:UIControlStateNormal];
    
    self.cellBgImageView.layer.borderWidth = (ISIPAD ? 4 : 2);
    self.cellBgImageView.layer.borderColor = [COLOR_YELLOW CGColor];
    self.cellBgImageView.backgroundColor = COLOR_GRAY;
    SET_VIEW_ROUND_CORNER(self.cellBgImageView);
        
    self.discountButton.backgroundColor = COLOR_GREEN;
    SET_VIEW_ROUND_CORNER(self.discountButton);
    
    self.buyButton.backgroundColor = COLOR_ORANGE;
    SET_VIEW_ROUND_CORNER(self.buyButton);
    
    [self.buyButton setTitleColor:COLOR_WHITE forState:UIControlStateNormal];
    
}

- (IBAction)clickBuyButton:(id)sender {
    if ([delegate respondsToSelector:@selector(didClickBuyButton:)]) {
        [delegate didClickBuyButton:indexPath];
    }
}

@end
