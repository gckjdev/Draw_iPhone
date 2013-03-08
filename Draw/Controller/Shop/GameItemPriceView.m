//
//  GameItemPriceView.m
//  Draw
//
//  Created by 王 小涛 on 13-3-6.
//
//

#import "GameItemPriceView.h"
#import "PriceView.h"
#import "PBGameItemUtils.h"

@implementation GameItemPriceView

+ (id)createWithItem:(PBGameItem *)item
{
    PriceView *priceView;
    if ([item isPromoting]) {
        priceView = [PriceView createWithPrice:item.priceInfo.price promotionPrice:[item promotionPrice] currency:item.priceInfo.currency];
    }else{
        priceView = [PriceView createWithPrice:item.priceInfo.price currency:item.priceInfo.currency];
    }
    
    return priceView;
}

@end
