//
//  CustomDiceSettingCell.h
//  Draw
//
//  Created by Orange on 12-9-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PPTableViewCell.h"
#import "HKGirlFontLabel.h"

@class Item;

@interface CustomDiceSettingCell : PPTableViewCell
@property (retain, nonatomic) IBOutlet UIImageView *DiceImageView;
@property (retain, nonatomic) IBOutlet HKGirlFontLabel *DiceTitleLabel;
@property (retain, nonatomic) IBOutlet HKGirlFontLabel *DiceDescriptionLabel;

+ (CGFloat)getCellHeight;
- (void)setCellInfo:(Item*)item;


@end
