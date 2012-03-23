//
//  ItemManager.h
//  Draw
//
//  Created by  on 12-3-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Item.h"

@interface ItemManager : NSObject
{
    
}
+ (ItemManager *)defaultManager;
- (NSArray *)itemList;
- (void)updateItemWithType:(ItemType)type amount:(NSInteger)amount;
@end
extern ItemManager *GlobalGetItemManager();
