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

//- (NSArray *)BoardList
//{
//    return _BoardList;
//}

- (void)dealloc
{
    PPRelease(_BoardList);
    [super dealloc];
}


#define BOARD_LIST_KEY @"boardList"
- (NSArray *)getLocalBoardList
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:BOARD_LIST_KEY];
    if (data) {
        NSArray *boardList =  [NSKeyedUnarchiver unarchiveObjectWithData:data];
        PPDebug(@"get Local board list, count = %d", [boardList count]);
        return boardList;
    }
    PPDebug(@"get Local board list = nil");
    return nil;
}
- (void)saveBoardList:(NSArray *)boardList
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSData* reData = [NSKeyedArchiver archivedDataWithRootObject:boardList];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:reData forKey:BOARD_LIST_KEY];
        [defaults synchronize];
        PPDebug(@"save boardList!, count = %d",[boardList count]);
    });
}


@end
