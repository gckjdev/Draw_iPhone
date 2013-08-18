//
//  GradientSettingView.m
//  TestCodePool
//
//  Created by gamy on 13-7-2.
//  Copyright (c) 2013年 ict. All rights reserved.
//

#import "GradientSettingView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIViewUtils.h"
#import "DrawColor.h"
#import "ShareImageManager.h"

@interface GradientSettingView()
{
    CGFloat _degree;
    
}
@property (retain, nonatomic) IBOutlet UIButton *degreeButton;
@property (retain, nonatomic) IBOutlet UIButton *leftColorButton;
@property (retain, nonatomic) IBOutlet UIButton *rightColorButton;
@property (retain, nonatomic) IBOutlet UIImageView *gradientBg;
@property (retain, nonatomic) IBOutlet UIButton *divisionButton;
@property (retain, nonatomic) CMPopTipView *popColorView;

@property (retain, nonatomic) CAGradientLayer *gradientLayer;
@property (retain, nonatomic) Gradient *gradient;

- (IBAction)clickDegreeButton:(UIButton *)sender;
- (IBAction)clickLeftColor:(UIButton *)sender;
- (IBAction)clickRightColorButton:(UIButton *)sender;

@end

@implementation GradientSettingView

- (void)updateDivisionButton
{
 
}

- (void)clear
{
    [self.popColorView removeFromSuperview];
    self.popColorView = nil;
}

- (void)updatePointsWithDegree:(CGFloat)degree
{
    [self callBack];
}

- (void)updateLayer
{
    
    DrawColor *midColor = [DrawColor midColorWithStartColor:_gradient.startColor endColor:_gradient.endColor];
    
    self.gradientLayer.colors = [NSArray arrayWithObjects:(id)_gradient.startColor.CGColor, (id)midColor.CGColor, (id)_gradient.endColor.CGColor, nil];
    self.gradientLayer.locations = [NSArray arrayWithObjects:@(0), @(1 - _gradient.division), @(1), nil];

    CGPoint startPoint, endPoint;
    
    CGRect rect = CGRectMake(0, 0, 1, 1);
    
    calGradientPoints(rect, _degree, &startPoint, &endPoint);

    self.gradientLayer.startPoint = startPoint;
    self.gradientLayer.endPoint = endPoint;

}

#define GRADIENT_LAYER_FRAME (ISIPAD ? CGRectMake(200, 13, 450, 60) : CGRectMake(90, 5, 175, 31))



- (void)updateView
{
    
    [self.bgImageView setImage:[[ShareImageManager defaultManager] drawColorBG]];

    
    self.leftColorButton.layer.cornerRadius = CGRectGetHeight(_leftColorButton.bounds) / 2;
    self.leftColorButton.layer.masksToBounds = YES;
    [self.leftColorButton setBackgroundColor:_gradient.startColor.color];
    
    self.rightColorButton.layer.cornerRadius = CGRectGetHeight(_rightColorButton.bounds) / 2;
    self.rightColorButton.layer.masksToBounds = YES;
    [self.rightColorButton setBackgroundColor:_gradient.endColor.color];


    self.gradientLayer = [CAGradientLayer layer];
    self.gradientLayer.cornerRadius = 8;
    [self.gradientLayer setMasksToBounds:YES];
    self.gradientLayer.frame = GRADIENT_LAYER_FRAME;
    [self.layer addSublayer:self.gradientLayer];
//    self.gradientLayer.transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
    [self bringSubviewToFront:self.divisionButton];
    for (UIButton *button in self.subviews) {
        if ([button isKindOfClass:[UIButton class]] && button != self.divisionButton) {
            [self bringSubviewToFront:button];
        }
    }
    _degree = _gradient.degree;
    [self.degreeButton setTitle:[@((int)_degree) stringValue] forState:UIControlStateNormal];
    [self.degreeButton setBackgroundColor:COLOR_COFFEE];
    [self.degreeButton.layer setCornerRadius:8];
    [self.degreeButton.layer setMasksToBounds:YES];
    [self updateLayer];
    [self updateDivisionButton];
}


+ (id)gradientSettingViewWithGradient:(Gradient *)gradient
{
    GradientSettingView *settingView = [GradientSettingView createViewWithXibIdentifier:@"GradientSettingView"];
    settingView.gradient = gradient;
    [settingView updateView];
    return settingView;
}

#define ENLARGE_SIZE (ISIPAD ? 40 : 20)

- (IBAction)moveDivisionButton:(UIButton *)sender forEvent:(UIEvent *)event {
    
    CGPoint location = [[[event allTouches] anyObject] locationInView:self];
    
    CGRect frame = GRADIENT_LAYER_FRAME;
    frame.origin.x -= ENLARGE_SIZE;
    frame.size.width += 2*ENLARGE_SIZE;
    
    if (!CGRectContainsPoint(GRADIENT_LAYER_FRAME, location)) {
        return;
    }
    
    [self dismissPopView];
    
    
    
    location.y = CGRectGetMidY(GRADIENT_LAYER_FRAME);
    location.x = MAX(CGRectGetMinX(GRADIENT_LAYER_FRAME), location.x);
    location.x = MIN(CGRectGetMaxX(GRADIENT_LAYER_FRAME), location.x);
    sender.center = location;
    
    CGFloat division = (location.x - CGRectGetMinX(GRADIENT_LAYER_FRAME)) / CGRectGetWidth(GRADIENT_LAYER_FRAME);
    
    self.gradient.division = division;
    [self updateLayer];
    [self callBack];

}


