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
#import "PenBox.h"
#import "ColorView.h"
#import "ShareImageManager.h"
#import "ItemManager.h"
#import "ItemType.h"

@interface DrawToolPanel ()
{
    NSTimer *timer;
    NSInteger _retainTime;
}

#pragma mark - click actions
- (IBAction)clickUndo:(id)sender;
- (IBAction)clickRedo:(id)sender;

- (IBAction)clickPen:(id)sender;
- (IBAction)clickEraser:(id)sender;
- (IBAction)clickAddColor:(id)sender;
- (IBAction)clickPalette:(id)sender;
- (IBAction)clickPaintBucket:(id)sender;
- (IBAction)clickChat:(id)sender;

@property (retain, nonatomic) IBOutlet DrawSlider *widthSlider;
@property (retain, nonatomic) IBOutlet DrawSlider *alphaSlider;
@property (retain, nonatomic) IBOutlet UILabel *penWidth;
@property (retain, nonatomic) IBOutlet UILabel *colorAlpha;
@property (retain, nonatomic) IBOutlet UIButton *pen;
@property (retain, nonatomic) IBOutlet UIButton *chat;
@property (retain, nonatomic) IBOutlet UIButton *timeSet;
@property (retain, nonatomic) IBOutlet UIButton *redo;
@property (retain, nonatomic) IBOutlet UIButton *undo;


@property (retain, nonatomic) CMPopTipView *penPopTipView;
@property (retain, nonatomic) CMPopTipView *colorBoxPopTipView;
@property (retain, nonatomic) CMPopTipView *palettePopTipView;

@property (retain, nonatomic) NSTimer *timer;


@end

@implementation DrawToolPanel
@synthesize timer = _timer;


#define MAX_COLOR_NUMBER 8
#define VALUE(x) (ISIPAD ? x*2 : x)

#define SPACE_COLOR_LEFT (ISIPAD ? 40 : 8)
#define SPACE_COLOR_COLOR (ISIPAD ? 14 : ((ISIPHONE5) ? 7 :2))
#define SPACE_COLOR_UP (ISIPHONE5 ? 20 : VALUE(9))

#define ALPHA_FONT_SIZE VALUE(14.0)
#define TIMESET_FONT_SIZE VALUE(15.0)

#define LINE_MIN_WIDTH VALUE(1.0)
#define LINE_MAX_WIDTH VALUE(27.0)
#define LINE_DEFAULT_WIDTH VALUE(3.0)

#define COLOR_MIN_ALPHA 0.1
#define COLOR_MAX_ALPHA 1.0
#define COLOR_DEFAULT_ALPHA 1.0

#define POP_POINTER_SIZE VALUE(8.0)

#define ALPHA_LABEL_FRAME (ISIPAD ? CGRectMake(0, 0, 40*2, 20*2) : CGRectMake(0, 0, 40, 20))


#pragma mark - setter methods




- (void)updatePopTipView:(CMPopTipView *)popTipView
{
    [popTipView setBackgroundColor:[UIColor colorWithRed:168./255. green:168./255. blue:168./255. alpha:0.4]];
    [popTipView setPointerSize:POP_POINTER_SIZE];
    [self.palettePopTipView setDelegate:self];
}

- (void)updateSliders
{
    CGPoint center = self.widthSlider.center;
    [self.widthSlider removeFromSuperview];
    self.widthSlider = [[[DrawSlider alloc] init] autorelease];
    self.widthSlider.center = center;
    self.widthSlider.delegate = self;
    
    [self.widthSlider setMaxValue:LINE_MAX_WIDTH];
    [self.widthSlider setMinValue:LINE_MIN_WIDTH];
    [self.widthSlider setValue:LINE_DEFAULT_WIDTH];

    [self addSubview:self.widthSlider];
    
    center = self.alphaSlider.center;
    [self.alphaSlider removeFromSuperview];
    self.alphaSlider = [[[DrawSlider alloc] init] autorelease];
    self.alphaSlider.center = center;
    [self.alphaSlider setMaxValue:COLOR_MAX_ALPHA];
    [self.alphaSlider setMinValue:COLOR_MIN_ALPHA];
    [self.alphaSlider setValue:COLOR_DEFAULT_ALPHA];
    
    self.alphaSlider.delegate = self;
    [self addSubview:self.alphaSlider];

    [self.penWidth setText:NSLS(@"kPenWidth")];
    [self.colorAlpha setText:NSLS(@"kColorAlpha")];
    
    //TODO implement color alpha
    self.alphaSlider.hidden = YES;
    self.colorAlpha.hidden = YES;
}


