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
#import "JumpHandler.h"
#import "ShareImageManager.h"
#import "AdService.h"

@implementation BoardView
@synthesize board = _board;
@synthesize delegate = _delegate;

#define BOARD_WIDTH ([DeviceDetection isIPAD]? 768.0 : 320.0)
#define SCREEN_WIDTH ([DeviceDetection isIPAD]? 768.0 : 320.0)

#define BOARD_HEIGHT ([DeviceDetection isIPAD]? 447.0 : 193.0)
#define BOARD_FRAME CGRectMake((SCREEN_WIDTH - BOARD_WIDTH)/2.0, 0, BOARD_WIDTH, BOARD_HEIGHT)

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
        case BoardTypeDefault:
            return [[[DefaultBoardView alloc] initWithBoard:board] autorelease];
            
        default:
            return nil;
    }
}

- (void)loadView
{
    //should be override by the sub classes.
}


- (void)innerJump:(NSURL *)URL
{
    //should be override by the sub classes.   
    if ([URL.scheme isEqualToString:BOARD_SCHEME_TEL] || [URL.scheme isEqualToString:BOARD_SCHEME_SMS]) {
        PPDebug(@"share application open URL = %@", URL);
        [[UIApplication sharedApplication] openURL:URL];
    }
}

//a handle method, used by sub classes.
- (BOOL)handleTap:(NSURL *)URL
{

    if (self.delegate && [self.delegate respondsToSelector:@selector(boardView:WillHandleJumpURL:)]) {
        if ([_delegate boardView:self WillHandleJumpURL:URL]) {
            if (_delegate && [_delegate respondsToSelector:@selector(boardView:HandleJumpURL:)]) {
                [_delegate boardView:self HandleJumpURL:URL];
            }
        }else{
            [self innerJump:URL];
            return NO;
        }
    }
    return YES;
}

@end


@implementation DefaultBoardView

- (void)loadView
{
    [super loadView];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    [imageView setImage:[[ShareImageManager defaultManager] defaultBoardImage]];
    [self addSubview:imageView];
    [imageView release];
    
    [[AdService defaultService] createAdInView:self 
                                adPlatformType:AdPlatformLm
                                 adPublisherId:@"eb4ce4f0a0f1f49b6b29bf4c838a5147"
                                         frame:CGRectMake(0, 0, 320, 50) 
                                     iPadFrame:CGRectMake((768-320)/2, 0, 320, 50)];

    
}

@end