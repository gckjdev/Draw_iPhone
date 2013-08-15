//
//  DrawLayerPanel.m
//  Draw
//
//  Created by gamy on 13-8-5.
//
//

#import "DrawLayerPanel.h"
#import "CMPopTipView.h"
#import "PPViewController.h"
#import "CommonDialog.h"
#import "InputDialog.h"
#import "ShareImageManager.h"

#define CELL_ID @"DrawLayerPanelCell"

@implementation DrawLayerPanelCell

- (void)handleDoubleTap:(UITapGestureRecognizer *)tap
{
    PPDebug(@"<handleDoubleTap> layer name = %@", _drawLayer.layerName);
    InputDialog *dialog = [InputDialog dialogWith:NSLS(@"kEditLayerName") defaultText:_drawLayer.layerName placeHolderText:nil clickOK:^(NSString *inputStr) {
        self.drawLayer.layerName = inputStr;
        [self.layerName setText:inputStr];
    } clickCancel:NULL];
    [dialog setAllowEmpty:NO];
    dialog.maxInputLen = 10;
    [dialog showInView:[self theTopView]];
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}
- (void)updateView
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    tap.delegate = self;
    tap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:tap];
    
    [tap release];
}

+ (id)cell:(id<DrawLayerPanelCellDelegate>)delegate
{
    NSInteger index = (ISIPAD ? 1: 0);
    DrawLayerPanelCell* cell = [DrawLayerPanelCell createViewWithXibIdentifier:@"DrawLayerPanel" ofViewIndex:index];
    cell.delegate = delegate;
    [cell updateView];
    return cell;
}


- (void)updateWithDrawLayer:(DrawLayer *)layer isSelected:(BOOL)selected
{
    if (layer == nil) {
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
    [self.layerName setText:layer.layerName];
    [self.showFlag setSelected:self.drawLayer.isHidden];
    [self.remove setHidden:![layer canBeRemoved]];
    [self.layerName setTextColor:COLOR_COFFEE];
    if (selected) {
        [self.bgView setBackgroundColor:COLOR_GREEN1];
    }else{
        [self.bgView setBackgroundColor:COLOR_WHITE];
    }
}


- (void)dealloc {
    PPDebug(@"%@ dealloc", [self class]);
    [_showFlag release];
    [_layerName release];
    [_remove release];
    [_bgView release];
    [super dealloc];
}
- (IBAction)clickShowFlag:(id)sender {
    
    if (self.drawLayer.isHidden || ([self.delegate canHidenLayer:self.drawLayer])) {
        [self.drawLayer setHidden:!self.drawLayer.isHidden];
        [sender setSelected:self.drawLayer.isHidden];
    }else{
        [(PPViewController *)[self theViewController] popupUnhappyMessage:NSLS(@"kMainLayerCannotHiden") title:nil];
    }
    
}

- (IBAction)clickRemove:(id)sender {
    
    [[CommonDialog createDialogWithTitle:NSLS(@"kTips") message:NSLS(@"kDeleteDrawLayer") style:CommonDialogStyleDoubleButton delegate:nil clickOkBlock:^{
        [self.delegate drawLayerPanelCell:self didClickRemoveAtDrawLayer:self.drawLayer];
    } clickCancelBlock:NULL] showInView:[self theTopView]];
    

}


@end


@interface DrawLayerPanel()
{
    
}

@end



@implementation DrawLayerPanel


- (void)updateAlphaLabelWithValue:(CGFloat)value
{
    NSString *v = [NSString stringWithFormat:@"%.0f%%",value*100];
    [self.alphaLabel setText:v];
}

- (void)drawSlider:(DrawSlider *)drawSlider didValueChange:(CGFloat)value
{
    [[_dlManager selectedLayer] setOpacity:value];
    [self updateAlphaLabelWithValue:value];

}
- (void)drawSlider:(DrawSlider *)drawSlider didStartToChangeValue:(CGFloat)value
{
    [[_dlManager selectedLayer] setOpacity:value];
    [self updateAlphaLabelWithValue:value];
}
/*
- (void)drawSlider:(DrawSlider *)drawSlider didFinishChangeValue:(CGFloat)value
{
    [[_dlManager selectedLayer] setOpacity:value];
    [self updateAlphaLabelWithValue:value];
}
 */


- (void)updateView
{
    
    self.layer.cornerRadius = 8;
    [self.layer setMasksToBounds:YES];
    
    self.recognizer = [self.tableView enableGestureTableViewWithDelegate:self];
    CGRect frame = self.alphaSlider.frame;
    CGFloat alpha = [[_dlManager selectedLayer] opacity];
    UIViewAutoresizing mark = self.alphaSlider.autoresizingMask;
    [self.alphaTitle setText:NSLS(@"kColorAlpha")];
    [self.alphaSlider removeFromSuperview];
    self.alphaSlider = [DrawSlider sliderWithMaxValue:1 minValue:0 defaultValue:alpha delegate:self];
    [self updateAlphaLabelWithValue:alpha];
    self.alphaSlider.autoresizingMask = mark;
    self.alphaSlider.center = CGRectGetCenter(frame);
    [self addSubview:self.alphaSlider];
    [self reloadView];
}

+ (id)drawLayerPanelWithDrawLayerManager:(DrawLayerManager *)dlManager
{
    NSInteger index = (ISIPAD ?  3 : 2);
    DrawLayerPanel *panel = [DrawLayerPanel createViewWithXibIdentifier:@"DrawLayerPanel" ofViewIndex:index];
    panel.dlManager = dlManager;
    [panel updateView];
    return panel;
}

- (void)dealloc
{
    PPDebug(@"%@ dealloc", [self class]);
    [_tableView release];
    [_help release];
    [_add release];
    PPRelease(_grabbedObject);
    PPRelease(_recognizer);
    [_alphaSlider release];
    [_alphaLabel release];
    [_alphaTitle release];
    [super dealloc];
}


#define TRANSLATE_ROW(row) row //([[_dlManager layers] count] - (row+1))

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
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    cell.drawLayer = nil;
 
    DrawLayer *layer = [self layerOfIndexPath:indexPath];
    if (layer == self.grabbedObject) {
        layer = nil;
    }
    [cell updateWithDrawLayer:layer isSelected:layer == _dlManager.selectedLayer];

    return cell;

}

