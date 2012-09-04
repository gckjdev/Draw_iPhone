//
//  BoardManager.m
//  Draw
//
//  Created by  on 12-8-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BoardManager.h"
#import "PPDebug.h"
#import "Board.h"

BoardManager *_staticBoardManager = nil;

@interface BoardManager()
{
    
}

- (NSArray *)getLocalBoardList;

@end

@implementation BoardManager

@synthesize boardList = _boardList;

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
        _boardList = [[NSMutableArray alloc] init];
        
        // load data from local board list
        NSArray* localBoardList = [self getLocalBoardList];
        if (localBoardList){
            [_boardList addObjectsFromArray:localBoardList];
        }
        else{
            // if no local data, load from default board
            [_boardList addObject:[Board defaultBoard]];
        }
    }
    return self;
}

- (void)dealloc
{
    PPRelease(_boardList);
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

- (void)saveBoardList:(NSArray *)newBoardList
{
    NSData* reData = [NSKeyedArchiver archivedDataWithRootObject:newBoardList];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:reData forKey:BOARD_LIST_KEY];
    [defaults synchronize];
    PPDebug(@"save boardList!, new board count = %d",[newBoardList count]);
    
    if ([newBoardList count] > 0){
        [_boardList removeAllObjects];
        [_boardList addObjectsFromArray:newBoardList];
    }
}


@end
