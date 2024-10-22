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
#import "AccountService.h"
#import "PPConfigManager.h"
#import "GameItemManager.h"

@implementation BuyItemSpecialHandler

+ (void)buySpecialHandle:(int)itemId
                   count:(int)count
{
    PBGameItem *item = [[GameItemManager defaultManager] itemWithItemId:itemId];
    switch (item.itemId) {
        case ItemTypeRemoveAd:
            PPDebug(@"warning, remove ad item not used now");
            break;
            
        case ItemTypePurse:
            [[AccountService defaultService] chargeCoin:([PPConfigManager getCoinsIngotRate] * item.priceInfo.price * count) source:ChargeViaBuyPurseItem];
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
            [[AccountService defaultService] chargeCoin:(([PPConfigManager getCoinsIngotRate] * item.priceInfo.price) * count) toUser:toUserId source:ChargeAsAGift];
            break;
            
        default:
            break;
    }
}

@end
