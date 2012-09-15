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
#import "RollAgainItemAction.h"
#import "IncTimeItemAction.h"
#import "DecTimeItemAction.h"
#import "DoubleKillItemAction.h"
#import "SkipItemAction.h"

@interface CommonDiceItemAction ()
{
    AccountService *_accountService;
}

@end

@implementation CommonDiceItemAction

@synthesize itemType = _itemType;
@synthesize userManager = _userManager;
@synthesize gameService = _gameService;

+ (CommonDiceItemAction *)createDiceItemActionWithItemType:(int)itemType
{
    switch (itemType) {
        case ItemTypeRollAgain:
            return [[[RollAgainItemAction alloc] initWithItemType:itemType] autorelease];
            break;
        case ItemTypeIncTime:
            return [[[IncTimeItemAction alloc] initWithItemType:itemType] autorelease];
            break;
        case ItemTypeDecTime:
            return [[[DecTimeItemAction alloc] initWithItemType:itemType] autorelease];
            break;
        case ItemTypeDoubleKill:
            return [[[DoubleKillItemAction alloc] initWithItemType:itemType] autorelease];
            break;
        case ItemTypeSkip:
            return [[[SkipItemAction alloc] initWithItemType:itemType] autorelease];
            break;
        default:
            return nil;
            break;
    }
}

- (id)initWithItemType:(int)itemType
{
    if (self = [super init]) {
        self.itemType = itemType;
        self.userManager = [UserManager defaultManager];
        _accountService = [AccountService defaultService];
        _gameService = [DiceGameService defaultService];
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

+ (void)handleItemResponse:(int)itemType
                controller:(DiceGamePlayController *)controller
                      view:(UIView *)view
{
    CommonDiceItemAction *action = [CommonDiceItemAction createDiceItemActionWithItemType:itemType];
    
    [action handleItemResponse:controller
                          view:view];
}

+ (void)handleItemRequest:(int)itemType
                   userId:(NSString *)userId
               controller:(DiceGamePlayController *)controller
                     view:(UIView *)view
{
    CommonDiceItemAction *action = [CommonDiceItemAction createDiceItemActionWithItemType:itemType];
    
    [action handleItemRequest:userId
                   controller:controller 
                         view:view];
}

- (void)handleItemResponse:(DiceGamePlayController *)controller
                      view:(UIView *)view
{
    [_accountService consumeItem:_itemType amount:1]; 
    
    if ([self isShowNameAnimation]) {
        [self showNameAnimation:_userManager.userId
                       itemType:_itemType
                     controller:controller
                           view:view];
    }
    
    [self useItemSuccess:controller view:view ];
}

- (void)handleItemRequest:(NSString *)userId
               controller:(DiceGamePlayController *)controller
                     view:(UIView *)view
{
    if ([self isShowNameAnimation]) {
        [self showNameAnimation:userId 
                       itemType:_itemType
                     controller:controller
                           view:view];
    }
    
    [self someoneUseItem:userId controller:controller view:view];
}

// Left to be realize for sub class.
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

