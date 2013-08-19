
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

typedef enum{
    UPPanelCellTypeSize = 0,
    UPPanelCellTypeBG,
    UPPanelCellTypeCopy,
    UPPanelCellTypeDesc,
    UPPanelCellTypeDrawTo,
    UPPanelCellTypeGrid,
    UPPanelCellTypeHelp,
    UPPanelCellTypeSubject,
    UPPanelCellTypeNumber
    
}UPPanelCellType;

@implementation DrawToolUpPanelCell

+ (id)createCell:(id)delegate
{
    NSInteger index = (ISIPAD ? 2 : 1);
    DrawToolUpPanelCell * cell = [UIView createViewWithXibIdentifier:@"ToolUpPanel" ofViewIndex:index];
    cell.delegate = delegate;
    cell.accessButton.hidden = YES;
    return cell;
}

+ (NSString*)getCellIdentifier
{
    return @"DrawToolUpPanelCell";
}

#define IMAGE(x) [UIImage imageNamed:x]
#define KEY(x) (@(x))

+ (UIImage *)imageForType:(UPPanelCellType)type
{
     NSDictionary *imageNameDict =
  @{KEY(UPPanelCellTypeSize): @"draw_up_panel_canvas_btn@2x.png",
    KEY(UPPanelCellTypeBG): @"draw_up_panel_background@2x.png",
    KEY(UPPanelCellTypeCopy): @"draw_up_panel_copy_paint_btn@2x.png",
    KEY(UPPanelCellTypeDesc): @"draw_up_panel_edit_btn@2x.png",
    KEY(UPPanelCellTypeDrawTo): @"draw_up_panel_draw_to_btn@2x.png",
    KEY(UPPanelCellTypeGrid): @"draw_up_panel_blocks@2x.png",
    KEY(UPPanelCellTypeHelp): @"draw_up_panel_help_btn_@2x.png",
    };
    NSString *name = [imageNameDict objectForKey:@(type)];
    return name ? IMAGE(name) : nil;
    
}
+ (NSString *)titleForType:(UPPanelCellType)type
{
        NSDictionary *titleDict = @{KEY(UPPanelCellTypeSize): NSLS(@"kSize"),
      KEY(UPPanelCellTypeBG): NSLS(@"kBackground"),
      KEY(UPPanelCellTypeCopy): NSLS(@"kCopyPaint"),
      KEY(UPPanelCellTypeDesc): NSLS(@"kDescription"),
      KEY(UPPanelCellTypeDrawTo): NSLS(@"kDrawTo"),
      KEY(UPPanelCellTypeGrid): NSLS(@"kGrid"),
      KEY(UPPanelCellTypeHelp): NSLS(@"kScaleHelp"),
//      KEY(UPPanelCellTypeSubject): NSLS(@"kSubject"),
      KEY(UPPanelCellTypeSubject): NSLS(@"kDefaultDrawWord")
      };
    return [titleDict objectForKey:@(type)];
}

- (void)updateIcon:(UIImage *)image
{
    [self.icon setImage:image];
}

-(void)updateTitle:(NSString *)title
{
    [self.titleLabel setText:title];
}


- (void)updateWithType:(UPPanelCellType)type
{
    self.type = type;
    [self updateIcon:[DrawToolUpPanelCell imageForType:type]];
    [self updateTitle:[DrawToolUpPanelCell titleForType:type]];
    if (type == UPPanelCellTypeSubject) {
        [self.icon setHidden:YES];
        [self.subject setHidden:NO];
        [self.subject setText:NSLS(@"kSubject")];

    }else{
        [self.icon setHidden:NO];
        [self.subject setHidden:YES];
    }
}

+ (DrawToolUpPanelCell *)cellForType:(UPPanelCellType)type delegate:(id)delegate
{
    DrawToolUpPanelCell *cell = [DrawToolUpPanelCell createCell:delegate];
    [cell updateWithType:type];
    return cell;
}

- (void)dealloc {
    [_control release];
    [_icon release];
    [_titleLabel release];
    [_accessButton release];
    [_subject release];
    [super dealloc];
}
- (IBAction)clickAccessButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didClickAccessor:atCell:)]) {
        [self.delegate didClickAccessor:sender
                                   atCell:self];
    }
}

- (IBAction)clickControl:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didClickCellControl:atCell:)]) {
        [self.delegate didClickCellControl:sender
                               atCell:self];
    }
}



@end

@interface DrawToolUpPanel () {
    NSInteger _retainTime;
    DrawColorManager *drawColorManager;
    ToolCommandManager *toolCmdManager;
    NSUInteger _commandVersion;
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
    PPRelease(cellDict);
    PPRelease(_tableView);
    [super dealloc];
}

#define ADD_COMMAND(cmd, cls, cellType, it)\
control = [self controlForType:cellType];\
cmd = [[[cls alloc] initWithControl:control itemType:it] autorelease];\
[toolCmdManager registerCommand:command];\
[cmd setToolPanel:self];


- (UIControl *)controlForType:(UPPanelCellType)type
{
    DrawToolUpPanelCell *cell = [cellDict objectForKey:@(type)];
    return cell.control;
}


