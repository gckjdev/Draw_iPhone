//
//  ShapeBox.m
//  Draw
//
//  Created by gamy on 13-2-26.
//
//

#import "ShapeBox.h"
#import "UIViewUtils.h"

@interface ShapeBox()
{
    
}

- (IBAction)selectShape:(UIButton *)sender;
- (IBAction)close:(id)sender;


@end

@implementation ShapeBox

+ (id)shapeBoxWithDelegate:(id<ShapeBoxDelegate>)delegate
{
    ShapeBox *box = [UIView createViewWithXibIdentifier:@"ShapeBox"];
    box.delegate = delegate;
    return box;
}


- (void)dismiss
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(dismissShapeBox:)]) {
        [self.delegate dismissShapeBox:self];
    }
}

- (IBAction)selectShape:(UIButton *)sender {
    sender.selected = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(shapeBox:didSelectShapeType:)]) {
        [self.delegate shapeBox:self didSelectShapeType:sender.tag];
    }
    [self dismiss];
}


- (IBAction)close:(id)sender {
    [self dismiss];
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
