//
//  Board.m
//  Draw
//
//  Created by  on 12-8-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Board.h"
#import "PPDebug.h"

@implementation Board
@synthesize type = _type;
@synthesize url = _url;
@synthesize version = _version;

- (id)initWithType:(BoardType)type 
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

- (Board *)BoardWithType:(BoardType)type 
                       version:(NSString *)version 
                           url:(NSString *)url
{
    return [[[Board alloc] initWithType:type 
                                   version:version 
                                       url:url] autorelease];
}



@end
