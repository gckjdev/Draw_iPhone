//
//  DrawLayerPanel.m
//  Draw
//
//  Created by gamy on 13-8-5.
//
//

#import "DrawLayerPanel.h"

#define CELL_ID @"DrawLayerPanelCell"

@implementation DrawLayerPanelCell

+ (id)cell:(id<DrawLayerPanelCellDelegate>)delegate
{
    DrawLayerPanelCell* cell = [DrawLayerPanelCell createViewWithXibIdentifier:@"DrawLayerPanel" ofViewIndex:0];
    cell.delegate = delegate;
    return cell;
}

- (void)onlyShowViews:(NSArray *)views
{
    NSArray *allViews = @[
                             self.showFlag,
                             self.layerName,
                             self.remove,
                             self.help,
                             self.add,
                             self.swap
                             ];
    
    for (UIView *view in allViews) {
        [view setHidden:![views containsObject:view]];
    }

}


- (void)updateWithDrawLayer:(DrawLayer *)layer
{
    self.drawLayer = layer;
    [self.layerName setTitle:layer.layerName forState:UIControlStateNormal];
    [self onlyShowViews: @[self.showFlag, self.layerName, self.remove]];
    [self.showFlag setSelected:self.drawLayer.hidden];
}


- (void)updateForSwapCell
{
    [self onlyShowViews:@[self.swap]];
}

- (void)updateForAddCell
{
    [self onlyShowViews:@[self.add]];
}

- (void)updateForHelpCell
{
    [self onlyShowViews:@[self.help]];
}

- (void)dealloc {
    [_showFlag release];
    [_help release];
    [_add release];
    [_layerName release];
    [_remove release];
    [_swap release];
    [super dealloc];
}
- (IBAction)clickShowFlag:(id)sender {
    [self.drawLayer setHidden:!self.drawLayer.hidden];
    [sender setSelected:self.drawLayer.hidden];
}

- (IBAction)clickRemove:(id)sender {
    [self.delegate drawLayerPanelCell:self didClickRemoveAtDrawLayer:self.drawLayer];
}

- (IBAction)clickName:(id)sender {
    [self.delegate drawLayerPanelCell:self
                         didClickName:self.drawLayer.layerName
                          onDrawLayer:self.drawLayer];
}

- (IBAction)clickAdd:(id)sender {
    [self.delegate didClickAddAtCell:self];
}

- (IBAction)clickHelp:(id)sender {
    [self.delegate didClickHelpAtCell:self];
}

- (IBAction)clickSwap:(id)sender {
    [self.delegate didClickSwapAtCell:self];
}
@end


#define BASIC_ROW_COUNT 2

@interface DrawLayerPanel()
{
    int RowOfAdd;
    int RowOfHelp;
    int RowOfSwap;
}

@end



@implementation DrawLayerPanel

+ (id)drawLayerPanelWithDrawLayerManager:(DrawLayerManager *)dlManager
{
    DrawLayerPanel *panel = [DrawLayerPanel createViewWithXibIdentifier:@"DrawLayerPanel" ofViewIndex:1];
    panel.dlManager = dlManager;
    [panel updateRows];
    return panel;
}

//- (void)awakeFromNib
//{
//    [self updateRows];
//}
- (void)dealloc
{
    [_tableView release];
    [super dealloc];
}

- (void)updateRows
{
    RowOfAdd = [[self.dlManager layers] count];
    RowOfHelp = RowOfAdd + 1;
    RowOfSwap = RowOfHelp + 1;    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.dlManager layers] count] + BASIC_ROW_COUNT;
}

- (DrawLayer *)layerOfIndexPath:(NSIndexPath *)indexPath
{
    NSInteger count = [[_dlManager layers] count];
    if (indexPath.row < count) {
        return [[_dlManager layers] objectAtIndex:indexPath.row];
    }
    return nil;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DrawLayerPanelCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID];
    if (cell == nil) {
        cell = [DrawLayerPanelCell cell:self];
    }
    cell.drawLayer = nil;
    if (indexPath.row == RowOfAdd)
        [cell updateForAddCell];
    else if(indexPath.row == RowOfHelp)
        [cell updateForHelpCell];
    else if(indexPath.row == RowOfSwap)
        [cell updateForSwapCell];
    else
        [cell updateWithDrawLayer:[self layerOfIndexPath:indexPath]];

    if (cell.drawLayer && cell.drawLayer == _dlManager.selectedLayer) {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    
    return cell;

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger layerCount = [[_dlManager layers] count];
    
    if (indexPath.row < layerCount) {
        DrawLayer *layer = [self layerOfIndexPath:indexPath];
        [_dlManager setSelectedLayer:layer];
    }
}

-(void)drawLayerPanelCell:(DrawLayerPanelCell *)cell
             didClickName:(NSString *)name
              onDrawLayer:(DrawLayer *)layer
{
    PPDebug(@"<didClickName> name = %@", layer.layerName);
}

-(void)didClickHelpAtCell:(DrawLayerPanelCell *)cell
{
    PPDebug(@"<didClickHelpAtCell>");
}
-(void)didClickAddAtCell:(DrawLayerPanelCell *)cell
{
    PPDebug(@"<didClickAddAtCell>");
    DrawLayer *layer = [DrawLayer layerWithLayer:[_dlManager selectedLayer]
                                           frame:[[_dlManager selectedLayer] bounds]];

    layer.layerTag = rand();
    layer.layerName = [@(layer.layerTag) stringValue];
    [_dlManager addLayer:layer];
    
    [self updateRows];
    [self.tableView reloadData];
}

-(void)didClickSwapAtCell:(DrawLayerPanelCell *)cell
{
    if ([[_dlManager layers] count] > 1) {
        DrawLayer *l1 = [[_dlManager layers] objectAtIndex:0];
        DrawLayer *l2 = [[_dlManager layers] lastObject];
        [_dlManager moveLayer:l2 below:l1];
        [self updateRows];
        [self.tableView reloadData];
    }
}

-(void)drawLayerPanelCell:(DrawLayerPanelCell *)cell
didClickRemoveAtDrawLayer:(DrawLayer *)layer
{
    [_dlManager removeLayer:layer];
    [self updateRows];
    [self.tableView reloadData];    
}
@end
