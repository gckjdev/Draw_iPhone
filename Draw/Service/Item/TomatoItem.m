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
    
    NetworkStatus currentStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    if (currentStatus == NotReachable) {
        EXECUTE_BLOCK(handler, ERROR_NETWORK, [self itemId], NO);
        return;
    }
    
    ConsumeItemResultHandler tempHandler = (ConsumeItemResultHandler)[self.blockArray copyBlock:handler];
    __block typeof (self) bself = self;
        // free for online play game
    [[DrawGameService defaultService] rankGameResult:RANK_TOMATO];
    EXECUTE_BLOCK(tempHandler, ERROR_SUCCESS, [bself itemId], NO);
    [bself.blockArray releaseBlock:tempHandler];
    

}

@end
