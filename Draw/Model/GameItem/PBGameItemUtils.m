//
//  PBGameItemUtils.m
//  Draw
//
//  Created by 王 小涛 on 13-3-4.
//
//

#import "PBGameItemUtils.h"

@implementation PBGameItem (Utils)

- (BOOL)isPromoting
{
    if (![self hasPromotionInfo]) {
        return NO;
    }
    
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:self.promotionInfo.startDate];
    NSDate *expireDate = [NSDate dateWithTimeIntervalSince1970:self.promotionInfo.expireDate];
    
    NSDate *earlierDate = [startDate earlierDate:[NSDate date]];
    NSDate *laterDate = [expireDate laterDate:[NSDate date]];
    
    if ([earlierDate isEqualToDate:startDate] && [laterDate isEqualToDate:expireDate]) {
        return YES;
    }
    
    return NO;
}

- (int)promotionPrice
{
    if ([self isPromoting]) {
        return self.priceInfo.price * self.promotionInfo.discount / 100;
    }else{
        return self.priceInfo.price;
    }
}

@end
