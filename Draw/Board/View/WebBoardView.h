//
//  WebBoardView.h
//  Draw
//
//  Created by  on 12-8-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BoardView.h"

@interface WebBoardView : BoardView<UIWebViewDelegate>
{
    
}

- (id)initWithBoard:(Board *)board;
- (void)loadView;
@end
