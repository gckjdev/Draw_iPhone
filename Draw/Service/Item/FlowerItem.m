//
//  FlowerItem.m
//  Draw
//
//  Created by 王 小涛 on 13-3-15.
//
//

#import "FlowerItem.h"
#import "FeedService.h"
#import "PPConfigManager.h"
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
#import "Opus.h"

@implementation FlowerItem

SYNTHESIZE_SINGLETON_FOR_CLASS(FlowerItem);


- (int)itemId
{
    return ItemTypeFlower;
}

// lots of duplicate code, to be improved later
- (void)useItem:(NSString*)toUserId
      isOffline:(BOOL)isOffline
           opus:(Opus*)opus
        forFree:(BOOL)isFree
  resultHandler:(ConsumeItemResultHandler)handler
{
    NSString *opusId = opus.pbOpus.opusId;
    NSString *authorId = opus.pbOpus.author.userId;
    
    int awardAmount = 0;
    int awardExp = 0;
    
    NetworkStatus currentStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    if (currentStatus == NotReachable) {
        EXECUTE_BLOCK(handler, ERROR_NETWORK, [self itemId], NO);
        return;
    }
    
    ConsumeItemResultHandler tempHandler = (ConsumeItemResultHandler)[self.blockArray copyBlock:handler];
    __block typeof (self) bself = self;
    
    if (isOffline) {
        
        // prepare data for consumeItem request
        awardAmount = [PPConfigManager getFlowerAwardAmount];
        awardExp = [PPConfigManager getFlowerAwardExp];
        
        if ([[UserManager defaultManager] isVip]){
            PPDebug(@"user is VIP user, don't need to consume any coin/item for flower");
            isFree = YES;
        }
        
        if (isFree) {
            [[FeedService defaultService] throwItem:[bself itemId]
                                             toOpus:opusId
                                             author:authorId
                                       awardBalance:awardAmount
                                           awardExp:awardExp
                                          contestId:opus.pbOpus.contestId
                                           category:opus.pbOpus.category
                                           delegate:nil];
            EXECUTE_BLOCK(tempHandler, 0, [bself itemId], NO);
            [bself.blockArray releaseBlock:tempHandler];
        }else{
            if ([[UserGameItemManager defaultManager] hasEnoughItem:ItemTypeFlower amount:1]) {
                [[UserGameItemService defaultService] consumeItem:ItemTypeFlower count:1 forceBuy:YES handler:^(int resultCode, int itemId, BOOL isBuy) {
                }];
                [[FeedService defaultService] throwItem:[bself itemId]
                                                 toOpus:opusId
                                                 author:authorId
                                           awardBalance:awardAmount
                                               awardExp:awardExp
                                              contestId:opus.pbOpus.contestId
                                               category:opus.pbOpus.category                 
                                               delegate:nil];
                
                EXECUTE_BLOCK(tempHandler, ERROR_SUCCESS, [bself itemId], NO);
                [bself.blockArray releaseBlock:tempHandler];
            }else if([[UserGameItemService defaultService] hasEnoughBalanceToBuyItem:ItemTypeFlower count:1]){
                [[UserGameItemService defaultService] consumeItem:ItemTypeFlower count:1 forceBuy:YES handler:^(int resultCode, int itemId, BOOL isBuy) {
                }];
                [[FeedService defaultService] throwItem:[bself itemId]
                                                 toOpus:opusId
                                                 author:authorId
                                           awardBalance:awardAmount
                                               awardExp:awardExp
                                              contestId:opus.pbOpus.contestId
                                               category:opus.pbOpus.category
                                               delegate:nil];
                
                EXECUTE_BLOCK(tempHandler, ERROR_SUCCESS, [bself itemId], YES);
                [bself.blockArray releaseBlock:tempHandler];
            }else{
                EXECUTE_BLOCK(tempHandler, ERROR_BALANCE_NOT_ENOUGH, [bself itemId], YES);
                [bself.blockArray releaseBlock:tempHandler];
            }
        }
        
    }else{
        // free for online play game
        [[DrawGameService defaultService] rankGameResult:RANK_FLOWER];
        EXECUTE_BLOCK(tempHandler, ERROR_SUCCESS, [bself itemId], NO);
        [bself.blockArray releaseBlock:tempHandler];
    }
}


