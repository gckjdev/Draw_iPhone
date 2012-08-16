//
//  AnnounceManager.m
//  Draw
//
//  Created by  on 12-8-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AnnounceManager.h"
#import "PPDebug.h"

AnnounceManager *_staticAnnounceManager = nil;

@interface AnnounceManager()
{
    NSMutableArray *_announceList;
}
@end

@implementation AnnounceManager

+ (AnnounceManager *)defaultManager
{
    if (_staticAnnounceManager == nil) {
        _staticAnnounceManager = [[AnnounceManager alloc] init];
    }
    return _staticAnnounceManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        _announceList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSArray *)announceList
{
    return _announceList;
}

- (void)dealloc
{
    PPRelease(_announceList);
    [super dealloc];
}

@end
