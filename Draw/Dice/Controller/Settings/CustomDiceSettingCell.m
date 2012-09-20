//
//  CustomDiceSettingCell.m
//  Draw
//
//  Created by Orange on 12-9-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CustomDiceSettingCell.h"

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
