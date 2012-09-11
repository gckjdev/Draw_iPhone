//
//  CommonDiceItemAction.h
//  Draw
//
//  Created by 小涛 王 on 12-9-11.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DiceGamePlayController;

@interface CommonDiceItemAction : NSObject

- (id)initWithController:(DiceGamePlayController *)controller
                    view:(UIView *)view;

- (void)showNameAnimation:(NSString*)userId
                 itemName:(NSString *)itemName;

- (BOOL)isShowNameAnimation;
- (void)hanleItemResponse:(int)itemType;

@end
