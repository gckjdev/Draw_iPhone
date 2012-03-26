//
//  ShoppingCell.h
//  Draw
//
//  Created by  on 12-3-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPTableViewCell.h"

typedef enum{
    SHOPPING_COIN_TYPE = 1,
    SHOPPING_ITEM_TYPE = 2
}SHOPPING_CELL_TYPE;

@protocol ShoppingCellDelegate <NSObject>

@optional
- (void)didClickBuyButtonAtIndexPath:(NSIndexPath *)indexPath 
                                type:(SHOPPING_CELL_TYPE)type;

@end

@interface ShoppingCell : PPTableViewCell
{
    SHOPPING_CELL_TYPE _type;
    NSInteger _count;
    CGFloat _price;
    id<ShoppingCellDelegate>_shoppingDelegate;
}

@property(nonatomic, assign)SHOPPING_CELL_TYPE type;
@property(nonatomic, assign)NSInteger count;
@property(nonatomic, assign)CGFloat price;
@property(nonatomic, assign)id<ShoppingCellDelegate>shoppingDelegate;

- (IBAction)clickBuyButton:(id)sender;
@property (retain, nonatomic) IBOutlet UILabel *priceLabel;
@property (retain, nonatomic) IBOutlet UILabel *countLabel;
- (void)setCellInfoWithCellType:(SHOPPING_CELL_TYPE)type 
                          count:(NSInteger)count 
                          price:(CGFloat)price;
@end
