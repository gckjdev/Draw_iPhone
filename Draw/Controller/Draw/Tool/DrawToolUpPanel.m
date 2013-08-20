
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



- (void)updateIcon:(UIImage *)image
{
    [self.icon setImage:image];
}

-(void)updateTitle:(NSString *)title
{
    [self.titleLabel setText:title];
}


- (void)updateWithType:(DrawToolType)type
{
    self.type = type;
    [self updateIcon:[PanelUtil imageForType:type]];
    [self updateTitle:[PanelUtil titleForType:type]];
    if (type == DrawToolTypeSubject) {
        [self.icon setHidden:YES];
        [self.subject setHidden:NO];
        [self.subject setText:NSLS(@"kSubject")];

    }else{
        [self.icon setHidden:NO];
        [self.subject setHidden:YES];
    }
}

+ (DrawToolUpPanelCell *)cellForType:(DrawToolType)type delegate:(id)delegate
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


- (UIControl *)controlForType:(DrawToolType)type
{
    DrawToolUpPanelCell *cell = [cellDict objectForKey:@(type)];
    return cell.control;
}


- (void)registerToolCommands
{

    toolCmdManager = [ToolCommandManager defaultManager];
    
    ToolCommand *command;
    UIControl *control;
    ADD_COMMAND(command, DrawBgCommand, DrawToolTypeBG, ItemTypeNo);
    ADD_COMMAND(command, CanvasSizeCommand, DrawToolTypeSize, ItemTypeNo);
    ADD_COMMAND(command, GridCommand, DrawToolTypeGrid, ItemTypeGrid);
    ADD_COMMAND(command, EditDescCommand, DrawToolTypeDesc, ItemTypeNo);
    ADD_COMMAND(command, DrawToCommand, DrawToolTypeDrawTo, ItemTypeNo);
    ADD_COMMAND(command, HelpCommand, DrawToolTypeHelp, ItemTypeNo);
    ADD_COMMAND(command, CopyPaintCommand, DrawToolTypeCopy, ItemTypeCopyPaint);
    

    //TODO register Show copy paint command
    DrawToolUpPanelCell *cell = [cellDict objectForKey:@(DrawToolTypeCopy)];
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
    DrawToolUpPanelCell *cell = [cellDict objectForKey:@(DrawToolTypeDrawTo)];
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
        cellDict = [[NSMutableDictionary alloc] initWithCapacity:DrawToolTypeNumber];
        for (int i = 0; i < DrawToolTypeNumber; ++ i) {
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
    DrawToolUpPanelCell *cell = [cellDict objectForKey:@(DrawToolTypeCopy)];
    [cell updateIcon:image];
    [cell.accessButton setHidden:(image == nil)];
}


- (void)updateSubject:(NSString *)subject
{
    DrawToolUpPanelCell *cell = [cellDict objectForKey:@(DrawToolTypeSubject)];
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
    NSArray *list = @[@(DrawToolTypeSize), @(DrawToolTypeSubject)];
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
