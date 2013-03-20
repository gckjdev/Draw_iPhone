//
//  GiftDetailView.m
//  Draw
//
//  Created by 王 小涛 on 13-3-8.
//
//

#import "GiftDetailView.h"
#import "AutoCreateViewByXib.h"
#import "PBGameItem+Extend.h"
#import "UIImageView+WebCache.h"
#import "ShareImageManager.h"
#import "GameItemManager.h"

@implementation GiftDetailView

AUTO_CREATE_VIEW_BY_XIB(GiftDetailView);

- (void)dealloc {
    [_itemNameLabel release];
    [_friendNameLabel release];
    [_countLable release];
    [_priceLabel release];
    [_currencyImageView release];
    [_itemImageView release];
    [_avatarImageView release];
    [super dealloc];
}

+ (id)createWithItem:(int)itemId
            myFriend:(MyFriend *)myFriend
               count:(int)count
{
    PBGameItem *item = [[GameItemManager defaultManager] itemWithItemId:itemId];
    GiftDetailView *view = [self createView];    
    view.itemNameLabel.text = NSLS(item.name);
    view.friendNameLabel.text = myFriend.nickName;
    view.countLable.text = [NSString stringWithFormat:@"%d", count];
    
    if (item.priceInfo.currency == PBGameCurrencyIngot) {
        view.currencyImageView.image = [UIImage imageNamed:@"ingot.png"];
    } else {
        view.currencyImageView.image = [UIImage imageNamed:@"coin.png"];
    }
    
    view.priceLabel.text = [NSString stringWithFormat:@"%d", [item promotionPrice] * count];
    
    [view.itemImageView setImageWithURL:[NSURL URLWithString:item.image]];
    UIImage *placeHolderImage = [myFriend isMale] ? [[ShareImageManager defaultManager] maleDefaultAvatarImage] : [[ShareImageManager defaultManager] femaleDefaultAvatarImage];
    
    [view.avatarImageView setImageWithURL:[NSURL URLWithString:myFriend.avatar] placeholderImage:placeHolderImage];
    
    return view;
}

@end
