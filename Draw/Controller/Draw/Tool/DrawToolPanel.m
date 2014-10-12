//
//  DrawToolPanel.m
//  Draw
//
//  Created by gamy on 12-12-24.
//
//

#import "DrawToolPanel.h"
#import "DrawColor.h"
#import "ShareImageManager.h"
#import "ItemType.h"
#import "DrawColorManager.h"
#import "AccountService.h"
#import "PPConfigManager.h"
#import "DrawSlider.h"
#import "ColorPoint.h"
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
#import "RedoCommand.h"
#import "UndoCommand.h"
#import "ShadowCommand.h"
#import "GradientCommand.h"
#import "SelectorCommand.h"
#import "TextCommand.h"
#import "FXCommand.h"

#import "WidthView.h"
#import "UIImageUtil.h"
#import "UIImageView+WebCache.h"
#import "DrawInfo.h"
#import "Item.h"
#import "ImageShapeManager.h"
#import "UIBezierPath+Ext.h"
#import "NotificationCenterManager.h"


#define AnalyticsReport(x) [[AnalyticsManager sharedAnalyticsManager] reportDrawClick:x]

@interface DrawToolPanel ()
{
    NSTimer *timer;
    NSInteger _retainTime;
    DrawColorManager *drawColorManager;
    ToolCommandManager *toolCmdManager;
    NSUInteger _commandVersion;
    NSMutableDictionary *buttonDict;
}

#pragma mark - click actions




@property (retain, nonatomic) IBOutlet UIImageView *colorBGImageView;
@property (retain, nonatomic) IBOutlet DrawSlider *widthSlider;
@property (retain, nonatomic) IBOutlet DrawSlider *alphaSlider;

@property (retain, nonatomic) IBOutlet UIButton *penWidth;
@property (retain, nonatomic) IBOutlet UIButton *colorAlpha;


@property (retain, nonatomic) IBOutlet UIButton *chat;
@property (retain, nonatomic) IBOutlet UIButton *timeSet;

@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIButton *addColor;
@property (retain, nonatomic) IBOutlet UIButton *switchPage;

@property (retain, nonatomic) IBOutlet UIButton *pen;
@property (retain, nonatomic) IBOutlet UIButton *palette;
@property (retain, nonatomic) IBOutlet UIButton *eraser;
@property (retain, nonatomic) IBOutlet UIButton *straw;


//@property (retain, nonatomic) IBOutlet UIButton *redo;
//@property (retain, nonatomic) IBOutlet UIButton *undo;

//@property (retain, nonatomic) IBOutlet UIButton *paintBucket;
//@property (retain, nonatomic) IBOutlet UIButton *shape;

//@property (retain, nonatomic) IBOutlet UIButton *shadow;
//@property (retain, nonatomic) IBOutlet UIButton *gradient;
//@property (retain, nonatomic) IBOutlet UIButton *selector;
//@property (retain, nonatomic) IBOutlet UIButton *fx;
//@property (retain, nonatomic) IBOutlet UIButton *text;

//@property (retain, nonatomic) IBOutlet UIView *colorHolderView;
@property (retain, nonatomic) NSTimer *timer;

@property (retain, nonatomic) UIView *closeSelector;

- (IBAction)switchToolPage:(UIButton *)sender;


@property (retain, nonatomic) IBOutlet UIImageView *toolBGImageView;

@end

@implementation DrawToolPanel
@synthesize timer = _timer;


#define MAX_COLOR_NUMBER 7
#define VALUE(x) (ISIPAD ? x*2 : x)

#define SPACE_COLOR_LEFT (ISIPAD ? 65 : 23)
#define SPACE_COLOR_COLOR (ISIPAD ? 14 : ((ISIPHONE5) ? 7 :2))
#define SPACE_COLOR_UP (ISIPHONE5 ? 20 : VALUE(22))


#define TIMESET_FONT_SIZE VALUE(15.0)

