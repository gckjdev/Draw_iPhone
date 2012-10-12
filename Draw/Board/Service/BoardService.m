//
//  AnnounceService.m
//  Draw
//
//  Created by  on 12-8-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BoardService.h"
#import "BoardNetwork.h"
#import "ConfigManager.h"
#import "BoardNetworkConstant.h"
#import "PPNetworkRequest.h"
#import "Board.h"
#import "BoardManager.h"

BoardService *_staticBoardService;



@implementation BoardService


+ (BoardService *)defaultService
{
    if (_staticBoardService == nil) {
        _staticBoardService = [[BoardService alloc] init];
    }
    return _staticBoardService;
}

- (id)init
{
    self = [super init];
    _boards = [[NSMutableArray alloc] init];
    return self;
}

- (void)stopLoadBoardTimer
{
    PPDebug(@"<stopLoadBoardTimer>");
    
    if ([_loadBoardTimer isValid]){
        [_loadBoardTimer invalidate];        
    }
    _loadBoardTimer = nil;
}

#define LOAD_BOARD_TIMER        60

- (void)startLoadBoardTimer
{
    [self stopLoadBoardTimer];

    PPDebug(@"<startLoadBoardTimer>");    
    _loadBoardTimer = [NSTimer scheduledTimerWithTimeInterval:LOAD_BOARD_TIMER target:self selector:@selector(handleLoadBoardTimer:) userInfo:nil repeats:YES];    
}

- (void)handleLoadBoardTimer:(id)sender
{
    [self syncBoards];
}

- (void)postNotification:(NSString*)name
{
    [[NSNotificationCenter defaultCenter] 
     postNotificationName:name 
     object:self
     userInfo:nil];    
    
    PPDebug(@"<%@> post notification %@", [self description], name);    
}

- (void)syncBoards
{
    dispatch_async(workingQueue, ^{
        DeviceType deviceType = [DeviceDetection deviceType];
        NSString *appId = [ConfigManager appId];
        NSString *gameId = [ConfigManager gameId];
        
        CommonNetworkOutput *output = [BoardNetwork getBoards:BOARD_SERVER_URL 
                                                        appId:appId 
                                                       gameId:gameId 
                                                   deviceType:deviceType]; 
        NSInteger errorCode = output.resultCode;
        NSArray *boardList = nil;
        PPDebug(@"<didGetBoards> result code = %d", errorCode);
        if (errorCode == ERROR_SUCCESS && [output.jsonDataArray count] != 0) {
            NSMutableArray * unSortedBoardList = [NSMutableArray array];
            for (NSDictionary *dict in output.jsonDataArray) {
                Board *board = [Board createBoardWithDictionary:dict];
                if (board) {
                    [unSortedBoardList addObject:board];
                }
            }
            //sort the boardList by the index
            boardList = [unSortedBoardList sortedArrayUsingComparator:^(id obj1,id obj2){
                Board *board1 = (Board *)obj1;
                Board *board2 = (Board *)obj2;
                if (board1.index < board2.index) {
                    return NSOrderedAscending;
                }else if(board1.index > board2.index){
                    return NSOrderedDescending;
                }
                return NSOrderedSame;
            }];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (errorCode == 0) {
                [[BoardManager defaultManager] saveBoardList:boardList];
                
                // post notifcation here, for UI to update
                [self postNotification:BOARD_UPDATE_NOTIFICATION];                
                [self stopLoadBoardTimer];
            }else {
                // failure, do nothing
            }                        
        });        

    });
}

- (void)dealloc
{
    if ([_loadBoardTimer isValid]){
        [_loadBoardTimer invalidate];        
    }
    _loadBoardTimer = nil;
    PPRelease(_boards);
    [super dealloc];
}

@end
