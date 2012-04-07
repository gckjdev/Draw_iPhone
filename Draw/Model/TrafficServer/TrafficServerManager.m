//
//  TrafficServerManager.m
//  Draw
//
//  Created by  on 12-3-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TrafficServerManager.h"
#import "CoreDataUtil.h"
#import "PPDebug.h"

@implementation TrafficServerManager

static TrafficServerManager* _defaultManager;

//@synthesize serverList = _serverList;

- (void)dealloc
{
//    [_serverList release];
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
//    self.serverList = [[[NSMutableArray alloc] init] autorelease];
    return self;
}

//- (void)addTrafficServer:(TrafficServer*)server
//{
//    [_serverList addObject:server];
//}

- (void)clearAllServers
{
    PPDebug(@"clearAllServers");
//    [self.serverList removeAllObjects];
    
    NSArray* allServers = [[CoreDataManager defaultManager] execute:@"findAllTrafficServers"];
    for (RouterTrafficServer* server in allServers){
        [[CoreDataManager defaultManager] del:server];
    }
}

- (NSArray*)findAllTrafficServers
{
    NSArray* allServers = [[CoreDataManager defaultManager] execute:@"findAllTrafficServers"];
    return allServers;
}

- (BOOL)hasData
{
    return [[self findAllTrafficServers] count] > 0;
}

- (void)createTrafficServer:(NSString*)address
                       port:(int)port
                   language:(int)language
{
    RouterTrafficServer* server = [[CoreDataManager defaultManager] insert:@"RouterTrafficServer"];
    [server setPort:[NSNumber numberWithInt:port]];
    [server setLanguage:[NSNumber numberWithInt:language]];
    [server setAddress:address];
    [server setServerKey:[RouterTrafficServer keyWithServerAddress:address port:port]];
    [server setCreateDate:[NSDate date]];
    [server setLastModified:[NSDate date]];
    
    [[CoreDataManager defaultManager] save];
    
    PPDebug(@"createTrafficServer (%@)", [server description]);
}




@end
