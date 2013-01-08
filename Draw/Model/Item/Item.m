//
//  Item.m
//  Draw
//
//  Created by  on 12-3-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Item.h"
#import "ItemType.h"
#import "LocaleUtils.h"
#import "ShareImageManager.h"
#import "ItemManager.h"
#import "ShoppingManager.h"
#import "ConfigManager.h"
#import "DiceImageManager.h"
#import "UIImageUtil.h"

@implementation Item
@synthesize amount = _amount;
@synthesize type = _type;
@synthesize itemImage = _itemImage;
@synthesize itemName = _itemName;
@synthesize shortName = _shortName;
@synthesize itemDescription = _itemDescription;
@synthesize buyAmountForOnce;
@synthesize price;
//@synthesize useScene = _useScene;

- (void)dealloc
{
    [_itemName release];
    [_shortName release];
    [_itemImage release];
    [_itemDescription release];
    [super dealloc];
}

- (id)initWithType:(ItemType)type amount:(NSInteger)amount
{
    self = [super init];
    if (self) {
        self.type = type;
        self.amount = amount;
    }
    return self;
}

#define KEY_TYPE @"KEY_TYPE"
#define KEY_AMOUNT @"KEY_AMOUNT"

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:_type forKey:KEY_TYPE];
    [aCoder encodeInteger:_amount forKey:KEY_AMOUNT];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self){
        self.type = [aDecoder decodeIntegerForKey:KEY_TYPE];
        self.amount = [aDecoder decodeIntegerForKey:KEY_AMOUNT];
    }
    return self;
}

- (id)initWithType:(ItemType)type 
             image:(UIImage*)anImage 
              name:(NSString*)aName 
       description:(NSString*)aDescription 
  buyAmountForOnce:(int)amount 
             price:(int)aPrice 
            amount:(int)currentAmount
{
    self = [super init];
    if(self){
        self.type = type;
        self.itemImage = anImage;
        self.itemName = aName;
        self.itemDescription = aDescription;
        self.buyAmountForOnce = amount;
        self.price = aPrice;
        self.amount = currentAmount;
    }
    return self;
}

- (id)initWithType:(ItemType)type 
             image:(UIImage*)anImage 
              name:(NSString*)aName 
         shortName:(NSString*)shortName
       description:(NSString*)aDescription 
  buyAmountForOnce:(int)amount 
             price:(int)aPrice 
            amount:(int)currentAmount
//          useScene:(UseScene)useScene
{
    self = [super init];
    if(self){
        self.type = type;
        self.itemImage = anImage;
        self.itemName = aName;
        self.shortName = shortName;
        self.itemDescription = aDescription;
        self.buyAmountForOnce = amount;
        self.price = aPrice;
        self.amount = currentAmount;
//        self.useScene = useScene;
    }
    return self;
}

//- (BOOL)canUseInScene:(UseScene)scene
//{
//    if (_useScene == (scene && _useScene)) {
//        return YES;
//    }
//    
//    return NO;
//}


