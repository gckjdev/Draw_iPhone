//
//  SynthesisView.m
//  Draw
//
//  Created by Orange on 12-4-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SynthesisView.h"

@implementation SynthesisView
@synthesize patternImage;
@synthesize drawImage;


- (void)dealloc
{
    [patternImage release], patternImage = nil;
    [drawImage release], drawImage = nil;
    [super dealloc];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0, self.bounds.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
    if (drawImage) {
        CGRect imageRect = self.bounds;
        CGContextDrawImage(context, imageRect, patternImage.CGImage);
    }

    if (patternImage) {
//        CGRect imageRect = self.bounds;
        CGRect imageRect = CGRectMake(0, 0, 78, 110);
        CGContextDrawImage(context, imageRect, drawImage.CGImage);
    }
    
}


@end
