//
//  ShapeBox.m
//  Draw
//
//  Created by gamy on 13-2-26.
//
//

#import "ShapeBox.h"
#import "UIViewUtils.h"
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import "UIColor+UIColorExt.h"



/*
@interface ShapeBox()
{
    
}

- (IBAction)selectShape:(UIButton *)sender;


@end

@implementation ShapeBox

+ (id)shapeBoxWithDelegate:(id<ShapeBoxDelegate>)delegate
{
    ShapeBox *box = [UIView createViewWithXibIdentifier:@"ShapeBox"];
    box.delegate = delegate;
    return box;
}



- (IBAction)selectShape:(UIButton *)sender {
    sender.selected = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(shapeBox:didSelectShapeType:)]) {
        [self.delegate shapeBox:self didSelectShapeType:sender.tag];
    }
}

- (ShapeType)shapeType
{
    for (UIButton *button in self.subviews) {
        if ([button isKindOfClass:[UIButton class]] && button.isSelected) {
            return button.tag;
        }
    }
    return ShapeTypeNone;
}

- (void)setShapeType:(ShapeType)type
{
    for (UIButton *button in self.subviews) {
        if ([button isKindOfClass:[UIButton class]]) {
            [button setSelected:(button.tag == type)];
        }
    }
}
@end
*/


#import "Draw.pb.h"
#import "UIViewUtils.h"
#import "ImageShapeManager.h"
#import "UIImageView+WebCache.h"
#import "LocaleUtils.h"
#import "CustomInfoView.h"
#import "UserGameItemManager.h"

@interface ShapeBox()
{
    
}
- (IBAction)clickCloseButton:(id)sender;

- (IBAction)changeDrawStyle:(id)sender;


@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) NSArray *dataList;
@property (retain, nonatomic) CustomInfoView *infoView;

@end

BOOL staticStroke = NO;
CGPoint contentOffset;

@implementation ShapeBox

- (void)dismiss
{
    contentOffset = [self.tableView contentOffset];
    [self.infoView dismiss];
    self.infoView.infoView = nil;
    self.infoView = nil;
}

#define FILL_BUTTON_TAG 101
#define STROK_BUTTON_TAG 100
- (id)fillButton
{
    return [self viewWithTag:FILL_BUTTON_TAG];
}

- (id)strokeButton
{
    return [self viewWithTag:STROK_BUTTON_TAG];
}



- (void)updateView
{
    self.dataList = [[ImageShapeManager defaultManager] imageShapeGroupList];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self setBackgroundColor:[UIColor clearColor]];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self setStroke:staticStroke];
    [[self fillButton] setTitle:NSLS(@"kFill") forState:UIControlStateNormal];
    [[self strokeButton] setTitle:NSLS(@"kStroke") forState:UIControlStateNormal];
    [self.tableView setContentOffset:contentOffset animated:YES];
}

+ (id)shapeBoxWithDelegate:(id<ShapeBoxDelegate>)delegate
{
    ShapeBox *box = [UIView createViewWithXibIdentifier:@"ShapeBox"];
    box.delegate = delegate;
    [box updateView];
    return box;
}

- (void)showInView:(UIView *)view
{
    if (self.infoView == nil) {
        __block typeof (self) bself = self;
        self.infoView = [CustomInfoView createWithTitle:NSLS(@"kSelectShape")
                                               infoView:self
                                           closeHandler:^{
                                               contentOffset = [bself.tableView contentOffset];
                                               bself.infoView = nil;
                                           }];
        
        [self.infoView.mainView updateCenterY:(self.infoView.mainView.center.y - (ISIPAD ? 35 : 20))];
    }
    
    [self.infoView showInView:view];
}
- (void)reloadView
{
    [self.tableView reloadData];
}

- (void)setStroke:(BOOL)stroke
{
    staticStroke = stroke;
    [[self strokeButton] setSelected:stroke];
    [[self fillButton] setSelected:!stroke];
}
- (BOOL)isStroke
{
    return staticStroke;
}

- (void)dealloc {
    PPRelease(_infoView);
    PPRelease(_tableView);
    PPRelease(_dataList);
    [super dealloc];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [ShapeGroupCell getCellHeight];
}

- (PBImageShapeGroup *)groupOfIndexPath:(NSIndexPath *)indexPath
{
    PBImageShapeGroup *group = [self.dataList objectAtIndex:indexPath.row];
    return group;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ShapeGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:[ShapeGroupCell getCellIdentifier]];
    if (cell == nil) {
        cell = [ShapeGroupCell createCell:self];
    }
    cell.indexPath = indexPath;
    PBImageShapeGroup *group = [self groupOfIndexPath:indexPath];
    [cell updateCellWithImageShapeGroup:group];
    return cell;
}

- (void)shapeGroupCell:(ShapeGroupCell *)cell didSelectedShape:(ShapeType)shape
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(shapeBox:didSelectedShape:isStroke:groudId:)]){
        PBImageShapeGroup *group = [self groupOfIndexPath:cell.indexPath];
        
        [self.delegate shapeBox:self didSelectedShape:shape isStroke:[self isStroke] groudId:group.groupId];
    }
}
- (IBAction)clickCloseButton:(id)sender {
    [self dismiss];
}



