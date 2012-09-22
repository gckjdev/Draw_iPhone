//
//  CommonDiceItemAction.h
//  Draw
//
//  Created by 小涛 王 on 12-9-11.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserManager.h"
#import "DiceGameService.h"
#import "GifView.h"
#import "DiceAvatarView.h"
#import "ItemManager.h"

@class DiceGamePlayController;

@interface CommonDiceItemAction : NSObject
{
    int _itemType;
    UserManager *_userManager;
    DiceGameService *_gameService;
    ItemManager *_itemManager;
}

@property (assign, nonatomic) int itemType;
@property (assign, nonatomic) UserManager *userManager;
@property (assign, nonatomic) DiceGameService *gameService;

+ (CommonDiceItemAction *)createDiceItemActionWithItemType:(int)itemType;

+ (BOOL)meetUseScene:(int)itemType;

+ (void)useItem:(int)itemType
     controller:(DiceGamePlayController *)controller
           view:(UIView *)view;

+ (void)handleItemResponse:(int)itemType
                controller:(DiceGamePlayController *)controller
                      view:(UIView *)view;

+ (void)handleItemRequest:(int)itemType
                   userId:(NSString *)userId
               controller:(DiceGamePlayController *)controller
                     view:(UIView *)view;

- (void)showGifViewOnUserAvatar:(NSString *)userId
                        gifFile:(NSString *)gifFile
                     controller:(DiceGamePlayController *)controller
                           view:(UIView *)view;

- (BOOL)isMyTurn;

// Left to be realize for sub class.

// 道具使用场合
- (BOOL)useScene;

// 是否等待服务器回应
- (BOOL)waitForResponse;

// 子类如果有带参数的道具，则实现这个方法
- (void)useItem:(DiceGamePlayController *)controller
           view:(UIView *)view;

// 显示道具动画
- (void)showItemAnimation:(NSString*)userId
                 itemType:(int)itemType
               controller:(DiceGamePlayController *)controller
                     view:(UIView *)view;

// 道具使用成功时的效果
- (void)useItemSuccess:(DiceGamePlayController *)controller
                  view:(UIView *)view;

// 其他人使用道具成功的效果
- (void)someoneUseItem:(NSString *)userId
            controller:(DiceGamePlayController *)controller
                  view:(UIView *)view;

@end
