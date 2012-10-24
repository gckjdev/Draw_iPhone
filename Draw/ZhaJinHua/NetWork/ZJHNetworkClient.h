//
//  ZJHNetworkClient.h
//  Draw
//
//  Created by 王 小涛 on 12-10-24.
//
//

#import "CommonGameNetworkClient.h"

@interface ZJHNetworkClient : CommonGameNetworkClient

- (void)sendBetRequest:(NSString *)userId
             sessionId:(int)sessionId
             singleBet:(int)singleBet
                 count:(int)count
         isCallStation:(BOOL)isCallStation;



@end
