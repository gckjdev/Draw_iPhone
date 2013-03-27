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
#import "ItemType.h"
#import "DrawColorManager.h"
#import "AccountService.h"
#import "ConfigManager.h"
#import "AnalyticsManager.h"
#import "WidthView.h"
#import "ShapeBox.h"
#import "DrawBgBox.h"
#import "DrawSlider.h"
#import "ColorPoint.h"
#import "WidthBox.h"
#import "Palette.h"
#import "ColorShopView.h"
#import "ColorBox.h"
#import "Draw.pb.h"
#import "DrawBgManager.h"
#import "UserGameItemManager.h"
#import "GameItemManager.h"
#import "UIButton+WebCache.h"

#import "AddColorCommand.h"
#import "AlphaSliderCommand.h"
#import "CanvasSizeCommand.h"
#import "ChatCommand.h"
#import "DrawBgCommand.h"
#import "DrawToCommand.h"
#import "EditDescCommand.h"
#import "EraserCommand.h"
#import "HelpCommand.h"
#import "PaintBucketCommand.h"
#import "PaletteCommand.h"
#import "SelectPenCommand.h"
#import "ShapeCommand.h"
#import "WidthPickCommand.h"
#import "WidthSliderCommand.h"
#import "StrawCommand.h"
#import "GridCommand.h"

#define AnalyticsReport(x) [[AnalyticsManager sharedAnalyticsManager] reportDrawClick:x]

@interface DrawToolPanel ()
{
    NSTimer *timer;
    NSInteger _retainTime;
    DrawColorManager *drawColorManager;
    ToolCommandManager *toolCmdManager;
}

#pragma mark - click actions

- (IBAction)clickTool:(id)sender;
- (IBAction)clickUndo:(id)sender;
- (IBAction)clickRedo:(id)sender;
- (IBAction)clickPalette:(id)sender;
- (IBAction)clickStraw:(id)sender;
- (IBAction)clickPen:(id)sender;
- (IBAction)clickEraser:(id)sender;
- (IBAction)clickAddColor:(id)sender;
- (IBAction)clickPaintBucket:(id)sender;
- (IBAction)clickChat:(id)sender;
- (IBAction)clickWidthBox:(UIButton *)widthBox;
- (IBAction)clickShape:(id)sender;
- (IBAction)clickDrawBg:(id)sender;


- (void)selectPen;
- (void)selectEraser;

@property (retain, nonatomic) IBOutlet UIImageView *colorBGImageView;
@property (retain, nonatomic) IBOutlet DrawSlider *widthSlider;
@property (retain, nonatomic) IBOutlet DrawSlider *alphaSlider;
@property (retain, nonatomic) IBOutlet UIButton *penWidth;
@property (retain, nonatomic) IBOutlet UIButton *colorAlpha;
@property (retain, nonatomic) IBOutlet UIButton *pen;
@property (retain, nonatomic) IBOutlet UIButton *chat;
@property (retain, nonatomic) IBOutlet UIButton *timeSet;
@property (retain, nonatomic) IBOutlet UIButton *redo;
@property (retain, nonatomic) IBOutlet UIButton *undo;
@property (retain, nonatomic) IBOutlet UIButton *palette;
@property (retain, nonatomic) IBOutlet UIButton *eraser;
@property (retain, nonatomic) IBOutlet UIButton *straw;
//@property (retain, nonatomic) WidthView *widthView;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIButton *addColor;
@property (retain, nonatomic) IBOutlet UIButton *switchPage;

@property (retain, nonatomic) CMPopTipView *penPopTipView;
@property (retain, nonatomic) CMPopTipView *colorBoxPopTipView;
@property (retain, nonatomic) CMPopTipView *palettePopTipView;
@property (retain, nonatomic) CMPopTipView *widthBoxPopTipView;
@property (retain, nonatomic) CMPopTipView *shapeBoxPopTipView;
@property (retain, nonatomic) CMPopTipView *drawBgBoxPopTipView;
@property (retain, nonatomic) IBOutlet UIButton *paintBucket;

