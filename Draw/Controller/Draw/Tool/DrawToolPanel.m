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
#import "ConfigManager.h"
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

#define AnalyticsReport(x) [[AnalyticsManager sharedAnalyticsManager] reportDrawClick:x]

@interface DrawToolPanel ()
{
    NSTimer *timer;
    NSInteger _retainTime;
    DrawColorManager *drawColorManager;
    ToolCommandManager *toolCmdManager;
    NSUInteger _commandVersion;
}

#pragma mark - click actions




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

@property (retain, nonatomic) IBOutlet UIButton *paintBucket;
@property (retain, nonatomic) IBOutlet UIButton *shape;

@property (retain, nonatomic) IBOutlet UIButton *shadow;
@property (retain, nonatomic) IBOutlet UIButton *gradient;
@property (retain, nonatomic) IBOutlet UIButton *selector;
@property (retain, nonatomic) IBOutlet UIButton *fx;
@property (retain, nonatomic) IBOutlet UIButton *text;

@property (retain, nonatomic) NSTimer *timer;

@property (retain, nonatomic) UIView *closeSelector;

- (IBAction)switchToolPage:(UIButton *)sender;


@property (retain, nonatomic) IBOutlet UIImageView *toolBGImageView;

@end

@implementation DrawToolPanel
@synthesize timer = _timer;


#define MAX_COLOR_NUMBER 7
#define VALUE(x) (ISIPAD ? x*2 : x)

#define SPACE_COLOR_LEFT (ISIPAD ? 40 : 10)
#define SPACE_COLOR_COLOR (ISIPAD ? 14 : ((ISIPHONE5) ? 7 :2))
#define SPACE_COLOR_UP (ISIPHONE5 ? 20 : VALUE(13))


#define TIMESET_FONT_SIZE VALUE(15.0)

#define LINE_MIN_WIDTH ([ConfigManager minPenWidth]) //(1.0)
#define LINE_MAX_WIDTH ([ConfigManager maxPenWidth])
#define LINE_DEFAULT_WIDTH ([ConfigManager defaultPenWidth])

#define COLOR_MIN_ALPHA ([ConfigManager minAlpha])
#define COLOR_MAX_ALPHA 1.0
#define COLOR_DEFAULT_ALPHA 1.0

#define POP_POINTER_SIZE VALUE(8.0)

//#define COLOR_BG_TAG 201304051
//#define TOOL_BG_TAG 201304052

#pragma mark - setter methods



