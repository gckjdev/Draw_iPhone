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
@property (nonatomic, retain) UIImage* itemImage;
@property (nonatomic, retain) NSString* itemName;
@property (nonatomic, retain) NSString* itemDescription;
@property (nonatomic, assign) int buyAmountForOnce;
@property (nonatomic, assign) int price;
- (id)initWithType:(int)type amount:(NSInteger)amount;
- (id)initWithType:(int)type 
             image:(UIImage*)anImage 
              name:(NSString*)aName 
       description:(NSString*)aDescription 
  buyAmountForOnce:(int)amount 
             price:(int)aPrice;
+ (Item *)itemWithType:(int)type amount:(NSInteger)amount;
+ (Item*)tomato;
+ (Item*)flower;
+ (Item*)tips;
+ (Item*)colors;
+ (Item*)removeAd;
+ (Item*)featherPen;
+ (Item*)brushPen;
+ (Item*)iceCreamPen;
@end