- (IBAction)changeDrawStyle:(id)sender {
//    [self setStroke:![self isStroke]];
    if (sender == [self strokeButton]) {
        [self setStroke:YES];
    }else{
        [self setStroke:NO];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(shapeBox:didChangeDrawStyle:)]) {
        [self.delegate shapeBox:self didChangeDrawStyle:[self isStroke]];
    }
}
@end



////////////////
////////////////




@implementation ShapeGroupCell

#define NAME_LABEL_TAG 10
#define FLAG_BUTTON_TAG 11

- (UILabel *)nameLabel
{
    return (id)[self viewWithTag:NAME_LABEL_TAG];
}

- (UIButton *)flagButton
{
    return (id)[self viewWithTag:FLAG_BUTTON_TAG];
}

- (void)clickButton:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(shapeGroupCell:didSelectedShape:)]) {
        NSInteger index = sender.tag - 1;
        NSNumber *type = [self.group.shapeTypeList objectAtIndex:index];
        [self.delegate shapeGroupCell:self didSelectedShape:type.integerValue];
    }
}

#define BUTTON_TAG_START 1
#define BUTTON_TAG_END 6

+ (id)createCell:(id)delegate
{
    ShapeGroupCell *cell = [UIView createViewWithXibIdentifier:@"ShapeBox" ofViewIndex:1];
    cell.delegate = delegate;
    for (NSInteger i = BUTTON_TAG_START; i <= BUTTON_TAG_END; ++ i) {
        UIButton *button = (id)[cell viewWithTag:i];
        [button setBackgroundColor:[UIColor clearColor]];
        [button addTarget:cell action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        [button.imageView setContentMode:UIViewContentModeScaleAspectFit];
        
    }
    return cell;
}

+ (CGFloat)getCellHeight
{
    return (ISIPAD ? 152 : 75);
}

- (NSString *)nameInList:(NSArray *)list language:(NSString *)language
{
    if ([list count] == 0) {
        return nil;
    }
    NSString *defaultName = nil;
    for (PBLocalizeString *ls in list) {
        if ([[ls languageCode] isEqualToString:language]) {
            return [ls localizedText];
        }else if([[ls languageCode] isEqualToString:@"en"]){
            defaultName = [ls localizedText];
        }
    }
    if (defaultName == nil) {
        defaultName = [[list objectAtIndex:0] localizedText];
    }
    return defaultName;
}

#define MAX_WITH_ITEM_NAME (ISIPAD ? 400 : 200)

- (void)updateName:(PBImageShapeGroup *)group
{
    NSArray *list = [group groupNameList];
    NSString *name = nil;
    if ([LocaleUtils isChinese]) {
        name = [self nameInList:list language:@"zh_Hans"];
    }else{
        name = [self nameInList:list language:@"en"];
    }
    CGSize withinSize = CGSizeMake(MAX_WITH_ITEM_NAME, 19);
    [[self nameLabel] setText:name];
    CGSize size = [name sizeWithFont:[self nameLabel].font constrainedToSize:withinSize lineBreakMode:[self nameLabel].lineBreakMode];
    [[self nameLabel] updateWidth:size.width];
    
    if ([[UserGameItemManager defaultManager] hasItem:group.groupId]) {
        CGFloat originX = CGRectGetMaxX([self nameLabel].frame) + 3;
        
        [[self flagButton] updateOriginX:originX];
        [[self flagButton] setHidden:NO];
        [[self flagButton] setTitle:NSLS(@"kAlreadyBought") forState:UIControlStateNormal];
    }else{
        [[self flagButton] setHidden:YES];
    }
    
}

#define SHAPE_LAYER_TAG @"SHAPE_LAYER_TAG"

- (void)updateCellWithImageShapeGroup:(PBImageShapeGroup *)group
{
    self.group = group;
    NSInteger i = 1;
    [self updateName:group];
    for (NSNumber *type in group.shapeTypeList) {

        UIButton *button = (UIButton *)[self viewWithTag:i];

        for (CAShapeLayer *layer in button.layer.sublayers) {
            if ([[layer valueForKey:SHAPE_LAYER_TAG] length] != 0) {
                [layer removeFromSuperlayer];
            }
        }
        
        UIBezierPath * path = [[ImageShapeManager defaultManager] pathWithType:type.integerValue];
        
        CGSize shapeSize = [ImageShapeInfo defaultImageShapeSize];
        const CGAffineTransform transform = (CGAffineTransformMakeScale(CGRectGetWidth(button.bounds)/shapeSize.width, CGRectGetHeight(button.bounds)/shapeSize.height));
        
        CGPathRef cgPath = CGPathCreateCopyByTransformingPath(path.CGPath, &transform);
        
        
        CAShapeLayer *layer = [CAShapeLayer layer];
        [layer setValue:SHAPE_LAYER_TAG forKey:SHAPE_LAYER_TAG];
        
        layer.frame = button.bounds;//CGRectMake(0, 0, SHAPE_SIZE, SHAPE_SIZE);
        [layer setFillColor:OPAQUE_COLOR(62, 43, 23).CGColor];
        [layer setStrokeColor:OPAQUE_COLOR(62, 43, 23).CGColor];
        [layer setPath:cgPath];
        [layer setLineWidth:2];
        [button.layer addSublayer:layer];
        CGPathRelease(cgPath);
        
        ++ i;
    }
}

+ (NSString *)getCellIdentifier
{
    return @"ShapeGroupCell";
}

@end