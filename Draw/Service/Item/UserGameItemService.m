//
//  UserGameItemService.m
//  Draw
//
//  Created by qqn_pipi on 13-2-22.
//
//

#import "UserGameItemService.h"
#import "SynthesizeSingleton.h"
#import "GameNetworkRequest.h"
#import "PPNetworkRequest.h"
#import "GameNetworkConstants.h"
#import "UserManager.h"
#import "ConfigManager.h"
#import "AccountManager.h"
#import "PBGameItemUtils.h"
#import "UserItem.h"

#define KEY_USER_ITEM_INFO @"KEY_USER_ITEM_INFO"

@interface UserGameItemService()

@property (retain, nonatomic) NSMutableArray *itemArr;

@end

@implementation UserGameItemService

SYNTHESIZE_SINGLETON_FOR_CLASS(UserGameItemService);

- (void)dealloc
{
    [_itemArr release];
    [super dealloc];
}

- (id)init{
    if (self = [super init]) {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_USER_ITEM_INFO];
        PBUserItemList *userItemList = [PBUserItemList parseFromData:data];
        for (PBUserItem *item in [userItemList itemsList]) {
            UserItem *userItem = [UserItem userItemFromPBUserItem:item];
        }
    }
    
    return self;
}

- (void)save
{
    PBUserItemList_Builder *builder = [[[PBUserItemList_Builder alloc] init] autorelease];
    [builder addAllItems:_itemArr];
    PBUserItemList *itemList = [builder build];
    [[NSUserDefaults standardUserDefaults] setObject:[itemList data] forKey:KEY_USER_ITEM_INFO];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (int)countOfItem:(int)itemId
{
//    return [[_itemDic objectForKey:@(itemId)] ];
}

- (void)increaseItem:(int)itemId count:(int)count
{
    int oldCount = [self countOfItem:itemId];
//    [_itemDic setObject:@(oldCount + count) forKey:@(itemId)];
}

- (void)decreaseItem:(int)itemId count:(int)count
{
    int oldCount = [self countOfItem:itemId];
//    [_itemDic setObject:@(MAX(oldCount-count, 0)) forKey:@(itemId)];
}

- (void)buyItem:(PBGameItem*)item
          count:(int)count
        handler:(BuyItemResultHandler)handler
{
    if (count <= 0) {
        return;
    }
    
    int balance = [[AccountManager defaultManager] getBalanceWithCurrency:item.priceInfo.currency];
    int totalPrice = [item promotionPrice] * count;
    
    if (balance < totalPrice) {
        PPDebug(@"<buyItem> but balance(%d) not enough, item cost(%d)", balance, totalPrice);
        return;
    }

    dispatch_async(workingQueue, ^{
        
        CommonNetworkOutput* output = [GameNetworkRequest buyItem:TRAFFIC_SERVER_URL appId:[ConfigManager appId] userId:[[UserManager defaultManager] userId] itemId:item.itemId count:count price:totalPrice currency:item.priceInfo.currency toUser:nil];
        
        if (output.resultCode == 0) {
            NSDictionary *dict = [output jsonDataDict];
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // if success, add user item locally
            [self increaseItem:item.itemId count:count];
            
            // if success update user ingot balance locally
            [[AccountManager defaultManager] updateBalance:balance currency:item.priceInfo.currency];

            
            handler(output.resultCode, item.itemId, count, nil);
        });
    });
}

- (void)giveItem:(int)itemId
          toUser:(NSString *)toUserId
           count:(int)count
         handler:(BuyItemResultHandler)handler
{
    return ;
}

- (void)useItem:(int)itemId
         toOpus:(NSString *)toOpusId
        handler:(UseItemResultHandler)handler
{
    return;
}

- (void)clearAllUserItems
{
    
}



@end
