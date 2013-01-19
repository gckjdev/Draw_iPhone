//
//  RecommendApp.m
//  FootballScore
//
//  Created by Orange on 12-6-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RecommendApp.h"
#import "LocaleUtils.h"

@implementation RecommendApp
@synthesize appName = _appName;
@synthesize appDescription = _appDescription;
@synthesize appIconUrl = _appIconUrl;
@synthesize appUrl = _appUrl;

- (void)dealloc
{
    PPRelease(_appName);
    PPRelease(_appDescription);
    PPRelease(_appIconUrl);
    PPRelease(_appUrl);
    [super dealloc];
}

- (id)initWithAppName:(NSString *)name 
          description:(NSString *)description 
              iconUrl:(NSString *)iconUrl 
               appUrl:(NSString *)appUrl
{
    self = [super init];
    if (self) {
        self.appName = name;
        self.appDescription = description;
        self.appIconUrl = iconUrl;
        self.appUrl = appUrl;
    }
    return self;
}

+ (RecommendApp*)draw
{
    return [[[RecommendApp alloc] initWithAppName:NSLS(@"kDraw") description:NSLS(@"kDrawDescription") iconUrl:@"http://img.you100.me:8080/upload/20120722/1fc73af0-d3b4-11e1-83de-00163e0174e8_pp" appUrl:@"http://itunes.apple.com/cn/app/ni-hua-wo-cai/id513819630?l=en&mt=8"] autorelease];
}

+ (RecommendApp*)shuriken
{
    return [[[RecommendApp alloc] initWithAppName:NSLS(@"kShuriken") description:NSLS(@"kShurikenDescription") iconUrl:@"http://img.you100.me:8080/upload/20120722/1fc73af0-d3b4-11e1-83de-00163e0174e8_pp" appUrl:@"http://itunes.apple.com/cn/app/ni-hua-wo-cai/id513819630?l=en&mt=8"] autorelease];
}
+ (RecommendApp*)crazyFinger
{
    return [[[RecommendApp alloc] initWithAppName:NSLS(@"kCrazyFinger") description:NSLS(@"kCrazyFingerDescription") iconUrl:@"http://img.you100.me:8080/upload/20120722/1fc73af0-d3b4-11e1-83de-00163e0174e8_pp" appUrl:@"http://itunes.apple.com/cn/app/ni-hua-wo-cai/id513819630?l=en&mt=8"] autorelease];
}
+ (RecommendApp*)ghostGame
{
    return [[[RecommendApp alloc] initWithAppName:NSLS(@"kGhostGame") description:NSLS(@"kGhostGameDescription") iconUrl:@"http://img.you100.me:8080/upload/20120722/1fc73af0-d3b4-11e1-83de-00163e0174e8_pp" appUrl:@"http://itunes.apple.com/cn/app/ni-hua-wo-cai/id513819630?l=en&mt=8"] autorelease];
}
+ (RecommendApp*)countBean
{
    return [[[RecommendApp alloc] initWithAppName:NSLS(@"kCountBean") description:NSLS(@"kCountBeanDescription") iconUrl:@"http://img.you100.me:8080/upload/20120722/1fc73af0-d3b4-11e1-83de-00163e0174e8_pp" appUrl:@"http://itunes.apple.com/cn/app/ni-hua-wo-cai/id513819630?l=en&mt=8"] autorelease];
}
+ (RecommendApp*)groupBuy
{
    return [[[RecommendApp alloc] initWithAppName:NSLS(@"kGroupBuy") description:NSLS(@"kGroupBuyDescription") iconUrl:@"http://img.you100.me:8080/upload/20120722/1fc73af0-d3b4-11e1-83de-00163e0174e8_pp" appUrl:@"http://itunes.apple.com/cn/app/ni-hua-wo-cai/id513819630?l=en&mt=8"] autorelease];
}

@end