@property (retain, nonatomic) IBOutlet UIButton *shape;
@property (retain, nonatomic) IBOutlet UIButton *canvasSize;
@property (retain, nonatomic) IBOutlet UIButton *grid;
@property (retain, nonatomic) IBOutlet UIButton *opusDesc;
@property (retain, nonatomic) IBOutlet UIButton *drawToUser;
@property (retain, nonatomic) IBOutlet UIButton *help;

@property (retain, nonatomic) IBOutlet UIButton *drawBg;
@property (retain, nonatomic) NSTimer *timer;

- (IBAction)switchToolPage:(UIButton *)sender;

@end

@implementation DrawToolPanel
@synthesize timer = _timer;


#define MAX_COLOR_NUMBER 7
#define VALUE(x) (ISIPAD ? x*2 : x)

#define SPACE_COLOR_LEFT (ISIPAD ? 40 : 8)
#define SPACE_COLOR_COLOR (ISIPAD ? 14 : ((ISIPHONE5) ? 7 :2))
#define SPACE_COLOR_UP (ISIPHONE5 ? 20 : VALUE(13))

#define ALPHA_FONT_SIZE VALUE(14.0)
#define TIMESET_FONT_SIZE VALUE(15.0)

#define LINE_MIN_WIDTH (1.0)
#define LINE_MAX_WIDTH ([ConfigManager maxPenWidth])
#define LINE_DEFAULT_WIDTH ([ConfigManager defaultPenWidth])

#define COLOR_MIN_ALPHA ([ConfigManager minAlpha])
#define COLOR_MAX_ALPHA 1.0
#define COLOR_DEFAULT_ALPHA 1.0

#define POP_POINTER_SIZE VALUE(8.0)

#define ALPHA_LABEL_FRAME (ISIPAD ? CGRectMake(0, 0, 40*2, 20*2) : CGRectMake(0, 0, 40, 20))


#pragma mark - setter methods


- (void)selectPen
{
    [self.pen setSelected:YES];
    [self.eraser setSelected:NO];
    [self.straw setSelected:NO];
}
- (void)selectEraser
{
    [self.pen setSelected:NO];
    [self.straw setSelected:NO];
    [self.eraser setSelected:YES];
}

- (void)selectStraw
{
    [self.pen setSelected:NO];
    [self.eraser setSelected:NO];
    [self.straw setSelected:YES];
}


- (void)updatePopTipView:(CMPopTipView *)popTipView
{
    [popTipView setBackgroundColor:[UIColor colorWithRed:255./255. green:255./255. blue:255./255. alpha:0.95]];
    [popTipView setPointerSize:POP_POINTER_SIZE];
    [popTipView setDelegate:self];
}
/*
- (void)updateScrollView
{
    CGRect frame = self.scrollView.frame;
    PPDebug(@"ScrollView frame = %@", NSStringFromCGRect(frame));
    CGSize size = frame.size;
    _scrollView.contentSize = CGSizeMake(size.width * 2, size.height);
    PPDebug(@"Content Size = %@",NSStringFromCGSize(_scrollView.contentSize));
    
}
*/
- (void)updateSliders
{
//    CGPoint center = self.widthSlider.center;
    CGRect frame = self.widthSlider.frame;
    [self.widthSlider removeFromSuperview];
    self.widthSlider = [DrawSlider sliderWithMaxValue:LINE_MAX_WIDTH
                                             minValue:LINE_MIN_WIDTH
                                         defaultValue:LINE_DEFAULT_WIDTH
                                             delegate:self];
    self.widthSlider.frame = frame;    
    [self.penWidth setTitle:NSLS(@"kPenWidth") forState:UIControlStateNormal];
    [self.scrollView addSubview:self.widthSlider];

    frame = self.alphaSlider.frame;
    [self.alphaSlider removeFromSuperview];
    self.alphaSlider = [DrawSlider sliderWithMaxValue:COLOR_MAX_ALPHA
                                             minValue:COLOR_MIN_ALPHA
                                         defaultValue:COLOR_DEFAULT_ALPHA
                                             delegate:self];
    
    self.alphaSlider.frame = frame;
    [self.scrollView addSubview:self.alphaSlider];
    [self.colorAlpha setTitle:NSLS(@"kColorAlpha") forState:UIControlStateNormal];
}