#define LINE_MIN_WIDTH ([PPConfigManager minPenWidth]) //(1.0)
#define LINE_MAX_WIDTH ([PPConfigManager maxPenWidth])
#define LINE_DEFAULT_WIDTH ([PPConfigManager defaultPenWidth])

#define COLOR_MIN_ALPHA ([PPConfigManager minAlpha])
#define COLOR_MAX_ALPHA 1.0
#define COLOR_DEFAULT_ALPHA 1.0

#define POP_POINTER_SIZE VALUE(8.0)


#pragma mark - setter methods



- (IBAction)clickTool:(id)sender
{
    [self.delegate drawToolPanel:self didClickTool:sender];
    ToolCommand *cmd = [toolCmdManager commandForControl:sender];
    [toolCmdManager hideAllPopTipViewsExcept:cmd];
    [cmd execute];
}

- (void)updateSliders
{
//    CGPoint center = self.widthSlider.center;
    CGRect frame = self.widthSlider.frame;
    [self.widthSlider removeFromSuperview];
    self.widthSlider = [DrawSlider sliderWithMaxValue:LINE_MAX_WIDTH
                                             minValue:LINE_MIN_WIDTH
                                         defaultValue:LINE_DEFAULT_WIDTH
                                             delegate:nil];
    self.widthSlider.frame = frame;    
    [self.penWidth setTitle:NSLS(@"kPenWidth") forState:UIControlStateNormal];


    frame = self.alphaSlider.frame;
    [self.alphaSlider removeFromSuperview];
    self.alphaSlider = [DrawSlider sliderWithMaxValue:COLOR_MAX_ALPHA
                                             minValue:COLOR_MIN_ALPHA
                                         defaultValue:COLOR_DEFAULT_ALPHA
                                             delegate:nil];
    
    self.alphaSlider.frame = frame;
    [self.colorAlpha setTitle:NSLS(@"kColorAlpha") forState:UIControlStateNormal];
    
    if (ISIPHONE5) {
        [self addSubview:self.alphaSlider];
        [self addSubview:self.widthSlider];
    }else{
        [self.scrollView addSubview:self.alphaSlider];
        [self.scrollView addSubview:self.widthSlider];
    }

}

#define COLOR_HOLDER_VIEW_TAG 20130819

- (UIView *)colorHolderView
{
    return [self viewWithTag:COLOR_HOLDER_VIEW_TAG];
}

