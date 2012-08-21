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
#import "FileUtil.h"

@implementation Board
@synthesize type = _type;
@synthesize status = _status;
@synthesize index = _index;
@synthesize version = _version;
@synthesize boardId = _boardId;


+(Board *)createBoardWithDictionary:(NSDictionary *)dict
{
    if (![dict respondsToSelector:@selector(objectForKey:)]) {
        return nil;
    }
    
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
        self.boardId = [dict objectForKey:PARA_BOARDID];
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
    PPRelease(_boardId);
    [super dealloc];
}
- (BOOL)isRunning
{
    return self.status == BoardStatusRun;
}

@end



@implementation AdBoard
@synthesize adList = _adList;
@synthesize number = _number;

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super initWithDictionary:dict];
    if (self) {
    
        self.number = [(NSNumber *)[dict objectForKey:PARA_AD_NUMBER] intValue];
        NSArray *adList = [dict objectForKey:PARA_ADLIST];
        NSMutableArray *temp = [NSMutableArray array];
        for (NSDictionary *subDict in adList) {
            
            //sure it is a dict
            if ([subDict respondsToSelector:@selector(objectForKey:)]) {
                AdObject *ad= [[AdObject alloc] initWithDict:subDict];
                [temp addObject:ad];
            }
        }
        self.adList = temp;
    }
    return self;
}


- (void)dealloc
{
    PPRelease(_adList);
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

#define LOCAL_HTML_DIR @"localHtml"
#define LOCAL_URL_KEY_PREFIX @"lu_"

- (NSString *)boardLocalHtmlDir
{
    NSString *path = [FileUtil getAppHomeDir];
    path = [path stringByAppendingPathComponent:LOCAL_HTML_DIR];
    path = [path stringByAppendingPathComponent:self.boardId];
    BOOL flag = [FileUtil createDir:path];
    if (flag) {
        return path;        
    }
    return nil;
}


- (NSString *)saveKey
{
    return [NSString stringWithFormat:@"%@%@_%@",LOCAL_URL_KEY_PREFIX,self.boardId,self.version];
}

- (void)saveLocalURL:(NSURL *)URL
{
    if (URL) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setURL:URL forKey:[self saveKey]];
        [defaults synchronize];
    }
}

- (NSURL *)localURL
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [self saveKey];
    return  [defaults URLForKey:key];
}

- (NSURL *)remoteURL
{
    return [NSURL URLWithString:self.remoteUrl];
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


@implementation AdObject

@synthesize platform = _platform;
@synthesize publishId = _publishId;

- (id)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.platform = [dict objectForKey:PARA_AD_PLATFORM];
        self.publishId = [dict objectForKey:PARA_AD_PUBLISH_ID];
    }
    return self;
}

- (void)dealloc
{
    PPRelease(_platform);
    PPRelease(_publishId);
    [super dealloc];
}

@end