- (IBAction)clickTool:(id)sender
{
    [self.delegate drawToolPanel:self didClickTool:sender];
    [toolCmdManager hideAllPopTipViewsExcept:[toolCmdManager commandForControl:sender]];
    [[toolCmdManager commandForControl:sender] execute];
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

- (void)updateRecentColorViewWithColor:(DrawColor *)color updateModel:(BOOL)updateModel
{
    color = [DrawColor colorWithColor:color];
    color.alpha = 1;
    
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
        [self insertSubview:point belowSubview:self.scrollView];
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


- (void)registerToolCommands
{
    toolCmdManager = [ToolCommandManager defaultManager];
    _commandVersion = [toolCmdManager createVersion];
    [toolCmdManager setVersion:_commandVersion];
    [toolCmdManager removeAllCommand:_commandVersion];
    
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

    
    command = [[[ShapeCommand alloc] initWithControl:self.shape itemType:ItemTypeNo] autorelease];
    [toolCmdManager registerCommand:command];
    
    command = [[[StrawCommand alloc] initWithControl:self.straw itemType:ColorStrawItem] autorelease];
    [toolCmdManager registerCommand:command];
    
    
    command = [[[WidthPickCommand alloc] initWithControl:self.penWidth itemType:ItemTypeNo] autorelease];
    [toolCmdManager registerCommand:command];
    
    
    command = [[[WidthSliderCommand alloc] initWithControl:self.widthSlider itemType:ItemTypeNo] autorelease];
    [toolCmdManager registerCommand:command];

    command = [[[AlphaSliderCommand alloc] initWithControl:self.alphaSlider itemType:ColorAlphaItem] autorelease];
    [toolCmdManager registerCommand:command];

    command = [[[TextCommand alloc] initWithControl:self.text itemType:ItemTypeNo] autorelease];
    [toolCmdManager registerCommand:command];
    
    command = [[[SelectorCommand alloc] initWithControl:self.selector itemType:ItemTypeSelector] autorelease];
    [toolCmdManager registerCommand:command];

    command = [[[FXCommand alloc] initWithControl:self.fx itemType:ItemTypeGrid] autorelease];
    [toolCmdManager registerCommand:command];

    
    command = [[[GradientCommand alloc] initWithControl:self.gradient itemType:ItemTypeGradient] autorelease];
    [toolCmdManager registerCommand:command];

    
    command = [[[ShadowCommand alloc] initWithControl:self.shadow itemType:ItemTypeShadow] autorelease];
    [toolCmdManager registerCommand:command];

    
    command = [[[RedoCommand alloc] initWithControl:self.redo itemType:ItemTypeNo] autorelease];
    [toolCmdManager registerCommand:command];

    command = [[[UndoCommand alloc] initWithControl:self.undo itemType:ItemTypeNo] autorelease];
    [toolCmdManager registerCommand:command];
    
    command = [[[ChatCommand alloc] initWithControl:self.chat itemType:ItemTypeNo] autorelease];
    [toolCmdManager registerCommand:command];
    
    [toolCmdManager updatePanel:self];
    [toolCmdManager updateDrawInfo:self.drawView.drawInfo];
    [toolCmdManager updateDrawView:self.drawView];
}



- (void)updateView
{
    [self.scrollView setDelegate:self];
    
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
    return panel;

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
        [self exchangeCenterView1:self.redo view2:self.paintBucket];
        [self exchangeCenterView1:self.undo view2:self.chat];
        
        self.redo.hidden = self.undo.hidden = YES;
//        self.grid.hidden = self.drawBg.hidden =
//        self.canvasSize.hidden = self.help.hidden =
//        self.opusDesc.hidden = self.drawToUser.hidden = YES;
    }
    
    CGRect frame = self.scrollView.frame;
    PPDebug(@"ScrollView frame = %@", NSStringFromCGRect(frame));
    CGSize size = frame.size;
    size.width = isOnline ? size.width : size.width * 2;
    _scrollView.contentSize = size;
    PPDebug(@"Content Size = %@",NSStringFromCGSize(_scrollView.contentSize));
}

#define COLOR_PANEL_TAG 123
- (void)hideColorPanel:(BOOL)hide
{
    UIView *view = [self viewWithTag:COLOR_PANEL_TAG];
    [view setHidden:hide];
    for (ColorPoint *cp in self.subviews) {
        if ([cp isKindOfClass:[ColorPoint class]]) {
            [cp setHidden:hide];
        }
    }
}

- (void)dealloc {
    
    PPDebug(@"%@ dealloc",self);
    [toolCmdManager removeAllCommand:_commandVersion];
    [drawColorManager syncRecentList];
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
    
    PPRelease(_eraser);
    PPRelease(_straw);
    PPRelease(_scrollView);
    PPRelease(_addColor);
    
    PPRelease(_shape);
    PPRelease(_paintBucket);
    
    PPRelease(_shadow);
    PPRelease(_gradient);
    PPRelease(_selector);
    PPRelease(_fx);
    PPRelease(_text);
    
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

- (void)updateShapeWithDrawInfo:(DrawInfo *)drawInfo
{
    UIBezierPath *path = [[ImageShapeManager defaultManager] pathWithType:drawInfo.shapeType];
    UIColor *color = ISIPHONE5 ? OPAQUE_COLOR(62, 43, 23) : [UIColor whiteColor];
    UIImage *image = nil;
    if(drawInfo.shapeType == ShapeTypeNone){
        return;
    }else if (drawInfo.strokeShape || drawInfo.shapeType == ShapeTypeBeeline) {
        image = [path toStrokeImageWithColor:color size:[ImageShapeInfo defaultImageShapeSize]];
    }else{
        image = [path toFillImageWithColor:color size:[ImageShapeInfo defaultImageShapeSize]];
    }
    [self.shape.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.shape setImage:image forState:UIControlStateNormal];

}

- (void)updateSelectorWithDrawInfo:(DrawInfo *)drawInfo
{
    UIImage *image = [DrawInfo imageForClipActionType:drawInfo.touchType];
    [self.selector setImage:image forState:UIControlStateNormal];
    [self.selector setImage:image forState:UIControlStateSelected];
    [self.selector setSelected:[drawInfo isSelectorMode]];
}

- (void)updatePenWithDrawInfo:(DrawInfo *)drawInfo
{
    if (drawInfo.penType != Eraser) {
        [self.pen setImage:[Item imageForItemType:drawInfo.penType] forState:UIControlStateNormal];
        [self.pen setImage:[Item seletedPenImageForType:drawInfo.penType] forState:UIControlStateSelected];
    }
}

- (void)updateWithDrawInfo:(DrawInfo *)drawInfo
{
    if (drawInfo == nil) {
        PPDebug(@"<updateWithDrawInfo> drawInfo = nil");
        return;
    }
    [toolCmdManager updateDrawInfo:drawInfo];
    
    NSArray *buttons = @[self.pen, self.straw, self.shape, self.eraser];
    for (UIButton *button in buttons) {
        [button setSelected:NO];
    }
    
    switch (drawInfo.touchType) {
        case TouchActionTypeDraw:
            if (drawInfo.penType == Eraser) {
                self.eraser.selected = YES;
            }else{
                self.pen.selected = YES;
            }
            break;
            
        case TouchActionTypeGetColor:
            [self.straw setSelected:YES];
            break;
            
        case TouchActionTypeShape:
            [self.shape setSelected:YES];
            
        default:
            break;
    }
    

    [self updatePenWithDrawInfo:drawInfo];
    [self updateShapeWithDrawInfo:drawInfo];
    [self updateSelectorWithDrawInfo:drawInfo];
    
    [self.alphaSlider setValue:drawInfo.alpha];
    [self.widthSlider setValue:drawInfo.penWidth];


    NSArray *array = @[@(TouchActionTypeClipEllipse), @(TouchActionTypeClipPath), @(TouchActionTypeClipPolygon), @(TouchActionTypeClipRectangle)];
    [self setCloseSelectorHidden:_drawView.currentClip == nil &&![array containsObject:@(drawInfo.touchType)]];
    
    DrawColor *color = [DrawColor colorWithColor:drawInfo.penColor];
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
    self.closeSelector = [UIView createViewWithXibIdentifier:@"ToolPanel" ofViewIndex:3];
//    UIView *_coloseView = self.closeSelector;
    
    if (ISIPAD) {
        _closeSelector.frame = CGRectMake(CLOSE_VIEW_X, CLOSE_VIEW_Y, IMAGE_VIEW_SIZE, IMAGE_VIEW_SIZE);
    }else{
        _closeSelector.frame = CGRectMake(CLOSE_VIEW_X, CLOSE_VIEW_Y, IMAGE_VIEW_SIZE, IMAGE_VIEW_SIZE);
    }
    
    UIButton *button = (id)[_closeSelector viewWithTag:CLOSE_BUTTON_TAG];
    [button addTarget:self action:@selector(clickCloseSelector:) forControlEvents:UIControlEventTouchUpInside];

    CGFloat x = CLOSE_VIEW_X + CGRectGetMinX(button.frame);
    CGFloat y = CLOSE_VIEW_Y + CGRectGetMinY(button.frame);
    [button updateOriginX:x];
    [button updateOriginY:y];
    
    UIImageView *bg = (id)[_closeSelector viewWithTag:CLOSE_BUTTON_BG_TAG];
    x = CLOSE_VIEW_X + CGRectGetMinX(bg.frame);
    y = CLOSE_VIEW_Y + CGRectGetMinY(bg.frame);
    [bg updateOriginX:x];
    [bg updateOriginY:y];
    
    [[self.drawView theTopView] addSubview:bg];
    [[self.drawView theTopView] addSubview:button];    
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
    drawInfo.penColor = [DrawColor colorWithColor:colorPoint.color];
    [drawInfo backToLastDrawMode];
    [self updateWithDrawInfo:drawInfo];
    [toolCmdManager hideAllPopTipViews];
}
@end

