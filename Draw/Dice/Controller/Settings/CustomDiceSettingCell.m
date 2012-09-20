//
//  CustomDiceSettingCell.m
//  Draw
//
//  Created by Orange on 12-9-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CustomDiceSettingCell.h"
#import "DiceItem.h"

@implementation CustomDiceSettingCell
@synthesize DiceImageView;
@synthesize DiceTitleLabel;
@synthesize DiceDescriptionLabel;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#define HEIGHT_DICE_ROOM_LIST_CELL  ([DeviceDetection isIPAD] ? 204: 102)

+ (CGFloat)getCellHeight
{
    return HEIGHT_DICE_ROOM_LIST_CELL;
}

- (void)setCellInfo:(Item*)item
{
    [self.DiceImageView setImage:item.itemImage];
    [self.DiceTitleLabel setText:item.itemName];
    [self.DiceDescriptionLabel setText:item.itemDescription];
}

+ (NSString*)getCellIdentifier
{
    return @"CustomDiceSettingCell";
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc {
    [DiceImageView release];
    [DiceTitleLabel release];
    [DiceDescriptionLabel release];
    [super dealloc];
}
@end
