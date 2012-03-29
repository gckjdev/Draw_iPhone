//
//  RouterService.m
//  Draw
//
//  Created by  on 12-3-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RouterService.h"
#import "GameNetworkRequest.h"
#import "GameNetworkConstants.h"
#import "PPNetworkRequest.h"
#import "TrafficServer.h"
#import "TrafficServerManager.h"

#define ROUTER_SERVER_URL   @"http://192.168.1.198:8600/api/?"

@implementation RouterService

static RouterService* _defaultRouterService;



- (void)dealloc
{

    [super dealloc];
}

+ (RouterService*)defaultService
{
    if (_defaultRouterService == nil)
        _defaultRouterService = [[RouterService alloc] init];
    
    return _defaultRouterService;
}

- (id)init
{
    self = [super init];
    return self;
}

- (void)fetchServerList:(id<RouterServiceDelegate>)delegate
{
    dispatch_async(workingQueue, ^{
        CommonNetworkOutput* output = [GameNetworkRequest getAllTrafficeServers:ROUTER_SERVER_URL];
        if (output.resultCode == 0){
            
            NSArray* jsonArray = output.jsonDataArray;
            TrafficServerManager* manager = [TrafficServerManager defaultManager];
            
            if ([jsonArray count] > 0){
                [manager clearAllServers];
            }
            
            for (NSDictionary* server in jsonArray){
                TrafficServer* trafficServer = 
                    [[TrafficServer alloc] initWithServerAddress:[server objectForKey:PARA_SERVER_ADDRESS]
                                                            port:[[server objectForKey:PARA_SERVER_PORT] intValue]
                                                        language:[[server objectForKey:PARA_SERVER_LANGUAGE] intValue]
                                                           usage:[[server objectForKey:PARA_SERVER_USAGE] intValue]                     
                                                        capacity:[[server objectForKey:PARA_SERVER_CAPACITY] intValue]];
                
                
                [manager addTrafficServer:trafficServer];
            }
        }
        
        if ([delegate respondsToSelector:@selector(didServerListFetched:)]){
            [delegate didServerListFetched:output.resultCode];
        }
    });
}

@end
