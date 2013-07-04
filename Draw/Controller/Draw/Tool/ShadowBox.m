//
//  ShadowBox.m
//  Draw
//
//  Created by gamy on 13-2-26.
//
//

#import "ShadowBox.h"
#import "DrawAction.h"
#import "DrawSlider.h"
#import "DrawColor.h"
#import "PocketSVG.h"
#import <QuartzCore/QuartzCore.h>
#import "CustomInfoView.h"
#import "ConfigManager.h"

@interface ShadowBox()
{
    ShadowPreview *preView;
    ShadowSettingView *settingView;
    BOOL _isSpan;
}
@property (retain, nonatomic) IBOutlet UILabel *recentLabel;
@property (retain, nonatomic) IBOutlet UIButton *cancelButton;
@property (retain, nonatomic) IBOutlet UIButton *applyButton;
@property (retain, nonatomic) IBOutlet UIButton *customButton;
@property (retain, nonatomic) CustomInfoView *infoView;

- (IBAction)clickCancel:(id)sender;
- (IBAction)clickApply:(id)sender;
- (IBAction)clickCustom:(id)sender;
- (IBAction)clickRecentShadow:(UIButton *)sender;
- (IBAction)clickSystemShadow:(UIButton *)sender;

@end

@implementation ShadowBox
@synthesize shadow = _shadow;

- (void)dismiss
{
    [self.infoView dismiss];
    self.infoView.infoView = nil;
    self.infoView = nil;
}

- (void)showInView:(UIView *)view
{
    if (self.infoView == nil) {
        __block typeof (self) bself = self;
        self.infoView = [CustomInfoView createWithTitle:NSLS(@"kSetShadow")
                                               infoView:self
                                           closeHandler:^{
                                               bself.infoView = nil;
                                           }];
        
        [self.infoView.mainView updateCenterY:(self.infoView.mainView.center.y - (ISIPAD ? 35 : 20))];
    }

    [self.infoView showInView:view];
    [self updateView];
}

- (void)dealloc {
    PPRelease(_cancelButton);
    PPRelease(_applyButton);
    PPRelease(_customButton);
    PPRelease(_shadow);
    PPRelease(_shadow);
    [_recentLabel release];
    [super dealloc];
}

#define SETTING_PARENT_VIEW_TAG 12345

#define RECENT_BUTTON_BASE_TAG 100
#define RECENT_BUTTON_COUNT 4

//System shadow
#define SYSTEM_SHADOW_BUTTON_TAG 200
#define SYSTEM_SHADOW_BUTTON_COUNT 4

- (void)updateSystemShadowButtons
{
    NSArray *titles = @[NSLS(@"kLeftTop"), NSLS(@"kRightTop"), NSLS(@"kLeftBottom"), NSLS(@"kRightBottom")];
    for (int i = 0; i < SYSTEM_SHADOW_BUTTON_COUNT; ++ i) {
        UIButton *button = (id)[self viewWithTag:SYSTEM_SHADOW_BUTTON_TAG + i];
        NSString *title = [titles objectAtIndex:i];
        [button setTitle:title forState:UIControlStateNormal];
    }
}

- (void)updateRecentShadows
{
    NSArray *list = [[ShadowManager defaultManager] recentShadowList];
    for (NSInteger i = 0; i < 4; ++ i) {
        NSInteger tag = RECENT_BUTTON_BASE_TAG + i;
        UIButton *button = (id)[self viewWithTag:tag];
        if (i < [list count]) {
            button.enabled = YES;
            [button setTitle:[@(i+1) stringValue] forState:UIControlStateNormal];
        }else{
            button.enabled = NO;
            [button setTitle:NSLS(@"kNone") forState:UIControlStateNormal];
        }
    }
}