- (void)updateRecentColorViewWithColor:(DrawColor *)color updateModel:(BOOL)updateModel
{
    color = [DrawColor colorWithColor:color];
    color.alpha = 1;
    
    if (updateModel) {
        [[DrawColorManager sharedDrawColorManager] updateColorListWithColor:color];
    }

    
    for (ColorPoint *p in self.colorHolderView.subviews) {
        if ([p isKindOfClass:[ColorPoint class]]) {
            [p removeFromSuperview];
        }
    }
    drawColorManager = [DrawColorManager sharedDrawColorManager];
    NSInteger i = 0;
    ColorPoint *selectedPoint = nil;
    
    [self.colorHolderView setBackgroundColor:[UIColor clearColor]];
    
    for (DrawColor *c in [drawColorManager recentColorList]) {
        ColorPoint *point = [ColorPoint pointWithColor:c];
        CGFloat x = SPACE_COLOR_LEFT + i * (CGRectGetWidth(point.frame) + SPACE_COLOR_COLOR);
        point.center = CGPointMake(x, self.addColor.center.y);
        point.delegate = self;
        [self.colorHolderView addSubview:point];
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

#define REG_CMD_CTRL(cls, ctrl, tp)\
command = [[[cls alloc] initWithControl:ctrl itemType:tp] autorelease];\
[toolCmdManager registerCommand:command];\
[command setToolPanel:self];\
[command setDrawInfo:self.drawView.drawInfo];\
[command setDrawView:self.drawView];


#define REG_CMD(cls, dt, tp)\
REG_CMD_CTRL(cls, [self buttonForType:dt], tp)

- (void)registerToolCommands
{
    toolCmdManager = [ToolCommandManager defaultManager];
    _commandVersion = [toolCmdManager createVersion];
    [toolCmdManager setVersion:_commandVersion];
    [toolCmdManager removeAllCommand:_commandVersion];
    
    ToolCommand *command = nil;
    REG_CMD(AddColorCommand, DrawToolTypeAddColor, ItemTypeNo);
    REG_CMD(PaletteCommand, DrawToolTypePalette, PaletteItem);

    REG_CMD(SelectPenCommand, DrawToolTypeAddColor, ItemTypeNo);
    REG_CMD(AddColorCommand, DrawToolTypePalette, PaletteItem);
        
    REG_CMD(SelectPenCommand, DrawToolTypePen, Pencil);
    REG_CMD(EraserCommand, DrawToolTypeEraser, Eraser);
    REG_CMD(PaintBucketCommand, DrawToolTypeBucket, ItemTypeNo);
    REG_CMD(ShapeCommand, DrawToolTypeShape, ItemTypeNo);
    REG_CMD(StrawCommand, DrawToolTypeStraw, ColorStrawItem);
    REG_CMD(WidthPickCommand, DrawToolTypeWidthPicker, ItemTypeNo);
    REG_CMD(TextCommand, DrawToolTypeText, ItemTypeNo);
    REG_CMD(SelectorCommand, DrawToolTypeSelector, ItemTypeSelector);
    REG_CMD(FXCommand, DrawToolTypeFX, ItemTypeFX);
    REG_CMD(GradientCommand, DrawToolTypeGradient, ItemTypeGradient);
    REG_CMD(ShadowCommand, DrawToolTypeShadow, ItemTypeShadow);
    REG_CMD(RedoCommand, DrawToolTypeRedo, ItemTypeNo);
    REG_CMD(UndoCommand, DrawToolTypeUndo, ItemTypeNo);
    REG_CMD(ChatCommand, DrawToolTypeChat, ItemTypeNo);
    
    REG_CMD(DrawBgCommand, DrawToolTypeCanvaseBG, ItemTypeNo);
    REG_CMD(GridCommand, DrawToolTypeBlock, ItemTypeGrid);
    REG_CMD(ChatCommand, DrawToolTypeChat, ItemTypeNo);
    
    REG_CMD_CTRL(WidthSliderCommand, self.widthSlider, ItemTypeNo);
    REG_CMD_CTRL(AlphaSliderCommand, self.alphaSlider, ColorAlphaItem);
}


- (UIButton *)buttonForType:(DrawToolType)type
{
    return [buttonDict objectForKey:KEY(type)];
}


#define EDGE (ISIPAD ? 12 : 5)
#define BUTTON_WDITH (ISIPAD ? 66 : 37)

- (UIButton *)createButtonWithType:(DrawToolType)type
{
    if ([buttonDict objectForKey:KEY(type)]) {
        PPDebug(@"<createButtonWithType> button is existed!! type =%d", type);
        return [buttonDict objectForKey:KEY(type)];
    }
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, BUTTON_WDITH, BUTTON_WDITH);
    UIImage *image = [PanelUtil imageForType:type];
    if (image) {
        [button setImage:image forState:UIControlStateNormal];
    }
    image = [PanelUtil bgImageForType:type state:UIControlStateNormal];
    if (image) {
        [button setBackgroundImage:image forState:UIControlStateNormal];
    }
    image = [PanelUtil bgImageForType:type state:UIControlStateSelected];
    
    if (image) {
        [button setBackgroundImage:image forState:UIControlStateSelected];
    }
    [buttonDict setObject:button forKey:KEY(type)];
    [button addTarget:self action:@selector(clickTool:) forControlEvents:UIControlEventTouchUpInside];
    return button;
    
}
#define UNDO_CENTER_X (ISIPAD ? 523 : (ISIPHONE5 ? 200 : 208))
#define REDO_CENTER_X (ISIPAD ? 617 : 250)
#define SHAPE_CENTER_X (150) //only for iphone 5

#define MAP_BUTTON(btn, tp)\
if (btn == nil) {\
btn = [self buttonForType:tp];\
}\
if (btn) {\
    [buttonDict setObject:btn forKey:@(tp)];\
}


- (void)mapToolButtons
{
    MAP_BUTTON(self.pen, DrawToolTypePen);
    MAP_BUTTON(self.palette, DrawToolTypePalette);
    MAP_BUTTON(self.eraser, DrawToolTypeEraser);
    MAP_BUTTON(self.straw, DrawToolTypeStraw);
    MAP_BUTTON(self.addColor, DrawToolTypeAddColor);
    MAP_BUTTON(self.penWidth, DrawToolTypeWidthPicker);
    MAP_BUTTON(self.timeSet, DrawToolTypeTimeset);
    MAP_BUTTON(self.chat, DrawToolTypeChat);
}

- (void)updateDrawToolButtons
{
    buttonDict = [[NSMutableDictionary dictionary] retain];
    CGFloat y = CGRectGetMidY(self.scrollView.bounds);
    CGFloat length = CGRectGetWidth(self.scrollView.bounds);
    UIButton *toolButton = nil;
    DrawToolType *types = [PanelUtil belowToolList];
    
    CGFloat start = length;

    toolButton = [self createButtonWithType:DrawToolTypeUndo];
    toolButton.center = CGPointMake(UNDO_CENTER_X, y);
    [self.scrollView addSubview:toolButton];
    toolButton = [self createButtonWithType:DrawToolTypeRedo];
    toolButton.center = CGPointMake(REDO_CENTER_X, y);
    [self.scrollView addSubview:toolButton];
    

    
    if (!ISIPHONE5) {
        types += 2;
    }else{
        toolButton = [self createButtonWithType:DrawToolTypeShape];
        toolButton.center = CGPointMake(SHAPE_CENTER_X, y);
        [self.scrollView addSubview:toolButton];

//        start = 0;
//        length *= 2;
        types += 3;
    }
    NSArray *xs = [PanelUtil xsForTypes:types edge:EDGE width:BUTTON_WDITH start:start length:length];
    
    NSInteger index = 0;
    for (DrawToolType *type = types; type != NULL && (*type) != DrawToolTypeEnd; ++ type, ++ index) {
        toolButton = [self createButtonWithType:(*type)];
        toolButton.center = CGPointMake([[xs objectAtIndex:index] floatValue], y);
        [self.scrollView addSubview:toolButton];        
    }
    
    //map it
    [self mapToolButtons];
}


- (void)handleNotification:(NSNotification *)note
{
    [self updateShowInfoWithDrawInfo:self.drawView.drawInfo];
}

- (void)updateView
{    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotification:)
                                                 name:DRAW_INFO_NEED_UPDATE
                                               object:nil];
    
    [self.scrollView setDelegate:self];
    [self updateDrawToolButtons];
    [self updateSliders];
    
    [self registerToolCommands];
    
    [self updateRecentColorViewWithColor:[DrawColor blackColor] updateModel:NO];

    [self.timeSet.titleLabel setFont:[UIFont fontWithName:@"DBLCDTempBlack" size:TIMESET_FONT_SIZE]];
    [self.colorBGImageView setImage:[[ShareImageManager defaultManager] drawColorBG]];
    [self.toolBGImageView setImage:[[ShareImageManager defaultManager] drawToolBG]];
    
}




