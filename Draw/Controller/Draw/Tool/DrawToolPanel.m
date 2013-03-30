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

#import "WidthView.h"
#import "UIImageUtil.h"

#define AnalyticsReport(x) [[AnalyticsManager sharedAnalyticsManager] reportDrawClick:x]

@interface DrawToolPanel ()
{
    NSTimer *timer;
    NSInteger _retainTime;
    DrawColorManager *drawColorManager;
    ToolCommandManager *toolCmdManager;
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
@property (retain, nonatomic) IBOutlet UIButton *canvasSize;
@property (retain, nonatomic) IBOutlet UIButton *grid;
@property (retain, nonatomic) IBOutlet UIButton *opusDesc;
@property (retain, nonatomic) IBOutlet UIButton *drawToUser;
@property (retain, nonatomic) IBOutlet UIButton *help;

@property (retain, nonatomic) IBOutlet UIButton *drawBg;
@property (retain, nonatomic) NSTimer *timer;

- (IBAction)switchToolPage:(UIButton *)sender;

- (IBAction)clickTool:(UIButton *)sender;

@end

@implementation DrawToolPanel
@synthesize timer = _timer;


#define MAX_COLOR_NUMBER 7
#define VALUE(x) (ISIPAD ? x*2 : x)

#define SPACE_COLOR_LEFT (ISIPAD ? 40 : 8)
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


- (void)updateDrawToUser:(MyFriend *)user
{

    NSURL *URL = [NSURL URLWithString:user.avatar];
    __block typeof(self) cp = self;
    [[SDWebImageManager sharedManager] downloadWithURL:URL delegate:URL options:0 success:^(UIImage *image, BOOL cached) {
        image = [UIImage shrinkImage:image withRate:0.8];
        [cp.drawToUser setImage:image forState:UIControlStateNormal];
    } failure:^(NSError *error) {
        
    }];
}

- (void)didSelectColorPoint:(ColorPoint *)colorPoint
{
    
    TouchActionType type = self.toolHandler.drawView.touchActionType;
    
    [self updateRecentColorViewWithColor:colorPoint.color updateModel:NO];
    [self.toolHandler changePenColor:colorPoint.color];
    [[[ToolCommandManager defaultManager] commandForControl:self.pen] becomeActive];
    if (type == TouchActionTypeShape) {
        [self.toolHandler enterStrawMode];
    }else{
        [self.toolHandler enterDrawMode];
    }

}

- (void)registerToolCommands
{
    toolCmdManager = [ToolCommandManager defaultManager];
    [toolCmdManager removeAllCommand];
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
    
    command = [[[ShapeCommand alloc] initWithControl:self.shape itemType:BasicShape] autorelease];
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
    
    [self updateSliders];
    
    [self registerToolCommands];
        
    [self updateRecentColorViewWithColor:[DrawColor blackColor] updateModel:NO];

    [self.timeSet.titleLabel setFont:[UIFont fontWithName:@"DBLCDTempBlack" size:TIMESET_FONT_SIZE]];
    [self.colorBGImageView setImage:[[ShareImageManager defaultManager] drawColorBG]];

//    [self updateScrollView];
    //update width and alpha

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

- (void)dealloc {
    
    PPDebug(@"%@ dealloc",self);
    [toolCmdManager removeAllCommand];
    [drawColorManager syncRecentList];
    PPRelease(_toolHandler);
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

