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
#import "PPConfigManager.h"
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
    }
    return self;
}

+ (UIImage *)seletedPenImageForType:(ItemType)type
{
    // pen image
    ShareImageManager* manager = [ShareImageManager defaultManager];
    switch (type) {
        case Pen:
            return manager.selectedBrushPenImage;
        case IcePen:
            return manager.selectedIcePenImage;
        case Quill:
            return manager.selectedFeatherPenImage;
        case WaterPen:
            return manager.selectedMarkPenImage;
        case Pencil:
            return manager.selectedPencilImage;
        case Eraser:
        case DeprecatedEraser:
            return manager.selectedEraserImage;
            
        case ItemTypeBrushGouache:
            return manager.brushGouacheSelectedImage;
            
        case ItemTypeBrushNewPencil:
            return manager.brushPencilSelectedImage;
            
        case ItemTypeBrushNewCrayon:
            return manager.brushCrayonSelectedImage;
            
        case ItemTypeBrushPen:
            return manager.brushPenSelectedImage;
            
        case ItemTypeBrushBlur:
            return manager.brushBlurSelectedImage;

        case ItemTypeBrushNewWater:
            return manager.brushWaterSelectedImage;
            
        case ItemTypeBrushDryCalligraphy:
            return manager.brushDrySelectedImage;
            
        case ItemTypeBrushFilledCalligraphy:
            return manager.brushFilledSelectedImage;

        default:
            return nil;
    }
}

+ (UIImage *)showPenImageForType:(ItemType)type
{
    ShareImageManager* manager = [ShareImageManager defaultManager];
    switch (type) {
        case Pen:
            return manager.showBrushPenImage;
        case IcePen:
            return manager.showIcePenImage;
        case Quill:
            return manager.showFeatherPenImage;
        case WaterPen:
            return manager.showMarkPenImage;
        case Pencil:
            return manager.showPencilPenImage;
        case Eraser:
        case DeprecatedEraser:            
            return manager.showEraserImage;
            
        //brush images
        case ItemTypeBrushGouache:
            return manager.brushGouacheShowImage;
            
//        //deprecated, see BrushNewPencil
//        case ItemTypeBrushPencil:
//            return manager.brushPencilShowImage;
//        //deprecated, see BrushNewCrayon
//        case ItemTypeBrushCrayon:
//            return manager.brushCrayonShowImage;
//        //deprecated, see BrushNewWater
//        case ItemTypeBrushWater:
//            return manager.brushWaterShowImage;
            
        case ItemTypeBrushPen:
            return manager.brushPenShowImage;
            
        case ItemTypeBrushBlur:
            return manager.brushBlurShowImage;
            
        case ItemTypeBrushDryCalligraphy:
            return manager.brushDryShowImage;
            
        case ItemTypeBrushFilledCalligraphy:
            return manager.brushFilledShowImage;

        case ItemTypeBrushNewCrayon:
            return manager.brushCrayonShowImage;
            
        case ItemTypeBrushNewWater:
            return manager.brushWaterShowImage;
            
        case ItemTypeBrushNewPencil:
            return manager.brushPencilShowImage;
            
        default:
            return nil;
    }
    
}


