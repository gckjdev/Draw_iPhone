//
//  ZJHNetworkClient.h
//  Draw
//
//  Created by 王 小涛 on 12-10-24.
//
//

#import "CommonGameNetworkClient.h"

@interface CommonGameNetworkClient (ZJHNetworkClient)

- (void)sendBetRequest:(NSString *)userId
             sessionId:(int)sessionId
             singleBet:(int)singleBet
                 count:(int)count
             isAutoBet:(BOOL)isAutoBet;

- (void)sendCheckCardRequest:(NSString *)userId
                   sessionId:(int)sessionId;

- (void)sendFoldCardRequest:(NSString *)userId
              sessionId:(int)sessionId;

- (void)sendCompareCardRequest:(NSString *)userId
                     sessionId:(int)sessionId
                      toUserId:(NSString *)toUserId;

- (void)sendShowCardRequest:(NSString *)userId
                  sessionId:(int)sessionId
                    cardIds:(NSArray *)cardIds;

- (void)sendChangeCardRequest:(NSString *)userId
                    sessionId:(int)sessionId
                       cardId:(int)cardId;

- (void)sendTimeoutSettingRequest:(NSString *)userId
                         sessionId:(int)sessionId
                            action:(int)action;


@end
