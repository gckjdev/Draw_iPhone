//
//  DrawToolPanel.m
//  Draw
//
//  Created by gamy on 12-12-24.
//
//

#import "DrawToolPanel.h"
#import "DrawColor.h"
#import "WidthView.h"
#import "CMPopTipView.h"



@interface DrawToolPanel ()
{
//    CMPopTipView *_penPopTipView;
//    CMPopTipView *_colorBoxPopTipView;
//    CMPopTipView *_palettePopTipView;
}

#pragma mark - click actions
- (IBAction)clickUndo:(id)sender;
- (IBAction)clickRedo:(id)sender;

- (IBAction)clickPen:(id)sender;
- (IBAction)clickEraser:(id)sender;
- (IBAction)clickAddColor:(id)sender;
- (IBAction)clickPalette:(id)sender;
- (IBAction)clickPaintBucket:(id)sender;

@property (retain, nonatomic) IBOutlet DrawSlider *widthSlider;
@property (retain, nonatomic) IBOutlet DrawSlider *alphaSlider;
@property (retain, nonatomic) IBOutlet UILabel *penWidth;
@property (retain, nonatomic) IBOutlet UILabel *colorAlpha;


@property (retain, nonatomic) CMPopTipView *penPopTipView;
@property (retain, nonatomic) CMPopTipView *colorBoxPopTipView;
@property (retain, nonatomic) CMPopTipView *palettePopTipView;




@end

@implementation DrawToolPanel

#define MAX_COLOR_NUMBER 8
#define VALUE(x) (ISIPAD ? x*2 : x)

#define SPACE_COLOR_LEFT VALUE(8)
#define SPACE_COLOR_COLOR VALUE(2)
#define SPACE_COLOR_UP VALUE(10)


- (void)updatePopTipView:(CMPopTipView *)popTipView
{
    [popTipView setBackgroundColor:[UIColor colorWithRed:168./255. green:168./255. blue:168./255. alpha:0.4]];
    [popTipView setPointerSize:6.0];
    [self.palettePopTipView setDelegate:self];
}

- (void)updateSliders
{
    CGPoint center = self.widthSlider.center;
    [self.widthSlider removeFromSuperview];
    self.widthSlider = [[[DrawSlider alloc] initWithDrawSliderStyle:DrawSliderStyleLarge] autorelease];
    self.widthSlider.center = center;
    self.widthSlider.delegate = self;
    
    [self.widthSlider setMaxValue:27];
    [self.widthSlider setMinValue:2];
    [self.widthSlider setValue:6];

    [self addSubview:self.widthSlider];
    
    center = self.alphaSlider.center;
    [self.alphaSlider removeFromSuperview];
    self.alphaSlider = [[[DrawSlider alloc] initWithDrawSliderStyle:DrawSliderStyleLarge] autorelease];
    self.alphaSlider.center = center;
    [self.alphaSlider setValue:1.0];
    self.alphaSlider.delegate = self;
    [self addSubview:self.alphaSlider];

}


- (void)updateView
{
    //update color
    NSArray *list = [DrawColor getRecentColorList];
    NSInteger i = 0;
    for (DrawColor *color in list) {
        ColorPoint *point = [ColorPoint pointWithColor:color];
        [self addSubview:point];
        CGRect frame = point.frame;
        CGFloat x = SPACE_COLOR_LEFT + i * (CGRectGetWidth(point.frame) + SPACE_COLOR_COLOR);
        
        frame.origin = CGPointMake(x, SPACE_COLOR_UP);
        point.frame = frame;
        point.delegate = self;
        if (++i >= MAX_COLOR_NUMBER) {
            break;
        }
    }
    
    
    //update width and alpha
    [self updateSliders];
}


+ (id)createViewWithdelegate:(id)delegate
{
    NSString *identifier = @"DrawToolPanel";
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:identifier
                                                             owner:self options:nil];
    
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create %@ but cannot find cell object from Nib", identifier);
        return nil;
    }
    
    DrawToolPanel  *view = (DrawToolPanel *)[topLevelObjects objectAtIndex:0];
    view.delegate = delegate;
    [view updateView];
    return view;
    
}