- (void)registerToolCommands
{

    toolCmdManager = [ToolCommandManager defaultManager];
    
    ToolCommand *command;
    UIControl *control;
    ADD_COMMAND(command, DrawBgCommand, UPPanelCellTypeBG, ItemTypeNo);
    ADD_COMMAND(command, CanvasSizeCommand, UPPanelCellTypeSize, ItemTypeNo);
    ADD_COMMAND(command, GridCommand, UPPanelCellTypeGrid, ItemTypeGrid);
    ADD_COMMAND(command, EditDescCommand, UPPanelCellTypeDesc, ItemTypeNo);
    ADD_COMMAND(command, DrawToCommand, UPPanelCellTypeDrawTo, ItemTypeNo);
    ADD_COMMAND(command, HelpCommand, UPPanelCellTypeHelp, ItemTypeNo);
    ADD_COMMAND(command, CopyPaintCommand, UPPanelCellTypeCopy, ItemTypeCopyPaint);
    

    //TODO register Show copy paint command
    DrawToolUpPanelCell *cell = [cellDict objectForKey:@(UPPanelCellTypeCopy)];
    control = cell.accessButton;
    command = [[[ShowCopyPaintCommand alloc] initWithControl:control itemType:ItemTypeCopyPaint] autorelease];
    [toolCmdManager registerCommand:command];
    [command setToolPanel:self];
    

    [toolCmdManager updateDrawInfo:self.drawView.drawInfo];
    [toolCmdManager updateDrawView:self.drawView];
    
}

- (void)updateWithDrawInfo:(DrawInfo *)drawInfo
{

}

+ (id)createViewWithDrawView:(DrawView *)drawView
{
    DrawToolUpPanel *panel = [self createViewWithXibIdentifier:@"ToolUpPanel" ofViewIndex:0];
    if (ISIPAD) {
        CGRect frame = panel.frame;
        frame.size = CGSizeMake(CGRectGetWidth(frame)/2, CGRectGetHeight(frame)/2);
    }
    panel.drawView = drawView;
    [panel updateView];
    [panel updateWithDrawInfo:drawView.drawInfo];
    return panel;
    
}


- (void)updateDrawToUser:(MyFriend *)user
{
    DrawToolUpPanelCell *cell = [cellDict objectForKey:@(UPPanelCellTypeDrawTo)];
    NSURL *URL = [NSURL URLWithString:user.avatar];
    [[SDWebImageManager sharedManager] downloadWithURL:URL delegate:URL options:0 success:^(UIImage *image, BOOL cached) {
        image = [UIImage shrinkImage:image withRate:0.8];
        [cell updateIcon:image];
    } failure:NULL];
    [cell updateTitle:user.nickName];
    
}

- (void)updateTableView
{
    if ([cellDict count] == 0) {
        cellDict = [[NSMutableDictionary alloc] initWithCapacity:UPPanelCellTypeNumber];
        for (int i = 0; i < UPPanelCellTypeNumber; ++ i) {
            DrawToolUpPanelCell *cell = [DrawToolUpPanelCell cellForType:i delegate:self];
            if (cell) {
                [cellDict setObject:cell forKey:@(i)];
            }
        }
    }
}

- (void)updateView
{
    self.layer.cornerRadius = 8;
    self.layer.masksToBounds = YES;

    [self updateTableView];
    [self registerToolCommands];
    [self.tableView reloadData];
}
- (IBAction)clickTool:(id)sender
{
    [toolCmdManager hideAllPopTipViews];
    [[toolCmdManager commandForControl:sender] execute];
}

- (void)disappear
{
    CMPopTipView *pop = (CMPopTipView *)[self superview];
    if ([pop isKindOfClass:[CMPopTipView class]]) {
        [pop dismissAnimated:YES];
    }
}


- (void)updateCopyPaint:(UIImage*)aPhoto
{
    UIImage* image = [UIImage shrinkImage:aPhoto withRate:0.8];
    DrawToolUpPanelCell *cell = [cellDict objectForKey:@(UPPanelCellTypeCopy)];
    [cell updateIcon:image];
    [cell.accessButton setHidden:(image == nil)];
}


- (void)updateSubject:(NSString *)subject
{
    DrawToolUpPanelCell *cell = [cellDict objectForKey:@(UPPanelCellTypeSubject)];
    [cell updateTitle:subject];
}

#pragma mark- tableView delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [cellDict count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [cellDict objectForKey:@(indexPath.row)];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (ISIPAD ? 62 : 31);
}

#pragma mark- Cell Delegate



- (void)didClickCellControl:(UIControl *)control atCell:(DrawToolUpPanelCell *)cell{
    NSArray *list = @[@(UPPanelCellTypeSize), @(UPPanelCellTypeSubject)];
    if (![list containsObject:@(cell.type)]) {
        [self disappear];
    }
    [[toolCmdManager commandForControl:control] execute];    
}

- (void)didClickAccessor:(UIButton *)accessor atCell:(DrawToolUpPanelCell *)cell{
    [self disappear];
    [[toolCmdManager commandForControl:accessor] execute];
}


@end
