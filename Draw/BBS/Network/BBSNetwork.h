//
//  BBSNetwork.h
//  Draw
//
//  Created by gamy on 12-11-14.
//
//

#import <Foundation/Foundation.h>
#import "GameNetworkConstants.h"
#import "PPNetworkConstants.h"
@class CommonNetworkOutput;

@interface BBSNetwork : NSObject

+ (CommonNetworkOutput*)getBBSBoardList:(NSString*)baseURL
                                  appId:(NSString*)appId
                                 userId:(NSString*)userId
                             deviceType:(int)deviceType;

@end
