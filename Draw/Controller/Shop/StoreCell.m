//
//  StoreCell.m
//  Draw
//
//  Created by 王 小涛 on 13-3-4.
//
//

#import "StoreCell.h"
#import "GameItemPriceView.h"
#import "PBGameItem+Extend.h"
#import "UIViewUtils.h"
#import "UIImageView+WebCache.h"
#import "UserGameItemManager.h"
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

#define CELL_HEIHT ([DeviceDetection isIPAD] ? (181) : (83))
+ (CGFloat)getCellHeight
{
    return CELL_HEIHT;
}

- (void)addPriceView
{
    [[self viewWithTag:TAG_PRICE_VIEW] removeFromSuperview];
    
    if (![_item hasPriceInfo] || _item.priceInfo.price <= 0) {
        return;
    }
    
    GameItemPriceView *priceView = [GameItemPriceView createWithItem:_item];

    priceView.tag = TAG_PRICE_VIEW;
    
    [priceView updateCenterY:self.itemNameLabel.center.y];
    [priceView updateOriginX:(self.itemDescLabel.frame.origin.x + self.itemDescLabel.frame.size.width - priceView.frame.size.width)];
    
    [self addSubview:priceView];
}

- (void)startAnimating
{
    self.indicatorView.hidden = NO;
    [self.indicatorView startAnimating];
}

- (void)stopAnimating
{
    [self.indicatorView stopAnimating];
    self.indicatorView.hidden = YES;
}

#define MAX_WITH_ITEM_NAME ([DeviceDetection isIPAD] ? (400) : (200))
- (void)setCellInfo:(PBGameItem *)item
{
    self.item = item;
    
    if ([_item isPromoting]) {
        self.promotionImageView.hidden = NO;
    }else{
        self.promotionImageView.hidden = YES;
        
    }
    
    [self startAnimating];
    [self.itemImageView setImageWithURL:[NSURL URLWithString:item.image] placeholderImage:nil success:^(UIImage *image, BOOL cached) {
        [self stopAnimating];
    } failure:^(NSError *error) {
        [self stopAnimating];
    }];
    self.itemNameLabel.text = NSLS(item.name);
    
    CGSize withinSize = CGSizeMake(MAX_WITH_ITEM_NAME, 19);
    CGSize size = [self.itemNameLabel.text sizeWithFont:self.itemNameLabel.font constrainedToSize:withinSize lineBreakMode:self.itemNameLabel.lineBreakMode];
    [self.itemNameLabel updateWidth:size.width];
    
    [self setItem:item count:[[UserGameItemManager defaultManager] countOfItem:item.itemId]];

    [self.countButton updateOriginX:(self.itemNameLabel.frame.origin.x + self.itemNameLabel.frame.size.width + 3)];
    
    self.itemDescLabel.text = NSLS(item.desc);

    [self addPriceView];
    
    self.cellBgImageView.layer.borderWidth = (ISIPAD ? 4 : 2);
    self.cellBgImageView.layer.borderColor = [COLOR_YELLOW CGColor];
    self.cellBgImageView.backgroundColor = COLOR_GRAY;
    SET_VIEW_ROUND_CORNER(self.cellBgImageView);
    
    self.itemBgImageView.backgroundColor = COLOR_WHITE;
    self.itemBgImageView.layer.borderWidth = (ISIPAD ? 4 : 2);
    self.itemBgImageView.layer.borderColor = [COLOR_ORANGE CGColor];
    SET_VIEW_ROUND_CORNER(self.itemBgImageView);
    
    self.itemNameLabel.textColor = COLOR_BROWN;
    self.itemDescLabel.textColor = COLOR_BROWN;
    
    self.countButton.backgroundColor = COLOR_BROWN;
    SET_VIEW_ROUND_CORNER(self.countButton);
}

- (void)setItem:(PBGameItem *)item
          count:(int)count
{
    if (item.itemId == ItemTypeColor
        || item.itemId == ItemTypePurse
        || item.itemId == ItemTypePurseOneThousand) {
        self.countButton.hidden = YES;
        return;
    }
    
    if (count == 0) {
        self.countButton.hidden = YES;
    }
    
    if (item.consumeType == PBGameItemConsumeTypeAmountConsumable) {
        [self.countButton setTitle:[NSString stringWithFormat:@"%d", count] forState:UIControlStateNormal];
    }
    
    if (item.consumeType == PBGameItemConsumeTypeNonConsumable) {
        if (count >= 1) {
            self.countButton.hidden = NO;
            [self.countButton setTitle:NSLS(@"kAlreadyBought") forState:UIControlStateNormal];
        }else{
            self.countButton.hidden = YES;
        }
    }
    
    if (item.consumeType == PBGameItemConsumeTypeTimeConsumable) {
        // TODO:
        
    }

}


- (void)dealloc {
    [_item release];
    [_itemImageView release];
    [_itemNameLabel release];
    [_itemDescLabel release];
    [_promotionImageView release];
    [_countButton release];
    [_indicatorView release];
    [_cellBgImageView release];
    [_itemBgImageView release];
    [super dealloc];
}
@end
