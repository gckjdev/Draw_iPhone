//
//  BuyItemSpecialHandler.m
//  Draw
//
//  Created by 王 小涛 on 13-4-11.
//
//

#import "BuyItemSpecialHandler.h"
#import "UserManager.h"
#import "ItemType.h"
#import "AdService.h"
#import "AccountService.h"
#import "ConfigManager.h"
#import "GameItemManager.h"
//#import "CustomDiceManager.h"

@implementation BuyItemSpecialHandler

+ (void)buySpecialHandle:(int)itemId
                   count:(int)count
{
    PBGameItem *item = [[GameItemManager defaultManager] itemWithItemId:itemId];
    switch (item.itemId) {
        case ItemTypeRemoveAd:
            [[AdService defaultService] disableAd];
            break;
            
        case ItemTypePurse:
            [[AccountService defaultService] chargeCoin:([ConfigManager getCoinsIngotRate] * item.priceInfo.price * count) source:ChargeViaBuyPurseItem];
            break;
            
        case ItemTypeCustomDicePatriotDice:
        case ItemTypeCustomDiceGoldenDice:
        case ItemTypeCustomDiceWoodDice:
        case ItemTypeCustomDiceBlueCrystalDice:
        case ItemTypeCustomDicePinkCrystalDice:
        case ItemTypeCustomDiceGreenCrystalDice:
        case ItemTypeCustomDicePurpleCrystalDice:
        case ItemTypeCustomDiceBlueDiamondDice:
        case ItemTypeCustomDicePinkDiamondDice:
        case ItemTypeCustomDiceGreenDiamondDice:
        case ItemTypeCustomDicePurpleDiamondDice:
//            [[CustomDiceManager defaultManager] setMyDiceTypeByItemType:itemId];
            break;
            
        default:
            break;
    }
}

+ (void)giveSpecialHandle:(int)itemId
                    count:(int)count
                 toUserId:(NSString *)toUserId
{
    PBGameItem *item = [[GameItemManager defaultManager] itemWithItemId:itemId];
    switch (itemId) {
        case ItemTypePurse:
            [[AccountService defaultService] chargeCoin:(([ConfigManager getCoinsIngotRate] * item.priceInfo.price) * count) toUser:toUserId source:ChargeAsAGift];
            break;
            
        default:
            break;
    }
}

@end
