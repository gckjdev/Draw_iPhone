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

#define VALUE(x) (ISIPAD ? x*2 : x)

#define WIDTH VALUE(92.5)


#define SPACE_EDGE_CONTENT VALUE(5)
#define HEIGHT (VALUE(12.0)+SPACE_EDGE_CONTENT*2)

#define POINT_WIDTH VALUE(11.0)
#define POINT_HEIGHT VALUE(12.0)



#define LOAD_START_X VALUE(4.0)
#define LOAD_START_Y (VALUE(3.8)+SPACE_EDGE_CONTENT)
#define LOAD_HEIGHT VALUE(2.6)
#define LOAD_WIDTH (WIDTH - LOAD_START_X*2)
#define LOAD_MIN_X (LOAD_START_X)
#define LOAD_MAX_X (WIDTH - LOAD_START_X*1.4)

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
    PPDebug(@"%@ dealloc",self);
    self.delegate = nil;
    PPRelease(_bgImage);
    PPRelease(_pointImage);
    PPRelease(loadColor);
    [super dealloc];
}

- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        //171 123 98
        loadColor = [[UIColor colorWithRed:171/255.0 green:123/255.0 blue:98/255.0 alpha:1] retain];
        
        currentPoint = CGPointZero;
        [self addTarget:self action:@selector(changeValue:) forControlEvents:UIControlEventValueChanged];
        [self setMaxValue:1.0];
        [self setMinValue:0.01];
        _percent = 0.5;

        self.bgImage = [[ShareImageManager defaultManager] drawSliderBG];
        self.pointImage = [[ShareImageManager defaultManager] drawSliderPoint];

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

//- (CGFloat)loadStartX
//{
//    return 4.0;
//}
//
//- (CGFloat)loadStartY
//{
//    return 3.8;
//}
//
//- (CGFloat)loadHeight
//{
//    return 2.6;
//}
//
//- (CGFloat)loadMinX
//{
//    return LOAD_START_X;
//}
//
//- (CGFloat)loadMaxX
//{
//    return WIDTH - LOAD_START_X;
//}


- (CGFloat)percentFromX:(CGFloat)x
{
    if (x <= LOAD_MIN_X) {
        return 0;
    }
    if (x >= LOAD_MAX_X) {
        return 1.0;
    }
    return (x-LOAD_MIN_X)/LOAD_WIDTH;
}

- (CGFloat)xFromPercent:(CGFloat)percent
{
    if (percent >= 1.0) {
        return LOAD_MAX_X;
    }
    if (percent <= 0.0) {
        return LOAD_MIN_X;
    }
    return LOAD_MIN_X + percent * LOAD_WIDTH;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.



- (void)drawRect:(CGRect)rect
{
    
    CGRect contentRect = CGRectMake(0, SPACE_EDGE_CONTENT, WIDTH, HEIGHT-SPACE_EDGE_CONTENT*2);
    
    if (self.selected) {
        [[[ShareImageManager defaultManager] drawSliderDisableImage] drawInRect:contentRect];
    }else{
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetFillColorWithColor(context, loadColor.CGColor);
        
        // Drawing code
        //Draw bg
        [self.bgImage drawInRect:contentRect];

        //Draw load
        CGRect r = CGRectMake(LOAD_START_X, LOAD_START_Y, POINT_X, LOAD_HEIGHT);
        CGContextFillRect(context, r);
        
        //draw point
        r = CGRectMake(POINT_X, SPACE_EDGE_CONTENT, POINT_WIDTH, POINT_HEIGHT);
        
        [self.pointImage drawInRect:r];
    }
    
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
        [poptipView setBackgroundColor:[UIColor colorWithRed:255./255. green:255./255. blue:255./255. alpha:0.95]];
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