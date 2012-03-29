//
//  TrafficServer.m
//  Draw
//
//  Created by  on 12-3-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TrafficServer.h"

@implementation TrafficServer

@synthesize serverAddress = _serverAddress;
@synthesize port = _port;
@synthesize language = _language;
@synthesize usage = _usage;
@synthesize capcity = _capcity;

- (void)dealloc
{
    [_serverAddress release];
    [super dealloc];
}

- (id)initWithServerAddress:(NSString *)address 
                       port:(int)port 
                   language:(int)language 
                      usage:(int)usage 
                   capacity:(int)capacity           
{
    self = [super init];
    self.serverAddress = address;
    self.port = port;
    self.capcity = capacity;
    self.language = language;
    self.usage = usage;
    return self;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"[TrafficServer, address=%@, port=%d, language=%d, usage=%d, capacity=%d]",
            _serverAddress, _port, _language, _usage, _capcity];
}

- (NSString*)key
{
    return [NSString stringWithFormat:@"%@:%d", _serverAddress, _port];
}

+ (NSString*)keyWithServerAddress:(NSString*)address port:(int)port
{
    return [NSString stringWithFormat:@"%@:%d", address, port];    
}

@end
