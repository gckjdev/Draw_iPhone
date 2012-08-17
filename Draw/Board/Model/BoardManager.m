//
//  BoardManager.m
//  Draw
//
//  Created by  on 12-8-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BoardManager.h"
#import "PPDebug.h"

BoardManager *_staticBoardManager = nil;

@interface BoardManager()
{
    NSMutableArray *_BoardList;
}
@end

@implementation BoardManager

+ (BoardManager *)defaultManager
{
    if (_staticBoardManager == nil) {
        _staticBoardManager = [[BoardManager alloc] init];
    }
    return _staticBoardManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        _BoardList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSArray *)BoardList
{
    return _BoardList;
}

- (void)dealloc
{
    PPRelease(_BoardList);
    [super dealloc];
}

@end
