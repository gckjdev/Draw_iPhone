//
//  SelectPenCommand.m
//  Draw
//
//  Created by gamy on 13-3-25.
//
//

#import "SelectPenCommand.h"

@implementation SelectPenCommand

- (BOOL)execute
{
    if ([super execute]) {
        [self updatePenWithPenType:self.itemType];
        [self showPopTipView];
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

- (void)updatePenWithPenType:(ItemType)type
{
    [self becomeActive];
    self.itemType = type;
//    [self.toolHandler enterDrawMode];
    [self.toolHandler changeInPenType:self.itemType];

    [self hidePopTipView];
    
    
    //TODO update Pen view
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