#define CELL_HEIGHT (ISIPAD ? 80 : 40)

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger layerCount = [[_dlManager layers] count];
    
    if (indexPath.row < layerCount) {
        DrawLayer *layer = [self layerOfIndexPath:indexPath];
        if (!layer.isHidden) {
            [_dlManager setSelectedLayer:layer];
            [[self alphaSlider] setValue:layer.opacity];
            [self updateAlphaLabelWithValue:layer.opacity];
            [self.tableView reloadData];
        }else{
            [(PPViewController *)[self theViewController] popupUnhappyMessage:NSLS(@"kHidenLayerCannotBeSelected") title:nil];
        }
    }
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

    [_dlManager genLayerTagAndName:layer];
    [_dlManager addLayer:layer];
    [self reloadView];
}

- (IBAction)clickHelp:(id)sender {

}



- (void)reloadView
{
 
    CMPopTipView *superView = (id)self.superview;
    CGFloat height = [[_dlManager layers] count] * CELL_HEIGHT + (CELL_HEIGHT * 3);
    
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

#pragma mark DrawLayer Cell Delegate
- (BOOL)canHidenLayer:(DrawLayer *)layer
{
    return [_dlManager selectedLayer] != layer;
}

#pragma mark JTTableViewGestureRecognizer Delegate
- (BOOL)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsCreatePlaceholderForRowAtIndexPath:(NSIndexPath *)indexPath {
    PPDebug(@"<needsCreatePlaceholderForRowAtIndexPath> at row = %d",indexPath.row);
    self.grabbedObject = [self layerOfIndexPath:indexPath];
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsMoveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
    PPDebug(@"<needsMoveRowAtIndexPath> from row = %d, to row = %d",sourceIndexPath.row, destinationIndexPath.row);
    
    id object = [self layerOfIndexPath:sourceIndexPath];
    [(NSMutableArray *)[_dlManager layers] removeObjectAtIndex:TRANSLATE_ROW(sourceIndexPath.row)];
    [(NSMutableArray *)[_dlManager layers] insertObject:object atIndex:TRANSLATE_ROW(destinationIndexPath.row)];

}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsReplacePlaceholderForRowAtIndexPath:(NSIndexPath *)indexPath {
    PPDebug(@"<needsReplacePlaceholderForRowAtIndexPath> at row = %d",indexPath.row);
    [(NSMutableArray *)[_dlManager layers] replaceObjectAtIndex:TRANSLATE_ROW(indexPath.row) withObject:self.grabbedObject];
    self.grabbedObject = nil;
    [self.dlManager reload];
}


@end
