//
//  LineView.m
//  Draw
//
//  Created by Gamy on 13-9-12.
//
//

#import "LineView.h"

@interface LineView()

@property(nonatomic, assign)BOOL isAnimating;


@end

@implementation LineView

- (void)startAnimation
{
    if (!_isAnimating) {
        self.isAnimating = YES;
        //TODO start animation
    }
}
- (void)stopAnimation
{
    if (_isAnimating) {
        self.isAnimating = NO;
        //TODO stop animation
    }
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setNeedsDisplay];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setNeedsDisplay];
}


@end
