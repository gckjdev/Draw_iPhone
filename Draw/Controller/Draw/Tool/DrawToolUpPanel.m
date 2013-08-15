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
    [_backgroundImageView release];
    
    PPRelease(_drawBg);
    PPRelease(_canvasSize);
    PPRelease(_grid);
    PPRelease(_opusDesc);
    PPRelease(_drawToUser);
    PPRelease(_help);

    
    [_subject release];
    [super dealloc];
}

#define ADD_COMMAND(cmd, cls, button, it)\
cmd = [[[cls alloc] initWithControl:button itemType:it] autorelease];\
[toolCmdManager registerCommand:command];\
[cmd setToolPanel:self];


- (void)registerToolCommands
{
    toolCmdManager = [ToolCommandManager defaultManager];
    
    
    ToolCommand *command;

    ADD_COMMAND(command, DrawBgCommand, self.drawBg, ItemTypeNo);
    ADD_COMMAND(command, CanvasSizeCommand, self.canvasSize, ItemTypeNo);
    ADD_COMMAND(command, GridCommand, self.grid, ItemTypeGrid);
    ADD_COMMAND(command, EditDescCommand, self.opusDesc, ItemTypeNo);
    ADD_COMMAND(command, DrawToCommand, self.drawToUser, ItemTypeNo);
    ADD_COMMAND(command, HelpCommand, self.help, ItemTypeNo);
    ADD_COMMAND(command, CopyPaintCommand, self.copyPaintPicker, ItemTypeCopyPaint);
    ADD_COMMAND(command, ShowCopyPaintCommand, self.copyPaint, ItemTypeCopyPaint);
    
    [toolCmdManager updateDrawInfo:self.drawView.drawInfo];
    [toolCmdManager updateDrawView:self.drawView];
    
}

- (void)updateWithDrawInfo:(DrawInfo *)drawInfo
{

}

+ (id)createViewWithDrawView:(DrawView *)drawView
{
    DrawToolUpPanel *panel = [UIView createViewWithXibIdentifier:@"DrawToolUpPanel"];
    panel.drawView = drawView;
    [panel updateView];
    [panel updateWithDrawInfo:drawView.drawInfo];
    return panel;
    
}


- (void)updateDrawToUser:(MyFriend *)user
{
    NSURL *URL = [NSURL URLWithString:user.avatar];
    [[SDWebImageManager sharedManager] downloadWithURL:URL delegate:URL options:0 success:^(UIImage *image, BOOL cached) {
        image = [UIImage shrinkImage:image withRate:0.8];
        [self.drawToUser setImage:image forState:UIControlStateNormal];
        [self.drawToUser setTitle:user.nickName forState:UIControlStateNormal];
    } failure:^(NSError *error) {
        
    }];

    [self.drawToUserNickNameLabel setText:user.nickName];
}

- (void)updateView
{
    self.layer.cornerRadius = 8;
    self.layer.masksToBounds = YES;
    [self registerToolCommands];
    [self.grid setSelected:NO];
    [self.canvasSize setTitle:NSLS(@"kSize") forState:UIControlStateNormal];
    [self.drawBg setTitle:NSLS(@"kBackground") forState:UIControlStateNormal];
    [self.copyPaintLabel setText:NSLS(@"kCopyPaint")];
    [self.opusDesc setTitle:NSLS(@"kDescription") forState:UIControlStateNormal];
    [self.drawToUserNickNameLabel setText:NSLS(@"kDrawTo")];
    [self.grid setTitle:NSLS(@"kGrid") forState:UIControlStateNormal];
    [self.help setTitle:NSLS(@"kScaleHelp") forState:UIControlStateNormal];
    [self.subject setTitle:NSLS(@"kSubject") forState:UIControlStateNormal];
    
}
- (IBAction)clickTool:(id)sender
{
    [toolCmdManager hideAllPopTipViews];
    [[toolCmdManager commandForControl:sender] execute];
    
    if (sender != self.canvasSize) {
        [self disappear];
    }
}

- (void)disappear
{
    CMPopTipView *pop = (CMPopTipView *)[self superview];
    if ([pop isKindOfClass:[CMPopTipView class]]) {
        [pop dismissAnimated:YES];
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

- (void)updateCopyPaint:(UIImage*)aPhoto
{
    UIImage* image = [UIImage shrinkImage:aPhoto withRate:0.8];
    [self.copyPaint setImage:image forState:UIControlStateNormal];
    [self.copyPaintPicker setHidden:NO];
}


@end
