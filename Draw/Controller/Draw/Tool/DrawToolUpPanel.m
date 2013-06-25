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

@interface DrawToolUpPanel () {
    NSInteger _retainTime;
    DrawColorManager *drawColorManager;
    ToolCommandManager *toolCmdManager;
    NSUInteger _commandVersion;
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
    [super dealloc];
}

- (void)registerToolCommands
{
    toolCmdManager = [ToolCommandManager defaultManager];
    _commandVersion = [toolCmdManager createVersion];
    [toolCmdManager setVersion:_commandVersion];
    [toolCmdManager removeAllCommand:_commandVersion];
    
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
    [self.copyPaint setTitle:NSLS(@"kCopyPaint") forState:UIControlStateNormal];
    [self.opusDesc setTitle:NSLS(@"kDescription") forState:UIControlStateNormal];
    [self.drawToUserNickNameLabel setText:NSLS(@"kDrawTo")];
    [self.grid setTitle:NSLS(@"kGrid") forState:UIControlStateNormal];
    [self.help setTitle:NSLS(@"kHelp") forState:UIControlStateNormal];
    
}
- (IBAction)clickTool:(id)sender
{
    [toolCmdManager hideAllPopTipViewsExcept:[toolCmdManager commandForControl:sender]];
    [[toolCmdManager commandForControl:sender] execute];
}

- (void)appear
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    self.center = CGPointMake(self.center.x, self.frame.size.height/2+30);
    [UIView commitAnimations];
    self.isVisable = YES;
}
- (void)disappear
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    self.center = CGPointMake(self.center.x, -self.frame.size.height/2);
    [UIView commitAnimations];
    self.isVisable = NO;
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
