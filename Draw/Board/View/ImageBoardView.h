//
//  ImageBoardView.h
//  Draw
//
//  Created by  on 12-8-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BoardView.h"

@interface ImageBoardView : BoardView<UIGestureRecognizerDelegate>
{

}

- (id)initWithBoard:(Board *)board;
- (void)loadView;

@end
