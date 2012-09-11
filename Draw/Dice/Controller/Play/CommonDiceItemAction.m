//
//  CommonDiceItemAction.m
//  Draw
//
//  Created by 小涛 王 on 12-9-11.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "CommonDiceItemAction.h"
#import "HKGirlFontLabel.h"
#import "DiceGamePlayController.h"
#import "AccountService.h"

@interface CommonDiceItemAction ()
{
    AccountService *_accountService;
}

@end

@implementation CommonDiceItemAction

@synthesize itemType = _itemType;
@synthesize userManager = _userManager;

- (id)initWithItemType:(int)itemType
{
    if (self = [super init]) {
        self.itemType = itemType;
        self.userManager = [UserManager defaultManager];
        _accountService = [AccountService defaultService];
    }
    
    return self;
}

- (void)showNameAnimation:(NSString*)userId
                 itemType:(int)itemType
               controller:(DiceGamePlayController *)controller
                     view:(UIView *)view
{
    HKGirlFontLabel *label = [[[HKGirlFontLabel alloc] initWithFrame:CGRectMake(0, 0, 70, 70) pointSize:50] autorelease];
    label.text = [Item nameForItemType:itemType];
    label.textAlignment = UITextAlignmentCenter;
    label.center = view.center;
    
    [view addSubview:label];
    
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
        label.center = [[controller bellViewOfUser:userId] center];
        label.transform = CGAffineTransformMakeScale(0.3, 0.3);
        label.alpha = 0.3;
    } completion:^(BOOL finished) {
        [label removeFromSuperview];
    }];
}

- (void)hanleItemResponse:(DiceGamePlayController *)controller
        view:(UIView *)view
{
    [_accountService consumeItem:[self itemType] amount:1]; 
    
    if ([self isShowNameAnimation]) {
        [self showNameAnimation:_userManager.userId
                       itemType:[self itemType]
                     controller:controller
                           view:view];
    }
    
    [self useItemSuccess:controller view:view ];
}

- (void)hanleItemRequest:(NSString *)userId
              controller:(DiceGamePlayController *)controller
                    view:(UIView *)view
{
    if ([self isShowNameAnimation]) {
        [self showNameAnimation:userId 
                       itemType:[self itemType] 
                     controller:controller
                           view:view];
    }
    
    [self someoneUseItem:userId controller:controller view:view];
}

// Left to be realize for sub class.
- (int)itemType
{
    return 0;
}

- (BOOL)isShowNameAnimation
{
    return YES;
}

- (void)useItemSuccess:(DiceGamePlayController *)controller
                  view:(UIView *)view
{
    return;
}

- (void)someoneUseItem:(NSString *)userId
            controller:(DiceGamePlayController *)controller
                  view:(UIView *)view
{
    return;
}

@end

