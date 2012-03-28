//
//  ShoppingCell.m
//  Draw
//
//  Created by  on 12-3-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ShoppingCell.h"
#import "SKProduct+LocalizedPrice.h"

@implementation ShoppingCell
@synthesize priceLabel;
@synthesize countLabel;
@synthesize model = _model;
@synthesize shoppingDelegate = _shoppingDelegate;

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
    return 44.0f;
}
- (void)dealloc {
    [countLabel release];
    [priceLabel release];
    [_model release];
    [super dealloc];
}

- (void)setCellInfo:(ShoppingModel *)model indexPath:(NSIndexPath *)aIndexPath
{
    self.indexPath = aIndexPath;
    self.model = model;
    NSString *countString = nil;
    NSString *priceString = nil;
    if (model.type == SHOPPING_COIN_TYPE) {
        countString = [NSString stringWithFormat:@"%d金币", model.count];
        priceString = [NSString stringWithFormat:@"%@", [model.product localizedPrice]];
    }else if(model.type == SHOPPING_ITEM_TYPE)
    {
        countString = [NSString stringWithFormat:@"锦囊 %d个",model.count];
        priceString = [NSString stringWithFormat:@"%.0f金币",model.price];
    }
     
    [self.countLabel setText:countString];
    [self.priceLabel setText:priceString];
}



- (IBAction)clickBuyButton:(id)sender {
    if (_shoppingDelegate && [_shoppingDelegate respondsToSelector:@selector(didClickBuyButtonAtIndexPath:model:)]) {
        [_shoppingDelegate didClickBuyButtonAtIndexPath:self.indexPath model:self.model];
    }
}
@end
