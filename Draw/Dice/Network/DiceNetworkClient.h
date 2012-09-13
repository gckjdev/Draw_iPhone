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
                      count:(int)count
                      wilds:(BOOL)wilds;


//- (void)sendCallDiceRequest:(NSString*)userId
//                  sessionId:(int)sessionId
//                       dice:(int)dice
//                      count:(int)count;

- (void)sendOpenDiceRequest:(NSString*)userId
                  sessionId:(int)sessionId
                   openType:(int)openType
                   multiple:(int)multiple;     


- (void)sendUserItemRequest:(NSString*)userId
                  sessionId:(int)sessionId
                     itemId:(int)itemId;
- (void)sendUserItemRequest:(NSString*)userId
                  sessionId:(int)sessionId
                     itemId:(int)itemId 
                 extendTime:(int)extendTime;
@end
