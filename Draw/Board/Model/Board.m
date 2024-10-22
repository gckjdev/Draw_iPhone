//
//  Board.m
//  Draw
//
//  Created by  on 12-8-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Board.h"
#import "BoardNetworkConstant.h"
#import "FileUtil.h"
#import "PPViewController.h"

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
//        case BoardTypeAd:
//            return [[[AdBoard alloc] initWithDictionary:dict] autorelease];
        case BoardTypeWeb:
            return [[[WebBoard alloc] initWithDictionary:dict] autorelease];
        case BoardTypeImage:
            return [[[ImageBoard alloc] initWithDictionary:dict] autorelease];
        case BoardTypeDefault:
            return [[[Board alloc] initWithDictionary:dict] autorelease];
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

+ (Board *)defaultBoard
{
    Board *board = [[[Board alloc] init] autorelease];
    board.type = BoardTypeDefault;
    board.status = BoardStatusRun;
    board.version = @"1";
    board.boardId = @"1";
    board.index = -1;
    return board;
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
@synthesize adImageUrl = _adImageUrl;
@synthesize clickUrl = _clickUrl;
@synthesize platform = _platform;
@synthesize publishId = _publishId;

@synthesize cnImageUrl = _cnImageUrl;
@synthesize cnAdImageUrl = _cnAdImageUrl;

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super initWithDictionary:dict];
    if (self) {
        self.imageUrl = [dict objectForKey:PARA_IMAGE_URL];
        self.clickUrl = [dict objectForKey:PARA_IMAGE_CLICK_URL];
        self.platform = [(NSNumber *)[dict objectForKey:PARA_AD_PLATFORM] integerValue];
        self.publishId = [dict objectForKey:PARA_AD_PUBLISH_ID];
        self.adImageUrl = [dict objectForKey:PARA_AD_IMAGE_URL];
            
        self.cnImageUrl = [dict objectForKey:PARA_CN_IMAGE_URL];        
        self.cnAdImageUrl = [dict objectForKey:PARA_CN_AD_IMAGE_URL];

    }
    return self;
}


#define CODE_KEY_IMAGE_URL @"imageURL"
#define CODE_KEY_CLICK_URL @"clickURL"
#define CODE_KEY_PLATFORM @"platform"
#define CODE_KEY_PUBLIC_ID @"publicId"
#define CODE_KEY_AD_IMAGE_URL @"adImageURL"

#define CODE_KEY_CN_IMAGE_URL @"CNImageURL"
#define CODE_KEY_CN_AD_IMAGE_URL @"CNAdImageURL"


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_imageUrl forKey:CODE_KEY_IMAGE_URL];
    [aCoder encodeObject:_adImageUrl forKey:CODE_KEY_AD_IMAGE_URL];
    [aCoder encodeObject:_clickUrl forKey:CODE_KEY_CLICK_URL];
    [aCoder encodeInteger:_platform forKey:CODE_KEY_PLATFORM];
    [aCoder encodeObject:_publishId forKey:CODE_KEY_PUBLIC_ID];
    
    //cn image
    [aCoder encodeObject:_cnImageUrl forKey:CODE_KEY_CN_IMAGE_URL];
    [aCoder encodeObject:_cnAdImageUrl forKey:CODE_KEY_CN_AD_IMAGE_URL];    
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.imageUrl = [aDecoder decodeObjectForKey:CODE_KEY_IMAGE_URL];
        self.adImageUrl = [aDecoder decodeObjectForKey:CODE_KEY_AD_IMAGE_URL];
        self.clickUrl = [aDecoder decodeObjectForKey:CODE_KEY_CLICK_URL];
        self.platform = [aDecoder decodeIntegerForKey:CODE_KEY_PLATFORM];
        self.publishId = [aDecoder decodeObjectForKey:CODE_KEY_PUBLIC_ID];
        //cn image
        self.cnImageUrl = [aDecoder decodeObjectForKey:CODE_KEY_CN_IMAGE_URL];
        self.cnAdImageUrl = [aDecoder decodeObjectForKey:CODE_KEY_CN_AD_IMAGE_URL];
    }
    return self;
}


- (void)dealloc
{
    PPRelease(_imageUrl);
    PPRelease(_adImageUrl);
    PPRelease(_clickUrl);
    PPRelease(_publishId);
    PPRelease(_cnAdImageUrl);
    PPRelease(_cnImageUrl);
    [super dealloc];
}

@end




