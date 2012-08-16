//
//  Announce.m
//  Draw
//
//  Created by  on 12-8-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Announce.h"
#import "PPDebug.h"

@implementation Announce
@synthesize type = _type;
@synthesize url = _url;
@synthesize version = _version;

- (id)initWithType:(AnnounceType)type 
           version:(NSString *)version 
               url:(NSString *)url
{
    self = [super init];
    if (self) {
        self.type = type;
        self.version = version;
        self.url = url;
    }
    return self;
}

- (void)dealloc
{
    PPRelease(_version);
    PPRelease(_url);
    [super dealloc];
}

- (Announce *)announceWithType:(AnnounceType)type 
                       version:(NSString *)version 
                           url:(NSString *)url
{
    return [[[Announce alloc] initWithType:type 
                                   version:version 
                                       url:url] autorelease];
}



@end
