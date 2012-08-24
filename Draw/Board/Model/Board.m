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

#define CODE_KEY_TYPE @"type"
#define CODE_KEY_INDEX @"index"
#define CODE_KEY_STATUS @"status"
#define CODE_KEY_VERSION @"version"
#define CODE_KEY_BOARDID @"boardId"

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:_type forKey:CODE_KEY_TYPE];
    [aCoder encodeInteger:_index forKey:CODE_KEY_INDEX];
    [aCoder encodeInteger:_status forKey:CODE_KEY_STATUS];
    [aCoder encodeObject:_version forKey:CODE_KEY_VERSION];
    [aCoder encodeObject:_boardId forKey:CODE_KEY_BOARDID];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.type = [aDecoder decodeIntegerForKey:CODE_KEY_TYPE];
        self.index = [aDecoder decodeIntegerForKey:CODE_KEY_INDEX];
        self.status = [aDecoder decodeIntegerForKey:CODE_KEY_STATUS];
        self.version = [aDecoder decodeObjectForKey:CODE_KEY_VERSION];
        self.boardId = [aDecoder decodeObjectForKey:CODE_KEY_BOARDID];
    }
    return self;
}

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

#define CODE_KEY_NUMBER @"number"
#define CODE_KEY_AD_LIST @"adList"


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeInteger:_number forKey:CODE_KEY_NUMBER];
    [aCoder encodeObject:_adList forKey:CODE_KEY_AD_LIST];

}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.number = [aDecoder decodeIntegerForKey:CODE_KEY_NUMBER];
        self.adList = [aDecoder decodeObjectForKey:CODE_KEY_AD_LIST];
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


#define CODE_KEY_WEBTYPE @"webType"
#define CODE_KEY_REMOTE_URL @"remoteURL"
#define CODE_KEY_LOCAL_URL @"localURL"

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeInteger:_webType forKey:CODE_KEY_WEBTYPE];
    [aCoder encodeObject:_remoteUrl forKey:CODE_KEY_REMOTE_URL];
    [aCoder encodeObject:_localUrl forKey:CODE_KEY_LOCAL_URL];
    
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.webType = [aDecoder decodeIntegerForKey:CODE_KEY_WEBTYPE];
        self.remoteUrl = [aDecoder decodeObjectForKey:CODE_KEY_REMOTE_URL];
        self.localUrl = [aDecoder decodeObjectForKey:CODE_KEY_LOCAL_URL];
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


#define CODE_KEY_IMAGE_URL @"imageURL"
#define CODE_KEY_CLICK_URL @"clickURL"

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_imageUrl forKey:CODE_KEY_IMAGE_URL];
    [aCoder encodeObject:_clickUrl forKey:CODE_KEY_CLICK_URL];
    
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.imageUrl = [aDecoder decodeObjectForKey:CODE_KEY_IMAGE_URL];
        self.clickUrl = [aDecoder decodeObjectForKey:CODE_KEY_CLICK_URL];
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
        
        self.platform = [(NSNumber *)[dict objectForKey:PARA_AD_PLATFORM] integerValue];
        self.publishId = [dict objectForKey:PARA_AD_PUBLISH_ID];
    }
    return self;
}

#define CODE_KEY_PLATFORM @"platform"
#define CODE_KEY_PUBLIC_ID @"publicId"

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:_platform forKey:CODE_KEY_PLATFORM];
    [aCoder encodeObject:_publishId forKey:CODE_KEY_PUBLIC_ID];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.platform = [aDecoder decodeIntegerForKey:CODE_KEY_PLATFORM];
        self.publishId = [aDecoder decodeObjectForKey:CODE_KEY_PUBLIC_ID];
    }
    return self;
}

- (void)dealloc
{
    PPRelease(_publishId);
    [super dealloc];
}

@end