- (void)updateView
{
    ColorPoint *firstPoint = nil;
    for (NSInteger i = 0; i < MAX_COLOR_NUMBER; ++ i) {
        ColorPoint *point = [ColorPoint pointWithColor:[DrawColor rankColor]];
        [self addSubview:point];
        CGRect frame = point.frame;
        CGFloat x = SPACE_COLOR_LEFT + i * (CGRectGetWidth(point.frame) + SPACE_COLOR_COLOR);
        
        frame.origin = CGPointMake(x, SPACE_COLOR_UP);
        point.frame = frame;
        point.delegate = self;
        if (i == 0) {
            firstPoint = point;
        }
    }    
    [firstPoint sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    [self.timeSet.titleLabel setFont:[UIFont fontWithName:@"DBLCDTempBlack" size:TIMESET_FONT_SIZE]];
    [self.colorBGImageView setImage:[[ShareImageManager defaultManager] drawColorBG]];

    //update width and alpha
    [self updateSliders];
}


+ (id)createViewWithdelegate:(id)delegate
{
    NSString *identifier = @"DrawToolPanel";
    if (ISIPHONE5) {
        identifier = @"DrawToolPanel_ip5";
    }
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

- (void)dismissPopTipViewsWithout:(CMPopTipView *)popView
{
    if (self.penPopTipView != popView) {
        [self.penPopTipView dismissAnimated:NO];
        self.penPopTipView = nil;
    }
    if (self.colorBoxPopTipView != popView) {
        [self.colorBoxPopTipView dismissAnimated:NO];
        self.colorBoxPopTipView = nil;
    }

    if (self.palettePopTipView != popView) {
        [self.palettePopTipView dismissAnimated:NO];
        self.palettePopTipView = nil;
    }
}

- (void)dismissAllPopTipViews
{
    [self dismissPopTipViewsWithout:nil];
}

- (void)disableAllTools
{
    for (UIControl *control in self.subviews) {
        [control setEnabled:NO];
    }
}

- (void)setPanelForOnline:(BOOL)isOnline
{
    self.redo.hidden = self.undo.hidden = isOnline;
    self.timeSet.hidden = self.chat.hidden = !isOnline;
}

#pragma mark - click actions
- (IBAction)clickUndo:(id)sender {
    [self dismissAllPopTipViews];
    if (self.delegate && [self.delegate respondsToSelector:@selector(drawToolPanel:didClickUndoButton:)]) {
        [self.delegate drawToolPanel:self didClickUndoButton:sender];
    }
}

- (IBAction)clickRedo:(id)sender {
    [self dismissAllPopTipViews];
    if (self.delegate && [self.delegate respondsToSelector:@selector(drawToolPanel:didClickRedoButton:)]) {
        [self.delegate drawToolPanel:self didClickRedoButton:sender];
    }
}

- (IBAction)clickChat:(id)sender {
    [self dismissAllPopTipViews];
    if (self.delegate && [self.delegate respondsToSelector:@selector(drawToolPanel:didClickChatButton:)]) {
        [self.delegate drawToolPanel:self didClickChatButton:sender];
    }    
}



- (IBAction)clickEraser:(id)sender {
    [self dismissAllPopTipViews];    
    if (self.delegate && [self.delegate respondsToSelector:@selector(drawToolPanel:didClickEraserButton:)]) {
        [self.delegate drawToolPanel:self didClickEraserButton:sender];
    }
}


- (IBAction)clickPaintBucket:(id)sender {
    [self dismissAllPopTipViews];    
    if (self.delegate && [self.delegate respondsToSelector:@selector(drawToolPanel:didClickPaintBucket:)]) {
        [self.delegate drawToolPanel:self didClickPaintBucket:sender];
    }
}


- (void)handlePopTipView:(CMPopTipView *)popView
             contentView:(UIView *(^)(void))contentView
                  atView:(UIView *)atView
                  setter:(SEL)setter
{
//    CMPopTipView *newView = popView;
    if (popView == nil) {
        UIView *customView = contentView();
        CMPopTipView *newView = [[[CMPopTipView alloc] initWithCustomView:customView] autorelease];
        [self performSelector:setter withObject: newView];
        newView.delegate = self;
        [newView presentPointingAtView:atView inView:self.superview animated:NO];
        [self updatePopTipView:newView];
        [self dismissPopTipViewsWithout:newView];
    }else{
        [popView dismissAnimated:NO];
        [self performSelector:setter withObject:nil];
        [self dismissPopTipViewsWithout:popView];
    }

}

- (IBAction)clickAddColor:(id)sender {
    //Pop up add color box
    [self handlePopTipView:_colorBoxPopTipView contentView:^UIView *{
        return [ColorBox createViewWithdelegate:self];
    } atView:sender setter:@selector(setColorBoxPopTipView:)];

}

- (IBAction)clickPalette:(id)sender {

    [self handlePopTipView:_palettePopTipView contentView:^UIView *{
        PPDebug(@"<block> [Palette createViewWithdelegate:self]");
        Palette *pallete = [Palette createViewWithdelegate:self];
        if (self.color) {
            pallete.currentColor = self.color;
        }
        return pallete;
    } atView:sender setter:@selector(setPalettePopTipView:)];
}

- (IBAction)clickPen:(id)sender {
    //pop up pen box.
    [self handlePopTipView:_penPopTipView contentView:^UIView *{
        PenBox *penBox = [PenBox createViewWithdelegate:self];
        penBox.delegate = self;
        return penBox;
    } atView:sender setter:@selector(setPenPopTipView:)];
}


- (void)handleSelectColorDelegateWithColor:(DrawColor *)color
{
    self.color = color;
    if (self.delegate && [self.delegate respondsToSelector:@selector(drawToolPanel:didSelectColor:)]) {
        [self.delegate drawToolPanel:self didSelectColor:color];
    }
    [self.alphaSlider setValue:1.0];
    //update show list;
}

#pragma mark - Color Point Delegate
- (void)didSelectColorPoint:(ColorPoint *)colorPoint
{
    for (ColorPoint *point in [self subviews]) {
        if ([point isKindOfClass:[ColorPoint class]] && colorPoint != point) {
            [point setSelected:NO];
        }
    }
    [colorPoint setSelected:YES];
    [self dismissAllPopTipViews];
    [self handleSelectColorDelegateWithColor:colorPoint.color];
}


#pragma mark - DrawSlider delegate


- (void)updateLabel:(UILabel *)label value:(CGFloat)value
{
    NSString *v = [NSString stringWithFormat:@"%.0f%%",value*100];
    [label setText:v];
}

- (void)drawSlider:(DrawSlider *)drawSlider
    didValueChange:(CGFloat)value
{
    if (self.widthSlider == drawSlider) {
        WidthView *widthView = (WidthView *)drawSlider.contentView;
        [widthView setWidth:value];
    }else if(self.alphaSlider == drawSlider){
        UILabel *label = (UILabel *)drawSlider.contentView;
        [self updateLabel:label value:value];
    }
}


- (void)drawSlider:(DrawSlider *)drawSlider didFinishChangeValue:(CGFloat)value
{
    [drawSlider dismissPopupView];
    if (drawSlider == self.widthSlider) {
        self.width = value;
        if (self.delegate && [self.delegate respondsToSelector:@selector(drawToolPanel:didSelectWidth:)]) {
            [self.delegate drawToolPanel:self didSelectWidth:value];
        }
    }else if(drawSlider == self.alphaSlider){
        self.alpha = value;
        if(self.delegate && [self.delegate respondsToSelector:@selector(drawToolPanel:didSelectAlpha:)])
        {
            [self.delegate drawToolPanel:self didSelectAlpha:value];
        }
    }
}

- (void)drawSlider:(DrawSlider *)drawSlider didStartToChangeValue:(CGFloat)value
{
    if (drawSlider == self.alphaSlider) {
        UILabel *label = [[[UILabel alloc] initWithFrame:ALPHA_LABEL_FRAME] autorelease];
        [label setTextAlignment:NSTextAlignmentCenter];
        [drawSlider popupWithContenView:label];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setFont:[UIFont boldSystemFontOfSize:ALPHA_FONT_SIZE]];
        [self updateLabel:label value:value];
        
    }else if(drawSlider == self.widthSlider){
        WidthView *width = [WidthView viewWithWidth:value];
        [drawSlider popupWithContenView:width];
        [width setSelected:YES];
    }
    [self dismissAllPopTipViews];
}

- (void)penBox:(PenBox *)penBox didSelectPen:(ItemType)penType penImage:(UIImage *)image
{
    [self.pen setImage:image forState:UIControlStateNormal];
    [self.pen setTag:penType];
    [self.penPopTipView dismissAnimated:NO];
    self.penPopTipView = nil;
    if (self.delegate && [self.delegate respondsToSelector:@selector(drawToolPanel:didSelectPen:)]) {
        [self.delegate drawToolPanel:self didSelectPen:penType];
    }
}

#pragma mark - CMPopTipView Delegate

- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
    if (popTipView == self.palettePopTipView) {
        self.palettePopTipView = nil;
    }else if(popTipView == self.penPopTipView){
        self.penPopTipView = nil;
    }else if(popTipView == self.colorBoxPopTipView){
        self.colorBoxPopTipView = nil;
    }
}
- (void)popTipViewWasDismissedByCallingDismissAnimatedMethod:(CMPopTipView *)popTipView
{
    if (popTipView == self.palettePopTipView) {
        self.palettePopTipView = nil;
    }else if(popTipView == self.penPopTipView){
        self.penPopTipView = nil;
    }else if(popTipView == self.colorBoxPopTipView){
        self.colorBoxPopTipView = nil;
    }
}


