//
//  Item.h
//  Draw
//
//  Created by  on 12-3-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

//typedef enum {
//    Bomb = 1, 
//    Kit = 2
//}ItemType;

@interface Item : NSObject<NSCoding>
{
    int _type;
    NSInteger _amount;
}

@property(nonatomic, assign)int type;
@property(nonatomic, assign)NSInteger amount;
- (id)initWithType:(int)type amount:(NSInteger)amount;
+ (Item *)itemWithType:(int)type amount:(NSInteger)amount;
@end
