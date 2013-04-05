//
//  TomatoItem.m
//  Draw
//
//  Created by 王 小涛 on 13-3-15.
//
//

#import "TomatoItem.h"
#import "FeedService.h"
#import "ConfigManager.h"
#import "DrawGameService.h"
#import "AccountService.h"
#import "GameConstants.h"
#import "UserGameItemService.h"
#import "GameNetworkConstants.h"
#import "PPNetworkRequest.h"
#import "BlockUtils.h"
#import "SynthesizeSingleton.h"
#import "BlockArray.h"
#import "Reachability.h"
#import "AccountManager.h"
#import "UserGameItemManager.h"

@implementation TomatoItem

SYNTHESIZE_SINGLETON_FOR_CLASS(TomatoItem);


- (int)itemId
{
    return ItemTypeTomato;
}

- (void)useItem:(NSString*)toUserId
      isOffline:(BOOL)isOffline
     feedOpusId:(NSString*)feedOpusId
     feedAuthor:(NSString*)feedAuthor
        forFree:(BOOL)isFree
  resultHandler:(ConsumeItemResultHandler)handler
{
//    int awardAmount = 0;
//    int awardExp = 0;    
    
    NetworkStatus currentStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    if (currentStatus == NotReachable) {
        EXECUTE_BLOCK(handler, ERROR_NETWORK, [self itemId], NO);
        return;
    }
    
    ConsumeItemResultHandler tempHandler = (ConsumeItemResultHandler)[self.blockArray copyBlock:handler];
    __block typeof (self) bself = self;

//    if (isOffline) {
//
//        // prepare data for consumeItem request
//        awardAmount = [ConfigManager getTomatoAwardAmount];
//        awardExp = [ConfigManager getTomatoAwardExp];
//        
//        if (isFree) {
//            [[FeedService defaultService] throwItem:[bself itemId]
//                                             toOpus:feedOpusId
//                                             author:feedAuthor
//                                       awardBalance:awardAmount
//                                           awardExp:awardExp
//                                           delegate:nil];
//            EXECUTE_BLOCK(tempHandler, 0, [bself itemId], NO);
//            [bself.blockArray releaseBlock:tempHandler];
//        }else{
//            if ([[UserGameItemManager defaultManager] hasEnoughItem:ItemTypeTomato amount:1]) {
//                [[UserGameItemService defaultService] consumeItem:ItemTypeTomato count:1 forceBuy:YES handler:^(int resultCode, int itemId, BOOL isBuy) {
//                }];
//                [[FeedService defaultService] throwItem:[bself itemId]
//                                                 toOpus:feedOpusId
//                                                 author:feedAuthor
//                                           awardBalance:awardAmount
//                                               awardExp:awardExp
//                                               delegate:nil];
//                
//                EXECUTE_BLOCK(tempHandler, ERROR_SUCCESS, [bself itemId], NO);
//                [bself.blockArray releaseBlock:tempHandler];
//            }else if([[UserGameItemService defaultService] hasEnoughBalanceToBuyItem:ItemTypeTomato count:1]){
//                [[UserGameItemService defaultService] consumeItem:ItemTypeTomato count:1 forceBuy:YES handler:^(int resultCode, int itemId, BOOL isBuy) {
//                }];
//                [[FeedService defaultService] throwItem:[bself itemId]
//                                                 toOpus:feedOpusId
//                                                 author:feedAuthor
//                                           awardBalance:awardAmount
//                                               awardExp:awardExp
//                                               delegate:nil];
//                
//                EXECUTE_BLOCK(tempHandler, ERROR_SUCCESS, [bself itemId], YES);
//                [bself.blockArray releaseBlock:tempHandler];
//            }else{
//                EXECUTE_BLOCK(tempHandler, ERROR_BALANCE_NOT_ENOUGH, [bself itemId], YES);
//                [bself.blockArray releaseBlock:tempHandler];
//            }
//        }
//
//    }else{
        // free for online play game
    [[DrawGameService defaultService] rankGameResult:RANK_TOMATO];
    EXECUTE_BLOCK(tempHandler, ERROR_SUCCESS, [bself itemId], NO);
    [bself.blockArray releaseBlock:tempHandler];
    
//    if ([[UserGameItemManager defaultManager] hasEnoughItem:ItemTypeTomato amount:1]) {
//        [[UserGameItemService defaultService] consumeItem:ItemTypeTomato count:1 forceBuy:YES handler:^(int resultCode, int itemId, BOOL isBuy) {
//        }];
//        [[DrawGameService defaultService] rankGameResult:RANK_TOMATO];
//        EXECUTE_BLOCK(tempHandler, ERROR_SUCCESS, [bself itemId], NO);
//        [bself.blockArray releaseBlock:tempHandler];
//        
//    }else if([[UserGameItemService defaultService] hasEnoughBalanceToBuyItem:ItemTypeTomato count:1]){
//        [[UserGameItemService defaultService] consumeItem:ItemTypeTomato count:1 forceBuy:YES handler:^(int resultCode, int itemId, BOOL isBuy) {
//        }];
//        [[DrawGameService defaultService] rankGameResult:RANK_TOMATO];
//        EXECUTE_BLOCK(tempHandler, ERROR_SUCCESS, [bself itemId], YES);
//        [bself.blockArray releaseBlock:tempHandler];
//    }else{
//        EXECUTE_BLOCK(tempHandler, ERROR_BALANCE_NOT_ENOUGH, [bself itemId], YES);
//        [bself.blockArray releaseBlock:tempHandler];
//    }
}

@end
