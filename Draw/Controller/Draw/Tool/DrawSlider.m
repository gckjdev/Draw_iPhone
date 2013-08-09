//
//  DrawSlider.m
//  Draw
//
//  Created by gamy on 12-12-25.
//
//

#import "DrawSlider.h"
#import "CMPopTipView.h"
#import "ShareImageManager.h"
#import "UIViewUtils.h"

#define VALUE(x) (ISIPAD ? x*2 : x)

//#define WIDTH VALUE(92.5)


//#define SPACE_EDGE_CONTENT VALUE(5)
//#define HEIGHT (VALUE(12.0)+SPACE_EDGE_CONTENT*2)
//
//#define POINT_WIDTH VALUE(11.0)
//#define POINT_HEIGHT VALUE(12.0)
//
//
//
//#define LOAD_START_X VALUE(4.0)
//#define LOAD_START_Y (VALUE(3.8)+SPACE_EDGE_CONTENT)
//#define LOAD_HEIGHT VALUE(2.6)
//#define LOAD_WIDTH (WIDTH - LOAD_START_X*2)
//#define LOAD_MIN_X (LOAD_START_X)
//#define LOAD_MAX_X (WIDTH - LOAD_START_X*1.4)
//
//#define POINT_X ([self xFromPercent:_percent] - POINT_WIDTH/2)
//
#define POP_POINT_SIZE VALUE(6.0)


@interface DrawSlider()
{
    UIColor *loadColor;
    CGFloat _value;
}
@property (retain, nonatomic) IBOutlet UIImageView *loaderImage;
@property(nonatomic, retain) IBOutlet UIImageView *bgImage;
@property(nonatomic, retain) IBOutlet UIImageView *pointImage;
- (IBAction)changeValue:(id)sender;
- (CGFloat)valueFromPoint:(CGPoint)point;
- (CGPoint)pointFromValue:(CGFloat)value;
- (void)updateViewWithValue:(CGFloat)value;
@end

@implementation DrawSlider


- (void)dealloc
{
    PPDebug(@"%@ dealloc",self);
    self.delegate = nil;
    PPRelease(_bgImage);
    PPRelease(_pointImage);
    PPRelease(loadColor);
    PPRelease(_loaderImage);
    [super dealloc];
}


- (void)updateView
{
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    [self.bgImage setImage:[imageManager drawSliderBG]];
    [self.loaderImage setImage:[imageManager drawSliderLoader]];
    [self.pointImage setImage:[imageManager drawSliderPoint]];

}
+ (id)sliderWithMaxValue:(CGFloat)maxValue
                minValue:(CGFloat)minValue
            defaultValue:(CGFloat)defaultValue
                delegate:(id<DrawSliderDelegate>) delegate
{
    DrawSlider *slider = [UIView createViewWithXibIdentifier:@"DrawSlider"];
    [slider updateView];
    [slider setMaxValue:maxValue];
    [slider setMinValue:minValue];
    [slider setValue:defaultValue];
    [slider setDelegate:delegate];
//    [slider addTarget:self action:@selector(changeValue:)
//     forControlEvents:UIControlEventValueChanged];
    return slider;
}

#define HALF_POINT_WDITH CGRectGetMidX(self.pointImage.bounds)
#define MIN_POINT_X (CGRectGetMinX(self.bgImage.frame) + HALF_POINT_WDITH)
#define MAX_POINT_X (CGRectGetMaxX(self.bgImage.frame) - HALF_POINT_WDITH)
#define CENTER_Y CGRectGetMidY(self.bgImage.frame)
#define LENGTH (MAX_POINT_X - MIN_POINT_X)

- (CGPoint)fixPoint:(CGPoint)point
{
    point.y = CENTER_Y;
    point.x = MIN(point.x, MAX_POINT_X);
    point.x = MAX(point.x, MIN_POINT_X);
    return point;
    
}
- (CGFloat)valueFromPoint:(CGPoint)point
{
    point = [self fixPoint:point];
    CGFloat percent = (point.x - MIN_POINT_X) / LENGTH;
    return percent * (_maxValue - _minValue) + _minValue;
}
- (CGPoint)pointFromValue:(CGFloat)value
{
    CGFloat percent = (value - _minValue) / (_maxValue -_minValue);
    CGFloat x = percent * LENGTH + MIN_POINT_X;
    return [self fixPoint:CGPointMake(x, CENTER_Y)];
}
- (void)updateViewWithValue:(CGFloat)value
{
    CGPoint point = [self pointFromValue:value];
    [self.pointImage setCenter:point];
    CGRect frame = self.loaderImage.frame;
    frame.size.width = point.x - MIN_POINT_X + HALF_POINT_WDITH;
    [self.loaderImage setFrame:frame];
}
- (CGFloat)value
{
    return _value;
}

- (void)setValue:(CGFloat)value
{
    _value = MIN(_maxValue, value);
    _value = MAX(_minValue, value);
    [self updateViewWithValue:_value];
    
}

- (void)updateValueWithPoint:(CGPoint)point
{
    self.value = [self valueFromPoint:point];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (selected) {
        self.alpha = 0.7;
    }else{
        self.alpha = 1.0;
    }
}


- (IBAction)changeValue:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(drawSlider:didValueChange:)]) {
        [self.delegate drawSlider:self didValueChange:self.value];
    }
}

- (BOOL)canSlide
{
    return ![self isSelected];
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint currentPoint = [touch locationInView:self];
    if ([self canSlide]) {
        [self updateValueWithPoint:currentPoint];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(drawSlider:didStartToChangeValue:)]) {
        [self.delegate drawSlider:self didStartToChangeValue:self.value];
    }
    return [self canSlide];
}
- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint currentPoint = [touch locationInView:self];
    [self updateValueWithPoint:currentPoint];
//    [self sendActionsForControlEvents:UIControlEventValueChanged];
    if (self.delegate && [self.delegate respondsToSelector:@selector(drawSlider:didValueChange:)]) {
        [self.delegate drawSlider:self didValueChange:self.value];
    }
    return YES;
}
- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint currentPoint = [touch locationInView:self];
    [self updateValueWithPoint:currentPoint];
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
        [poptipView setBackgroundColor:[UIColor colorWithRed:255./255. green:255./255. blue:255./255. alpha:0.95]];
    }else{
        if (poptipView.customView != contentView) {
            [poptipView.customView removeFromSuperview];
            [poptipView setCustomView:contentView];
        }
 
    }
    [poptipView presentPointingAtView:self inView:inView animated:NO pointDirection:PointDirectionDown];
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