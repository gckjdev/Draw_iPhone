//
//  DrawToolUpPanel.m
//  Draw
//
//  Created by Kira on 13-6-25.
//
//

#import "DrawToolUpPanel.h"
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

#import "WidthView.h"
#import "UIImageUtil.h"
#import "CopyPaintCommand.h"
#import "ShowCopyPaintCommand.h"

@interface DrawToolUpPanel () {
    NSInteger _retainTime;
    DrawColorManager *drawColorManager;
    ToolCommandManager *toolCmdManager;
    NSUInteger _commandVersion;
    
    UIControl* _mask;
}

@property (retain, nonatomic) IBOutlet UIButton *canvasSize;
@property (retain, nonatomic) IBOutlet UIButton *grid;
@property (retain, nonatomic) IBOutlet UIButton *opusDesc;
@property (retain, nonatomic) IBOutlet UIButton *drawToUser;
@property (retain, nonatomic) IBOutlet UIButton *help;

@property (retain, nonatomic) IBOutlet UIButton *drawBg;
@property (retain, nonatomic) NSTimer *timer;

@end

@implementation DrawToolUpPanel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)dealloc
{
    [_copyPaint release];
    [_titleLabel release];
    [_drawToUserNickNameLabel release];
    [_copyPaintPicker release];
    [_copyPaintLabel release];
    [super dealloc];
}

- (void)registerToolCommands
{
    toolCmdManager = [ToolCommandManager defaultManager];
//    _commandVersion = [toolCmdManager createVersion];
//    [toolCmdManager setVersion:_commandVersion];
//    [toolCmdManager removeAllCommand:_commandVersion];
    
    ToolCommand *command;

    
    //
    command = [[[DrawBgCommand alloc] initWithControl:self.drawBg itemType:ItemTypeNo] autorelease];
    [toolCmdManager registerCommand:command];
    
    command = [[[CanvasSizeCommand alloc] initWithControl:self.canvasSize itemType:ItemTypeNo] autorelease];
    [toolCmdManager registerCommand:command];
    
    command = [[[GridCommand alloc] initWithControl:self.grid itemType:ItemTypeGrid] autorelease];
    [toolCmdManager registerCommand:command];
    
    command = [[[EditDescCommand alloc] initWithControl:self.opusDesc itemType:ItemTypeNo] autorelease];
    [toolCmdManager registerCommand:command];
    
    command = [[[DrawToCommand alloc] initWithControl:self.drawToUser itemType:ItemTypeNo] autorelease];
    [toolCmdManager registerCommand:command];
    
    command = [[[HelpCommand alloc] initWithControl:self.help itemType:ItemTypeNo] autorelease];
    [toolCmdManager registerCommand:command];
    
    command = [[[CopyPaintCommand alloc] initWithControl:self.copyPaintPicker itemType:ItemTypeNo] autorelease];
    [toolCmdManager registerCommand:command];
    
    command = [[[ShowCopyPaintCommand alloc] initWithControl:self.copyPaint itemType:ItemTypeNo] autorelease];
    [toolCmdManager registerCommand:command];
    
    [toolCmdManager updateHandler:self.toolHandler];
    [toolCmdManager updatePanel:self];
    
    [self.toolHandler enterDrawMode];
}

+ (id)createViewWithdToolHandler:(ToolHandler *)handler
{
    DrawToolUpPanel *panel = nil;
    panel = [UIView createViewWithXibIdentifier:@"DrawToolUpPanel"];
    panel.toolHandler = handler;
    handler.drawToolPanel = panel;
    panel.hidden = YES;
    [panel updateView];
    return panel;
}

- (void)updateDrawToUser:(MyFriend *)user
{
    [super updateDrawToUser:user];
    [self.drawToUserNickNameLabel setText:user.nickName];
}

- (void)updateView
{
    [self registerToolCommands];
    [self.grid setSelected:NO];
    [self.canvasSize setTitle:NSLS(@"kSize") forState:UIControlStateNormal];
    [self.drawBg setTitle:NSLS(@"kBackground") forState:UIControlStateNormal];
    [self.copyPaintLabel setText:NSLS(@"kCopyPaint")];
    [self.opusDesc setTitle:NSLS(@"kDescription") forState:UIControlStateNormal];
    [self.drawToUserNickNameLabel setText:NSLS(@"kDrawTo")];
    [self.grid setTitle:NSLS(@"kGrid") forState:UIControlStateNormal];
    [self.help setTitle:NSLS(@"kHelp") forState:UIControlStateNormal];
    
}
- (IBAction)clickTool:(id)sender
{
    [toolCmdManager hideAllPopTipViewsExcept:[toolCmdManager commandForControl:sender]];
    [[toolCmdManager commandForControl:sender] execute];
    
    if (sender != self.canvasSize) {
        [self disappear];
    }
}

- (IBAction)clickShowCopyPaint:(id)sender
{
    if (self.copyPaintPicker.hidden) {
        [toolCmdManager hideAllPopTipViewsExcept:[toolCmdManager commandForControl:self.copyPaintPicker]];
        [[toolCmdManager commandForControl:self.copyPaintPicker] execute];
    } else {
        [toolCmdManager hideAllPopTipViewsExcept:[toolCmdManager commandForControl:sender]];
        [[toolCmdManager commandForControl:sender] execute];
        [self disappear];
    }
    
}

- (void)appear:(UIViewController*)parentController
         title:(NSString*)title
{
    self.layer.opacity = 0;
    self.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1);
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    self.layer.opacity = 1;
    self.layer.transform = CATransform3DMakeScale(1, 1, 1);
    self.center = CGPointMake(self.center.x, self.frame.size.height/2+(ISIPAD?70:30));
    [UIView commitAnimations];
    self.isVisable = YES;
    self.hidden = NO;
    [self.titleLabel setText:title];
    
    [self addMask:parentController];
}

- (void)addMask:(UIViewController*)parentController
{
    _mask= [[[UIControl alloc] initWithFrame:parentController.view.bounds] autorelease];
    [parentController.view insertSubview:_mask belowSubview:self];
    [_mask addTarget:self action:@selector(clickMask:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)clickMask:(id)sender
{
    UIControl* control = (UIControl*)sender;
    [self disappear];
    [control removeFromSuperview];
}
- (void)disappear
{
    [_mask removeFromSuperview];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    self.center = CGPointMake(self.center.x, -self.frame.size.height/2);
    self.layer.opacity = 0;
    self.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1);
    [UIView commitAnimations];
    self.isVisable = NO;
    self.hidden = YES;
    
    
}

- (void)updateCopyPaint:(UIImage*)aPhoto
{
    UIImage* image = [UIImage shrinkImage:aPhoto withRate:0.8];
    [self.copyPaint setImage:image forState:UIControlStateNormal];
    [self.copyPaintPicker setHidden:NO];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
