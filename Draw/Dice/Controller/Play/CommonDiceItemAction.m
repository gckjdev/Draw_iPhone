//
//  CommonDiceItemAction.m
//  Draw
//
//  Created by 小涛 王 on 12-9-11.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "CommonDiceItemAction.h"
#import "DiceGamePlayController.h"
#import "AccountService.h"
#import "RollAgainItemAction.h"
#import "IncTimeItemAction.h"
#import "DecTimeItemAction.h"
#import "DoubleKillItemAction.h"
#import "SkipItemAction.h"
#import "PeekItemAction.h"
#import "DiceRobotItemAction.h"
#import "CutItemAction.h"
#import "ReverseItemAction.h"
#import "UserGameItemService.h"

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
        case ItemTypeCut:
            return [[[CutItemAction alloc] initWithItemType:itemType] autorelease];
            break;
            
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
            
        case ItemTypeReverse:
            return [[[ReverseItemAction alloc] initWithItemType:itemType] autorelease];
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
        _itemManager = [ItemManager defaultManager];
    }
    
    return self;
}

+ (BOOL)meetUseScene:(int)itemType
{
    CommonDiceItemAction *action = [CommonDiceItemAction createDiceItemActionWithItemType:itemType];
    return [action meetUseScene];
}

+ (void)useItem:(int)itemType
     controller:(DiceGamePlayController *)controller
           view:(UIView *)view
{
    CommonDiceItemAction *action = [CommonDiceItemAction createDiceItemActionWithItemType:itemType];
    [action useItem:controller view:view];

    if (![action waitForResponse]) {
        [self handleItemResponse:itemType controller:controller view:view response:nil];
    }
}

+ (void)handleItemResponse:(int)itemType
                controller:(DiceGamePlayController *)controller
                      view:(UIView *)view
{
    CommonDiceItemAction *action = [CommonDiceItemAction createDiceItemActionWithItemType:itemType];
    
    if ([action waitForResponse]) {
        [action handleItemResponse:controller
                              view:view];
    }
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

+ (void)handleItemResponse:(int)itemType
                controller:(DiceGamePlayController *)controller
                      view:(UIView *)view 
                  response:(UseItemResponse*)response
{
    CommonDiceItemAction *action = [CommonDiceItemAction createDiceItemActionWithItemType:itemType];
    
    if ([action waitForResponse]) {
        [action handleItemResponse:controller
                              view:view 
                          response:response];
    }
}

+ (void)handleItemRequest:(int)itemType
                   userId:(NSString *)userId
               controller:(DiceGamePlayController *)controller
                     view:(UIView *)view 
                  request:(UseItemRequest*)request
{
    CommonDiceItemAction *action = [CommonDiceItemAction createDiceItemActionWithItemType:itemType];
    
    [action handleItemRequest:userId
                   controller:controller 
                         view:view 
                      request:request];
}


- (void)handleItemResponse:(DiceGamePlayController *)controller
                      view:(UIView *)view 
                  response:(UseItemResponse*)response
{
    [[UserGameItemService defaultService] consumeItem:_itemType count:1];
    
    [self showItemAnimation:_userManager.userId itemType:_itemType controller:controller view:view];
    
    [self useItemSuccess:controller view:view response:response];
}

- (void)handleItemRequest:(NSString *)userId
               controller:(DiceGamePlayController *)controller
                     view:(UIView *)view 
                  request:(UseItemRequest*)request
{
    [self showItemAnimation:userId itemType:_itemType controller:controller view:view];
    
    [self someoneUseItem:userId controller:controller view:view request:request];
}

- (void)handleItemResponse:(DiceGamePlayController *)controller
                      view:(UIView *)view 
{
    [[UserGameItemService defaultService] consumeItem:_itemType count:1];
    
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

- (void)showGifViewOnUserAvatar:(NSString *)userId
                    gifFile:(NSString *)gifFile
                     controller:(DiceGamePlayController *)controller
                           view:(UIView *)view
{
    DiceAvatarView *avatarView = [controller avatarViewOfUser:userId];
    GifView *gifView = [self gifViewFromBundleFile:gifFile frame:avatarView.bounds];
    
    gifView.userInteractionEnabled = NO;
    [avatarView addSubview:gifView];
    
    [UIView animateWithDuration:1 delay:3.0 options:UIViewAnimationCurveLinear animations:^{
        gifView.alpha = 0;
    } completion:^(BOOL finished) {
        [gifView removeFromSuperview];
    }];
}

- (BOOL)isMyTurn
{    
    NSString *currentPlayUserId = _gameService.session.currentPlayUserId;
    BOOL isMyTurn = [_userManager isMe:currentPlayUserId];
    return isMyTurn;
}

- (GifView *)gifViewFromBundleFile:(NSString *)fileName frame:(CGRect)frame
{
    NSArray *array = [fileName componentsSeparatedByString:@"."];
    if ([array count] < 2) {
        return nil;
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:[array objectAtIndex:0] 
                                                     ofType:[array objectAtIndex:1]];
    
    if (path == nil) {
        return nil;
    }
    
    GifView* view = [[[GifView alloc] initWithFrame:frame
                                           filePath:path
                                   playTimeInterval:0.2] autorelease];
    
    return view;
}

- (BOOL)meetUseScene
{
    NSNumber *count = [NSNumber numberWithInt:[_itemManager amountForItem:_itemType]];
    if ([count intValue] <= 0 || _gameService.diceSession.isMeAByStander ) {
        return NO;
    }
    
    if (!_gameService.diceSession.isMeAByStander && _gameService.diceSession.openDiceUserId != nil) {
        return NO;
    }
    
    return [self useScene];
}


// Left to be realize for sub class.

- (BOOL)useScene
{
    return YES;
}

- (BOOL)waitForResponse
{
    return YES;
}

- (void)useItem:(DiceGamePlayController *)controller
           view:(UIView *)view
{
    [self.gameService userItem:_itemType];
}

- (void)showItemAnimation:(NSString*)userId
                 itemType:(int)itemType
               controller:(DiceGamePlayController *)controller
                     view:(UIView *)view
{
    return;
}

- (void)useItemSuccess:(DiceGamePlayController *)controller
                  view:(UIView *)view 
              response:(UseItemResponse*)response
{
    return;
}

- (void)someoneUseItem:(NSString *)userId
            controller:(DiceGamePlayController *)controller
                  view:(UIView *)view 
               request:(UseItemRequest*)request
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

