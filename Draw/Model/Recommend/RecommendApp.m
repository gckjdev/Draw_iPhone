//
//  RecommendApp.m
//  FootballScore
//
//  Created by Orange on 12-6-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RecommendApp.h"

@implementation RecommendApp
@synthesize appName = _appName;
@synthesize appDescription = _appDescription;
@synthesize appIconUrl = _appIconUrl;
@synthesize appUrl = _appUrl;

- (void)dealloc
{
    [_appName release];
    [_appDescription release];
    [_appIconUrl release];
    [_appUrl release];
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

@end
