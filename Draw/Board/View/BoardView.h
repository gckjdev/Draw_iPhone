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
didCaptureRequest:(NSURL *)URL;

@end

@interface BoardView : UIView
{
    Board *_board;
    id<BoardViewDelegate> _delegate;
}

@property(nonatomic, retain)Board *board;
@property(nonatomic, assign)id<BoardViewDelegate>delegate;

+ (BoardView *)createBoardView:(Board *)board;
- (id)initWithBoard:(Board *)board;
- (void)loadView;

@end
