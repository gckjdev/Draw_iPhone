//
//  DiceItem.h
//  Draw
//
//  Created by 小涛 王 on 12-8-17.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DiceItem : NSObject

- (DiceItem *)diceItemWithItemId:(int)itemId
                        itemName:(NSString *)itemName
                           count:(int)count;

- (int)itemId;
- (NSString *)itemName;
- (int)count;

@end