- (void)updateView
{
//    self.backgroundColor = [UIColor yellowColor];
    _isSpan = YES;
    preView = [ShadowPreview shadowPreviewWithShadow:self.shadow];
    [self addSubview:preView];
    settingView = [ShadowSettingView shadowSettingViewWithShadow:_shadow];
    [[self viewWithTag:SETTING_PARENT_VIEW_TAG] addSubview:settingView];
    settingView.delegate = self;
    [self hideSettingView:NO];
    [self updateRecentShadows];
    
    //Set text
    [self.cancelButton setTitle:NSLS(@"kNoShadow") forState:UIControlStateNormal];
    [self.applyButton setTitle:NSLS(@"kApply") forState:UIControlStateNormal];
    [self.customButton setTitle:NSLS(@"kCustom") forState:UIControlStateNormal];
    
    [self.recentLabel setText:NSLS(@"kRecent")];

    //update system shadow button
    [self updateSystemShadowButtons];

}

+ (id)shadowBoxWithShadow:(Shadow *)shadow
{
    ShadowBox *box = [UIView createViewWithXibIdentifier:@"ShadowBox"];
    box.shadow = shadow;
    return box;
}

- (void)shadowSettingView:(ShadowSettingView *)settingView didChangeShadow:(Shadow *)shadow
{
    [preView setNeedsDisplay];
}

- (IBAction)clickCancel:(id)sender {
    _shadow.blur = 0;
    [_shadow updateWithDegree:0 distance:0];
    _shadow.color = [DrawColor grayColor];
    [preView setNeedsDisplay];
    [settingView updateSliders];
    
    [self clickApply:nil];//apply && close the window
    
}

- (IBAction)clickApply:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(shadowBox:didGetShadow:)])
    {
        [self.delegate shadowBox:self didGetShadow:self.shadow];
    }
    [[ShadowManager defaultManager] pushRecentShadow:self.shadow];    
}

#define ANIMATION_INTERVAL 0.5
#define SPAN_HEIGHT ISIPAD ? 330 : 159

- (void)spanSettingView:(BOOL)animated
{
    if (!_isSpan) {
        _isSpan = YES;
        
//        __block CGRect frame = self.frame;
        __block CGRect frame = self.infoView.mainView.frame;
        NSTimeInterval interval = animated ? ANIMATION_INTERVAL : 0;
        [UIView animateWithDuration:interval animations:^{
            frame.size.height += SPAN_HEIGHT;
//            self.frame = frame;
            self.infoView.mainView.frame = frame;
        } completion:^(BOOL finished) {
            [settingView.superview setClipsToBounds:NO];
        }];
    }

}

- (void)hideSettingView:(BOOL)animated
{
    if (_isSpan) {
        _isSpan = NO;
        
        [settingView.superview setClipsToBounds:YES];
//        __block CGRect frame = self.frame;
        __block CGRect frame = self.infoView.mainView.frame;
        NSTimeInterval interval = animated ? ANIMATION_INTERVAL : 0;
        
        [UIView animateWithDuration:interval animations:^{
            frame.size.height -= SPAN_HEIGHT;
//            self.frame = frame;
            self.infoView.mainView.frame = frame;            
        } completion:NULL];
    }
}

- (IBAction)clickCustom:(id)sender {
    [self spanSettingView:YES];
    [self makeSelectedButton:sender];
}

#define MOD 100

- (void)performClickShadowButton:(NSInteger)tag shadowList:(NSArray *)list
{
    NSInteger index = tag % MOD;
    if (index < [list count]) {
        Shadow *shadow = [list objectAtIndex:index];
        shadow = [Shadow shadowWithShadow:shadow];
        if (shadow) {
            [self setShadow:shadow];
            [settingView setShadow:shadow];
            [preView setShadow:shadow];
        }
    }
}

- (void)makeSelectedButton:(UIButton *)button
{
    for (UIButton *btn in self.subviews) {
        if (btn.tag > 0 && [btn isKindOfClass:[UIButton class]] && btn.isSelected) {
            [btn setSelected:NO];
        }
    }
    [button setSelected:YES];
}

- (IBAction)clickRecentShadow:(UIButton *)sender {
    [self hideSettingView:YES];
    NSArray *list = [[ShadowManager defaultManager] recentShadowList];
    [self performClickShadowButton:sender.tag shadowList:list];
    [self makeSelectedButton:sender];
}

- (IBAction)clickSystemShadow:(UIButton *)sender{
    [self hideSettingView:YES];
    NSArray *list = [[ShadowManager defaultManager] systemShadowList];
    [self performClickShadowButton:sender.tag shadowList:list];
    [self makeSelectedButton:sender];    
}
@end




