//
//  DrawSlider.m
//  Draw
//
//  Created by gamy on 12-12-25.
//
//

#import "DrawSlider.h"
#import "CMPopTipView.h"

#define VALUE(x) (ISIPAD ? x*2 : x)

#define WIDTH VALUE(92.5)
#define HEIGHT VALUE(12.0)

#define POINT_WIDTH VALUE(11.0)
#define POINT_HEIGHT VALUE(12.0)

#define LOAD_START_X VALUE([self loadStartX])
#define LOAD_START_Y VALUE([self loadStartY])
#define LOAD_HEIGHT VALUE([self loadHeight])
#define LOAD_WIDTH (WIDTH - LOAD_START_X*2)
#define POINT_X ([self xFromPercent:_percent] - POINT_WIDTH/2)

#define POP_POINT_SIZE VALUE(6.0)


@interface DrawSlider()
{
    CGPoint currentPoint;
    UIColor *loadColor;
    CGFloat _percent;
}
@property(nonatomic, retain) UIImage *bgImage;
@property(nonatomic, retain) UIImage *pointImage;


@end

@implementation DrawSlider


- (void)dealloc
{
    PPRelease(_bgImage);
    PPRelease(_pointImage);
    PPRelease(loadColor);
    [super dealloc];
}

- (id)initWithDrawSliderStyle:(DrawSliderStyle)style
{
    self = [super initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        //171 123 98
        loadColor = [[UIColor colorWithRed:171/255.0 green:123/255.0 blue:98/255.0 alpha:1] retain];
        
        currentPoint = CGPointZero;
        self.style = style;
        [self addTarget:self action:@selector(changeValue:) forControlEvents:UIControlEventValueChanged];
        [self setMaxValue:1.0];
        [self setMinValue:0.0];
        _percent = 0.5;
//        [self setValue:0.5];
    }
    return self;
}

- (CGFloat)value
{
    return (_percent * (_maxValue - _minValue)) + _minValue;
}

- (void)setValue:(CGFloat)value
{
    if (value >= _maxValue) {
        _percent = 1.0;
    }else if(value <= _minValue){
        _percent = 0.0;
    }else{
        _percent = (value - _minValue) / (_maxValue - _minValue);
    }
    //update the point
    [self setNeedsDisplay];
}

- (void)setMinValue:(CGFloat)minValue
{
    _minValue = minValue;
}

- (void)setMaxValue:(CGFloat)maxValue
{
    _maxValue = maxValue;
}

- (void)changeValue:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(drawSlider:didValueChange:)]) {
        [self.delegate drawSlider:self didValueChange:self.value];
    }
}

- (CGFloat)loadStartX
{
    return DrawSliderStyleLarge == self.style ? 4.0 : 4.2;
}

- (CGFloat)loadStartY
{
    return DrawSliderStyleLarge == self.style ? 3.8 : 4.5;
}

- (CGFloat)loadHeight
{
    return DrawSliderStyleLarge == self.style ? 2.6 : 2.0;
}

- (CGFloat)loadMinX
{
    return LOAD_START_X;
}

- (CGFloat)loadMaxX
{
    return WIDTH - LOAD_START_X;
}


- (CGFloat)percentFromX:(CGFloat)x
{
    if (x <= [self loadMinX]) {
        return 0;
    }
    if (x >= [self loadMaxX]) {
        return 1.0;
    }
    return (x-[self loadMinX])/LOAD_WIDTH;
}

- (CGFloat)xFromPercent:(CGFloat)percent
{
    if (percent >= 1.0) {
        return [self loadMaxX];
    }
    if (percent <= 0.0) {
        return [self loadMinX];
    }
    return [self loadMinX] + percent * LOAD_WIDTH;
}


- (void)setStyle:(DrawSliderStyle)style
{
    _style = style;
    //set the image according to the style
    
//    if (style == DrawSliderStyleLarge) {
    self.bgImage = [UIImage imageNamed:@"draw_slider2_bg"];
    self.pointImage = [UIImage imageNamed:@"draw_slider2_point"];
//    }else if (style == DrawSliderStyleSmall){
//        self.bgImage = [UIImage imageNamed:@"draw_slider1_bg"];
//        self.pointImage = [UIImage imageNamed:@"draw_slider1_point"];
//    }else{
//        return;
//    }    
    [self setNeedsDisplay];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, loadColor.CGColor);
    
    // Drawing code
    //Draw bg
    [self.bgImage drawAtPoint:CGPointMake(0, 0)];

    //Draw load
    CGRect r = CGRectMake(LOAD_START_X, LOAD_START_Y, POINT_X, LOAD_HEIGHT);
    CGContextFillRect(context, r);
    
    //draw point
    [self.pointImage drawAtPoint:CGPointMake(POINT_X, 0)];
    
    [super drawRect:rect];
}

- (void)updateValueWithCurrentPoint
{
    _percent = [self percentFromX:currentPoint.x];
}



- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    currentPoint = [touch locationInView:self];
    [self updateValueWithCurrentPoint];
    [self setNeedsDisplay];
    if (self.delegate && [self.delegate respondsToSelector:@selector(drawSlider:didStartToChangeValue:)]) {
        [self.delegate drawSlider:self didStartToChangeValue:self.value];
    }
    return YES;
}
- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    currentPoint = [touch locationInView:self];
    [self updateValueWithCurrentPoint];
    [self setNeedsDisplay];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    return YES;
}
- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    currentPoint = [touch locationInView:self];
    [self updateValueWithCurrentPoint];
    [self setNeedsDisplay];
    if (self.delegate && [self.delegate respondsToSelector:@selector(drawSlider:didFinishChangeValue:)]) {
        [self.delegate drawSlider:self didFinishChangeValue:self.value];
    }

}

@end


@implementation DrawSlider (PopupView)

#define POPTIPVIEW_TAG 201212271

- (void)popupWithContenView:(UIView *)contentView
{
    UIView *inView = [self superview];
    CMPopTipView *poptipView = (CMPopTipView *)[inView viewWithTag:POPTIPVIEW_TAG];
    if (poptipView == nil) {
        poptipView = [[[CMPopTipView alloc] initWithCustomView:contentView] autorelease];
        poptipView.tag = POPTIPVIEW_TAG;
        [poptipView setBackgroundColor:[UIColor colorWithRed:168./255. green:168./255. blue:168./255. alpha:0.4]];
    }else{
        if (poptipView.customView != contentView) {
            [poptipView.customView removeFromSuperview];
            [poptipView setCustomView:contentView];
        }
    }
    [poptipView presentPointingAtView:self inView:inView animated:NO];
    [poptipView setPointerSize:POP_POINT_SIZE];
}
- (void)dismissPopupView
{
    UIView *inView = [self superview];
    CMPopTipView *poptipView = (CMPopTipView *)[inView viewWithTag:POPTIPVIEW_TAG];
    [poptipView dismissAnimated:NO];
}

- (UIView *)contentView
{
    UIView *inView = [self superview];
    CMPopTipView *poptipView = (CMPopTipView *)[inView viewWithTag:POPTIPVIEW_TAG];
    return poptipView.customView;
}
- (CMPopTipView *)popTipView
{
    UIView *inView = [self superview];
    CMPopTipView *poptipView = (CMPopTipView *)[inView viewWithTag:POPTIPVIEW_TAG];
    return poptipView;
}
@end