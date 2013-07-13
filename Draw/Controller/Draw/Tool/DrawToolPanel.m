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

#define LINE_MIN_WIDTH (1.0)
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

- (void)updateWidthSliderWithValue:(CGFloat)value
{
    [self.widthSlider setValue:value];
}

- (void)setShapeSelected:(BOOL)selected
{
    self.shape.selected = selected;
}

- (void)setStrawSelected:(BOOL)selected
{
    [self.straw setSelected:selected];
}

- (void)setPenSelected:(BOOL)selected
{
    [self.pen setSelected:selected];
}

- (void)setEraserSelected:(BOOL)selected
{
    [self.eraser setSelected:selected];
}
//- (void)updateDrawToUser:(MyFriend *)user
//{
//
//}
//


- (void)didSelectColorPoint:(ColorPoint *)colorPoint
{
    
    TouchActionType type = self.toolHandler.drawView.touchActionType;
    
    [self updateRecentColorViewWithColor:colorPoint.color updateModel:NO];
    [self.toolHandler changePenColor:colorPoint.color];
    [[[ToolCommandManager defaultManager] commandForControl:self.pen] becomeActive];
    if(type == TouchActionTypeShape){
        [self.toolHandler enterShapeMode];
    }else{
        [self.toolHandler enterDrawMode];
    }

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

    //
    command = [[[TextCommand alloc] initWithControl:self.text itemType:ItemTypeNo] autorelease];
    [toolCmdManager registerCommand:command];
/*
    command = [[[CanvasSizeCommand alloc] initWithControl:self.canvasSize itemType:ItemTypeNo] autorelease];
    [toolCmdManager registerCommand:command];
  */
    
    command = [[[SelectorCommand alloc] initWithControl:self.selector itemType:ItemTypeNo] autorelease];
    [toolCmdManager registerCommand:command];

    command = [[[FXCommand alloc] initWithControl:self.fx itemType:ItemTypeGrid] autorelease];
    [toolCmdManager registerCommand:command];

//    command = [[[EditDescCommand alloc] initWithControl:self.opusDesc itemType:ItemTypeNo] autorelease];
//    [toolCmdManager registerCommand:command];

/*
    command = [[[DrawToCommand alloc] initWithControl:self.drawToUser itemType:ItemTypeNo] autorelease];
    [toolCmdManager registerCommand:command];
*/
    
    command = [[[GradientCommand alloc] initWithControl:self.gradient itemType:ItemTypeNo] autorelease];
    [toolCmdManager registerCommand:command];

    
    command = [[[ShadowCommand alloc] initWithControl:self.shadow itemType:ItemTypeNo] autorelease];
    [toolCmdManager registerCommand:command];

/*
    command = [[[HelpCommand alloc] initWithControl:self.help itemType:ItemTypeNo] autorelease];
    [toolCmdManager registerCommand:command];
*/
    
    command = [[[RedoCommand alloc] initWithControl:self.redo itemType:ItemTypeNo] autorelease];
    [toolCmdManager registerCommand:command];

    command = [[[UndoCommand alloc] initWithControl:self.undo itemType:ItemTypeNo] autorelease];
    [toolCmdManager registerCommand:command];
    
    command = [[[ChatCommand alloc] initWithControl:self.chat itemType:ItemTypeNo] autorelease];
    [toolCmdManager registerCommand:command];
    

    [toolCmdManager updateHandler:self.toolHandler];
    [toolCmdManager updatePanel:self];
    
    [self.toolHandler enterDrawMode];
}



- (void)updateViewsForSimpleDraw
{
    if (isSimpleDrawApp()) {
//        if(!ISIPAD){
//            self.paintBucket.center = self.drawToUser.center;
//        }else{
//            self.shape.center = self.opusDesc.center;
//            self.paintBucket.center = self.drawToUser.center;
//        }
//        self.drawToUser.hidden = self.opusDesc.hidden = YES;
    }

}

- (void)updateView
{
    [self updateSliders];
    
    [self registerToolCommands];
        
    [self updateRecentColorViewWithColor:[DrawColor blackColor] updateModel:NO];

    [self.timeSet.titleLabel setFont:[UIFont fontWithName:@"DBLCDTempBlack" size:TIMESET_FONT_SIZE]];
    [self.colorBGImageView setImage:[[ShareImageManager defaultManager] drawColorBG]];
    [self.toolBGImageView setImage:[[ShareImageManager defaultManager] drawToolBG]];
    
    [self updateViewsForSimpleDraw];
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
        
//        self.redo.hidden = self.undo.hidden =
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
    PPRelease(_toolHandler);
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
@end

