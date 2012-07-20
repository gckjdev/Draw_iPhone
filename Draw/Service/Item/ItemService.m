//
//  ItemService.m
//  Draw
//
//  Created by  on 12-7-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ItemService.h"
#import "AccountService.h"
#import "ItemManager.h"
#import "LevelService.h"
#import "PPDebug.h"
#import "DrawGameService.h"
#import "GameConstants.h"
#import "FeedService.h"

ItemService *_staticItemService = nil;

@implementation ItemService

+ (ItemService *)defaultService
{
    if (_staticItemService == nil) {
        _staticItemService = [[ItemService alloc] init];
    }
    return _staticItemService;
}



- (void)receiveItem:(ItemType)type
{
    int awardAmount = [ItemManager awardAmountByItem:type];
    int awardExp = [ItemManager awardExpByItem:type];
    PPDebug(@"<receiveItem> type=%d, awardAmount=%d, exp=%d",
            type, awardAmount, awardExp);

    // update account
    [[AccountService defaultService] chargeAccount:awardAmount 
                                            source:DirectAwardCoinType 
                                     transactionId:nil 
                                transactionRecepit:nil];
    
    // update experience
    if (awardExp > 0){
        [[LevelService defaultService] addExp:awardExp 
                                     delegate:nil];
    }
    else if (awardExp < 0){
        [[LevelService defaultService] minusExp:-awardExp 
                                       delegate:nil];
    }
}

- (void)sendItemAward:(ItemType)itemType 
         targetUserId:(NSString*)toUserId 
            isOffline:(BOOL)isOffline
           feedOpusId:(NSString*)feedOpusId
           feedAuthor:(NSString*)feedAuthor
{
    int awardAmount = 0;
    int awardExp = 0;
    NSString* targetUserId = nil;
    
    if (isOffline) {
        
        // prepare data for consumeItem request
        targetUserId = toUserId;
        awardAmount = [ItemManager awardAmountByItem:itemType];
        awardExp = [ItemManager awardExpByItem:itemType];
        
        // send feed action
        if (itemType == ItemTypeTomato) {
            [[FeedService defaultService] throwTomatoToOpus:feedOpusId author:feedAuthor delegate:nil];
        }
    if (itemType == ItemTypeFlower) {
        [[FeedService defaultService] throwFlowerToOpus:feedOpusId author:feedAuthor delegate:nil];
    }
        
        
    }else{
        // send online request for online realtime play
        int rankResult = (itemType == ItemTypeFlower) ? RANK_FLOWER : RANK_TOMATO;
        [[DrawGameService defaultService] rankGameResult:rankResult];             
    }
    
    [[AccountService defaultService] consumeItem:itemType 
                                          amount:1 
                                    targetUserId:targetUserId 
                                     awardAmount:awardAmount
                                        awardExp:awardExp];    
    
}


@end
