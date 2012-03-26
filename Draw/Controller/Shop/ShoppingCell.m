//
//  ShoppingCell.m
//  Draw
//
//  Created by  on 12-3-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ShoppingCell.h"

@implementation ShoppingCell
@synthesize priceLabel;
@synthesize countLabel;
@synthesize type = _type;
@synthesize price = _price;
@synthesize count = _count;
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
    [super dealloc];
}

- (void)setCellInfoWithCellType:(SHOPPING_CELL_TYPE)type 
                          count:(NSInteger)count 
                          price:(CGFloat)price
{
    self.type = type;
    self.count = count;
    self.price = price;
    NSString *countString = nil;
    NSString *priceString = nil;
    if (type == SHOPPING_COIN_TYPE) {
        countString = [NSString stringWithFormat:@"%d金币",count];
        priceString = [NSString stringWithFormat:@"$%.2f",price];
    }else if(type == SHOPPING_ITEM_TYPE)
    {
        countString = [NSString stringWithFormat:@"锦囊 %d个",count];
        priceString = [NSString stringWithFormat:@"%.0f金币",price];
        
    }
}

- (IBAction)clickBuyButton:(id)sender {
    if (_shoppingDelegate && [_shoppingDelegate respondsToSelector:@selector(didClickBuyButtonAtIndexPath:type:)]) {
        [_shoppingDelegate didClickBuyButtonAtIndexPath:self.indexPath type:self.type];
    }
}
@end
