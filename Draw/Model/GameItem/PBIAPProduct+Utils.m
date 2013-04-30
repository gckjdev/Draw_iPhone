//
//  PBIAPProduct+Utils.m
//  Draw
//
//  Created by 王 小涛 on 13-4-29.
//
//

#import "PBIAPProduct+Utils.h"
#import "SKProductManager.h"
#import "SKProduct+LocalizedPrice.h"
#import "LocaleUtils.h"

@implementation PBIAPProduct (Utils)

- (NSString *)localizedPrice;
{
    SKProduct *product = [[SKProductManager defaultManager] productWithId:self.appleProductId];
    NSString *localizePrice = product.localizedPrice;

    if ([localizePrice length] > 0) {
        return localizePrice;
    }else{
        NSString *countryCode = [LocaleUtils getCountryCode];
        PBIAPProductPrice *price = [self priceInCountry:countryCode];
        if (price == nil) {
            price = [self priceInCountry:@"US"];
        }
        
        if (price == nil) {
            PPDebug(@"Warnning: IAPProduct using default price!");
            return [NSString stringWithFormat:@"%@%@", self.currency, self.totalPrice];
        }
        
        localizePrice = [NSString stringWithFormat:@"%@%@", price.currency, price.price];
        return localizePrice;  
    }
}

- (PBIAPProductPrice *)priceInCountry:(NSString *)countryCode
{
    for (PBIAPProductPrice *price in self.pricesList) {
        if ([price.country isEqualToString:countryCode]) {
            return price;
        }
    }
    
    return nil;
}

@end
