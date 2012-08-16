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
- (void)BoardView:(BoardView *)BoardView 
   didCaptureRequest:(NSURLRequest *)request;

@end

@interface BoardView : UIView
{
    Board *_board;
}

@property(nonatomic, retain)Board *Board;
- (id)initWithBoard:(Board *)board;
+ (BoardView *)creatBoardView:(Board *)board;
- (void)loadView;

@end
