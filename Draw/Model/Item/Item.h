//
//  Item.h
//  Draw
//
//  Created by  on 12-3-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ItemType.h"
//typedef enum {
//    Bomb = 1, 
//    Kit = 2
//}ItemType;

#define MATCH_SECECE

//typedef enum {
//    MyTurn = 0x1, 
//    GamePlaying = 0x11
//}UseScene;

@interface Item : NSObject<NSCoding>
{
    ItemType _type;
    NSInteger _amount;
}

@property(nonatomic, assign)ItemType type;
@property(nonatomic, assign)NSInteger amount;
@property (nonatomic, retain) UIImage* itemImage;
@property (nonatomic, retain) NSString* itemName;
@property (nonatomic, retain) NSString* shortName;
@property (nonatomic, retain) NSString* itemDescription;
@property (nonatomic, assign) int buyAmountForOnce;
@property (nonatomic, assign) int price;
//@property (nonatomic, assign) UseScene useScene;

- (id)initWithType:(ItemType)type amount:(NSInteger)amount;
- (id)initWithType:(ItemType)type 
             image:(UIImage*)anImage 
              name:(NSString*)aName 
       description:(NSString*)aDescription 
  buyAmountForOnce:(int)amount 
             price:(int)aPrice 
            amount:(int)currentAmount;

- (id)initWithType:(ItemType)type 
             image:(UIImage*)anImage 
              name:(NSString*)aName 
         shortName:(NSString*)shortName
       description:(NSString*)aDescription 
  buyAmountForOnce:(int)amount 
             price:(int)aPrice 
            amount:(int)currentAmount;
//          useScene:(UseScene)useScene;

//- (BOOL)canUseInScene:(UseScene)scene;

+ (Item *)itemWithType:(ItemType)type amount:(NSInteger)amount;
+ (Item*)tomato;
+ (Item*)flower;
+ (Item*)tips;
+ (Item*)colors;
+ (Item*)removeAd;
+ (Item*)featherPen;
+ (Item*)brushPen;
+ (Item*)iceCreamPen;
+ (Item*)waterPen;
+ (Item*)PaletteItem;
+ (Item*)ColorAlphaItem;

+ (UIImage *)imageForItemType:(ItemType)type;
+ (NSString *)nameForItemType:(ItemType)type;
+ (NSString *)descriptionForItemType:(ItemType)type;
+ (NSString *)actionNameForItemType:(ItemType)type;
+ (BOOL)isItemCountable:(ItemType)type;
+ (NSString*)getItemTips:(ItemType)type;
+ (BOOL)isCustomDice:(ItemType)type;
@end