#pragma mark - Color Box delegate

- (void)dismissColorBoxPopTipView
{
    [self.colorBoxPopTipView dismissAnimated:NO];
    self.colorBoxPopTipView = nil;
}

- (void)colorBox:(ColorBox *)colorBox didSelectColor:(DrawColor *)color
{
    [self handleSelectColorDelegateWithColor:color];
    [self dismissColorBoxPopTipView];
}
- (void)didClickCloseButtonOnColorBox:(ColorBox *)colorBox
{
    [self dismissColorBoxPopTipView];
}
- (void)didClickMoreButtonOnColorBox:(ColorBox *)colorBox
{
    ColorShopView *colorShop = [ColorShopView colorShopViewWithFrame:self.superview.bounds];
    colorShop.delegate  = self;
    [colorShop showInView:self.superview animated:YES];
}

#pragma mark - ColorShopView Delegate

- (void)didPickedColorView:(ColorView *)colorView{
    [self handleSelectColorDelegateWithColor:colorView.drawColor];
    [self dismissColorBoxPopTipView];
}

- (void)palette:(Palette *)palette didPickColor:(DrawColor *)color
{
    [self handleSelectColorDelegateWithColor:color];    
}

- (void)dealloc {
    PPRelease(_colorBoxPopTipView);
    PPRelease(_penPopTipView);
    PPRelease(_palettePopTipView);
    
    PPRelease(_widthSlider);
    PPRelease(_alphaSlider);
    PPRelease(_penWidth);
    PPRelease(_colorAlpha);
    PPRelease(_timer);
    
    [_pen release];
    [_chat release];
    [_timeSet release];
    [_redo release];
    [_undo release];
    [_colorBGImageView release];
    [super dealloc];
}

#pragma mark - timer methods

- (void)handleTimer:(NSTimer *)timer
{
    PPDebug(@"panel <handleTimer>: retain time = %d",_retainTime);
    if (_retainTime >= 0) {
        NSString *title = [NSString stringWithFormat:@"%d", _retainTime];
        [self.timeSet setTitle:title forState:UIControlStateNormal];
        _retainTime --;
    }
    if (_retainTime < 0) {
        [self stopTimer];
        //enable all the tools
        [self dismissAllPopTipViews];
        [self disableAllTools];
        if (_delegate && [_delegate respondsToSelector:@selector(drawToolPanelDidTimeout:)]) {
            [_delegate drawToolPanelDidTimeout:self];
        }
    }
}

- (void)startTimer
{
    [self stopTimer];
    _retainTime = self.timerDuration;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
    [self handleTimer:self.timer];
}
- (void)stopTimer
{
    PPDebug(@"panel <stopTimer>: retain time = %d",_retainTime);
    if ([self.timer isValid]) {
        [self.timer invalidate];
    }
    self.timer = nil;
}

@end

