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

BoardService *_staticBoardService;

typedef enum{
    DeviceTypeIPhone = 1,
    DeviceTypeIPad = 2,
}DeviceType;


@implementation BoardService


+ (BoardService *)defaultService
{
    if (_staticBoardService == nil) {
        _staticBoardService = [[BoardService alloc] init];
    }
    return _staticBoardService;
}

- (void)getBoardsWithDelegate:(id<BoardServiceDelegate>)delegate
{
    dispatch_async(workingQueue, ^{
        DeviceType deviceType = [DeviceDetection isIPAD] ? DeviceTypeIPad :  DeviceTypeIPhone;
        NSString *appId = [ConfigManager appId];
        CommonNetworkOutput *output = [BoardNetwork getBoards:TRAFFIC_SERVER_URL 
                                                        appId:appId 
                                                   deviceType:deviceType]; 
        NSInteger errorCode = output.resultCode;
        NSMutableArray *boardList = nil;
        if (errorCode == ERROR_SUCCESS && [output.jsonDataArray count] != 0) {
            boardList = [NSMutableArray array];
            for (NSDictionary *dict in output.jsonDataArray) {
                Board *board = [Board createBoardWithDictionary:dict];
                if (board) {
                    [boardList addObject:board];
                }
            }
        }
        if (delegate && [delegate respondsToSelector:@selector(didGetBoards:resultCode:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate didGetBoards:boardList resultCode:errorCode]; 
            });
        }
    });
}

- (void)dealloc
{
    [super dealloc];
}

@end
