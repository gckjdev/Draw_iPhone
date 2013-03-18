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

//- (void)excuteAction//WithParameters//:(NSDictionary *)parameters
//{
//    NSString *toUserId = [_parameters objectForKey:PARA_KEY_USER_ID];
//    NSString *opusId = [_parameters objectForKey:PARA_KEY_OPUS_ID];
//
//    // send feed action
//    [[FeedService defaultService] throwItem:[self itemId]
//                                     toOpus:opusId
//                                     author:toUserId
//                                   delegate:nil];
//}



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
    
    if (isOffline) {
        __block typeof (self) bself = self;

        // prepare data for consumeItem request
        targetUserId = toUserId;
        awardAmount = [ConfigManager getFlowerAwardAmount];
        awardExp = [ConfigManager getFlowerAwardExp];
        
        if (!isFree) {
            [[UserGameItemService defaultService] consumeItem:ItemTypeFlower count:1 forceBuy:YES handler:^(int resultCode, int itemId) {
                if (resultCode == ERROR_SUCCESS) {
                    // send feed action
                    [[FeedService defaultService] throwItem:[bself itemId]
                                                     toOpus:feedOpusId
                                                     author:feedAuthor
                                                   delegate:nil];
                }
                
                EXCUTE_BLOCK(tempHandler, 0, [bself itemId]);
                [bself.blockArray releaseBlock:tempHandler];
            }];
        }

    }else{
        // send online request for online realtime play
        int rankResult = RANK_FLOWER;
        [[DrawGameService defaultService] rankGameResult:rankResult];
        [[AccountService defaultService] consumeItem:[self itemId]
                                              amount:isFree?0:1
                                        targetUserId:targetUserId
                                         awardAmount:isFree?0:awardAmount
                                            awardExp:isFree?0:awardExp];

        EXCUTE_BLOCK(tempHandler, 0, [self itemId]);
        [self.blockArray releaseBlock:tempHandler];                
    }
}

@end