- (void)dismissAllPopTipViews
{
    [self.penPopTipView dismissAnimated:NO];
    [self.colorBoxPopTipView dismissAnimated:NO];
    [self.palettePopTipView dismissAnimated:NO];
}

#pragma mark - click actions
- (IBAction)clickUndo:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(drawToolPanel:didClickUndoButton:)]) {
        [self.delegate drawToolPanel:self didClickUndoButton:sender];
    }
}

- (IBAction)clickRedo:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(drawToolPanel:didClickRedoButton:)]) {
        [self.delegate drawToolPanel:self didClickRedoButton:sender];
    }
}


- (IBAction)clickEraser:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(drawToolPanel:didClickEraserButton:)]) {
        [self.delegate drawToolPanel:self didClickEraserButton:sender];
    }
}


- (IBAction)clickPaintBucket:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(drawToolPanel:didClickPaintBucket:)]) {
        [self.delegate drawToolPanel:self didClickPaintBucket:sender];
    }
}

- (IBAction)clickAddColor:(id)sender {
    //Pop up add color box
}

- (IBAction)clickPalette:(id)sender {

    if (self.palettePopTipView == nil) {
        //pop up palette
        Palette *palette = [Palette createViewWithdelegate:self];
        self.palettePopTipView = [[[CMPopTipView alloc] initWithCustomView:palette] autorelease];
        [self.palettePopTipView presentPointingAtView:sender inView:self.superview animated:NO];
        [self updatePopTipView:self.palettePopTipView];
    }else{
        [self.palettePopTipView dismissAnimated:NO];
        self.palettePopTipView = nil;
    }
}

- (IBAction)clickPen:(id)sender {
    //pop up pen box.
}


#pragma mark - Color Point Delegate
- (void)didSelectColorPoint:(ColorPoint *)colorPoint
{
    for (ColorPoint *point in [self subviews]) {
        if ([point isKindOfClass:[ColorPoint class]] && colorPoint != point) {
            [point setSelected:NO];
        }
    }
}


#pragma mark - DrawSlider delegate


- (void)drawSlider:(DrawSlider *)drawSlider
    didValueChange:(CGFloat)value
{
    if (self.widthSlider == drawSlider) {
        WidthView *widthView = (WidthView *)drawSlider.contentView;
        [widthView setWidth:value];
    }else if(self.alphaSlider == drawSlider){
        NSString *v = [NSString stringWithFormat:@"%.1f",value];
        UILabel *label = (UILabel *)drawSlider.contentView;
        [label setText:v];
    }
}


- (void)drawSlider:(DrawSlider *)drawSlider didFinishChangeValue:(CGFloat)value
{
    [drawSlider dismissPopupView];
}

- (void)drawSlider:(DrawSlider *)drawSlider didStartToChangeValue:(CGFloat)value
{
    if (drawSlider == self.alphaSlider) {
        NSString *v = [NSString stringWithFormat:@"%.1f",value];
        UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 20)] autorelease];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setText:v];
        [drawSlider popupWithContenView:label];
        [label setBackgroundColor:[UIColor clearColor]];
    }else if(drawSlider == self.widthSlider){
        WidthView *width = [WidthView viewWithWidth:value];
        [drawSlider popupWithContenView:width];
        [width setSelected:YES];
        [width setNeedsDisplay];
    }
}


#pragma mark - CMPopTipView Delegate

- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
    PPDebug(@"<popTipViewWasDismissedByUser> popTipView retain Count = %d", [popTipView retainCount]);
    if (popTipView == self.palettePopTipView) {
        self.palettePopTipView = nil;
    }
}
- (void)popTipViewWasDismissedByCallingDismissAnimatedMethod:(CMPopTipView *)popTipView
{
    
}


- (void)dealloc {
    PPRelease(_colorBoxPopTipView);
    PPRelease(_penPopTipView);
    PPRelease(_palettePopTipView);
    
    PPRelease(_widthSlider);
    PPRelease(_alphaSlider);
    PPRelease(_penWidth);
    PPRelease(_colorAlpha);
    
    [super dealloc];
}
@end