+(UIImage *)imageForItemType:(ItemType)type
{
    ShareImageManager* manager = [ShareImageManager defaultManager];
    DiceImageManager* diceManager = [DiceImageManager defaultManager];
    switch (type) {
        case ItemTypeFlower:
            return manager.flower;
        case ItemTypeTomato:
            return manager.tomato;
        case ItemTypeColor:
            return manager.printOil;
        case ItemTypeRemoveAd:
            return manager.removeAd;
        case ItemTypeTips:
            return manager.tipBag;
        case Pen:
            return [UIImage adjustImage:manager.penImage toRatio:1];
        case IcePen:
            return [UIImage adjustImage:manager.iceImage toRatio:1];
        case Quill:
            return [UIImage adjustImage:manager.quillImage toRatio:1];
        case WaterPen:
            return [UIImage adjustImage:manager.waterPenImage toRatio:1];
        case Pencil:
            return [UIImage adjustImage:manager.pencilImage toRatio:1];
        case ItemTypeRollAgain: 
            return [diceManager toShopImage:diceManager.diceToolRollAgainImage];
        case ItemTypeCut: 
            return [diceManager toShopImage:diceManager.diceToolCutImage];
        case ItemTypeIncTime:
            return [diceManager toShopImage:diceManager.postponeImage];
        case ItemTypeDecTime:
            return [diceManager toShopImage:diceManager.urgeImage];
        case ItemTypeSkip:
            return [diceManager toShopImage:diceManager.turtleImage];
        case ItemTypeDoubleKill:
            return [diceManager toShopImage:diceManager.doubleKillImage];
        case ItemTypeDiceRobot:
            return [diceManager toShopImage:diceManager.diceRobotImage];
        case ItemTypePeek:
            return [diceManager toShopImage:diceManager.peekImage];
        case ItemTypeReverse:
            return [diceManager toShopImage:diceManager.reverseImage];
        case ItemTypeCustomDicePatriotDice:
            return [diceManager toShopImage:diceManager.patriotDiceImage];
        case ItemTypeCustomDiceGoldenDice:
            return [diceManager toShopImage:diceManager.goldenDiceImage];
        case ItemTypeCustomDiceWoodDice:
            return [diceManager toShopImage:diceManager.woodDiceImage];
        case ItemTypeCustomDiceBlueCrystalDice:
            return [diceManager toShopImage:diceManager.blueCrystalDiceImage];
        case ItemTypeCustomDicePinkCrystalDice:
            return [diceManager toShopImage:diceManager.pinkCrystalDiceImage];
        case ItemTypeCustomDiceGreenCrystalDice:
            return [diceManager toShopImage:diceManager.greenCrystalDiceImage];
        case ItemTypeCustomDicePurpleCrystalDice:
            return [diceManager toShopImage:diceManager.purpleCrystalDiceImage];
        case ItemTypeCustomDiceBlueDiamondDice:
            return [diceManager toShopImage:diceManager.blueDiamondDiceImage];
        case ItemTypeCustomDicePinkDiamondDice:
            return [diceManager toShopImage:diceManager.pinkDiamondDiceImage];
        case ItemTypeCustomDiceGreenDiamondDice:
            return [diceManager toShopImage:diceManager.greenDiamondDiceImage];
        case ItemTypeCustomDicePurpleDiamondDice:
            return [diceManager toShopImage:diceManager.purpleDiamondDiceImage];
        default:
            return nil;
    }    
}
+(NSString *)nameForItemType:(ItemType)type
{
    switch (type) {
        case ItemTypeFlower:
            return NSLS(@"kFlower");
        case ItemTypeTomato:
            return NSLS(@"kTomato");
        case ItemTypeColor:
            return NSLS(@"kColor");
        case ItemTypeRemoveAd:
            return NSLS(@"kRemoveAd");
        case ItemTypeTips:
            return NSLS(@"kTips");
        case Pen:
            return NSLS(@"kPen");
        case IcePen:
            return NSLS(@"kIcePen");
        case Quill:
            return NSLS(@"kQuill"); 
        case WaterPen:
            return NSLS(@"kWaterPen");
        case ItemTypeRollAgain:
            return NSLS(@"kRollAgain");
        case ItemTypeCut:
            return NSLS(@"kCut");
        default:
            return nil;
    }

}

+(NSString *)descriptionForItemType:(ItemType)type
{
    switch (type) {
        case ItemTypeFlower:
            return  NSLS(@"kFlowerDescription");
        case ItemTypeTomato:
            return NSLS(@"kTomatoDescription");
        case ItemTypeColor:
            return NSLS(@"kColorDescription");
        case ItemTypeRemoveAd:
            return NSLS(@"kRemoveAdDescription");
        case ItemTypeTips:
            return NSLS(@"kTipsDescription");
        case Pen:
            return NSLS(@"kBrushPenDescription");
        case IcePen:
            return NSLS(@"kIcePenDescription");
        case Quill:
            return NSLS(@"kQuillDescription");  
        case WaterPen:
            return NSLS(@"kWaterPenDescription");
        default:
            return nil;
    }
    
}

+ (NSString *)actionNameForItemType:(ItemType)type
{
    if(ItemTypeTips == type)
    {
        return NSLS(@"kBombTips");
    }
    if (ItemTypeFlower == type) {
        return NSLS(@"kThrowFlower");        
    }
    if (ItemTypeTomato == type) {
        return NSLS(@"kThrowTomato");
    }
    return nil;
}

+ (BOOL)isItemCountable:(ItemType)type
{
    if(type == ItemTypeTomato 
       || type == ItemTypeFlower 
       || type == ItemTypeTips 
       || type == ItemTypeRollAgain 
       || type == ItemTypeCut 
       || type == ItemTypeIncTime 
       || type == ItemTypeDecTime 
       || type == ItemTypeSkip 
       || type == ItemTypeDoubleKill 
       || type == ItemTypeDiceRobot
       || type == ItemTypePeek
       || type == ItemTypeReverse)
        return YES;
    return NO;
}

+ (BOOL)isCustomDice:(ItemType)type
{
    if (type > ItemTypeCustomDiceStart && type < ItemTypeCustomDiceEnd) {
        return YES;
    }
    return NO;
}

+ (NSString*)getItemTips:(ItemType)type
{
    if ([Item isCustomDice:type]) {
        return NSLS(@"kCustomDiceTips");
    }
    return nil;
}

+ (Item *)itemWithType:(ItemType)type amount:(NSInteger)amount
{
    switch (type) {
        case ItemTypeFlower:
            return [Item flower];
        case ItemTypeTomato:
            return[Item tomato];
        case ItemTypeColor:
            return [Item colors];
        case ItemTypeRemoveAd:
            return [Item removeAd];
        case ItemTypeTips:
            return [Item tips];
        case IcePen:
            return [Item iceCreamPen];
        case Quill:
            return [Item featherPen];
        case WaterPen:
            return [Item waterPen];
        default:
            break;
    }
    return [[[Item alloc] initWithType:type amount:amount]autorelease];
}

