//
//  FlowerItem.m
//  Draw
//
//  Created by 王 小涛 on 13-3-15.
//
//

#import "FlowerItem.h"
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

@implementation FlowerItem

SYNTHESIZE_SINGLETON_FOR_CLASS(FlowerItem);


- (int)itemId
{
    return ItemTypeFlower;
}

- (void)useItem:(NSString*)toUserId
      isOffline:(BOOL)isOffline
     feedOpusId:(NSString*)feedOpusId
     feedAuthor:(NSString*)feedAuthor
        forFree:(BOOL)isFree
  resultHandler:(ConsumeItemResultHandler)handler
{
    int awardAmount = 0;
    int awardExp = 0;
    NSString* targetUserId = nil;
    
    ConsumeItemResultHandler tempHandler = (ConsumeItemResultHandler)[self.blockArray copyBlock:handler];
    __block typeof (self) bself = self;

    if (isOffline) {

        // prepare data for consumeItem request
        targetUserId = toUserId;
        awardAmount = [ConfigManager getFlowerAwardAmount];
        awardExp = [ConfigManager getFlowerAwardExp];
        
        if (!isFree) {
            [[UserGameItemService defaultService] consumeItem:ItemTypeFlower count:1 forceBuy:YES handler:^(int resultCode, int itemId, BOOL isBuy) {
                if (resultCode == ERROR_SUCCESS) {
                    // send feed action
                    [[FeedService defaultService] throwItem:[bself itemId]
                                                     toOpus:feedOpusId
                                                     author:feedAuthor
                                                   delegate:nil];
                }
                
                EXCUTE_BLOCK(tempHandler, 0, [bself itemId], isBuy);
                [bself.blockArray releaseBlock:tempHandler];
            }];
        }else{
            // send feed action
            [[FeedService defaultService] throwItem:[bself itemId]
                                             toOpus:feedOpusId
                                             author:feedAuthor
                                           delegate:nil];
            EXCUTE_BLOCK(tempHandler, 0, [bself itemId], NO);
            [bself.blockArray releaseBlock:tempHandler];
        }

    }else{
        int rankResult = RANK_FLOWER;
        
        if (!isFree) {
            [[UserGameItemService defaultService] consumeItem:[self itemId] count:1 forceBuy:YES handler:^(int resultCode, int itemId, BOOL isBuy) {
                if (resultCode == ERROR_SUCCESS) {
                    [[DrawGameService defaultService] rankGameResult:rankResult];
                    EXCUTE_BLOCK(tempHandler, 0, [bself itemId], isBuy);
                    [bself.blockArray releaseBlock:tempHandler];
                }
            }];
        }else{
            [[DrawGameService defaultService] rankGameResult:rankResult];
            EXCUTE_BLOCK(tempHandler, 0, [bself itemId], NO);
            [bself.blockArray releaseBlock:tempHandler];
        }
    }
}

@end