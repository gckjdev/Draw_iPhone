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
- (void)boardView:(BoardView *)BoardView 
   didCaptureRequest:(NSURLRequest *)request;

@end

@interface BoardView : UIView
{
    Board *_board;
    id<BoardViewDelegate> _delegate;
}

@property(nonatomic, retain)Board *board;
@property(nonatomic, assign)id<BoardViewDelegate>delegate;
- (id)initWithBoard:(Board *)board;
+ (BoardView *)creatBoardView:(Board *)board;
- (void)loadView;

@end
