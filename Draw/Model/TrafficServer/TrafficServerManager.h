//
//  TrafficServerManager.h
//  Draw
//
//  Created by  on 12-3-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonService.h"
#import "TrafficServer.h"

@interface TrafficServerManager : NSObject

@property (nonatomic, retain) NSMutableArray* serverList;

+ (TrafficServerManager*)defaultManager;

- (void)clearAllServers;
- (void)addTrafficServer:(TrafficServer*)server;
- (BOOL)hasData;


@end
