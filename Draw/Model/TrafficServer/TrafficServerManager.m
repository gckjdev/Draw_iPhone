//
//  TrafficServerManager.m
//  Draw
//
//  Created by  on 12-3-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TrafficServerManager.h"

@implementation TrafficServerManager

static TrafficServerManager* _defaultManager;

@synthesize serverList = _serverList;

- (void)dealloc
{
    [_serverList release];
    [super dealloc];
}

+ (TrafficServerManager*)defaultManager
{
    if (_defaultManager == nil){
        _defaultManager = [[TrafficServerManager alloc] init];
    }
    
    return _defaultManager;
}

- (id)init
{
    self = [super init];
    self.serverList = [[[NSMutableArray alloc] init] autorelease];
    return self;
}

- (void)addTrafficServer:(TrafficServer*)server
{
    [_serverList addObject:server];
}

- (void)clearAllServers
{
    [self.serverList removeAllObjects];
}

- (BOOL)hasData
{
    return [_serverList count] > 0;
}



@end
