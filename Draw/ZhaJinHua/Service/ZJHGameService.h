//
//  ZJHGameService.h
//  Draw
//
//  Created by 王 小涛 on 12-10-24.
//
//

#import "CommonGameNetworkService.h"
#import "ZJHGameState.h"
#import "ZJHGameNotification.h"
#import "AccountService.h"
#import "UserService.h"

@interface ZJHGameService : CommonGameNetworkService <AccountServiceDelegate, UserServiceDelegate>

@property (readonly, retain, nonatomic) ZJHGameState *gameState;
@property (retain, nonatomic) NSArray *chipValues;
@property (assign, nonatomic) PBZJHUserAction timeoutAcion;


+ (ZJHGameService*)defaultService;

- (ZJHUserPlayInfo *)userPlayInfo:(NSString *)userId;
- (ZJHUserPlayInfo *)myPlayInfo;

- (NSArray *)pokersOfUser:(NSString *)userId;
- (int)betCountOfUser:(NSString *)userId;
- (int)totalBetOfUser:(NSString *)userId;

- (void)bet:(BOOL)autoBet;                      // 跟注
- (void)raiseBet:(int)singleBet;                // 加注
- (void)setAutoBet:(BOOL)isAutobet;
- (BOOL)isMeAutoBet;
//- (void)autoBet;                                // 自动跟注

- (void)checkCard;                              // 看牌
- (void)foldCard;                               // 弃牌
- (void)compareCard:(NSString*)toUserId;        // 比牌
- (void)showCard:(int)cardId;                   // 亮牌(单张)
//- (void)showCards:(NSArray *)cardIds;           // 亮牌(多张)；目前该接口没用到
- (void)changeCard:(int)cardId;

- (BOOL)isMyBalanceEnough;

- (BOOL)canIBet;
- (BOOL)canIRaiseBet;
- (BOOL)canIAutoBet;
- (BOOL)canICheckCard;
- (BOOL)canIFoldCard;
- (BOOL)canICompareCard;
- (BOOL)canIShowCard:(int)cardId;

- (BOOL)canUserBeCompared:(NSString *)userId;
- (BOOL)canIChangeCard:(int)cardId;

- (PBZJHCardType)myCardType;
- (NSString *)myCardTypeString;

- (NSString *)cardTypeOfUser:(NSString *)userId;
- (BOOL)doIWin;
- (NSString *)winner;
- (int)myBalance;
- (int)balanceOfUser:(NSString *)userId;
- (int)levelOfUser:(NSString *)userId;

- (NSArray *)compareUserIdList;

- (BOOL)canIQuitGameDirectly;
//- (NSString *)getRoomName;

- (void)chargeCoin:(int)amount
               source:(BalanceSourceType)source;
- (void)syncAccount:(id<AccountServiceDelegate>)delegate;

- (NSArray *)myReplacedCards;
- (NSArray *)replacedCardsOfUser:(NSString *)userId;

- (void)reset;

- (void)setTimeoutSettingWithAction:(PBZJHUserAction)action;
- (BOOL)canISetTimeoutSetting;


@end