- (void)dealloc {
    PPDebug(@"<GradientSettingView> dealloc");
    PPRelease(_degreeButton);
    PPRelease(_leftColorButton);
    PPRelease(_rightColorButton);
    PPRelease(_gradientBg);
    PPRelease(_divisionButton);
    PPRelease(_gradientLayer);
    PPRelease(_gradient);
    PPRelease(_popColorView);
    [_bgImageView release];
    [super dealloc];
}

#define LEFT_PALETTE_TAG 1
#define RIGHT_PALETTE_TAG 2
#define DEGREE_TAG 3

- (void)callBack
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(gradientSettingView:didChangeradient:)]) {
        [self.delegate gradientSettingView:self didChangeradient:self.gradient];
    }
    
}

- (IBAction)clickDegreeButton:(UIButton *)sender {
    
    if (self.popColorView.customView.tag == DEGREE_TAG) {
        [self dismissPopView];
    }else{
        [self dismissPopView]; 
        DrawSlider *slider = [DrawSlider sliderWithMaxValue:360 minValue:0 defaultValue:_degree delegate:self];
        slider.tag = DEGREE_TAG;
        self.popColorView = [[[CMPopTipView alloc] initWithCustomView:slider] autorelease];
        self.popColorView.delegate = self;
        [self.popColorView setBackgroundColor:[UIColor colorWithRed:255./255. green:255./255. blue:255./255. alpha:0.95]];

        [self.popColorView presentPointingAtView:sender inView:self.theTopView animated:NO];
    }
}


- (void)handleColorSelection:(DrawColor *)color sender:(UIButton *)sender
{
    [self.popColorView dismissAnimated:NO];
    self.popColorView = nil;
    Palette *palette = [Palette createViewWithdelegate:self];
    palette.tag = (sender == self.leftColorButton) ? LEFT_PALETTE_TAG : RIGHT_PALETTE_TAG;
    [palette setCurrentColor:color];
    self.popColorView = [[[CMPopTipView alloc] initWithCustomView:palette] autorelease];
    self.popColorView.delegate = self;    
    [self.popColorView setBackgroundColor:[UIColor colorWithRed:255./255. green:255./255. blue:255./255. alpha:0.95]];

    [self.popColorView presentPointingAtView:sender inView:self.theTopView animated:NO pointDirection:PointDirectionDown];
 
}

- (IBAction)clickLeftColor:(UIButton *)sender {
    if (LEFT_PALETTE_TAG == self.popColorView.customView.tag) {
        [self dismissPopView];
        return;
    }    
    [self handleColorSelection:[DrawColor colorWithColor:_gradient.startColor] sender:sender];
}

- (IBAction)clickRightColorButton:(UIButton *)sender {
    if (RIGHT_PALETTE_TAG == self.popColorView.customView.tag) {
        [self dismissPopView];
        return;
    }
    [self handleColorSelection:[DrawColor colorWithColor:_gradient.endColor] sender:sender];
}



#pragma mark pallete delegate
- (void)palette:(Palette *)palette didPickColor:(DrawColor *)color
{
    if (palette.tag == LEFT_PALETTE_TAG) {
        _gradient.startColor = color;
        self.leftColorButton.backgroundColor = color.color;
    }else{
        _gradient.endColor = color;
        self.rightColorButton.backgroundColor = color.color;
    }
    [self updateLayer];
    [self callBack];
}


- (void)dismissPopView
{
    if (self.popColorView) {
        [self.popColorView dismissAnimated:NO];
        //self.popColorView = nil;
        PPRelease(_popColorView);
    }
}

#pragma mark- DrawSlider Delegate

- (void)updateDegreeWithValue:(CGFloat)value slider:(DrawSlider *)slider
{
    _degree = value;
    _gradient.degree = value;
    [self updateLayer];
    UILabel *label = (id)slider.contentView;
    
    NSString *str = [NSString stringWithFormat:@"%.0f°",value];
    [label setText:str];
    
    [self.degreeButton setTitle:[@((int)value) stringValue] forState:UIControlStateNormal];
    [self callBack];
}

- (void)drawSlider:(DrawSlider *)drawSlider didValueChange:(CGFloat)value
{
    [self updateDegreeWithValue:value slider:drawSlider];
}

- (void)drawSlider:(DrawSlider *)drawSlider didStartToChangeValue:(CGFloat)value
{
    if (DEGREE_TAG != drawSlider.tag) {
        [self dismissPopView];
    }
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 30)] autorelease];
    [drawSlider popupWithContenView:label];
    [label setTextAlignment:NSTextAlignmentCenter];
    [self updateDegreeWithValue:value slider:drawSlider];
}

- (void)drawSlider:(DrawSlider *)drawSlider didFinishChangeValue:(CGFloat)value
{
    [self updateDegreeWithValue:value slider:drawSlider];
    [drawSlider dismissPopupView];
}

#pragma mark-- CMPopTipView delegate

- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
//    if (popTipView.customView.tag == DEGREE_TAG) {
//    PPRelease(popTipView);
//    }
    self.popColorView = nil;
}

@end
