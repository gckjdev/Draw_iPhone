//
//  AnnounceNetwork.h
//  Draw
//
//  Created by  on 12-8-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CommonNetworkOutput;

@interface BoardNetwork : NSObject
+ (CommonNetworkOutput*)getBoards:(NSString*)baseURL
                            appId:(NSString*)appId
                           gameId:(NSString*)gameId
                       deviceType:(int)deviceType; //ipad iphone?

+ (CommonNetworkOutput*)updateBoardStatictic:(NSString*)baseURL
                            appId:(NSString*)appId
                           gameId:(NSString*)gameId 
                          boardId:(NSString *)boardId
                           userId:(NSString *)userId
                       deviceType:(int)deviceType; //ipad iphone?

@end
