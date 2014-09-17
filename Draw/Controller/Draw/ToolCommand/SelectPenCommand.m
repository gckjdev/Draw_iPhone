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
    int *list = [[UserGameItemManager defaultManager] defaultPenTypeList]; //boughtPenTypeList];
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
    if (self.drawInfo.touchType == TouchActionTypeDraw &&
        self.drawView.shareDrawInfo.penType != Eraser){
        // 如果当前已经是画画模式并且画笔类型不是橡皮擦，则弹出画笔选择提示框
        self.drawInfo.touchType = TouchActionTypeDraw;
        [self updateToolPanel];
        
        if ([super execute]) {
            [self updatePenWithPenType:self.itemType];
            if ([self popupPenView] != 0) {
                [self showPopTipView];
            }
            return YES;
        }
        return NO;
        
    }
    else{
        //否则直接选中画笔
        self.drawInfo.touchType = TouchActionTypeDraw;
        [self updatePenWithPenType:self.drawView.shareDrawInfo.lastPenType];
        return YES;
    }
    
}


- (UIView *)contentView
{
    PenBox *penBox = [PenBox createViewWithdelegate:self];
    penBox.delegate = self;
    return penBox;
}


- (void)updatePenWithPenType:(ItemType)type
{
    [self hidePopTipView];
    self.itemType = type;
    self.drawView.shareDrawInfo.penType = type;
    
    if (type == Quill){
        // fix width
        self.drawView.shareDrawInfo.penWidth = QUILL_PEN_WIDTH;
    }
    
    [self updateToolPanel];
    
}

- (id)initWithControl:(UIControl *)control itemType:(ItemType)itemType
{
    self = [super initWithControl:control itemType:itemType];
    return self;
}


- (void)hidePopTipView
{
    [super hidePopTipView];
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
