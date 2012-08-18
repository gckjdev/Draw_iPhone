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
#import "ImageBoardView.h"

@implementation BoardView
@synthesize board = _board;
@synthesize delegate = _delegate;

#define BOARD_WIDTH ([DeviceDetection isIPAD]? 650.0 : 280.0)
#define SCREEN_WIDTH ([DeviceDetection isIPAD]? 768.0 : 320.0)
#define BOARD_FRAME CGRectMake((SCREEN_WIDTH - BOARD_WIDTH)/2.0, 0, BOARD_WIDTH, BOARD_WIDTH*0.618)

- (id)initWithBoard:(Board *)board
{
    self = [super initWithFrame:BOARD_FRAME];
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
+ (BoardView *)createBoardView:(Board *)board
{
    if (board == nil) {
        return nil;
    }
    switch (board.type) {
        case BoardTypeAd:
            return [[[AdBoardView alloc] initWithBoard:board] autorelease];
        case BoardTypeWeb:
            return [[[WebBoardView alloc] initWithBoard:board] autorelease];
        case BoardTypeImage:
            return [[[ImageBoardView alloc] initWithBoard:board] autorelease];
        default:
            return nil;
    }
}

- (void)loadView
{
    //should be override by the sub classes.
}

@end
