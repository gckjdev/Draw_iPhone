//
//  HKGirlFontLabel.m
//  Draw
//
//  Created by Orange on 12-8-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "HKGirlFontLabel.h"

@implementation HKGirlFontLabel

- (id)initWithFrame:(CGRect)frame
{
    self = self = [super initWithFrame:self.frame fontName:@"diceFont" pointSize:self.font.pointSize];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self = [super initWithFrame:self.frame fontName:@"diceFont" pointSize:self.font.pointSize];  
        [self setBackgroundColor:[UIColor clearColor]];
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

@end
