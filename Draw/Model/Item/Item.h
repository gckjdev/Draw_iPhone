//
//  Item.h
//  Draw
//
//  Created by  on 12-3-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    Bomb = 1, 
    Kit = 2
}ItemType;

@interface Item : NSObject<NSCoding>
{
    ItemType _type;
    NSInteger _amount;
}

@property(nonatomic, assign)ItemType type;
@property(nonatomic, assign)NSInteger amount;
- (id)initWithType:(ItemType)type amount:(NSInteger)amount;
+ (Item *)itemWithType:(ItemType)type amount:(NSInteger)amount;
@end
