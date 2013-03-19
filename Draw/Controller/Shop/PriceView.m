//
//  PriceView.m
//  Draw
//
//  Created by 王 小涛 on 13-3-4.
//
//

#import "PriceView.h"
#import "AutoCreateViewByXib.h"
#import "UIViewUtils.h"
#import "ShareImageManager.h"

@implementation PriceView

AUTO_CREATE_VIEW_BY_XIB(PriceView);

+ (id)createWithPrice:(int)price currency:(PBGameCurrency)currency
{
    PriceView *view = [self createView];
    [view.promotionCurrencyImageView removeFromSuperview];
    [view.promotionPriceLabel removeFromSuperview];
    [view.grayLineImageView removeFromSuperview];
    
    CGFloat distance = view.priceLabel.frame.origin.x - view.currencyImageView.frame.origin.x - view.currencyImageView.frame.size.width;
    view.currencyImageView.frame = CGRectMake(0, view.currencyImageView.frame.origin.y, view.currencyImageView.frame.size.width, view.currencyImageView.frame.size.height);
    
    CGFloat originX = view.currencyImageView.frame.origin.x + view.currencyImageView.frame.size.width + distance;
    
    [view updateLabelWidth:view.priceLabel
                  withText:[NSString stringWithFormat:@"%d", price]];
    [view.priceLabel updateOriginX:originX];
    
    [view updateWidth:(view.priceLabel.frame.origin.x + view.priceLabel.frame.size.width)];
    
    view.currencyImageView.image = [[ShareImageManager defaultManager] currencyImageWithType:currency];
    
    return view;
}

- (void)updateLabelWidth:(UILabel *)label
                withText:(NSString *)text
{
    CGSize withinSize = CGSizeMake(100, label.frame.size.height);
    
    CGSize size = [text sizeWithFont:label.font constrainedToSize:withinSize lineBreakMode:UILineBreakModeTailTruncation];
    
    [label updateWidth:size.width];
    
    label.text = text;
}

+ (id)createWithPrice:(int)price promotionPrice:(int)promotionPrice currency:(PBGameCurrency)currency
{
    PriceView *view = [self createView];
    
    CGFloat distance1 = view.currencyImageView.frame.origin.x - view.promotionPriceLabel.frame.origin.x - view.promotionPriceLabel.frame.size.width;
    
    CGFloat distance2 = view.priceLabel.frame.origin.x - view.currencyImageView.frame.origin.x - view.currencyImageView.frame.size.width;
    
    CGFloat originX = view.promotionPriceLabel.frame.origin.x;
    [view updateLabelWidth:view.promotionPriceLabel
                  withText:[NSString stringWithFormat:@"%d",
                            price]];
    [view.promotionPriceLabel updateOriginX:originX];
    
    CGFloat width = view.promotionPriceLabel.frame.origin.x + view.promotionPriceLabel.frame.size.width - view.promotionCurrencyImageView.frame.origin.x;
    [view.grayLineImageView updateOriginX:view.promotionCurrencyImageView.frame.origin.x];
    [view.grayLineImageView updateWidth:width];
    
    originX = view.promotionPriceLabel.frame.origin.x + view.promotionPriceLabel.frame.size.width + distance1;
    [view.currencyImageView updateOriginX:originX];
    
    originX = view.currencyImageView.frame.origin.x + view.currencyImageView.frame.size.width + distance2;
    [view updateLabelWidth:view.priceLabel withText:[NSString stringWithFormat:@"%d", promotionPrice]];
    [view.priceLabel updateOriginX:originX];
    
    [view updateWidth:(view.priceLabel.frame.origin.x + view.priceLabel.frame.size.width)];
    
    view.promotionCurrencyImageView.image = [[ShareImageManager defaultManager] grayCurrencyImageWithType:currency];
    
    view.currencyImageView.image = [[ShareImageManager defaultManager] currencyImageWithType:currency];
    
    return view;
}

- (void)dealloc {
    [_promotionCurrencyImageView release];
    [_promotionPriceLabel release];
    [_grayLineImageView release];
    [_currencyImageView release];
    [_priceLabel release];
    [super dealloc];
}

@end
