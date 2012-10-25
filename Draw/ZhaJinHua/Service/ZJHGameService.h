//
//  ZJHGameService.h
//  Draw
//
//  Created by 王 小涛 on 12-10-24.
//
//

#import "CommonGameNetworkService.h"
#import "ZJHGameSession.h"

@interface ZJHGameService : CommonGameNetworkService

+ (ZJHGameService*)defaultService;

- (ZJHGameSession *)ZJHGameSession;

- (void)bet;                                    // 跟注
- (void)raiseBet;                               // 加注
- (void)autoBet;                                // 自动跟注

- (void)checkCard;                              // 看牌
- (void)foldCard;                               // 弃牌
- (void)compareCard:(NSString*)toUserId;        // 比牌
- (void)showCard:(NSArray *)cardIds;            // 亮牌

@end