- (void)updateRecentColorViewWithColor:(DrawColor *)color updateModel:(BOOL)updateModel
{
    if (updateModel) {
        [[DrawColorManager sharedDrawColorManager] updateColorListWithColor:color];
    }

    
    for (ColorPoint *p in self.subviews) {
        if ([p isKindOfClass:[ColorPoint class]]) {
            [p removeFromSuperview];
        }
    }
    drawColorManager = [DrawColorManager sharedDrawColorManager];
    NSInteger i = 0;
    ColorPoint *selectedPoint = nil;
    
    for (DrawColor *c in [drawColorManager recentColorList]) {
        ColorPoint *point = [ColorPoint pointWithColor:c];
        CGRect frame = point.frame;
        CGFloat x = SPACE_COLOR_LEFT + i * (CGRectGetWidth(point.frame) + SPACE_COLOR_COLOR);
        frame.origin = CGPointMake(x, SPACE_COLOR_UP);
        point.frame = frame;
        point.delegate = self;
        [self addSubview:point];
        [point setSelected:NO];
        if (i == 0 ||  [color isEqual:c]) {
            selectedPoint = point;
        }
        i ++;
        if (i >= MAX_COLOR_NUMBER) {
            break;
        }
    }
    [selectedPoint setSelected:YES];
}
- (void)updateRecentColorViews
{
    [self updateRecentColorViewWithColor:[DrawColor blackColor] updateModel:NO];
}

- (void)updateNeedBuyToolViews
{
    if (![[UserGameItemManager defaultManager] hasItem:PaletteItem]) {

        [self.palette setSelected:YES];
    }else{
        [self.palette setSelected:NO];
    }
    if (![[UserGameItemManager defaultManager] hasItem:ColorAlphaItem]) {

        [self.alphaSlider setSelected:YES];
    }else{
        [self.alphaSlider setSelected:NO];
    }
    [self.straw setSelected:NO];
}

- (void)convertViewToSuperView:(UIView *)view
{
    CGPoint center = [self convertPoint:view.center toView:self];
    view.center = center;
    [self insertSubview:view belowSubview:self.scrollView];
}
- (void)updateColorTools
{
//  because of the scrollview needs to clip to bounds, so the pop tip view won't show outside the views. So I make the scrollview very high, but do this make the buttons adding on the subview can not receive click event. So add the buttons to the superview. But it is to boring to convert the views on the xib, so I code this code below. By Gamy 2013.3.23
    

//    [self addSubview:self.palette];
//    [self convertViewToSuperView:self.palette];
//    [self convertViewToSuperView:self.straw];
//    [self convertViewToSuperView:self.addColor];
    
}

