//
//  StoreCell.m
//  Draw
//
//  Created by 王 小涛 on 13-3-4.
//
//

#import "StoreCell.h"
#import "PriceView.h"
#import "PBGameItemUtils.h"
#import "UIViewUtils.h"
#import "UIImageView+WebCache.h"

#define TAG_PRICE_VIEW 209
#define ORIGINY_PRICE_VIEW 13;

@interface StoreCell ()

@property (retain, nonatomic) PBGameItem *item;

@end

@implementation StoreCell

+ (NSString *)getCellIdentifier
{
    return @"StoreCell";
}

+ (CGFloat)getCellHeight
{
    return 82;
}

- (void)addPriceView
{
    [[self viewWithTag:TAG_PRICE_VIEW] removeFromSuperview];
    
    PriceView *priceView;
    if ([_item isPromoting]) {
        self.promotionImageView.hidden = NO;
        int promotionPrice = _item.priceInfo.price * _item.promotionInfo.discount / 100;
        priceView = [PriceView createWithPrice:_item.priceInfo.price promotionPrice:promotionPrice currency:_item.priceInfo.currency];
    }else{
        self.promotionImageView.hidden = YES;
        priceView = [PriceView createWithPrice:_item.priceInfo.price currency:_item.priceInfo.currency];
    }
    
    priceView.tag = TAG_PRICE_VIEW;
    
    [priceView updateOriginY:13];
    [priceView updateOriginX:(self.itemDescLabel.frame.origin.x + self.itemDescLabel.frame.size.width - priceView.frame.size.width)];
    
    [self addSubview:priceView];
}

- (void)setCellInfo:(PBGameItem *)item
{
    self.item = item;
    
    [self.itemImageView setImageWithURL:[NSURL URLWithString:item.image]];
    self.itemNameLabel.text = NSLS(item.name);
    self.itemDescLabel.text = NSLS(item.desc);
    [self addPriceView];
}


- (void)dealloc {
    [_item release];
    [_itemImageView release];
    [_itemNameLabel release];
    [_itemDescLabel release];
    [_promotionImageView release];
    [super dealloc];
}
@end