+ (id)createViewWithDrawView:(DrawView *)drawView;
{
    DrawToolPanel *panel = nil;
    NSUInteger index = 0;
    
    if (ISIPHONE5) {
        index = 1;
    }else if(ISIPAD){
        index = 2;
    }

    panel = [UIView createViewWithXibIdentifier:@"ToolPanel" ofViewIndex:index];
    panel.drawView = drawView;
    [panel addCloseSelectorView];
    [panel updateView];
    [panel updateWithDrawInfo:drawView.drawInfo];
    
    if (ISIPAD){
        
        [panel.switchPage setImage:[UIImage imageNamedFixed:@"draw_switch@2x.png"]
                       forState:UIControlStateNormal];
        
        [panel.straw setImage:[UIImage imageNamedFixed:@"draw_straw@2x.png"] forState:UIControlStateNormal];
        [panel.addColor setImage:[UIImage imageNamedFixed:@"draw_add@2x.png"] forState:UIControlStateNormal];
        [panel.palette setImage:[UIImage imageNamedFixed:@"draw_palette@2x.png"] forState:UIControlStateNormal];
    }
    
    return panel;

}

- (void)bindController:(PPViewController *)controller
{
    [[ToolCommandManager defaultManager] bindController:controller];
}


- (void)exchangeCenterView1:(UIView *)v1 view2:(UIView *)v2
{
    CGPoint v1Center = v1.center;
    v1.center = v2.center;
    v2.center = v1Center;
}