- (void)registerToolCommands
{
    toolCmdManager = [[ToolCommandManager alloc] init];
    ToolCommand *command = [[[AddColorCommand alloc] initWithControl:self.addColor itemType:ItemTypeNo] autorelease];
    [toolCmdManager registerCommand:command];
    
    command = [[[PaletteCommand alloc] initWithControl:self.palette itemType:PaletteItem] autorelease];
    [toolCmdManager registerCommand:command];
    
    command = [[[SelectPenCommand alloc] initWithControl:self.pen itemType:Pencil] autorelease];
    [toolCmdManager registerCommand:command];

    command = [[[EraserCommand alloc] initWithControl:self.eraser itemType:Eraser] autorelease];
    [toolCmdManager registerCommand:command];

    command = [[[PaintBucketCommand alloc] initWithControl:self.paintBucket itemType:ItemTypeNo] autorelease];
    [toolCmdManager registerCommand:command];
    
    command = [[[ShapeCommand alloc] initWithControl:self.shape itemType:Eraser] autorelease];
    [toolCmdManager registerCommand:command];
    
    command = [[[StrawCommand alloc] initWithControl:self.straw itemType:ColorStrawItem] autorelease];
    [toolCmdManager registerCommand:command];
    
    
    command = [[[WidthPickCommand alloc] initWithControl:self.penWidth itemType:ItemTypeNo] autorelease];
    [toolCmdManager registerCommand:command];
    
    
    command = [[[WidthSliderCommand alloc] initWithControl:self.widthSlider itemType:ItemTypeNo] autorelease];
    [toolCmdManager registerCommand:command];

    command = [[[AlphaSliderCommand alloc] initWithControl:self.widthSlider itemType:ColorAlphaItem] autorelease];
    [toolCmdManager registerCommand:command];

    //
    command = [[[DrawBgCommand alloc] initWithControl:self.drawBg itemType:ItemTypeNo] autorelease];
    [toolCmdManager registerCommand:command];

    command = [[[CanvasSizeCommand alloc] initWithControl:self.canvasSize itemType:ItemTypeNo] autorelease];
    [toolCmdManager registerCommand:command];

    command = [[[GridCommand alloc] initWithControl:self.grid itemType:ColorAlphaItem] autorelease];
    [toolCmdManager registerCommand:command];

    command = [[[EditDescCommand alloc] initWithControl:self.opusDesc itemType:ItemTypeNo] autorelease];
    [toolCmdManager registerCommand:command];

    command = [[[DrawToCommand alloc] initWithControl:self.drawToUser itemType:ItemTypeNo] autorelease];
    [toolCmdManager registerCommand:command];

    command = [[[HelpCommand alloc] initWithControl:self.help itemType:ItemTypeNo] autorelease];
    [toolCmdManager registerCommand:command];

    [toolCmdManager updateHandler:self.toolHandler];
    [toolCmdManager updatePanel:self];

}

- (void)updateView
{
    [self registerToolCommands];
    

    
    [self updateRecentColorViews];

    [self.timeSet.titleLabel setFont:[UIFont fontWithName:@"DBLCDTempBlack" size:TIMESET_FONT_SIZE]];
    [self.colorBGImageView setImage:[[ShareImageManager defaultManager] drawColorBG]];

//    [self updateScrollView];
    //update width and alpha
    [self updateSliders];
    [self setWidth:LINE_DEFAULT_WIDTH];
    [self setPenType:Pencil];
    [self updateNeedBuyToolViews];
}

