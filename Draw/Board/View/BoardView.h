//
//  BoardView.h
//  Draw
//
//  Created by  on 12-8-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Board.h"

@class BoardView;
@protocol BoardViewDelegate <NSObject>

@optional 

- (void)boardView:(BoardView *)boardView 
HandleJumpURL:(NSURL *)URL;

- (BOOL)boardView:(BoardView *)boardView 
WillHandleJumpURL:(NSURL *)URL;

@end

@interface BoardView : UIView
{
    Board *_board;
    id<BoardViewDelegate> _delegate;
    NSMutableArray *_adViewList;
}

@property(nonatomic, retain)Board *board;
@property(nonatomic, assign)id<BoardViewDelegate>delegate;

+ (BoardView *)createBoardView:(Board *)board;
- (id)initWithBoard:(Board *)board;

//used by subclass to clear ad view
- (void)clearAllAdView;

//override by subclass;
- (void)loadView;
- (void)innerJump:(NSURL *)URL;

//a handle method, used by sub classes.
- (BOOL)handleTap:(NSURL *)URL; //if inner Jump return NO.


@end

@interface DefaultBoardView : BoardView {
    
}
@end
