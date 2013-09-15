//
//  LineView.m
//  Draw
//
//  Created by Gamy on 13-9-12.
//
//

#import "LineView.h"
#import <QuartzCore/QuartzCore.h>

@interface LineView()

@property(nonatomic, assign)BOOL isAnimating;
@property(nonatomic, assign)UIView* line;
@property(nonatomic, assign)UIView* point;

@end

@implementation LineView

#define SHAPE_ANGLE (0.2)
#define DEFAULT_FRAME CGRectMake(0, 0, (ISIPAD?50:30), (ISIPAD?240:120))
#define DEFAULT_HEIGHT (CGRectGetHeight(DEFAULT_FRAME)*0.7)
#define POINT_SIZE CGSizeMake((ISIPAD?32:16),(ISIPAD?32:16))
#define LINE_WIDTH (ISIPAD?3:2)


- (void)startAnimation
{
    if (!_isAnimating) {
        self.isAnimating = YES;
        [self resetPositions];
        [self.line setTransform:CGAffineTransformMakeRotation(-0.2)];
        [self.line.layer setAnchorPoint:CGPointMake(0.5, 0)];
        self.line.layer.position = CGPointMake(_line.layer.position.x, 0);
        
        
        [UIView beginAnimations:@"shake" context:nil];
        [UIView setAnimationDuration:0.4];
        [UIView setAnimationRepeatAutoreverses:YES];
        [UIView setAnimationRepeatCount:MAXFLOAT];
        [self.line setTransform:CGAffineTransformMakeRotation(0.2)];
        
        [UIView setAnimationDuration:0.5];
        
        [UIView commitAnimations];
    }
}
- (void)stopAnimation
{
    if (_isAnimating) {
        [self.line.layer removeAllAnimations];
        [self.point.layer removeAllAnimations];
        self.isAnimating = NO;
        self.line.transform = CGAffineTransformIdentity;
        [self resetPositions];
    }
}


- (void)resetPositions
{
    CGFloat x = CGRectGetMidX(self.bounds);
    CGFloat lineHeight = DEFAULT_HEIGHT-POINT_SIZE.height;
    self.line.frame = CGRectMake(x, 0, LINE_WIDTH, lineHeight);
    [self.line updateCenterX:x];
    self.point.center = CGPointMake(x, (DEFAULT_HEIGHT+lineHeight)/2);

}
- (void)baseInit
{
    self.frame = DEFAULT_FRAME;
    self.pointColor = COLOR_GREEN;
    self.backgroundColor = [UIColor clearColor];
    CGFloat x = CGRectGetMidX(self.bounds);
    CGFloat lineHeight = DEFAULT_HEIGHT-POINT_SIZE.height;
    self.line = [[[UIView alloc] initWithFrame:CGRectMake(x, 0, LINE_WIDTH, lineHeight)] autorelease];
    self.line.backgroundColor = COLOR_WHITE;
    [self addSubview:self.line];
    
    self.point = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, POINT_SIZE.width, POINT_SIZE.height)] autorelease];
    SET_VIEW_ROUND(self.point);
    self.point.layer.borderColor = [COLOR_WHITE CGColor];
    self.point.layer.borderWidth = LINE_WIDTH;
    [self.point setBackgroundColor:self.pointColor];
    [self.line addSubview:self.point];
    [self resetPositions];
    
    
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self baseInit];
    }
    return self;

}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self baseInit];
    }
    return self;
}



@end
