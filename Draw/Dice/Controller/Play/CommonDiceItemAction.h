//
//  CommonDiceItemAction.h
//  Draw
//
//  Created by 小涛 王 on 12-9-11.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserManager.h"

@class DiceGamePlayController;

@interface CommonDiceItemAction : NSObject
{
    UserManager *_userManager;
    int _itemType;
}

@property (assign, nonatomic) int itemType;
@property (assign, nonatomic) UserManager *userManager;

- (id)initWithItemType:(int)itemType;

- (void)hanleItemResponse:(DiceGamePlayController *)controller
                     view:(UIView *)view;

- (void)hanleItemRequest:(NSString *)userId
              controller:(DiceGamePlayController *)controller
                    view:(UIView *)view;

// Left to be realize for sub class.
- (int)itemType;

- (BOOL)isShowNameAnimation;

- (void)useItemSuccess:(DiceGamePlayController *)controller
                  view:(UIView *)view;

- (void)someoneUseItem:(NSString *)userId
            controller:(DiceGamePlayController *)controller
                  view:(UIView *)view;

@end