- (void)setPanelForOnline:(BOOL)isOnline
{
    self.switchPage.hidden = isOnline;
    self.timeSet.hidden = self.chat.hidden = !isOnline;
    
    if(isOnline){
        UIButton *redo = [self buttonForType:DrawToolTypeRedo];
        UIButton *undo = [self buttonForType:DrawToolTypeUndo];
        UIButton *chat = [self buttonForType:DrawToolTypeChat];
        UIButton *bucket = [self buttonForType:DrawToolTypeBucket];
        [self exchangeCenterView1:redo view2:bucket];
        [self exchangeCenterView1:undo view2:chat];
        redo.hidden = undo.hidden = YES;
    }
    
    CGRect frame = self.scrollView.frame;
    PPDebug(@"ScrollView frame = %@", NSStringFromCGRect(frame));
    CGSize size = frame.size;
    size.width = isOnline ? size.width : size.width * 2;
    _scrollView.contentSize = size;
    PPDebug(@"Content Size = %@",NSStringFromCGSize(_scrollView.contentSize));
}

- (void)showGradientSettingView:(UIView *)gradientSettingView
{
    gradientSettingView.center = [self colorHolderView].center;
    [self addSubview:gradientSettingView];
}

#define COLOR_PANEL_TAG 123
- (void)hideColorPanel:(BOOL)hide
{
    [[self colorHolderView] setHidden:hide];
}

- (void)dealloc {
    
    PPDebug(@"%@ dealloc",self);

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [toolCmdManager removeAllCommand:_commandVersion];
    [drawColorManager syncRecentList];

    [buttonDict removeAllObjects];
    PPRelease(buttonDict);
    
    PPRelease(_widthSlider);
    PPRelease(_alphaSlider);
    PPRelease(_penWidth);
    PPRelease(_colorAlpha);
    PPRelease(_timer);
    
    PPRelease(_pen);
    PPRelease(_chat);
    PPRelease(_timeSet);
    PPRelease(_colorBGImageView);
    PPRelease(_palette);

    PPRelease(_switchPage);
    
    PPRelease(_eraser);
    PPRelease(_straw);
    PPRelease(_scrollView);
    PPRelease(_addColor);

    
    PPRelease(_toolBGImageView);
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
    [toolCmdManager hideAllPopTipViews];
    sender.selected = !sender.isSelected;
    NSUInteger page = sender.isSelected;
    [self scrollToPage:page];
    
    [UIView animateWithDuration:0.15 animations:^{
        CGFloat angle = sender.isSelected ? M_PI : -M_PI;
        [sender setTransform:CGAffineTransformRotate(sender.transform, angle)];
    }];
    
}

- (void)updateButtonWithOffsetX:(CGFloat)x
{
    if (x < CGRectGetWidth(self.scrollView.bounds)) {
        [UIView animateWithDuration:0.15 animations:^{
            [self.switchPage setTransform:CGAffineTransformIdentity];
        }];
        self.switchPage.selected = NO;
    }else{
        [UIView animateWithDuration:0.15 animations:^{
            [self.switchPage setTransform:CGAffineTransformRotate(CGAffineTransformIdentity, M_PI)];
        }];
        self.switchPage.selected = YES;
    }

}


