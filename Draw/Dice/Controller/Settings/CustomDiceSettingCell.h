//
//  CustomDiceSettingCell.h
//  Draw
//
//  Created by Orange on 12-9-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PPTableViewCell.h"

@class Item;

@interface CustomDiceSettingCell : PPTableViewCell
@property (retain, nonatomic) IBOutlet UIImageView *DiceImageView;
@property (retain, nonatomic) IBOutlet UILabel *DiceTitleLabel;
@property (retain, nonatomic) IBOutlet UILabel *DiceDescriptionLabel;

+ (CGFloat)getCellHeight;
- (void)setCellInfo:(Item*)item;
- (void)setDefault;

@end
