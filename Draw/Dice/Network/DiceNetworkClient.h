//
//  DiceNetworkClient.h
//  Draw
//
//  Created by  on 12-7-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonGameNetworkClient.h"

@interface DiceNetworkClient : CommonGameNetworkClient

- (void)sendCallDiceRequest:(NSString*)userId
                  sessionId:(int)sessionId
                       dice:(int)dice
                      count:(int)count;

@end
