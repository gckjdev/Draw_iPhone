//
//  ColorShopCell.h
//  Draw
//
//  Created by  on 12-4-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPTableViewCell.h"
@class ColorGroup;
@interface ColorShopCell : PPTableViewCell
{
    
}

- (void)setCellInfo:(ColorGroup *)colorGroup hasBought:(BOOL)hasBought;
@property (retain, nonatomic) IBOutlet UIImageView *coinImageView;
@property (retain, nonatomic) IBOutlet UILabel *priceLabel;

@end
