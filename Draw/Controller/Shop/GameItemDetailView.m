//
//  GameItemDetailViewView.m
//  Draw
//
//  Created by 王 小涛 on 13-3-6.
//
//

#import "GameItemDetailView.h"
#import "AutoCreateViewByXib.h"
#import "PBGameItemUtils.h"
#import "GameItemPriceView.h"
#import "UIViewUtils.h"
#import "UIImageView+WebCache.h"

@implementation GameItemDetailView

AUTO_CREATE_VIEW_BY_XIB(GameItemDetailView);

- (void)dealloc {
    [_itemImageView release];
    [_discountLabel release];
    [_discountNoteLabel release];
    [_priceNoteLabel release];
    [_descNoteLabel release];
    [super dealloc];
}

+ (id)createWithItem:(PBGameItem *)item
{
    GameItemDetailView *view = [self createView];
    
    [view.itemImageView setImageWithURL:[NSURL URLWithString:item.image]];
    
    view.discountLabel.text = NSLS(@"kDicount:");
    view.priceNoteLabel.text = NSLS(@"kPrice:");
    view.descNoteLabel.text = NSLS(@"kDesc:");

    if ([item isPromoting]) {
        view.discountLabel.text = [NSString stringWithFormat:NSLS(@"kDiscountIs"), item.promotionInfo.discount];
    }else{
        view.discountLabel.text = NSLS(@"kNoDiscount");
    }
    
    GameItemPriceView *priceView = [GameItemPriceView createWithItem:item];
    [priceView updateOriginX:view.discountLabel.frame.origin.x];
    [priceView updateOriginY:view.priceNoteLabel.frame.origin.y];
    [view addSubview:priceView];
    
    UILabel *label = [[[UILabel alloc] init] autorelease];
    label.backgroundColor = [UIColor clearColor];
    label.font = view.discountLabel.font;
    label.textColor = view.discountLabel.textColor;
    label.numberOfLines = 0;
    
    CGSize withinSize = CGSizeMake(128, 68);
    CGSize size = [item.desc sizeWithFont:label.font constrainedToSize:withinSize lineBreakMode:UILineBreakModeTailTruncation];
    label.frame = CGRectMake(view.descNoteLabel.frame.origin.x, view.descNoteLabel.frame.origin.y, size.width, MAX(view.descNoteLabel.frame.size.height, size.height) );
    label.text = NSLS(item.desc);
    [view addSubview:label];
    
    return view;
}

- (void)showInView:(UIView *)view
{
    self.center = view.center;
    [view addSubview:self];
}


@end
