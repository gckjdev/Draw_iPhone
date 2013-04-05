//
//  GameItemDetailViewView.m
//  Draw
//
//  Created by 王 小涛 on 13-3-6.
//
//

#import "GameItemDetailView.h"
#import "AutoCreateViewByXib.h"
#import "PBGameItem+Extend.h"
#import "GameItemPriceView.h"
#import "UIViewUtils.h"
#import "UIImageView+WebCache.h"
#import "ShareImageManager.h"

@implementation GameItemDetailView

AUTO_CREATE_VIEW_BY_XIB(GameItemDetailView);

- (void)dealloc {
    [_itemImageView release];
    [_discountLabel release];
    [_discountNoteLabel release];
    [_priceNoteLabel release];
    [_descNoteLabel release];
    [_backgroundImageView release];
    [super dealloc];
}

#define MAX_WITH_DESC_LABEL ([DeviceDetection isIPAD] ? (256) : (128))
#define MAX_HEIGHT_DESC_LABEL CGFLOAT_MAX

#define HEIGHT_OF_DESC_LABEL ([DeviceDetection isIPAD] ? 130 : 65)

#define HEIGHT_ADDTION_TO_DESC_LABEL ([DeviceDetection isIPAD] ? 10 : 5)


+ (id)createWithItem:(PBGameItem *)item
{
    GameItemDetailView *view = [self createView];
    
    [view.itemImageView setImageWithURL:[NSURL URLWithString:item.image]];
    
    view.discountNoteLabel.text = NSLS(@"kPromotion:");
    view.priceNoteLabel.text = NSLS(@"kPrice:");
    view.descNoteLabel.text = NSLS(@"kDesc:");

    if ([item isPromoting]) {
        view.discountLabel.text = [NSString stringWithFormat:NSLS(@"kDiscountIs"), [item discount]];
    }else{
        view.discountLabel.text = NSLS(@"kNoDiscount");
    }
    
    
    
    GameItemPriceView *priceView = [GameItemPriceView createWithItem:item];
    [priceView updateOriginX:view.discountLabel.frame.origin.x];
    [priceView updateCenterY:view.priceNoteLabel.center.y];
    
    [view addSubview:priceView];
    
    UILabel *label = [[[UILabel alloc] init] autorelease];
    label.backgroundColor = [UIColor clearColor];
    label.font = view.discountLabel.font;
    label.textColor = view.discountLabel.textColor;
    label.numberOfLines = 0;
    NSString *desc = [@"          " stringByAppendingString:NSLS(item.desc)];


    CGSize withinSize = CGSizeMake(MAX_WITH_DESC_LABEL, MAX_HEIGHT_DESC_LABEL);
    CGSize size = [desc sizeWithFont:label.font constrainedToSize:withinSize lineBreakMode:UILineBreakModeTailTruncation];
    
    if(size.height > HEIGHT_OF_DESC_LABEL){
        CGFloat delta = (size.height - HEIGHT_OF_DESC_LABEL + HEIGHT_ADDTION_TO_DESC_LABEL);
        [view updateHeight:(view.frame.size.height + delta)];
        [view.backgroundImageView setImage:[[ShareImageManager defaultManager] itemDetailBgImage]];
    }
    
    label.frame = CGRectMake(view.descNoteLabel.frame.origin.x, view.descNoteLabel.frame.origin.y, size.width, MAX(view.descNoteLabel.frame.size.height, size.height) );
    label.text = desc;
    [view addSubview:label];
    
    return view;
}

- (void)showInView:(UIView *)view
{
    self.center = view.center;
    [view addSubview:self];
}


@end