+ (Item*)tomato
{
    return [[[Item alloc] initWithType:ItemTypeTomato 
                                 image:[Item imageForItemType:ItemTypeTomato]
                                  name:[Item nameForItemType:ItemTypeTomato]
                           description:[Item descriptionForItemType:ItemTypeTomato]
                      buyAmountForOnce:10 
                                 price:[[ShoppingManager defaultManager] getTomatoPrice]
                                amount:[[ItemManager defaultManager] amountForItem:ItemTypeTomato]] autorelease];
}

+ (Item*)flower
{
    return [[[Item alloc] initWithType:ItemTypeFlower
                                 image:[Item imageForItemType:ItemTypeFlower]
                                  name:[Item nameForItemType:ItemTypeFlower]
                           description:[Item descriptionForItemType:ItemTypeFlower]
                      buyAmountForOnce:10 
                                 price:[[ShoppingManager defaultManager] getFlowerPrice]
                                amount:[[ItemManager defaultManager] amountForItem:ItemTypeFlower]] autorelease];
}

+ (Item*)tips
{
    return [[[Item alloc] initWithType:ItemTypeTips 
                                 image:[Item imageForItemType:ItemTypeTips]
                                  name:[Item nameForItemType:ItemTypeTips]
                           description:[Item descriptionForItemType:ItemTypeTips] 
                      buyAmountForOnce:10 
                                 price:[[ShoppingManager defaultManager] getTipBagPrice]
                                amount:[[ItemManager defaultManager] amountForItem:ItemTypeTips]] autorelease];
}

+ (Item*)colors
{
    return [[[Item alloc] initWithType:ItemTypeColor 
                                 image:[Item imageForItemType:ItemTypeColor]
                                  name:[Item nameForItemType:ItemTypeColor]
                           description:[Item descriptionForItemType:ItemTypeColor] 
                      buyAmountForOnce:10 
                                 price:[[ShoppingManager defaultManager] getColorPrice]
                                amount:0] autorelease];//kira:amount=0 because color is not countable,and always can be bought
}

+ (Item*)removeAd
{
    
    int amount = 0;
    if ([ConfigManager isProVersion]){
        amount = 1;
    }
    else{
        amount = [[ItemManager defaultManager] amountForItem:ItemTypeRemoveAd];
    }
    
    return [[[Item alloc] initWithType:ItemTypeRemoveAd 
                                 image:[Item imageForItemType:ItemTypeRemoveAd]
                                  name:[Item nameForItemType:ItemTypeRemoveAd]
                           description:[Item descriptionForItemType:ItemTypeRemoveAd] 
                      buyAmountForOnce:10 
                                 price:[[ShoppingManager defaultManager] getRemoveAdPrice]
                                amount:amount] autorelease];
}

+ (Item*)featherPen
{
    return [[[Item alloc] initWithType:Quill 
                                 image:[Item imageForItemType:Quill]
                                  name:[Item nameForItemType:Quill]
                           description:[Item descriptionForItemType:Quill] 
                      buyAmountForOnce:1
                                 price:[[ShoppingManager defaultManager] getPenPrice]
                                amount:[[ItemManager defaultManager] amountForItem:Quill]] autorelease];
}

+ (Item*)brushPen
{
    return [[[Item alloc] initWithType:Pen 
                                 image:[Item imageForItemType:Pen]
                                  name:[Item nameForItemType:Pen]
                           description:[Item descriptionForItemType:Pen] 
                      buyAmountForOnce:1 
                                 price:[[ShoppingManager defaultManager] getPenPrice] 
                                amount:[[ItemManager defaultManager] amountForItem:Pen]] autorelease];
}

+ (Item*)iceCreamPen
{
    return [[[Item alloc] initWithType:IcePen 
                                 image:[Item imageForItemType:IcePen]
                                  name:[Item nameForItemType:IcePen]
                           description:[Item descriptionForItemType:IcePen] 
                      buyAmountForOnce:1 
                                 price:[[ShoppingManager defaultManager] getPenPrice] 
                                amount:[[ItemManager defaultManager] amountForItem:IcePen]] autorelease];
}

+ (Item*)waterPen
{
    return [[[Item alloc] initWithType:WaterPen 
                                 image:[Item imageForItemType:WaterPen]
                                  name:[Item nameForItemType:WaterPen]
                           description:[Item descriptionForItemType:WaterPen] 
                      buyAmountForOnce:1 
                                 price:[[ShoppingManager defaultManager] getPenPrice] 
                                amount:[[ItemManager defaultManager] amountForItem:WaterPen]] autorelease];
}




@end
