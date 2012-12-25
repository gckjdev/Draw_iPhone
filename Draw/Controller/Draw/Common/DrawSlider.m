//
//  DrawSlider.m
//  Draw
//
//  Created by gamy on 12-12-25.
//
//

#import "DrawSlider.h"

#define VALUE(x) (ISIPAD ? x*2 : x)

#define WIDTH VALUE(96.0)
#define HEIGHT VALUE(12.0)

#define POINT_WIDTH VALUE(11.0)
#define POINT_HEIGHT VALUE(12.0)


@interface DrawSlider()
{
    CGPoint currentPoint;
}
@property(nonatomic, retain) UIImage *bgImage;
@property(nonatomic, retain) UIImage *loadImage;
@property(nonatomic, retain) UIImage *pointImage;


@end

@implementation DrawSlider


- (void)dealloc
{
    PPRelease(_bgImage);
    PPRelease(_loadImage);
    PPRelease(_pointImage);
    [super dealloc];
}

- (id)initWithDrawSliderStyle:(DrawSliderStyle)style
{
    self = [super initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        currentPoint = CGPointZero;
        self.style = style;
    }
    return self;

}

- (void)setStyle:(DrawSliderStyle)style
{
    _style = style;
    //set the image according to the style
    
    if (style == DrawSliderStyleLarge) {
        self.bgImage = [UIImage imageNamed:@"draw_slider2_bg"];
        self.loadImage = [UIImage imageNamed:@"draw_slider2_load"];
        self.pointImage = [UIImage imageNamed:@"draw_slider2_point"];
    }else if (style == DrawSliderStyleSmall){
        self.bgImage = [UIImage imageNamed:@"draw_slider1_bg"];
        self.loadImage = [UIImage imageNamed:@"draw_slider1_load"];
        self.pointImage = [UIImage imageNamed:@"draw_slider1_point"];
    }else{
        return;
    }
    
    [self setNeedsDisplay];
}

- (void)setValue:(CGFloat)value
{
    _value = value;
    currentPoint = CGPointMake(value * CGRectGetWidth(self.bounds), self.center.y);
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
//    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Drawing code
    //Draw bg
    [self.bgImage drawInRect:self.bounds];
    
    //Draw load
    CGRect r = CGRectMake(10, 0, currentPoint.x, CGRectGetHeight(self.bounds));
    [self.loadImage drawInRect:r];
    //draw point
    CGFloat x = currentPoint.x - POINT_WIDTH/2.0;
    r = CGRectMake(x, 0, POINT_WIDTH, POINT_HEIGHT);
    [self.pointImage drawInRect:r];
    
    [super drawRect:rect];
}

- (void)updateValueWithCurrentPoint
{
    self.value = currentPoint.x / CGRectGetWidth(self.bounds);
}



- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    currentPoint = [touch locationInView:self];
    [self updateValueWithCurrentPoint];
    [self setNeedsDisplay];
    return YES;
}
- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    currentPoint = [touch locationInView:self];
    [self updateValueWithCurrentPoint];
    [self setNeedsDisplay];
    return YES;
}
- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    currentPoint = [touch locationInView:self];
    [self updateValueWithCurrentPoint];
    [self setNeedsDisplay];
}

@end