//#define NORMAL_SIZE 64
#define SCALE (ISIPAD ? 1.8 : 0.9)
#define PREVIEW_FRAME_IPHONE CGRectMake(5, 91, 240, 60)
#define PREVIEW_FRAME_IPAD CGRectMake(10, 162, 480, 120)
#define PREVIEW_FRAME ISIPAD ? PREVIEW_FRAME_IPAD : PREVIEW_FRAME_IPHONE

@implementation ShadowPreview

- (void)setShadow:(Shadow *)shadow
{
    if (_shadow != shadow) {
        _shadow = shadow;
        [self setNeedsDisplay];
    }
}

+ (id)shadowPreviewWithShadow:(Shadow *)shadow
{
    ShadowPreview *preView = [[ShadowPreview alloc] initWithFrame:PREVIEW_FRAME];
    [preView setShadow:shadow];
    [preView setBackgroundColor:[UIColor clearColor]];
    return [preView autorelease];
}

- (void)drawRect:(CGRect)rect
{
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:8];
    [[UIColor whiteColor] setFill];
    [path fill];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 4);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    UIColor *color = OPAQUE_COLOR(149, 239, 238);
    [color setFill];
    [color setStroke];
    UIBezierPath *line = [PocketSVG bezierPathWithSVGFileNamed:@"line"];
    UIBezierPath *rect3 = [PocketSVG bezierPathWithSVGFileNamed:@"rect"];
    path = [PocketSVG bezierPathWithSVGFileNamed:@"path"];
    CGContextSaveGState(context);

    CGContextScaleCTM(context, SCALE, SCALE);
    if (self.shadow) {
        [self.shadow updateContext:context];
    }
    CGContextTranslateCTM(context, 30, 2);
    [line fill];
    CGContextTranslateCTM(context, 70, 0);
    [rect3 fill];
    CGContextTranslateCTM(context, 70, 0);
    [path fill];
    
    CGContextRestoreGState(context);


    
}

@end

#define VALUE(X) (ISIPAD ? 2 * X : X)
#define ALPHA_LABEL_FRAME (ISIPAD ? CGRectMake(0, 0, 40*2, 20*2) : CGRectMake(0, 0, 40, 20))
#define ALPHA_FONT_SIZE VALUE(14.0)


@implementation ShadowSettingView

#define REPLACE_SLIDER(SLIDER,MIN_VALUE,MAX_VALUE,DEFAULT_VALUE,TAG)\
frame = SLIDER.frame;\
[SLIDER removeFromSuperview];\
SLIDER = [DrawSlider sliderWithMaxValue:MAX_VALUE\
                               minValue:MIN_VALUE\
                           defaultValue:DEFAULT_VALUE\
                               delegate:self];\
SLIDER.frame = frame;\
SLIDER.tag = TAG;\
[self addSubview:SLIDER];


#define MAX_SHADOW_DISTANCE [ConfigManager maxShadowDistance]
#define MAX_SHADOW_BLUR [ConfigManager maxShadowBlur]



- (void)updateViews
{
    
    CGRect frame;
    REPLACE_SLIDER(self.degreeSlider, 0, 360, _shadow.degree, 1);
    REPLACE_SLIDER(self.distanceSlider, 0, MAX_SHADOW_DISTANCE, _shadow.distance, 2);
    REPLACE_SLIDER(self.blurSlider, 0, MAX_SHADOW_BLUR, _shadow.blur, 3);
    
    
    //add Palette
    Palette *palette = [Palette createViewWithdelegate:self];
    palette.backgroundColor = [UIColor whiteColor];
    palette.layer.cornerRadius = 10;
    palette.layer.masksToBounds = YES;
    
    frame = self.palette.frame;
    CGFloat sx = CGRectGetWidth(self.palette.bounds) / CGRectGetWidth(palette.bounds);
    CGFloat sy = CGRectGetHeight(self.palette.bounds) / CGRectGetHeight(palette.bounds);
    CGAffineTransform scale = CGAffineTransformMakeScale(sx, sy);
    [palette setTransform:scale];
    palette.center = CGRectGetCenter(frame);
    [self.palette removeFromSuperview];
    self.palette = palette;
    [self addSubview:palette];
    if (self.shadow.color) {
//        palette.currentColor = self.shadow.color;
        self.palette.currentColor = [DrawColor colorWithColor:_shadow.color];
    }
    
    //Set Text
    [self.distanceLabel setText:NSLS(@"kDistance")];
    [self.degreeLabel setText:NSLS(@"kDegree")];
    [self.blurLabel setText:NSLS(@"kBlur")];
    
}

