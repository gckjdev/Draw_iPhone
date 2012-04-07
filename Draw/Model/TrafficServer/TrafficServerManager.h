//
//  TrafficServerManager.h
//  Draw
//
//  Created by  on 12-3-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonService.h"
#import "RouterTrafficServer.h"

@interface TrafficServerManager : NSObject

//@property (nonatomic, retain) NSMutableArray* serverList;

+ (TrafficServerManager*)defaultManager;

- (void)clearAllServers;
- (NSArray*)findAllTrafficServers;
- (BOOL)hasData;


- (void)createTrafficServer:(NSString*)address
                       port:(int)port
                   language:(int)language;


@end