- (void)useItem:(NSString*)toUserId
      isOffline:(BOOL)isOffline
       drawFeed:(DrawFeed*)drawFeed
        forFree:(BOOL)isFree
  resultHandler:(ConsumeItemResultHandler)handler
{
    int awardAmount = 0;
    int awardExp = 0;    
    
    NetworkStatus currentStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    if (currentStatus == NotReachable) {
        EXECUTE_BLOCK(handler, ERROR_NETWORK, [self itemId], NO);
        return;
    }
    
    ConsumeItemResultHandler tempHandler = (ConsumeItemResultHandler)[self.blockArray copyBlock:handler];
    __block typeof (self) bself = self;

    if ([[UserManager defaultManager] isVip]){
        PPDebug(@"user is VIP user, don't need to consume any coin/item for flower");
        isFree = YES;
    }    
    
    if (isOffline) {

        // prepare data for consumeItem request
        awardAmount = [PPConfigManager getFlowerAwardAmount];
        awardExp = [PPConfigManager getFlowerAwardExp];
        
        if (isFree) {
            [[FeedService defaultService] throwItem:[bself itemId]
                                             toOpus:drawFeed.feedId
                                             author:drawFeed.feedUser.userId
                                       awardBalance:awardAmount
                                           awardExp:awardExp
                                          contestId:drawFeed.contestId
                                           category:drawFeed.categoryType             
                                           delegate:nil];
            EXECUTE_BLOCK(tempHandler, 0, [bself itemId], NO);
            [bself.blockArray releaseBlock:tempHandler];
        }else{
            if ([[UserGameItemManager defaultManager] hasEnoughItem:ItemTypeFlower amount:1]) {
                [[UserGameItemService defaultService] consumeItem:ItemTypeFlower count:1 forceBuy:YES handler:^(int resultCode, int itemId, BOOL isBuy) {
                }];
                [[FeedService defaultService] throwItem:[bself itemId]
                                                 toOpus:drawFeed.feedId
                                                 author:drawFeed.feedUser.userId
                                           awardBalance:awardAmount
                                               awardExp:awardExp
                                              contestId:drawFeed.contestId
                                               category:drawFeed.categoryType
                                               delegate:nil];
                
                EXECUTE_BLOCK(tempHandler, ERROR_SUCCESS, [bself itemId], NO);
                [bself.blockArray releaseBlock:tempHandler];
            }else if([[UserGameItemService defaultService] hasEnoughBalanceToBuyItem:ItemTypeFlower count:1]){
                [[UserGameItemService defaultService] consumeItem:ItemTypeFlower count:1 forceBuy:YES handler:^(int resultCode, int itemId, BOOL isBuy) {
                }];
                [[FeedService defaultService] throwItem:[bself itemId]
                                                 toOpus:drawFeed.feedId
                                                 author:drawFeed.feedUser.userId
                                           awardBalance:awardAmount
                                               awardExp:awardExp
                                              contestId:drawFeed.contestId
                                               category:drawFeed.categoryType                 
                                               delegate:nil];
                
                EXECUTE_BLOCK(tempHandler, ERROR_SUCCESS, [bself itemId], YES);
                [bself.blockArray releaseBlock:tempHandler];
            }else{
                EXECUTE_BLOCK(tempHandler, ERROR_BALANCE_NOT_ENOUGH, [bself itemId], YES);
                [bself.blockArray releaseBlock:tempHandler];
            }
        }

    }else{
        // free for online play game
        [[DrawGameService defaultService] rankGameResult:RANK_FLOWER];
        EXECUTE_BLOCK(tempHandler, ERROR_SUCCESS, [bself itemId], NO);
        [bself.blockArray releaseBlock:tempHandler];        
    }
}

@end