- (void)userItem:(ItemType)type
{
    switch (type) {
        case ColorStrawItem:
            [self clickStraw:self.straw];
            break;
        case PaletteItem:
            [self clickPalette:self.palette];
        default:
            break;
    }
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

+ (id)createViewWithdToolHandler:(ToolHandler *)handler
{
    DrawToolPanel *panel = nil;
    if (ISIPHONE5) {
        panel = [UIView createViewWithXibIdentifier:@"DrawToolPanel_ip5"];
    }else{
        panel = [UIView createViewWithXibIdentifier:@"DrawToolPanel"];
    }
    panel.toolHandler = handler;
    handler.drawToolPanel = panel;
    [panel updateView];
    return panel;
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
    if (self.widthBoxPopTipView != popView) {
        [self.widthBoxPopTipView dismissAnimated:NO];
        self.widthBoxPopTipView = nil;
    }
    if(popView != self.shapeBoxPopTipView){
        [self.shapeBoxPopTipView dismissAnimated:NO];
        self.shapeBoxPopTipView = nil;
    }
    if (popView != self.drawBgBoxPopTipView) {
        [self.drawBgBoxPopTipView dismissAnimated:NO];
        self.drawBgBoxPopTipView = nil;
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
//    self.redo.hidden = self.undo.hidden = isOnline;
    self.timeSet.hidden = self.chat.hidden = !isOnline;
    
    CGRect frame = self.scrollView.frame;
    PPDebug(@"ScrollView frame = %@", NSStringFromCGRect(frame));
    CGSize size = frame.size;
    size.width = isOnline ? size.width : size.width * 2;
    _scrollView.contentSize = size;
    PPDebug(@"Content Size = %@",NSStringFromCGSize(_scrollView.contentSize));
}

- (void)setColor:(DrawColor *)color
{
    if (_color != color) {
        PPRelease(_color);
        _color = [color retain];
    }
}

- (void)setPenType:(ItemType)penType
{
    _penType = penType;
    self.pen.tag = penType;
    PBGameItem *item = [[GameItemManager defaultManager] itemWithItemId:penType];
    [self.pen setImageWithURL:[NSURL URLWithString:item.image]];
    [self selectPen];
}

#pragma mark - click actions

- (IBAction)clickWidthBox:(UIButton *)widthBox
{
    [self handlePopTipView:_widthBoxPopTipView contentView:^UIView *{
        WidthBox *box = [WidthBox widthBox];
        [box setWidthSelected:self.width];
        box.delegate = self;
        return box;
    } atView:widthBox setter:@selector(setWidthBoxPopTipView:)];
    AnalyticsReport(DRAW_CLICK_WIDTH_BOX);
}

- (IBAction)clickShape:(id)sender {
    [self handlePopTipView:_shapeBoxPopTipView contentView:^UIView *{
        ShapeBox *shapeBox = [ShapeBox shapeBoxWithDelegate:self];
        [shapeBox setShapeType:self.shapeType];
        return shapeBox;
    } atView:sender setter:@selector(setShapeBoxPopTipView:)];
    AnalyticsReport(DRAW_CLICK_SHAPE_BOX);
}

- (IBAction)clickDrawBg:(id)sender {
    [self handlePopTipView:_drawBgBoxPopTipView contentView:^UIView *{
        DrawBgBox *drawBgBox = [DrawBgBox drawBgBoxWithDelegate:self];
        [drawBgBox updateViewsWithSelectedBgId:self.drawBgId];
        return drawBgBox;
    } atView:sender setter:@selector(setDrawBgBoxPopTipView:)];
    AnalyticsReport(DRAW_CLICK_DRAWBG_BOX);
}


- (IBAction)clickUndo:(id)sender {
    [self dismissAllPopTipViews];
    if (self.delegate && [self.delegate respondsToSelector:@selector(drawToolPanel:didClickUndoButton:)]) {
        [self.delegate drawToolPanel:self didClickUndoButton:sender];
    }
    AnalyticsReport(DRAW_CLICK_UNDO);

}

- (IBAction)clickRedo:(id)sender {
    [self dismissAllPopTipViews];
    if (self.delegate && [self.delegate respondsToSelector:@selector(drawToolPanel:didClickRedoButton:)]) {
        [self.delegate drawToolPanel:self didClickRedoButton:sender];
    }
    AnalyticsReport(DRAW_CLICK_REDO);
}

- (IBAction)clickChat:(id)sender {
    [self dismissAllPopTipViews];
    if (self.delegate && [self.delegate respondsToSelector:@selector(drawToolPanel:didClickChatButton:)]) {
        [self.delegate drawToolPanel:self didClickChatButton:sender];
    }
    AnalyticsReport(DRAW_CLICK_CHAT);
}

- (IBAction)clickStraw:(id)sender {
    if (![[UserGameItemManager defaultManager] hasItem:ColorStrawItem]) {
        if (_delegate && [_delegate respondsToSelector:@selector(drawToolPanel:startToBuyItem:)]) {
            [_delegate drawToolPanel:self startToBuyItem:ColorStrawItem];
        }
        return;
    }
    [self selectStraw];
    [self dismissAllPopTipViews];
    if (self.delegate && [self.delegate respondsToSelector:@selector(drawToolPanel:didClickStrawButton:)]) {
        [self.delegate drawToolPanel:self didClickStrawButton:sender];
    }
    AnalyticsReport(DRAW_CLICK_STRAW);
}



- (IBAction)clickEraser:(id)sender {
    [self clickTool:sender];
    return;

    
    [self selectEraser];
    [self dismissAllPopTipViews];
        if (self.delegate && [self.delegate respondsToSelector:@selector(drawToolPanel:didClickEraserButton:)]) {
        [self.delegate drawToolPanel:self didClickEraserButton:sender];
    }
    AnalyticsReport(DRAW_CLICK_ERASER);
}


- (IBAction)clickPaintBucket:(id)sender {
    [self clickTool:sender];
    return;

    [self selectPen];
    [self dismissAllPopTipViews];    
    if (self.delegate && [self.delegate respondsToSelector:@selector(drawToolPanel:didClickPaintBucket:)]) {
        [self.delegate drawToolPanel:self didClickPaintBucket:sender];
    }
    AnalyticsReport(DRAW_CLICK_PAINT_BUCKET);
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

- (IBAction)clickTool:(id)sender
{
    [toolCmdManager hideAllPopTipViewsExcept:[toolCmdManager commandForControl:sender]];
    [[toolCmdManager commandForControl:sender] execute];    
}

- (IBAction)clickAddColor:(id)sender {
    [self clickTool:sender];
    //Pop up add color box
//    [self handlePopTipView:_colorBoxPopTipView contentView:^UIView *{
//        return [ColorBox createViewWithdelegate:self];
//    } atView:sender setter:@selector(setColorBoxPopTipView:)];
//        AnalyticsReport(DRAW_CLICK_COLOR_BOX);
}



- (IBAction)clickPalette:(id)sender {

    [self clickTool:sender];
    return;
    
    [toolCmdManager hideAllPopTipViewsExcept:[toolCmdManager commandForControl:sender]];
    [[toolCmdManager commandForControl:sender] execute];
    return;
    
    if (self.palette.selected) {
        if (_delegate && [_delegate respondsToSelector:@selector(drawToolPanel:startToBuyItem:)]) {
            [_delegate drawToolPanel:self startToBuyItem:PaletteItem];
        }
        return;
    }
    
    AnalyticsReport(DRAW_CLICK_PALETTE);
    
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
    [self clickTool:sender];
    return;

    AnalyticsReport(DRAW_CLICK_PEN);
    //pop up pen box.
    [self handlePopTipView:_penPopTipView contentView:^UIView *{
        PenBox *penBox = [PenBox createViewWithdelegate:self];
        penBox.delegate = self;
        return penBox;
    } atView:sender setter:@selector(setPenPopTipView:)];
}


- (void)handleSelectColorDelegateWithColor:(DrawColor *)color
                         updateRecentColor:(BOOL)updateRecentColor
{
    [self selectPen];
//    if (self.delegate && [self.delegate respondsToSelector:@selector(drawToolPanel:didSelectPen:bought:)]) {
//        [self.delegate drawToolPanel:self didSelectPen:self.pen.tag bought:YES];
//    }

    self.color = color;
    if (self.delegate && [self.delegate respondsToSelector:@selector(drawToolPanel:didSelectColor:)]) {
        [self.delegate drawToolPanel:self didSelectColor:color];
    }

    [self updateRecentColorViewWithColor:color updateModel:updateRecentColor];

//    [self.alphaSlider setValue:1.0];
    //update show list;
}

#pragma mark - Color Point Delegate
- (void)didSelectColorPoint:(ColorPoint *)colorPoint
{
//    for (ColorPoint *point in [self subviews]) {
//        if ([point isKindOfClass:[ColorPoint class]] && colorPoint != point) {
//            [point setSelected:NO];
//        }
//    }
    [colorPoint setSelected:YES];
    [self updateRecentColorViewWithColor:colorPoint.color updateModel:NO];
    [self.toolHandler changePenColor:colorPoint.color];
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
        if ([self.alphaSlider isSelected]) {
            return;
        }

        UILabel *label = (UILabel *)drawSlider.contentView;
        [self updateLabel:label value:value];
    }
}


- (void)drawSlider:(DrawSlider *)drawSlider didFinishChangeValue:(CGFloat)value
{
    [self.scrollView setClipsToBounds:YES];
    [drawSlider dismissPopupView];
    if (drawSlider == self.widthSlider) {
        NSInteger intValue = value;
        self.width = intValue;
        if (self.delegate && [self.delegate respondsToSelector:@selector(drawToolPanel:didSelectWidth:)]) {
            [self.delegate drawToolPanel:self didSelectWidth:intValue];
        }
    }else if(drawSlider == self.alphaSlider){
        if ([self.alphaSlider isSelected]) {
            return;
        }

        self.alpha = value;
        if(self.delegate && [self.delegate respondsToSelector:@selector(drawToolPanel:didSelectAlpha:)])
        {
            [self.delegate drawToolPanel:self didSelectAlpha:value];
        }
    }
}

- (void)drawSlider:(DrawSlider *)drawSlider didStartToChangeValue:(CGFloat)value
{
    [self.scrollView setClipsToBounds:NO];
    
    [self.straw setSelected:NO];
    [self dismissAllPopTipViews];
    
    if (drawSlider == self.alphaSlider) {
        if ([self.alphaSlider isSelected]) {
            if (_delegate && [_delegate respondsToSelector:@selector(drawToolPanel:startToBuyItem:)]) {
                [_delegate drawToolPanel:self startToBuyItem:ColorAlphaItem];
            }
            return;
        }
        AnalyticsReport(DRAW_CLICK_ALPHA);
        UILabel *label = [[[UILabel alloc] initWithFrame:ALPHA_LABEL_FRAME] autorelease];
        [label setTextAlignment:NSTextAlignmentCenter];
        [drawSlider popupWithContenView:label];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setFont:[UIFont boldSystemFontOfSize:ALPHA_FONT_SIZE]];
        UIColor *textColor = [UIColor colorWithRed:23./255. green:21./255. blue:20./255. alpha:1];
        [label setTextColor:textColor];
        [self updateLabel:label value:value];
        
    }else if(drawSlider == self.widthSlider){
        AnalyticsReport(DRAW_CLICK_WIDTH);
        WidthView *width = [WidthView viewWithWidth:value];
        [drawSlider popupWithContenView:width];
        [width setSelected:YES];
    }
}

- (void)penBox:(PenBox *)penBox didSelectPen:(ItemType)penType penImage:(UIImage *)image
{
    [self.penPopTipView dismissAnimated:NO];
    self.penPopTipView = nil;
    BOOL hasBought = penType == Pencil || [[UserGameItemManager defaultManager] hasItem:penType] ;

    if (hasBought) {
        [self setPenType:penType];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(drawToolPanel:didSelectPen:bought:)]) {
        [self.delegate drawToolPanel:self didSelectPen:penType bought:hasBought];
    }
}

