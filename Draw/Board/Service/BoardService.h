//
//  AnnounceService.h
//  Draw
//
//  Created by  on 12-8-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommonService.h"

#define BOARD_UPDATE_NOTIFICATION   @"BOARD_UPDATE_NOTIFICATION"

@protocol BoardServiceDelegate <NSObject>

@optional
- (void)didGetBoards:(NSArray *)boards 
          resultCode:(NSInteger)resultCode;

@end

@interface BoardService : CommonService
{
    NSTimer             *_loadBoardTimer;
    NSMutableArray      *_boards;
}

+ (BoardService *)defaultService;
- (void)syncBoards;
- (void)updateBoardStatistic:(NSString *)boardId;

@end
