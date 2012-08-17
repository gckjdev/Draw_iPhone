//
//  Board.m
//  Draw
//
//  Created by  on 12-8-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Board.h"
#import "PPDebug.h"
#import "BoardNetworkConstant.h"

@implementation Board
@synthesize type = _type;
@synthesize status = _status;
@synthesize index = _index;
@synthesize version = _version;

+(Board *)createBoardWithDictionary:(NSDictionary *)dict
{
    BoardType type = [(NSNumber *)[dict objectForKey:PARA_TYPE] intValue];
    switch (type) {
        case BoardTypeAd:
            return [[[AdBoard alloc] initWithDictionary:dict] autorelease];
        case BoardTypeWeb:
            return [[[WebBoard alloc] initWithDictionary:dict] autorelease];
        case BoardTypeImage:
            return [[[ImageBoard alloc] initWithDictionary:dict] autorelease];
        default:
            return nil;
    }
}

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        
        self.type = [(NSNumber *)[dict objectForKey:PARA_TYPE] intValue];
        self.index = [(NSNumber *)[dict objectForKey:PARA_INDEX] intValue];
        self.status = [(NSNumber *)[dict objectForKey:PARA_STATUS] intValue];
        self.version = [dict objectForKey:PARA_VERSION];
    }
    return self;
}
/*
- (id)initWithType:(BoardType)type 
            status:(BoardStatus)status  
             index:(NSInteger)index
           version:(NSString *)version
{
    self = [super init];
    if (self) {
        self.type = type;
        self.status = status;
        self.index = index;
        self.version= version;
    }
    return self;
}
*/
- (void)dealloc
{
    PPRelease(_version);
    [super dealloc];
}
- (BOOL)isRunning
{
    return self.status == BoardStatusRun;
}

@end



@implementation AdBoard
@synthesize addList = _addList;
@synthesize number = _number;

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super initWithDictionary:dict];
    if (self) {
    
        self.number = [(NSNumber *)[dict objectForKey:PARA_AD_NUMBER] intValue];
        self.addList = [dict objectForKey:PARA_ADLIST];

//#define PARA_AD_PLATFORM @"adp"
//#define PARA_AD_PUBLISH_ID @"adpid"        
    }
    return self;
}


- (void)dealloc
{
    PPRelease(_addList);
    [super dealloc];
}

@end


@implementation WebBoard
@synthesize remoteUrl = _remoteUrl;
@synthesize localUrl = _localUrl;
@synthesize webType = _webType;

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super initWithDictionary:dict];
    if (self) {
        self.webType = [(NSNumber *)[dict objectForKey:PARA_WEB_TYPE] integerValue];
        self.remoteUrl = [dict objectForKey:PARA_REMOTE_URL];
        self.localUrl = [dict objectForKey:PARA_LOCAL_URL];       
    }
    return self;
}

-(void)dealloc
{
    PPRelease(_remoteUrl);
    PPRelease(_localUrl);
    [super dealloc];
}

@end


@implementation ImageBoard
@synthesize imageUrl = _imageUrl;
@synthesize clickUrl = _clickUrl;

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super initWithDictionary:dict];
    if (self) {
        self.imageUrl = [dict objectForKey:PARA_IMAGE_URL];
        self.clickUrl = [dict objectForKey:PARA_IMAGE_CLICK_URL];
    }
    return self;
}

- (void)dealloc
{
    PPRelease(_imageUrl);
    PPRelease(_clickUrl);
    [super dealloc];
}

@end


