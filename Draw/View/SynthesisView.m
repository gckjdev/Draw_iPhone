//
//  SynthesisView.m
//  Draw
//
//  Created by Orange on 12-4-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SynthesisView.h"
#import <QuartzCore/QuartzCore.h>

@implementation SynthesisView
@synthesize patternImage = _patternImage;
@synthesize drawImage = _drawImage;


- (void)dealloc
{
    [_patternImage release], _patternImage = nil;
    [_drawImage release], _drawImage = nil;
    [super dealloc];
}

- (void)setPatternImage:(UIImage *)patternImage
{
    if (_patternImage != patternImage) {
        [_patternImage release];
        _patternImage = [patternImage retain];
        [self setNeedsDisplay];
    }
}

- (void)setDrawImage:(UIImage *)drawImage
{
    if (_drawImage != drawImage) {
        [_drawImage release];
        _drawImage = [drawImage retain];
        [self setNeedsDisplay];
    }
    
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
    self.backgroundColor = [UIColor whiteColor];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0, self.frame.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
    if (_drawImage) {
        if (_patternImage) {
            
            
            CGRect imageRect = CGRectMake(self.frame.size.width*0.1, self.frame.size.height*0.1, self.frame.size.width*0.8, self.frame.size.height*0.8);
            CGContextDrawImage(context, imageRect, _drawImage.CGImage);
            
            CGRect imageRectPattern = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
            
            CGContextDrawImage(context, imageRectPattern, _patternImage.CGImage);
            

        } else {
            CGRect imageRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
            CGContextDrawImage(context, imageRect, _drawImage.CGImage);

        }
            }
    if (_patternImage) {
        //        CGRect imageRect = self.bounds;
        
    }
    


    
}

- (UIImage*)createImage
{
    CGRect rect = self.frame;
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}


@end
