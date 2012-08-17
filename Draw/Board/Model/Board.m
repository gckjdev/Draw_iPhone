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
@synthesize status = _status;
@synthesize index = _index;
@synthesize version = _version;

- (id)initWithType:(BoardType)type 
           number:(NSInteger)number 
               url:(NSString *)url
{
    self = [super init];
    if (self) {
        self.type = type;
        self.number = number;
        self.url = url;
    }
    return self;
}

- (void)dealloc
{
    PPRelease(_url);
    [super dealloc];
}

+ (Board *)boardWithType:(BoardType)type 
                 number:(NSInteger)number 
                     url:(NSString *)url;
{
    return [[[Board alloc] initWithType:type 
                                   number:number 
                                       url:url] autorelease];
}



@end