+(UIImage *)imageForItemType:(ItemType)type
{
    ShareImageManager* manager = [ShareImageManager defaultManager];
    DiceImageManager* diceManager = [DiceImageManager defaultManager];
    switch (type) {
        case ItemTypeFlower:
            return [manager flower];
        case ItemTypeTomato:
            return [manager tomato];
        case ItemTypeColor:
            return [manager printOil];
        case ItemTypeRemoveAd:
            return [manager removeAd];
        case ItemTypeTips:
            return [manager tipBag];
        case Pen:
            return [manager penImage];
        case IcePen:
            return [manager iceImage];
        case Quill:
            return [manager quillImage];
        case WaterPen:
            return [manager waterPenImage];
        case Pencil:
            return [manager pencilImage];
            
        case ItemTypeBrushGouache:
            return manager.brushGouacheImage;
            
        case ItemTypeBrushNewPencil:
            return manager.brushPencilImage;
            
        case ItemTypeBrushNewCrayon:
            return manager.brushCrayonImage;
            
        case ItemTypeBrushPen:
            return manager.brushPenImage;
            
        case ItemTypeBrushBlur:
            return manager.brushBlurImage;

        case ItemTypeBrushNewWater:
            return manager.brushWaterImage;
            
        case ItemTypeBrushDryCalligraphy:
            return manager.brushDryImage;
            
        case ItemTypeBrushFilledCalligraphy:
            return manager.brushFilledImage;
            
        case PaletteItem:
            return [manager shopItemPaletteImage];
        case ColorAlphaItem:
            return [manager shopItemAlphaImage];
        case PaintPlayerItem:
            return [manager paintPlayerImage];
        case ColorStrawItem:
            return [manager strawImage];
            
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
        case PaletteItem:
            return NSLS(@"kPaletteItem");
        case ColorAlphaItem:
            return NSLS(@"kColorAlphaItem");
        case PaintPlayerItem:
            return NSLS(@"kPaintPlayerItem");
        case ColorStrawItem:
            return NSLS(@"kStraw");
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
        case PaletteItem:
            return NSLS(@"kPaletteItemDescription");
        case ColorAlphaItem:
            return NSLS(@"kColorAlphaItemDescription");
        case PaintPlayerItem:
            return NSLS(@"kPaintPlayerItemDescription");
        case ColorStrawItem:
            return NSLS(@"kStrawDescription");
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
        case Pen:
            return [Item brushPen];
        case IcePen:
            return [Item iceCreamPen];
        case Quill:
            return [Item featherPen];
        case WaterPen:
            return [Item waterPen];
        case PaletteItem:
            return [Item paletteItem];
        case ColorAlphaItem:
            return [Item colorAlphaItem];
        case PaintPlayerItem:
            return [Item paintPlayerItem];
        case ColorStrawItem:
            return [Item straw];
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
    if ([PPConfigManager isProVersion]){
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

+ (Item*)paletteItem
{
    return [[[Item alloc] initWithType:PaletteItem
                                 image:[Item imageForItemType:PaletteItem]
                                  name:[Item nameForItemType:PaletteItem]
                           description:[Item descriptionForItemType:PaletteItem]
                      buyAmountForOnce:1
                                 price:[[ShoppingManager defaultManager] getPaletteItemPrice]
                                amount:[[ItemManager defaultManager] amountForItem:PaletteItem]] autorelease];
}

+ (Item*)colorAlphaItem
{
    return [[[Item alloc] initWithType:ColorAlphaItem
                                 image:[Item imageForItemType:ColorAlphaItem]
                                  name:[Item nameForItemType:ColorAlphaItem]
                           description:[Item descriptionForItemType:ColorAlphaItem]
                      buyAmountForOnce:1
                                 price:[[ShoppingManager defaultManager] getColorAlphaItemPrice]
                                amount:[[ItemManager defaultManager] amountForItem:ColorAlphaItem]] autorelease];
}

+ (Item*)paintPlayerItem
{
    return [[[Item alloc] initWithType:PaintPlayerItem
                                 image:[Item imageForItemType:PaintPlayerItem]
                                  name:[Item nameForItemType:PaintPlayerItem]
                           description:[Item descriptionForItemType:PaintPlayerItem]
                      buyAmountForOnce:1
                                 price:[[ShoppingManager defaultManager] getPaintPlayerItemPrice]
                                amount:[[ItemManager defaultManager] amountForItem:PaintPlayerItem]] autorelease];
}

+ (Item*)straw
{
    return [[[Item alloc] initWithType:ColorStrawItem
                                 image:[Item imageForItemType:ColorStrawItem]
                                  name:[Item nameForItemType:ColorStrawItem]
                           description:[Item descriptionForItemType:ColorStrawItem]
                      buyAmountForOnce:1
                                 price:[[ShoppingManager defaultManager] getStrawPrice]
                                amount:[[ItemManager defaultManager] amountForItem:ColorStrawItem]] autorelease];
}


- (int)unitPrice
{
    return (self.price / self.buyAmountForOnce);
}

@end