#pragma mark - CMPopTipView Delegate

- (void)finishDismissPopTipView:(CMPopTipView *)popTipView
{
    if (popTipView == self.palettePopTipView) {
        self.palettePopTipView = nil;
    }else if(popTipView == self.penPopTipView){
        self.penPopTipView = nil;
    }else if(popTipView == self.colorBoxPopTipView){
        self.colorBoxPopTipView = nil;
    }else if(popTipView == self.widthBoxPopTipView){
        self.widthBoxPopTipView = nil;
    }else if(popTipView == self.shapeBoxPopTipView){
        self.shapeBoxPopTipView = nil;
    }else if(popTipView == self.drawBgBoxPopTipView){
        self.drawBgBoxPopTipView = nil;
    }
}

- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
    [self finishDismissPopTipView:popTipView];
}
- (void)popTipViewWasDismissedByCallingDismissAnimatedMethod:(CMPopTipView *)popTipView
{
    [self finishDismissPopTipView:popTipView];
}


#pragma mark - Color Box delegate
- (void)widthBox:(WidthBox *)widthBox didSelectWidth:(CGFloat)width
{
    [self dismissAllPopTipViews];
    [self.widthSlider setValue:width];
    [self drawSlider:self.widthSlider didFinishChangeValue:width];
}

