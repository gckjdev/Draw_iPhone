//
//  PBGameItem+Extend.m
//  Draw
//
//  Created by 王 小涛 on 13-3-15.
//
//

#import "PBGameItem+Extend.h"
#import "NSDate+TKCategory.h"

@implementation PBGameItem (Extend)

- (BOOL)isPromoting
{
    if (![self hasPromotionInfo]) {
        return NO;
    }
    
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:self.promotionInfo.startDate];
    NSDate *expireDate = [NSDate dateWithTimeIntervalSince1970:self.promotionInfo.expireDate];
    
    return [[NSDate date] isBetweenDate:startDate anotherDate:expireDate];
}

- (int)promotionPrice
{
    if ([self isPromoting]) {
        return self.promotionInfo.price;
    }else{
        return self.priceInfo.price;
    }
}

- (int)discount
{
    if ([self isPromoting]) {
        return (self.promotionInfo.price * 100 / self.priceInfo.price);
    }else{
        return 100;
    }
}

@end
