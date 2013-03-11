//
//  StoreCell.m
//  Draw
//
//  Created by 王 小涛 on 13-3-4.
//
//

#import "StoreCell.h"
#import "GameItemPriceView.h"
#import "PBGameItemUtils.h"
#import "UIViewUtils.h"
#import "UIImageView+WebCache.h"
#import "UserGameItemService.h"
#import "ItemType.h"

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
    
    GameItemPriceView *priceView = [GameItemPriceView createWithItem:_item];

    priceView.tag = TAG_PRICE_VIEW;
    
    [priceView updateCenterY:self.itemNameLabel.center.y];
    [priceView updateOriginX:(self.itemDescLabel.frame.origin.x + self.itemDescLabel.frame.size.width - priceView.frame.size.width)];
    
    [self addSubview:priceView];
}

- (void)setCellInfo:(PBGameItem *)item
{
    self.item = item;
    
    if ([_item isPromoting]) {
        self.promotionImageView.hidden = NO;
    }else{
        self.promotionImageView.hidden = YES;
        
    }
    
    [self.itemImageView setImageWithURL:[NSURL URLWithString:item.image]];
    self.itemNameLabel.text = NSLS(item.name);
    
    CGSize withinSize = CGSizeMake(200, 19);
    CGSize size = [self.itemNameLabel.text sizeWithFont:self.itemNameLabel.font constrainedToSize:withinSize lineBreakMode:self.itemNameLabel.lineBreakMode];
    [self.itemNameLabel updateWidth:size.width];
    
    [self setItem:item count:[[UserGameItemService defaultService] countOfItem:item.itemId]];

    [self.countButton updateOriginX:(self.itemNameLabel.frame.origin.x + self.itemNameLabel.frame.size.width + 3)];
    
    self.itemDescLabel.text = NSLS(item.desc);

    [self addPriceView];
}

- (void)setItem:(PBGameItem *)item
          count:(int)count
{
    if (item.itemId == ItemTypeColor) {
        self.countButton.hidden = YES;
        return;
    }
    
    if (count == 0) {
        self.countButton.hidden = YES;
    }
    
    if (item.salesType == PBGameItemSalesTypeMultiple) {
        [self.countButton setTitle:[NSString stringWithFormat:@"%d", count] forState:UIControlStateNormal];
    }
    
    if (item.salesType == PBGameItemSalesTypeOneOff) {
        if (count >= 1) {
            self.countButton.hidden = NO;
            [self.countButton setTitle:NSLS(@"kAlreadyBought") forState:UIControlStateNormal];
        }else{
            self.countButton.hidden = YES;
        }
    }

}


- (void)dealloc {
    [_item release];
    [_itemImageView release];
    [_itemNameLabel release];
    [_itemDescLabel release];
    [_promotionImageView release];
    [_countButton release];
    [super dealloc];
}
@end
