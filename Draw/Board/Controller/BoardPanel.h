//
//  BoardPanel.h
//  Draw
//
//  Created by  on 12-8-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BoardView.h"
@interface BoardPanel : UIView
{
    
}
+ (BoardPanel *)boardPanel;
- (void)setBoardList:(NSArray *)boardList;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;

@end