#pragma mark- ScrollView delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [toolCmdManager hideAllPopTipViews];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    CGFloat offset = scrollView.contentOffset.x;
    [self updateButtonWithOffsetX:offset];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat offset = scrollView.contentOffset.x;
    [self updateButtonWithOffsetX:offset];    
}




/////new methods

#define INSET (ISIPAD ? 8 : 5)

- (void)updateShapeWithDrawInfo:(DrawInfo *)drawInfo
{
    if(drawInfo.shapeType == ShapeTypeNone){
        return;
    }
    UIBezierPath *path = [[ImageShapeManager defaultManager] pathWithType:drawInfo.shapeType];
    UIColor *color = [UIColor whiteColor];
    UIImage *image = nil;
    CGSize size = [ImageShapeInfo defaultImageShapeSize];
    
    if (drawInfo.strokeShape || drawInfo.shapeType == ShapeTypeBeeline) {
        image = [path toStrokeImageWithColor:color size:size];
    }else{
        image = [path toFillImageWithColor:color size:size];
    }
    UIButton *shape = [self buttonForType:DrawToolTypeShape];
    [shape.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [shape setImage:image forState:UIControlStateNormal];
    
    [shape setContentEdgeInsets:UIEdgeInsetsMake(INSET, INSET, INSET, INSET)];
}

- (void)updateSelectorWithDrawInfo:(DrawInfo *)drawInfo
{
    UIImage *image = [DrawInfo imageForClipActionType:drawInfo.touchType];
    UIButton *selector = [self buttonForType:DrawToolTypeSelector];
    [selector setContentEdgeInsets:UIEdgeInsetsMake(INSET, INSET, INSET, INSET)];
    [selector setImage:image forState:UIControlStateNormal];
    [selector setImage:image forState:UIControlStateSelected];
    [selector setSelected:[drawInfo isSelectorMode]];
}

- (void)updatePenWithDrawInfo:(DrawInfo *)drawInfo
{
    ShareDrawInfo* shareDrawInfo = self.drawView.shareDrawInfo;
    
    if (shareDrawInfo.penType != Eraser) {
        [self.pen setImage:[Item imageForItemType:shareDrawInfo.penType] forState:UIControlStateNormal];
        [self.pen setImage:[Item seletedPenImageForType:shareDrawInfo.penType] forState:UIControlStateSelected];
    }
}

#define SHOW_INFO_HEIGHT (ISIPAD ? 20 : 11)
#define SHOW_INFO_Y (ISIPAD ? 9 : 6)

- (UIView *)infoPointWithTag:(NSInteger)tag x:(CGFloat)x
{
    UIView *view = [self reuseViewWithTag:tag viewClass:[UIView class] frame:CGRectMake(x, SHOW_INFO_Y, SHOW_INFO_HEIGHT, SHOW_INFO_HEIGHT)];
    [view setBackgroundColor:COLOR_GREEN];
    view.layer.cornerRadius = SHOW_INFO_HEIGHT/2;
    view.layer.masksToBounds = YES;
    
    return view;
}
#define INFO_FONT_SIZE (ISIPAD ? 16: 10)

- (UILabel *)infoLabelWithTag:(NSInteger)tag
                            x:(CGFloat)x
                         text:(NSString *)text
{
    UILabel *label = [self reuseLabelWithTag:tag
                                       frame:CGRectMake(x, SHOW_INFO_Y, SHOW_INFO_HEIGHT, SHOW_INFO_HEIGHT)
                                        font:[UIFont systemFontOfSize:INFO_FONT_SIZE]
                                        text:text];

    [label setBackgroundColor:[UIColor clearColor]];
    [label setShadowColor:[UIColor whiteColor]];
    [label setShadowOffset:CGSizeMake(VALUE(0), VALUE(1)) blur:0 shadowColor:[UIColor whiteColor]];
    return label;
}

#define SHOW_INFO_TAG_BASE 1308200
#define INFO_LEFT (ISIPAD ? 34 : 6)
#define INFO_ITEM_SPACE (ISIPAD ? 30 : 10)
#define INFO_INNER_SPACE (ISIPAD ? 8 : 4)

- (void)updateInfo:(NSString *)info atIndex:(NSInteger)index
{
    CGFloat x = INFO_LEFT;
    NSInteger tag = SHOW_INFO_TAG_BASE + index * 2;
    UIView *p;    UILabel *l;
    if (index != 0) {
        l = (id)[self viewWithTag:tag-1];
        x = CGRectGetMaxX(l.frame) + INFO_ITEM_SPACE;
    }
    p = [self infoPointWithTag:tag x:x];
    l = [self infoLabelWithTag:tag+1 x:CGRectGetMaxX(p.frame)+INFO_INNER_SPACE text:info];
}

- (NSString *)modeNameForType:(TouchActionType)type
{
    NSDictionary *nameDict = @{
    KEY(TouchActionTypeDraw) : NSLS(@"kDrawPen"),
    KEY(TouchActionTypeGetColor) : NSLS(@"kStraw"),
    KEY(TouchActionTypeShape) : NSLS(@"kShape"),
    KEY(TouchActionTypeClipPath) : NSLS(@"kSelector"),
    KEY(TouchActionTypeClipPolygon) : NSLS(@"kSelector"),
    KEY(TouchActionTypeClipEllipse) : NSLS(@"kSelector"),
    KEY(TouchActionTypeClipRectangle) : NSLS(@"kSelector")};
    return [nameDict objectForKey:KEY(type)];
}

- (void)updateShowInfoWithDrawInfo:(DrawInfo *)drawInfo
{
    ShareDrawInfo* shareDrawInfo = _drawView.shareDrawInfo;
    
    NSString *layerName = [[self.drawView currentLayer] layerName];
    [self updateInfo:layerName atIndex:0];
    
    CGFloat scale = self.drawView.scale;
    [self updateInfo:[NSString stringWithFormat:@"%.0f %%", scale * 100] atIndex:1];

    NSString *mode = [self modeNameForType:drawInfo.touchType];
    if (drawInfo.touchType == TouchActionTypeDraw && shareDrawInfo.penType == Eraser) {
        mode = NSLS(@"kEraser");
    }
    [self updateInfo:mode atIndex:2];
}


- (void)updateWithDrawInfo:(DrawInfo *)drawInfo
{
    if (drawInfo == nil) {
        PPDebug(@"<updateWithDrawInfo> drawInfo = nil");
        return;
    }
    [toolCmdManager updateDrawInfo:drawInfo];
    
    NSArray *types = @[KEY(DrawToolTypePen), KEY(DrawToolTypeStraw), KEY(DrawToolTypeShape), KEY(DrawToolTypeEraser)];
    
    for (NSNumber *type in types) {
        UIButton *button = [self buttonForType:type.integerValue];
        [button setSelected:NO];
    }
    
    ShareDrawInfo* shareDrawInfo = self.drawView.shareDrawInfo;
    
    switch (drawInfo.touchType) {
        case TouchActionTypeDraw:
            if (shareDrawInfo.penType == Eraser) {
                self.eraser.selected = YES;
            }else{
                self.pen.selected = YES;
            }
            break;
            
        case TouchActionTypeGetColor:
            [self.straw setSelected:YES];
            break;
            
        case TouchActionTypeShape:
            [[self buttonForType:DrawToolTypeShape] setSelected:YES];
            
        default:
            break;
    }
    

    [self updatePenWithDrawInfo:drawInfo];
    [self updateShapeWithDrawInfo:drawInfo];
    [self updateSelectorWithDrawInfo:drawInfo];
    [self updateShowInfoWithDrawInfo:drawInfo];
    
//    if (drawInfo.penType == Eraser){
//        [self.alphaSlider setValue:drawInfo.eraserAlpha];
//        [self.widthSlider setValue:drawInfo.eraserWidth];
//    }
//    else{
//    }
    [self.alphaSlider setValue:[shareDrawInfo itemAlpha]];
    
    if (shareDrawInfo.penType == Quill){
        // fix width, so disable width slider
        self.widthSlider.enabled = NO;
        self.penWidth.enabled = NO;
//        [self.penWidth setTitleColor:COLOR_GRAY forState:UIControlStateNormal];
    }
    else{
        self.widthSlider.enabled = YES;
        self.penWidth.enabled = YES;
//        [self.penWidth setTitleColor:COLOR_BROWN forState:UIControlStateNormal];
        
        // reset pen width if needed
        if ([shareDrawInfo itemWidth] <= QUILL_PEN_WIDTH){
            [shareDrawInfo setItemWidth:LINE_DEFAULT_WIDTH];
        }
        
        [self.widthSlider setValue:[shareDrawInfo itemWidth]];
    }
    

    NSArray *array = @[KEY(TouchActionTypeClipEllipse), KEY(TouchActionTypeClipPath), KEY(TouchActionTypeClipPolygon), KEY(TouchActionTypeClipRectangle)];
    [self setCloseSelectorHidden:![_drawView.currentClip isLegal] && ![array containsObject:KEY(drawInfo.touchType)]];
    
    DrawColor *color = [DrawColor colorWithColor:shareDrawInfo.penColor];
    [color setAlpha:1];
    [self updateRecentColorViewWithColor:color updateModel:NO];
}




#define IMAGE_VIEW_SIZE (ISIPAD ? 140 : 70)
#define CLOSE_VIEW_SIZE (ISIPAD ? 80 : 40)

#define CLOSE_BUTTON_TAG 201307301
#define CLOSE_BUTTON_BG_TAG 201307302
#define CLOSE_VIEW_X (ISIPAD ? (768-IMAGE_VIEW_SIZE-34) : (320-IMAGE_VIEW_SIZE-10))
#define CLOSE_VIEW_Y (ISIPAD ? 100 : 50)

- (void)setCloseSelectorHidden:(BOOL)hidden
{
    UIButton *button = (id)[[self.drawView theTopView] viewWithTag:CLOSE_BUTTON_TAG];
    UIImageView *bg = (id)[[self.drawView theTopView] viewWithTag:CLOSE_BUTTON_BG_TAG];
    button.hidden = bg.hidden = hidden;
}

- (void)addCloseSelectorView
{
    self.closeSelector = [UIView createViewWithXibIdentifier:@"ToolPanel" ofViewIndex:(3+ISIPAD)];
    
    
    
    UIButton *button = (id)[_closeSelector viewWithTag:CLOSE_BUTTON_TAG];
    [button addTarget:self action:@selector(clickCloseSelector:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *bg = (id)[_closeSelector viewWithTag:CLOSE_BUTTON_BG_TAG];
    
    
    [[self.drawView theTopView] addSubview:bg];
    [[self.drawView theTopView] addSubview:button];
    
    CGFloat x = CGRectGetMaxX(self.drawView.superview.frame) - CGRectGetWidth(bg.frame);
    CGFloat y = CGRectGetMinY(self.drawView.superview.frame);
    
    [bg updateOriginX:x]; [bg updateOriginY:y];

    x = CGRectGetMaxX(self.drawView.superview.frame) - CGRectGetWidth(button.frame);
    
    [button updateOriginX:x]; [button updateOriginY:y];
    
    

}



- (void)clickCloseSelector:(id)sender
{
 
    [self.drawView exitFromClipMode];
    [self.drawView.drawInfo backToLastDrawMode];
    [self updateWithDrawInfo:self.drawView.drawInfo];
}


- (void)didSelectColorPoint:(ColorPoint *)colorPoint
{
    [self updateRecentColorViewWithColor:colorPoint.color updateModel:NO];
    DrawInfo *drawInfo = self.drawView.drawInfo;
    self.drawView.shareDrawInfo.penColor = [DrawColor colorWithColor:colorPoint.color];
    
    [drawInfo backToLastDrawMode];
    [self.drawView.shareDrawInfo backToLastDrawMode];
    
    [self updateWithDrawInfo:drawInfo];
    [toolCmdManager hideAllPopTipViews];
}
@end

