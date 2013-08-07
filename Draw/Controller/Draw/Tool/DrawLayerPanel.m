//
//  DrawLayerPanel.m
//  Draw
//
//  Created by gamy on 13-8-5.
//
//

#import "DrawLayerPanel.h"
#import "CMPopTipView.h"
#define CELL_ID @"DrawLayerPanelCell"

@implementation DrawLayerPanelCell

+ (id)cell:(id<DrawLayerPanelCellDelegate>)delegate
{
    DrawLayerPanelCell* cell = [DrawLayerPanelCell createViewWithXibIdentifier:@"DrawLayerPanel" ofViewIndex:0];
    cell.delegate = delegate;
    return cell;
}

//- (void)onlyShowViews:(NSArray *)views
//{
//    NSArray *allViews = @[
//                             self.showFlag,
//                             self.layerName,
//                             self.remove,
//                             ];
//    
//    for (UIView *view in allViews) {
//        [view setHidden:![views containsObject:view]];
//    }
//
//}


- (void)updateWithDrawLayer:(DrawLayer *)layer
{
    if (![layer isKindOfClass:[DrawLayer class]]) {
        self.drawLayer = nil;
        for (UIView *view in self.subviews) {
            view.hidden = YES;
        }
        return;
    }
    for (UIView *view in self.subviews) {
        view.hidden = NO;
    }

    self.drawLayer = layer;
    [self.layerName setTitle:layer.layerName forState:UIControlStateNormal];
    [self.showFlag setSelected:self.drawLayer.hidden];
}




- (void)dealloc {
    [_showFlag release];
    [_layerName release];
    [_remove release];
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

@end


@interface DrawLayerPanel()
{
    
}

@end



@implementation DrawLayerPanel

+ (id)drawLayerPanelWithDrawLayerManager:(DrawLayerManager *)dlManager
{
    DrawLayerPanel *panel = [DrawLayerPanel createViewWithXibIdentifier:@"DrawLayerPanel" ofViewIndex:1];
    panel.dlManager = dlManager;
    [panel reloadView];
    [panel.tableView enableGestureTableViewWithDelegate:panel];
    return panel;
}

- (void)dealloc
{
    [_tableView release];
    [_help release];
    [_add release];    
    [super dealloc];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.dlManager layers] count];
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
    [cell updateWithDrawLayer:[self layerOfIndexPath:indexPath]];
    if (cell.drawLayer && cell.drawLayer == _dlManager.selectedLayer) {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    
    return cell;

}

#define CELL_HEIGHT 45

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT;
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



-(void)drawLayerPanelCell:(DrawLayerPanelCell *)cell
didClickRemoveAtDrawLayer:(DrawLayer *)layer
{
    [_dlManager removeLayer:layer];
    [self reloadView];
}

- (IBAction)clickAdd:(id)sender {
    PPDebug(@"<didClickAddAtCell>");
    DrawLayer *layer = [DrawLayer layerWithLayer:[_dlManager selectedLayer]
                                           frame:[[_dlManager selectedLayer] bounds]];
    
    layer.layerTag = rand();
    layer.layerName = [@(layer.layerTag) stringValue];
    [_dlManager addLayer:layer];
    [self reloadView];
}

- (IBAction)clickHelp:(id)sender {

}



- (void)reloadView
{
 
    CMPopTipView *superView = (id)self.superview;
    CGFloat height = [[_dlManager layers] count] * CELL_HEIGHT + (CELL_HEIGHT * 2);
    
    CGFloat x = height - CGRectGetHeight(self.bounds);
    
    NSTimeInterval interval = 0;
    if (superView) {
        interval = 0.3;
    }
    
    [UIView animateWithDuration:interval animations:^{        
        if ([superView isKindOfClass:[CMPopTipView class]]) {
            superView.noAdjustCustomViewFrame = YES;
            [superView updateHeight:CGRectGetHeight(superView.bounds) + x];
        }        
        [self updateHeight:height];

    }];
    
    [self.tableView reloadData];
}


- (BOOL)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsCreatePlaceholderForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.grabbedObject = [self layerOfIndexPath:indexPath];
    [(NSMutableArray *)[_dlManager layers] replaceObjectAtIndex:indexPath.row withObject:@""];
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsMoveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    id object = [self layerOfIndexPath:sourceIndexPath];
    [(NSMutableArray *)[_dlManager layers] removeObjectAtIndex:sourceIndexPath.row];
    [(NSMutableArray *)[_dlManager layers] insertObject:object atIndex:destinationIndexPath.row];

}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsReplacePlaceholderForRowAtIndexPath:(NSIndexPath *)indexPath {
    [(NSMutableArray *)[_dlManager layers] replaceObjectAtIndex:indexPath.row withObject:self.grabbedObject];
    self.grabbedObject = nil;
    [self.dlManager reload];
}


@end
