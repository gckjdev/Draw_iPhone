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
#import "PeekItemAction.h"
#import "DiceRobotItemAction.h"

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
        case ItemTypePeek:
            return [[[PeekItemAction alloc] initWithItemType:itemType] autorelease];
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
        case ItemTypeDiceRobot:
            return [[[DiceRobotItemAction alloc] initWithItemType:itemType] autorelease];
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
    
    [self showItemAnimation:_userManager.userId itemType:_itemType controller:controller view:view];
    
    [self useItemSuccess:controller view:view ];
}

- (void)handleItemRequest:(NSString *)userId
               controller:(DiceGamePlayController *)controller
                     view:(UIView *)view
{
    [self showItemAnimation:userId itemType:_itemType controller:controller view:view];
    
    [self someoneUseItem:userId controller:controller view:view];
}

// Left to be realize for sub class.
- (void)showItemAnimation:(NSString*)userId
                 itemType:(int)itemType
               controller:(DiceGamePlayController *)controller
                     view:(UIView *)view
{
    return;
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

