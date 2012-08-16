//
//  BoardView.m
//  Draw
//
//  Created by  on 12-8-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BoardView.h"
#import "AdBoardView.h"
#import "WebBoardView.h"

@implementation BoardView
@synthesize Board = _board;

#define Board_FRAME ([DeviceDetection isIPAD]?CGRectMake(0, 0, 300 * 2, 200 * 2):CGRectMake(0, 0, 300, 200))

- (id)initWithBoard:(Board *)board
{
    self = [super initWithFrame:Board_FRAME];
    if (self) {
        self.board = board;
    }
    return self;
}

- (void)dealloc
{
    PPRelease(_board);
    [super dealloc];
    
}
+ (BoardView *)creatBoardView:(Board *)board
{
    if (board == nil) {
        return nil;
    }
    switch (board.type) {
        case BoardTypeAd:
            return [[[AdBoardView alloc] initWithBoard:board] autorelease];
        case BoardTypeLocal:
        case BoardTypeRemote:
            return [[[WebBoardView alloc] initWithBoard:board] autorelease];
        default:
            return nil;
    }
}

- (void)loadView
{
    //should be override by the sub classes.
}

@end
