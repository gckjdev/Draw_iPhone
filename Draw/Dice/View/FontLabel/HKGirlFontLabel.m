//
//  HKGirlFontLabel.m
//  Draw
//
//  Created by Orange on 12-8-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "HKGirlFontLabel.h"
#import "DiceFontManager.h"
#import "PPDebug.h"

@implementation HKGirlFontLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame
                       fontName:[[DiceFontManager defaultManager] fontName]
                      pointSize:15];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame pointSize:(int)pointSize
{
    self = [super initWithFrame:frame 
                       fontName:[[DiceFontManager defaultManager] fontName]
                      pointSize:pointSize];
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
        PPDebug(@"font size = %f", self.font.pointSize);
        self = [super initWithFrame:self.frame
                           fontName:[[DiceFontManager defaultManager] fontName] 
                          pointSize:self.font.pointSize];  
        
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
