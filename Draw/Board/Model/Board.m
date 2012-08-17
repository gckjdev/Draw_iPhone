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

+(Board *)createBoardWithDictionary:(NSDictionary *)dict
{
    
}

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

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