#pragma mark ShapeBox Delegate

- (void)dismissShapeBox:(ShapeBox *)shapeBox
{
    [self dismissAllPopTipViews];
}

- (void)shapeBox:(ShapeBox *)shapeBox didSelectShapeType:(ShapeType)type
{
    self.shapeType = type;
    if (self.delegate && [self.delegate respondsToSelector:@selector(drawToolPanel:didSelectShapeType:)]) {
        [self.delegate drawToolPanel:self didSelectShapeType:type];
    }
}

#pragma mark -- Draw BG Box delegate
- (void)drawBgBox:(DrawBgBox *)drawBgBox didSelectedDrawBg:(PBDrawBg *)drawBg
{
    self.drawBgId = drawBg.bgId;
    PPDebug(@"<didSelectedDrawBg>:bg id = %@",self.drawBgId);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(drawToolPanel:didSelectDrawBg:)]) {
        [self.delegate drawToolPanel:self didSelectDrawBg:drawBg];
    }
    [self performSelector:@selector(dismissAllPopTipViews)];

}

#pragma mark - Color Box delegate

- (void)dismissColorBoxPopTipView
{
    [self.colorBoxPopTipView dismissAnimated:NO];
    self.colorBoxPopTipView = nil;
}

- (void)colorBox:(ColorBox *)colorBox didSelectColor:(DrawColor *)color
{
    [self handleSelectColorDelegateWithColor:color updateRecentColor:YES];
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

#pragma mark - DrawViewStrawDelegate
- (void)didStrawGetColor:(DrawColor *)color
{
    DrawColor *c = [DrawColor colorWithRed:color.red green:color.green blue:color.blue alpha:1];
    PPDebug(@"<didStrawGetColor> color = %@",[c description]);
    [self handleSelectColorDelegateWithColor:c updateRecentColor:YES];
    [self.alphaSlider setValue:COLOR_MAX_ALPHA];
    [self drawSlider:self.alphaSlider didFinishChangeValue:COLOR_MAX_ALPHA];
}

#pragma mark - ColorShopView Delegate

- (void)didPickedColorView:(ColorView *)colorView{
    [self handleSelectColorDelegateWithColor:colorView.drawColor updateRecentColor:YES];
    [self dismissColorBoxPopTipView];
    [self selectPen];
}

- (void)didBuyColorList:(NSArray *)colorList groupId:(NSInteger)groupId
{
    [self dismissColorBoxPopTipView];
    [self selectPen];
}

- (void)palette:(Palette *)palette didPickColor:(DrawColor *)color
{
    [self handleSelectColorDelegateWithColor:color updateRecentColor:NO];
}

- (void)dealloc {
    
    PPDebug(@"%@ dealloc",self);
    self.delegate = nil;
    [drawColorManager syncRecentList];
    PPRelease(_toolHandler);    
    PPRelease(_colorBoxPopTipView);
    PPRelease(_penPopTipView);
    PPRelease(_palettePopTipView);
    PPRelease(_widthBoxPopTipView);
    PPRelease(_shapeBoxPopTipView);
    PPRelease(_drawBgBoxPopTipView);
    PPRelease(_drawBgId);
    PPRelease(_widthSlider);
    PPRelease(_alphaSlider);
    PPRelease(_penWidth);
    PPRelease(_colorAlpha);
    PPRelease(_timer);
    
    PPRelease(_pen);
    PPRelease(_chat);
    PPRelease(_timeSet);
    PPRelease(_redo);
    PPRelease(_undo);
    PPRelease(_colorBGImageView);
    PPRelease(_palette);

    PPRelease(_switchPage);
    
    [_eraser release];
    [_straw release];
    [_scrollView release];
    [_addColor release];

    [_shape release];
    [_paintBucket release];
    [_drawBg release];
    [_canvasSize release];
    [_grid release];
    [_opusDesc release];
    [_drawToUser release];
    [_help release];
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

//0 or 1
- (void)scrollToPage:(NSUInteger)page
{
    CGRect rect = self.scrollView.bounds;
    rect.origin.x = page * CGRectGetWidth(rect);
    [self.scrollView scrollRectToVisible:rect animated:YES];
}

- (IBAction)switchToolPage:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    NSUInteger page = sender.isSelected;
    [self scrollToPage:page];
    
    [UIView animateWithDuration:0.15 animations:^{
        CGFloat angle = sender.isSelected ? M_PI : -M_PI;
        [sender setTransform:CGAffineTransformRotate(sender.transform, angle)];
    }];
    
}
@end

