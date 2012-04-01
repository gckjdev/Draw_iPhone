//
//  ShoppingCell.m
//  Draw
//
//  Created by  on 12-3-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ShoppingCell.h"
#import "SKProduct+LocalizedPrice.h"
#import "ShareImageManager.h"
#import "LocaleUtils.h"

#define ITEM_PRICE_CENTER CGPointMake(195,34)
#define COIN_PRICE_CENTER CGPointMake(180,34)

@implementation ShoppingCell
@synthesize priceLabel;
@synthesize coinImage;
@synthesize countLabel;
@synthesize toolImage;
@synthesize costCoinImage;
@synthesize model = _model;
@synthesize shoppingDelegate = _shoppingDelegate;
@synthesize buyButton;

+ (id)createCell:(id)delegate
{
    NSString* cellId = [self getCellIdentifier];
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellId owner:self options:nil];
    // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).  
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create %@ but cannot find cell object from Nib", cellId);
        return nil;
    }
    
    ((PPTableViewCell*)[topLevelObjects objectAtIndex:0]).delegate = delegate;
    
    return [topLevelObjects objectAtIndex:0];
}

+ (NSString*)getCellIdentifier
{
    return @"ShoppingCell";
}

+ (CGFloat)getCellHeight
{
    return 96.0f;
}
- (void)dealloc {
    [countLabel release];
    [priceLabel release];
    [_model release];
    [coinImage release];
    [toolImage release];
    [buyButton release];
    [costCoinImage release];
    [super dealloc];
}



- (void)setCellInfo:(ShoppingModel *)model indexPath:(NSIndexPath *)aIndexPath
{
    self.indexPath = aIndexPath;
    self.model = model;
    NSString *countString = nil;
    NSString *priceString = nil;
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    if (model.type == SHOPPING_COIN_TYPE) {
        countString = [NSString stringWithFormat:@"x%d", model.count];
        priceString = [NSString stringWithFormat:@"%@", [model.product localizedPrice]];
        [self.priceLabel setCenter:COIN_PRICE_CENTER];
        [self.coinImage setHidden:NO];
        [self.toolImage setHidden:YES];        
        [self.costCoinImage setHidden:YES];
        
    }else if(model.type == SHOPPING_ITEM_TYPE)
    {
        countString = [NSString stringWithFormat:@"x%d",model.count];
        priceString = [NSString stringWithFormat:@"%.0f",model.price];
        [self.costCoinImage setHidden:NO];
        [self.coinImage setHidden:YES];
        [self.toolImage setHidden:NO];
        [self.priceLabel setCenter:ITEM_PRICE_CENTER];
    }
    [self.buyButton setTitle:NSLS(@"kBuy") forState:UIControlStateNormal];
    [self.buyButton setBackgroundImage:[imageManager buyButtonImage] forState:UIControlStateNormal];
    
    [self.countLabel setText:countString];
    [self.priceLabel setText:priceString];
}



- (IBAction)clickBuyButton:(id)sender {
    if (_shoppingDelegate && [_shoppingDelegate respondsToSelector:@selector(didClickBuyButtonAtIndexPath:model:)]) {
        [_shoppingDelegate didClickBuyButtonAtIndexPath:self.indexPath model:self.model];
    }
}
@end