- (void)updateSliders
{
    self.degreeSlider.value = _shadow.degree;
    self.distanceSlider.value = _shadow.distance;
    self.blurSlider.value = _shadow.blur;
    self.palette.currentColor = [DrawColor colorWithColor:_shadow.color];
}


+ (id)shadowSettingViewWithShadow:(Shadow *)shadow
{
    ShadowSettingView *view = [UIView createViewWithXibIdentifier:@"ShadowBox" ofViewIndex:1];
//    view.center = SETTINGVIEW_CENTER;
    [view setShadow:shadow];
    [view updateViews];
    return view;
}
- (void)updateLabel:(UILabel *)label value:(CGFloat)value format:(NSString *)format
{
    NSString *v = [NSString stringWithFormat:format,value];
    [label setText:v];
}

- (void)callBack
{
    if ([self.delegate respondsToSelector:@selector(shadowSettingView:didChangeShadow:)]) {
        [self.delegate shadowSettingView:self didChangeShadow:self.shadow];
    }
}

- (void)setShadow:(Shadow *)shadow
{
    if (_shadow != shadow) {
        _shadow = shadow;
        self.distanceSlider.value = _shadow.distance;
        self.blurSlider.value = _shadow.blur;
        self.degreeSlider.value = _shadow.degree;
    }
}

- (void)updateShadowWithSlider:(DrawSlider *)slider
{
    CGFloat value = slider.value;
    if (slider == self.degreeSlider) {
        [self.shadow updateWithDegree:value distance:_shadow.distance];
    }else if(slider == self.distanceSlider){
        [self.shadow updateWithDegree:_shadow.degree distance:value];
    }else if(slider == self.blurSlider){
        self.shadow.blur = value;
    }else{
        
    }
    [self callBack];
}

- (void)drawSlider:(DrawSlider *)drawSlider didValueChange:(CGFloat)value
{
    UILabel *label = (UILabel *)drawSlider.contentView;

    if (drawSlider == self.degreeSlider) {
        [self updateLabel:label value:value format:@"%.0f°"];
    }else{
        [self updateLabel:label value:value format:@"%.01f"];
    }
    [self updateShadowWithSlider:drawSlider];    
}
- (void)drawSlider:(DrawSlider *)drawSlider didStartToChangeValue:(CGFloat)value
{
    
    UILabel *label = [[[UILabel alloc] initWithFrame:ALPHA_LABEL_FRAME] autorelease];
    [label setTextAlignment:NSTextAlignmentCenter];
    [drawSlider popupWithContenView:label];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setFont:[UIFont boldSystemFontOfSize:ALPHA_FONT_SIZE]];
    UIColor *textColor = [UIColor colorWithRed:23./255. green:21./255. blue:20./255. alpha:1];
    [label setTextColor:textColor];
    if (drawSlider == self.degreeSlider) {
        [self updateLabel:label value:value format:@"%.0f°"];
    }else{
        [self updateLabel:label value:value format:@"%.01f"];
    }
    [self updateShadowWithSlider:drawSlider];
}
- (void)drawSlider:(DrawSlider *)drawSlider didFinishChangeValue:(CGFloat)value
{
    [drawSlider.contentView removeFromSuperview];
    [drawSlider dismissPopupView];
}

- (void)palette:(Palette *)palette didPickColor:(DrawColor *)color
{
    _shadow.color = color;
    [self callBack];
}

- (void)dealloc {
    PPRelease(_degreeLabel);
    PPRelease(_distanceLabel);
    PPRelease(_blurLabel);
    PPRelease(_degreeSlider);
    PPRelease(_distanceSlider);
    PPRelease(_blurSlider);
    PPRelease(_palette);
    [super dealloc];
}
@end
