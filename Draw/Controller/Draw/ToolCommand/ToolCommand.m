//
//  ToolCommand.m
//  Draw
//
//  Created by gamy on 13-3-25.
//
//

#import "ToolCommand.h"
#import "UserGameItemManager.h"
#import "BuyItemView.h"
#import "BalanceNotEnoughAlertView.h"

@implementation ToolCommand


- (id)initWithButton:(UIControl *)control itemType:(ItemType)itemType
{
    self = [super init];
    if (self) {
        self.control = control;
        self.itemType = itemType;
    }
    return self;
}

- (UIView *)thePPTopView
{
    UIView *view = self;
    while (view.superview != nil) {
        view = view.superview;
    }
    return view;
}

- (BOOL)canUseItem:(ItemType)type
{
    if (type == ItemTypeNo || [[UserGameItemManager defaultManager] hasItem:type]) {
        return YES;
    }
    
    __block typeof(self) cp = self;
    
    [BuyItemView showOnlyBuyItemView:type inView:[self thePPTopView] resultHandler:^(int resultCode, int itemId, int count, NSString *toUserId) {
        if (resultCode == ERROR_SUCCESS) {
            [cp buyItemSuccess:itemId result:resultCode];
        }else if (resultCode == ERROR_BALANCE_NOT_ENOUGH) {
            [BalanceNotEnoughAlertView showInController:cp.controller];
        }
    }];

    
    return NO;
}

- (BOOL)excute
{
    if ([self canUseItem:self.itemType]) {

        return YES;
    }
    return NO;
}
- (void)showPopTipView
{
    
}
- (void)hidePopTipView
{
    
}
- (void)finish
{
    [self hidePopTipView];
}

//need to be override by the sub classes
- (UIView *)contentView
{
    return nil;
}

@end
