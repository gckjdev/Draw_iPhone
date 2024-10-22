//
//  RouterTrafficServer.m
//  Draw
//
//  Created by  on 12-4-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RouterTrafficServer.h"


@implementation RouterTrafficServer

@dynamic address;
@dynamic capacity;
@dynamic createDate;
@dynamic language;
@dynamic lastModified;
@dynamic port;
@dynamic serverKey;
@dynamic usage;

- (NSString*)key
{
    return [NSString stringWithFormat:@"%@:%d", self.address, [self.port intValue]];
}

+ (NSString*)keyWithServerAddress:(NSString*)address port:(int)port
{
    return [NSString stringWithFormat:@"%@:%d", address, port];    
}


@end
