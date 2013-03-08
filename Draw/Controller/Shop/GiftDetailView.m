//
//  GiftDetailView.m
//  Draw
//
//  Created by 王 小涛 on 13-3-8.
//
//

#import "GiftDetailView.h"
#import "AutoCreateViewByXib.h"
#import "PBGameItemUtils.h"


@implementation GiftDetailView

AUTO_CREATE_VIEW_BY_XIB(GiftDetailView);

- (void)dealloc {
    [_itemNameLabel release];
    [_friendNameLabel release];
    [_countLable release];
    [_priceLabel release];
    [_currencyImageView release];
    [_itemTypeLabel release];
    [super dealloc];
}

+ (id)createWithItem:(PBGameItem *)item
            myFriend:(MyFriend *)myFriend
               count:(int)count
{
    GiftDetailView *view = [self createView];
    if (item.type == PBDrawItemTypeTool) {
        //工具
        view.itemTypeLabel.text = NSLS(@"kTool");
    } else{
        //道具
        view.itemTypeLabel.text = NSLS(@"kProps");
    }
    
    view.itemNameLabel.text = item.name;
    view.friendNameLabel.text = myFriend.nickName;
    view.countLable.text = count;
    
    if (item.priceInfo.currency == PBGameCurrencyIngot) {
        view.currencyImageView.image = [UIImage imageNamed:@"coin.png"];
    } else {
        view.currencyImageView.image = [UIImage imageNamed:@"ingot.png"];
    }
    
    view.priceLabel.text = [NSString stringWithFormat:@"%d", item.priceInfo.price * count];
    
    return view;
}

@end
