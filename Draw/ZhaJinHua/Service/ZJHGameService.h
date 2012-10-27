//
//  ZJHGameService.h
//  Draw
//
//  Created by 王 小涛 on 12-10-24.
//
//

#import "CommonGameNetworkService.h"
#import "ZJHGameState.h"

@interface ZJHGameService : CommonGameNetworkService

@property (readonly, retain, nonatomic) ZJHGameState *gameState;

+ (ZJHGameService*)defaultService;

- (void)bet;                                    // 跟注
- (void)raiseBet:(int)singleBet;                // 加注
- (void)autoBet;                                // 自动跟注

- (void)checkCard;                              // 看牌
- (void)foldCard;                               // 弃牌
- (void)compareCard:(NSString*)toUserId;        // 比牌
- (void)showCard:(int)cardId;            // 亮牌(单张)
- (void)showCards:(NSArray *)cardIds;            // 亮牌(多张)；目前该接口没用到

@end
