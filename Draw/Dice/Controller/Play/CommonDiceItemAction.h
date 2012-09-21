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

@class DiceGamePlayController;

@interface CommonDiceItemAction : NSObject
{
    int _itemType;
    UserManager *_userManager;
    DiceGameService *_gameService;
}

@property (assign, nonatomic) int itemType;
@property (assign, nonatomic) UserManager *userManager;
@property (assign, nonatomic) DiceGameService *gameService;

+ (CommonDiceItemAction *)createDiceItemActionWithItemType:(int)itemType;

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

// Left to be realize for sub class.
- (void)showItemAnimation:(NSString*)userId
                 itemType:(int)itemType
               controller:(DiceGamePlayController *)controller
                     view:(UIView *)view;

- (void)useItemSuccess:(DiceGamePlayController *)controller
                  view:(UIView *)view;

- (void)someoneUseItem:(NSString *)userId
            controller:(DiceGamePlayController *)controller
                  view:(UIView *)view;

@end
