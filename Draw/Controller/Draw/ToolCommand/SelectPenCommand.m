//
//  SelectPenCommand.m
//  Draw
//
//  Created by gamy on 13-3-25.
//
//

#import "SelectPenCommand.h"
#import "UserGameItemManager.h"
#import "Item.h"

@implementation SelectPenCommand

- (BOOL)popupPenView
{
    int *list = [[UserGameItemManager defaultManager] boughtPenTypeList];
    while (list != NULL && *list != ItemTypeListEndFlag) {
        if (*list != Pencil) {
            return YES;
        }
        ++ list;
    }
    return NO;
}

- (BOOL)execute
{
    if ([super execute]) {
        [self updatePenWithPenType:self.itemType];
        if ([self popupPenView] != 0) {
            [self showPopTipView];
        }
        return YES;
    }
    return NO;
}


- (UIView *)contentView
{
    PenBox *penBox = [PenBox createViewWithdelegate:self];
    penBox.delegate = self;
    return penBox;
}

- (void)updateControlView
{
    [self.control setSelected:YES];
    UIButton *button = (UIButton *)self.control;
    [button setImage:[Item imageForItemType:self.itemType] forState:UIControlStateNormal];
    [button setImage:[Item seletedPenImageForType:self.itemType] forState:UIControlStateSelected];
}

- (void)updatePenWithPenType:(ItemType)type
{
    [self hidePopTipView];
    [self becomeActive];
    self.itemType = type;
    [self.toolHandler changeInPenType:self.itemType];
    [self updateControlView];
}

- (id)initWithControl:(UIControl *)control itemType:(ItemType)itemType
{
    self = [super initWithControl:control itemType:itemType];
    if (self) {
        [self updateControlView];
    }
    return self;
}


- (void)hidePopTipView
{
    [super hidePopTipView];
    [self.control setSelected:NO];
}

- (void)buyItemSuccessfully:(ItemType)type
{
    [self updatePenWithPenType:type];
}


- (void)sendAnalyticsReport
{
    AnalyticsReport(DRAW_CLICK_PEN);
}

#pragma mark-- pen box delegate

- (void)penBox:(PenBox *)penBox didSelectPen:(ItemType)penType penImage:(UIImage *)image
{
    if ([self canUseItem:penType]) {
        [self updatePenWithPenType:penType];
    }
}
@end
